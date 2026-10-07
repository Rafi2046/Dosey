-- ==============================================================================
-- Dosey Family Sharing: abuse limits and a private nudge-push endpoint
--
-- Before applying, store the push secret in Vault (the same value goes to
-- the edge function as NUDGE_PUSH_SECRET):
--
--   SELECT vault.create_secret('<random hex>', 'nudge_push_secret');
--
-- Without these, anyone could call send-nudge-push, a caregiver could
-- spam a patient with pushes, names and messages had no size limit, a share
-- code could be guessed by trying codes as fast as the server answered, and
-- the app alone decided when a code expired.
-- ==============================================================================

-- 1. The trigger signs each push request with the Vault secret; the edge
--    function (NUDGE_PUSH_SECRET) refuses calls that don't carry it.
CREATE OR REPLACE FUNCTION public.push_family_nudge()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    PERFORM net.http_post(
        url := 'https://datkdpcomjgtuhodggml.supabase.co/functions/v1/send-nudge-push',
        headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'x-nudge-secret', coalesce(
                (SELECT decrypted_secret FROM vault.decrypted_secrets
                 WHERE name = 'nudge_push_secret'),
                ''
            )
        ),
        body := jsonb_build_object('nudge_id', NEW.id)
    );
    RETURN NEW;
END;
$$;

-- 2. Size limits. NOT VALID: rows already stored are left alone, every new
--    or changed row is checked.
ALTER TABLE public.family_nudges
    DROP CONSTRAINT IF EXISTS family_nudges_message_length,
    DROP CONSTRAINT IF EXISTS family_nudges_caregiver_name_length;
ALTER TABLE public.family_nudges
    ADD CONSTRAINT family_nudges_message_length
        CHECK (char_length(message) <= 500) NOT VALID,
    ADD CONSTRAINT family_nudges_caregiver_name_length
        CHECK (char_length(caregiver_name) <= 80) NOT VALID;

ALTER TABLE public.family_shares
    DROP CONSTRAINT IF EXISTS family_shares_patient_name_length,
    DROP CONSTRAINT IF EXISTS family_shares_caregiver_name_length;
ALTER TABLE public.family_shares
    ADD CONSTRAINT family_shares_patient_name_length
        CHECK (char_length(patient_name) <= 80) NOT VALID,
    ADD CONSTRAINT family_shares_caregiver_name_length
        CHECK (char_length(caregiver_name) <= 80) NOT VALID;

-- 3. Nudge rate limit, per caregiver and patient: 5 in 10 minutes, 50 a day.
--    created_at is set here, so a backdated row can't slip under the limit.
CREATE OR REPLACE FUNCTION public.family_nudges_rate_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    NEW.created_at := timezone('utc'::text, now());

    -- One caregiver's nudges to one patient at a time, so the counts below
    -- can't be raced by parallel inserts.
    PERFORM pg_advisory_xact_lock(hashtext(NEW.caregiver_uid || '>' || NEW.patient_uid));

    IF (SELECT count(*) FROM public.family_nudges
        WHERE caregiver_uid = NEW.caregiver_uid
          AND patient_uid = NEW.patient_uid
          AND created_at > now() - interval '10 minutes') >= 5 THEN
        RAISE EXCEPTION 'You have sent several reminders just now. Please wait a few minutes.';
    END IF;
    IF (SELECT count(*) FROM public.family_nudges
        WHERE caregiver_uid = NEW.caregiver_uid
          AND patient_uid = NEW.patient_uid
          AND created_at > now() - interval '1 day') >= 50 THEN
        RAISE EXCEPTION 'Daily reminder limit reached. Please try again tomorrow.';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS family_nudges_rate_limit ON public.family_nudges;
CREATE TRIGGER family_nudges_rate_limit
    BEFORE INSERT ON public.family_nudges
    FOR EACH ROW EXECUTE FUNCTION public.family_nudges_rate_limit();

CREATE INDEX IF NOT EXISTS idx_family_nudges_pair_created
    ON public.family_nudges(caregiver_uid, patient_uid, created_at);

