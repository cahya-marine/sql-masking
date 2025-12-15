-- Create the restricted role
CREATE ROLE analytics_viewer LOGIN PASSWORD 'secure_pass_for_analytics';

-- Grant necessary read access
GRANT CONNECT ON DATABASE barging TO analytics_viewer;
GRANT USAGE ON SCHEMA public TO analytics_viewer;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analytics_viewer;
GRANT SELECT ON ALL TABLES IN SCHEMA anon TO analytics_viewer;

-- Apply the Security Label (This is the trigger for masking)
SECURITY LABEL FOR anon ON ROLE analytics_viewer IS 'MASKED';

-- Start Dynamic Masking Engine
SELECT anon.start_dynamic_masking();


-- Apply masking rules to the identified sensitive columns

-- Users PII
SECURITY LABEL FOR anon ON COLUMN public.users.full_name IS 'MASKED WITH FUNCTION anon.fake_last_name()';
SECURITY LABEL FOR anon ON COLUMN public.users.email IS 'MASKED WITH FUNCTION anon.pseudo_email(email)';
SECURITY LABEL FOR anon ON COLUMN public.users.phone_number IS 'MASKED WITH FUNCTION anon.partial(phone_number, 2, ''XXXXXX'', 4)';

-- Financial PII
SECURITY LABEL FOR anon ON COLUMN public.bank_accounts.account_name IS 'MASKED WITH FUNCTION anon.fake_company()';
SECURITY LABEL FOR anon ON COLUMN public.bank_accounts.account_number IS 'MASKED WITH FUNCTION anon.partial(account_number, 4, ''****'', 4)';

-- Legal PII
SECURITY LABEL FOR anon ON COLUMN public.cargo_owner_profiles.director_ktp IS 'MASKED WITH FUNCTION anon.digest(director_ktp, ''xsfnjefnjsnfjsnf'' ,''sha256'')';
SECURITY LABEL FOR anon ON COLUMN public.cargo_owner_profiles.npwp_num IS 'MASKED WITH FUNCTION anon.partial(npwp_num, 3, ''***'', 4)';

-- Operational PII
SECURITY LABEL FOR anon ON COLUMN public.purchase_orders.captain_name IS 'MASKED WITH FUNCTION anon.fake_first_name()';
SECURITY LABEL FOR anon ON COLUMN public.purchase_orders.captain_phone_number IS 'MASKED WITH FUNCTION anon.partial(captain_phone_number, 0, ''********'', 4)';
