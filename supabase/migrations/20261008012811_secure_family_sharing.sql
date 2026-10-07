-- ==============================================================================
-- Dosey Family Sharing: lock the tables to signed-in, verified users
--
-- Apply only once Firebase is added under Supabase Dashboard ->
-- Authentication -> Third-party Auth (project dosey-502ae).
--
-- Before this, every policy was `USING (true)`: anyone holding the app's
-- public key could read and change every family's medicines and doses.
-- Now the app sends the user's Firebase ID token and each row is reachable
-- only by its patient, or by a caregiver the patient has accepted.
--
-- Firebase tokens carry no `role` claim, so requests run as `anon`; the
-- policies below therefore check the token itself (issuer, audience and a
-- confirmed email), not the role. The bare public key matches nothing.
-- ==============================================================================

-- 1. Who is calling: the Firebase uid, or NULL when there's no valid token
--    for this project or the email isn't confirmed yet.
CREATE OR REPLACE FUNCTION public.fb_uid()
RETURNS TEXT
LANGUAGE sql
STABLE
SET search_path = public
AS $$
    SELECT CASE
        WHEN auth.jwt() ->> 'iss' = 'https://securetoken.google.com/dosey-502ae'
         AND auth.jwt() ->> 'aud' = 'dosey-502ae'
         AND coalesce((auth.jwt() ->> 'email_verified')::boolean, false)
        THEN auth.jwt() ->> 'sub'
    END;
$$;

-- 2. Whether the caller is an accepted caregiver of [p_patient]. SECURITY
--    DEFINER so it can read family_shares without recursing into its RLS.
CREATE OR REPLACE FUNCTION public.is_caregiver_of(p_patient TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.family_shares
        WHERE patient_uid = p_patient
          AND caregiver_uid = public.fb_uid()
          AND is_active
          AND status = 'accepted'
    );
$$;

GRANT EXECUTE ON FUNCTION public.fb_uid() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.is_caregiver_of(TEXT) TO anon, authenticated;

-- 3. Redeeming a code. Callers can no longer list other people's shares, so
--    the lookup by code happens here, with the same checks the app made.
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

    SELECT * INTO share FROM public.family_shares
    WHERE share_code = upper(trim(p_code)) AND is_active
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid or expired share code. Please ask your family member for a new code.';
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

-- 4. A caregiver may rename, cancel or leave their link, never accept it
--    or move it to someone else. The patient may change anything on theirs.
CREATE OR REPLACE FUNCTION public.family_shares_guard()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
    me TEXT := public.fb_uid();
BEGIN
    -- The patient, or the dashboard / service role (no Firebase token).
    IF me IS NULL OR me = OLD.patient_uid THEN
        RETURN NEW;
    END IF;

    IF NEW.patient_uid IS DISTINCT FROM OLD.patient_uid
       OR NEW.share_code IS DISTINCT FROM OLD.share_code
       OR NEW.created_at IS DISTINCT FROM OLD.created_at
       OR NEW.expires_at IS DISTINCT FROM OLD.expires_at
       OR (NEW.is_active AND NOT OLD.is_active)
       OR (NEW.caregiver_uid IS NOT NULL AND NEW.caregiver_uid <> me) THEN
        RAISE EXCEPTION 'Only the patient can change this link.';
    END IF;
    IF NEW.status = 'accepted' AND OLD.status IS DISTINCT FROM 'accepted' THEN
        RAISE EXCEPTION 'Only the patient can accept a link request.';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS family_shares_guard ON public.family_shares;
CREATE TRIGGER family_shares_guard
    BEFORE UPDATE ON public.family_shares
    FOR EACH ROW EXECUTE FUNCTION public.family_shares_guard();

-- 5. family_shares: each side sees and edits only its own links.
DROP POLICY IF EXISTS "Allow anon read family_shares" ON public.family_shares;
DROP POLICY IF EXISTS "Allow anon insert family_shares" ON public.family_shares;
DROP POLICY IF EXISTS "Allow anon update family_shares" ON public.family_shares;

DROP POLICY IF EXISTS "Shares: own links" ON public.family_shares;
CREATE POLICY "Shares: own links" ON public.family_shares
    FOR SELECT TO anon, authenticated
    USING (patient_uid = public.fb_uid() OR caregiver_uid = public.fb_uid());

DROP POLICY IF EXISTS "Shares: patient creates a code" ON public.family_shares;
CREATE POLICY "Shares: patient creates a code" ON public.family_shares
    FOR INSERT TO anon, authenticated
    WITH CHECK (patient_uid = public.fb_uid() AND caregiver_uid IS NULL);