-- 4. Share codes live at most 7 days from when the server saw them made,
--    whatever the app sends; created_at never moves after that. An update
--    that leaves expires_at alone keeps it as is, or family_shares_guard
--    (which runs after this) would refuse a caregiver leaving an old link.
CREATE OR REPLACE FUNCTION public.family_shares_expiry()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_at := timezone('utc'::text, now());
    ELSE
        NEW.created_at := OLD.created_at;
        IF NEW.expires_at IS NOT DISTINCT FROM OLD.expires_at THEN
            RETURN NEW;
        END IF;
    END IF;
    NEW.expires_at := least(
        coalesce(NEW.expires_at, NEW.created_at + interval '7 days'),
        NEW.created_at + interval '7 days'
    );
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS family_shares_expiry ON public.family_shares;
CREATE TRIGGER family_shares_expiry
    BEFORE INSERT OR UPDATE ON public.family_shares
    FOR EACH ROW EXECUTE FUNCTION public.family_shares_expiry();

-- Codes made before this had no server-side expiry.
UPDATE public.family_shares
SET expires_at = timezone('utc'::text, now()) + interval '7 days'
WHERE expires_at IS NULL AND caregiver_uid IS NULL AND is_active;

-- 5. Redeem attempts: 10 per user in 15 minutes. No policies, so only the
--    function below can touch the table.
CREATE TABLE IF NOT EXISTS public.share_code_attempts (
    uid TEXT NOT NULL,
    attempted_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);
CREATE INDEX IF NOT EXISTS idx_share_code_attempts_uid
    ON public.share_code_attempts(uid, attempted_at);
ALTER TABLE public.share_code_attempts ENABLE ROW LEVEL SECURITY;

-- Same as in the secure_family_sharing migration, plus the attempt limit. A wrong
-- code returns NULL instead of raising: an exception would roll back the
-- attempt it just recorded, and guessing would cost nothing.
CREATE OR REPLACE FUNCTION public.redeem_share_code(p_code TEXT, p_caregiver_name TEXT)
RETURNS public.family_shares
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    me TEXT := public.fb_uid();
    share public.family_shares;
BEGIN
    IF me IS NULL THEN
        RAISE EXCEPTION 'Please sign in with a verified email first.';
    END IF;

    PERFORM pg_advisory_xact_lock(hashtext('redeem>' || me));
    DELETE FROM public.share_code_attempts
    WHERE uid = me AND attempted_at < now() - interval '1 day';
    IF (SELECT count(*) FROM public.share_code_attempts
        WHERE uid = me AND attempted_at > now() - interval '15 minutes') >= 10 THEN
        RAISE EXCEPTION 'Too many attempts. Please wait 15 minutes and try again.';
    END IF;
    INSERT INTO public.share_code_attempts (uid) VALUES (me);

    SELECT * INTO share FROM public.family_shares
    WHERE share_code = upper(trim(p_code)) AND is_active
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN NULL;
    END IF;
    IF share.patient_uid = me THEN
        RAISE EXCEPTION 'You cannot link to your own profile.';
    END IF;
    IF share.caregiver_uid IS NOT NULL AND share.caregiver_uid <> me THEN
        RAISE EXCEPTION 'This share code has already been requested by another caregiver.';
    END IF;
    IF share.expires_at IS NOT NULL AND share.expires_at < now() THEN
        RAISE EXCEPTION 'This share code has expired.';
    END IF;

    UPDATE public.family_shares
    SET caregiver_uid = me,
        caregiver_name = p_caregiver_name,
        -- Asking again never undoes an accepted link.
        status = CASE WHEN status = 'accepted' THEN status ELSE 'pending' END
    WHERE id = share.id
    RETURNING * INTO share;

    RETURN share;
END;
$$;

GRANT EXECUTE ON FUNCTION public.redeem_share_code(TEXT, TEXT) TO anon, authenticated;

-- 6. Account deletion also clears the user's attempt log (replaces the
--    version in the delete_account_data migration).
CREATE OR REPLACE FUNCTION public.delete_my_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    me TEXT := public.fb_uid();
BEGIN
    IF me IS NULL THEN
        RETURN;
    END IF;

    DELETE FROM public.patient_prescriptions WHERE patient_uid = me;
    DELETE FROM public.patient_shared_adherence WHERE patient_uid = me;
    DELETE FROM public.family_nudges WHERE patient_uid = me OR caregiver_uid = me;
    DELETE FROM public.family_shares WHERE patient_uid = me OR caregiver_uid = me;
    UPDATE public.patient_prescriptions SET updated_by = NULL WHERE updated_by = me;
    DELETE FROM public.device_push_tokens WHERE uid = me;
    DELETE FROM public.share_code_attempts WHERE uid = me;
END;
$$;
