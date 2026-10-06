-- ==============================================================================
-- Dosey Family Sharing & Caregiver Mode Schema
-- Run this in your Supabase SQL Editor: Dashboard -> SQL Editor -> New Query
-- ==============================================================================

-- 1. Create family_shares table
CREATE TABLE IF NOT EXISTS public.family_shares (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_uid TEXT NOT NULL,
    patient_name TEXT,
    caregiver_uid TEXT,
    caregiver_name TEXT,
    share_code VARCHAR(6) NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    status TEXT NOT NULL DEFAULT 'unclaimed',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    expires_at TIMESTAMPTZ
);

-- Ensure status column exists if table already created
ALTER TABLE public.family_shares ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'unclaimed';

-- 2. Indexes for fast querying
CREATE INDEX IF NOT EXISTS idx_family_shares_patient_uid ON public.family_shares(patient_uid);
CREATE INDEX IF NOT EXISTS idx_family_shares_caregiver_uid ON public.family_shares(caregiver_uid);
CREATE INDEX IF NOT EXISTS idx_family_shares_share_code ON public.family_shares(share_code);
CREATE INDEX IF NOT EXISTS idx_family_shares_status ON public.family_shares(status);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE public.family_shares ENABLE ROW LEVEL SECURITY;

-- 4. Policies (Allow app users via anon key to read, generate, and redeem share codes)
DROP POLICY IF EXISTS "Allow anon read family_shares" ON public.family_shares;
CREATE POLICY "Allow anon read family_shares" ON public.family_shares
    FOR SELECT
    TO anon, authenticated
    USING (true);

DROP POLICY IF EXISTS "Allow anon insert family_shares" ON public.family_shares;
CREATE POLICY "Allow anon insert family_shares" ON public.family_shares
    FOR INSERT
    TO anon, authenticated
    WITH CHECK (true);

DROP POLICY IF EXISTS "Allow anon update family_shares" ON public.family_shares;
CREATE POLICY "Allow anon update family_shares" ON public.family_shares
    FOR UPDATE
    TO anon, authenticated
    USING (true);

-- 5. Create patient_shared_adherence table for live dose tracking & caregiver monitoring
CREATE TABLE IF NOT EXISTS public.patient_shared_adherence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_uid TEXT NOT NULL,
    patient_name TEXT,
    date TEXT NOT NULL, -- YYYY-MM-DD
    medicine_name TEXT NOT NULL,
    dosage TEXT,
    time TEXT NOT NULL, -- HH:mm a (e.g. 09:00 AM)
    form TEXT,
    meal_relation TEXT,
    status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'taken', 'skipped', 'missed'
    taken_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE (patient_uid, date, medicine_name, time)
);

CREATE INDEX IF NOT EXISTS idx_shared_adherence_patient_date ON public.patient_shared_adherence(patient_uid, date);
ALTER TABLE public.patient_shared_adherence ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow anon read patient_shared_adherence" ON public.patient_shared_adherence;
CREATE POLICY "Allow anon read patient_shared_adherence" ON public.patient_shared_adherence
    FOR SELECT
    TO anon, authenticated
    USING (true);

DROP POLICY IF EXISTS "Allow anon upsert patient_shared_adherence" ON public.patient_shared_adherence;
CREATE POLICY "Allow anon upsert patient_shared_adherence" ON public.patient_shared_adherence
    FOR ALL
    TO anon, authenticated
    USING (true)
    WITH CHECK (true);

-- 6. Create family_nudges table for caregiver reminders
CREATE TABLE IF NOT EXISTS public.family_nudges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_uid TEXT NOT NULL,
    caregiver_uid TEXT NOT NULL,
    caregiver_name TEXT,
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    is_read BOOLEAN NOT NULL DEFAULT false
);

CREATE INDEX IF NOT EXISTS idx_family_nudges_patient ON public.family_nudges(patient_uid, is_read);
ALTER TABLE public.family_nudges ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow anon read family_nudges" ON public.family_nudges;
CREATE POLICY "Allow anon read family_nudges" ON public.family_nudges
    FOR SELECT
    TO anon, authenticated
    USING (true);

DROP POLICY IF EXISTS "Allow anon insert family_nudges" ON public.family_nudges;
CREATE POLICY "Allow anon insert family_nudges" ON public.family_nudges
    FOR ALL
    TO anon, authenticated
    USING (true)
    WITH CHECK (true);

-- 7. Realtime: deliver caregiver nudges, shares, and adherence instantly.
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.family_nudges;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.family_shares;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.patient_shared_adherence;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 8. Push tokens: one row per device, for caregiver nudges via FCM.
-- No RLS policies on purpose: app users can't read tokens, they only
-- register/unregister their own device through the functions below. The
-- send-nudge-push edge function reads them with the service role.
CREATE TABLE IF NOT EXISTS public.device_push_tokens (
    token TEXT PRIMARY KEY,
    uid TEXT NOT NULL,
    platform TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_device_push_tokens_uid ON public.device_push_tokens(uid);
ALTER TABLE public.device_push_tokens ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.register_push_token(p_uid TEXT, p_token TEXT, p_platform TEXT)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
    -- A device that changes account moves to the new uid.
    INSERT INTO public.device_push_tokens (token, uid, platform, updated_at)
    VALUES (p_token, p_uid, p_platform, timezone('utc'::text, now()))
    ON CONFLICT (token) DO UPDATE
        SET uid = EXCLUDED.uid,
            platform = EXCLUDED.platform,
            updated_at = EXCLUDED.updated_at;
$$;

CREATE OR REPLACE FUNCTION public.unregister_push_token(p_token TEXT)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
    DELETE FROM public.device_push_tokens WHERE token = p_token;
$$;

GRANT EXECUTE ON FUNCTION public.register_push_token(TEXT, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.unregister_push_token(TEXT) TO anon, authenticated;

-- 9. On each new nudge, ask the send-nudge-push edge function to push it.
CREATE EXTENSION IF NOT EXISTS pg_net;

CREATE OR REPLACE FUNCTION public.push_family_nudge()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    PERFORM net.http_post(
        url := 'https://datkdpcomjgtuhodggml.supabase.co/functions/v1/send-nudge-push',
        headers := '{"Content-Type": "application/json"}'::jsonb,
        body := jsonb_build_object('nudge_id', NEW.id)
    );
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS family_nudges_push ON public.family_nudges;
CREATE TRIGGER family_nudges_push
    AFTER INSERT ON public.family_nudges
    FOR EACH ROW EXECUTE FUNCTION public.push_family_nudge();