DROP POLICY IF EXISTS "Shares: patient manages" ON public.family_shares;
CREATE POLICY "Shares: patient manages" ON public.family_shares
    FOR UPDATE TO anon, authenticated
    USING (patient_uid = public.fb_uid())
    WITH CHECK (patient_uid = public.fb_uid());

DROP POLICY IF EXISTS "Shares: caregiver manages own link" ON public.family_shares;
CREATE POLICY "Shares: caregiver manages own link" ON public.family_shares
    FOR UPDATE TO anon, authenticated
    USING (caregiver_uid = public.fb_uid())
    WITH CHECK (caregiver_uid IS NULL OR caregiver_uid = public.fb_uid());

-- 6. patient_shared_adherence: the patient writes, accepted caregivers read.
DROP POLICY IF EXISTS "Allow anon read patient_shared_adherence" ON public.patient_shared_adherence;
DROP POLICY IF EXISTS "Allow anon upsert patient_shared_adherence" ON public.patient_shared_adherence;

DROP POLICY IF EXISTS "Adherence: patient owns" ON public.patient_shared_adherence;
CREATE POLICY "Adherence: patient owns" ON public.patient_shared_adherence
    FOR ALL TO anon, authenticated
    USING (patient_uid = public.fb_uid())
    WITH CHECK (patient_uid = public.fb_uid());

DROP POLICY IF EXISTS "Adherence: caregiver reads" ON public.patient_shared_adherence;
CREATE POLICY "Adherence: caregiver reads" ON public.patient_shared_adherence
    FOR SELECT TO anon, authenticated
    USING (public.is_caregiver_of(patient_uid));

-- 7. family_nudges: accepted caregivers send, the patient reads and marks.
DROP POLICY IF EXISTS "Allow anon read family_nudges" ON public.family_nudges;
DROP POLICY IF EXISTS "Allow anon insert family_nudges" ON public.family_nudges;

DROP POLICY IF EXISTS "Nudges: caregiver sends" ON public.family_nudges;
CREATE POLICY "Nudges: caregiver sends" ON public.family_nudges
    FOR INSERT TO anon, authenticated
    WITH CHECK (caregiver_uid = public.fb_uid() AND public.is_caregiver_of(patient_uid));

DROP POLICY IF EXISTS "Nudges: both sides read" ON public.family_nudges;
CREATE POLICY "Nudges: both sides read" ON public.family_nudges
    FOR SELECT TO anon, authenticated
    USING (patient_uid = public.fb_uid() OR caregiver_uid = public.fb_uid());

DROP POLICY IF EXISTS "Nudges: patient marks read" ON public.family_nudges;
CREATE POLICY "Nudges: patient marks read" ON public.family_nudges
    FOR UPDATE TO anon, authenticated
    USING (patient_uid = public.fb_uid())
    WITH CHECK (patient_uid = public.fb_uid());

-- 8. patient_prescriptions: the patient and their accepted caregivers.
DROP POLICY IF EXISTS "Allow anon read patient_prescriptions" ON public.patient_prescriptions;
DROP POLICY IF EXISTS "Allow anon upsert patient_prescriptions" ON public.patient_prescriptions;

DROP POLICY IF EXISTS "Prescriptions: patient and caregivers" ON public.patient_prescriptions;
CREATE POLICY "Prescriptions: patient and caregivers" ON public.patient_prescriptions
    FOR ALL TO anon, authenticated
    USING (patient_uid = public.fb_uid() OR public.is_caregiver_of(patient_uid))
    WITH CHECK (patient_uid = public.fb_uid() OR public.is_caregiver_of(patient_uid));

-- 9. Push tokens: a device registers under its own signed-in uid only (the
--    p_uid argument is kept so existing app builds still match the call).
CREATE OR REPLACE FUNCTION public.register_push_token(p_uid TEXT, p_token TEXT, p_platform TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    me TEXT := public.fb_uid();
BEGIN
    IF me IS NULL OR p_uid IS DISTINCT FROM me THEN
        RAISE EXCEPTION 'Sign in to receive caregiver reminders.';
    END IF;
    -- A device that changes account moves to the new uid.
    INSERT INTO public.device_push_tokens (token, uid, platform, updated_at)
    VALUES (p_token, me, p_platform, timezone('utc'::text, now()))
    ON CONFLICT (token) DO UPDATE
        SET uid = EXCLUDED.uid,
            platform = EXCLUDED.platform,
            updated_at = EXCLUDED.updated_at;
END;
$$;

CREATE OR REPLACE FUNCTION public.unregister_push_token(p_token TEXT)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
    DELETE FROM public.device_push_tokens
    WHERE token = p_token AND uid = public.fb_uid();
$$;
