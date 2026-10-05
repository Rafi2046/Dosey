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

-- 7. Realtime: deliver caregiver nudges instantly instead of waiting for the poll.
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.family_nudges;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
