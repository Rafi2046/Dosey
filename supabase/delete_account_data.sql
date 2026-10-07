-- ==============================================================================
-- Dosey: erase a user's cloud data when they delete their account
--
-- Run AFTER secure_family_sharing.sql (it uses public.fb_uid()).
--
-- The app calls delete_my_data() just before deleting the Firebase account,
-- while its ID token still works. Without it, deleting the account left the
-- user's medicines, doses, nudges and family links behind in Supabase.
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.delete_my_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    me TEXT := public.fb_uid();
BEGIN
    -- No verified token: the policies never let this caller write a row,
    -- so there is nothing of theirs to erase.
    IF me IS NULL THEN
        RETURN;
    END IF;

    -- As a patient: everything shared about them.
    DELETE FROM public.patient_prescriptions WHERE patient_uid = me;
    DELETE FROM public.patient_shared_adherence WHERE patient_uid = me;

    -- Nudges and links on either side; removing a link also takes a
    -- caregiver's access to this patient, and this caregiver's to theirs.
    DELETE FROM public.family_nudges WHERE patient_uid = me OR caregiver_uid = me;
    DELETE FROM public.family_shares WHERE patient_uid = me OR caregiver_uid = me;

    -- As a caregiver: keep the patient's medicines, drop who last edited them.
    UPDATE public.patient_prescriptions SET updated_by = NULL WHERE updated_by = me;

    DELETE FROM public.device_push_tokens WHERE uid = me;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.delete_my_data() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.delete_my_data() TO anon, authenticated;
