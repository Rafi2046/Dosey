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
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    expires_at TIMESTAMPTZ
);

-- 2. Indexes for fast querying
CREATE INDEX IF NOT EXISTS idx_family_shares_patient_uid ON public.family_shares(patient_uid);
CREATE INDEX IF NOT EXISTS idx_family_shares_caregiver_uid ON public.family_shares(caregiver_uid);
CREATE INDEX IF NOT EXISTS idx_family_shares_share_code ON public.family_shares(share_code);

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
