UPDATE public.users
SET full_name    = anon.fake_first_name() + anon.fake_last_name(),
    email        = anon.pseudo_email(email),
    -- Static Redaction of PII that is not needed for testing
    phone_number = '0000000000';

UPDATE public.cargo_owner_profiles
SET
    -- Permanent Hashing (Destroys value but allows checking for duplicates)
    director_ktp = anon.digest(director_ktp, 'md5'),
    -- Redact the NPWP entirely
    npwp_num     = 'REDACTED_NPWP';

-- 2. Apply Redaction (Permanent Destruction of Value)
-- Essential for highly sensitive financial data.

UPDATE public.bank_accounts
SET account_name   = anon.fake_company(), -- Use a fake company name
    -- Keep only the last 4 digits of the account number
    account_number = 'XXXXXXXX' || RIGHT(account_number, 4);

UPDATE public.cargo_owner_contact_persons
SET email = anon.pseudo_email(email);

-- 3. Finalize
-- Commit the changes and vacuum the table to physically remove the original data from disk.
COMMIT;
VACUUM FULL VERBOSE public.users;