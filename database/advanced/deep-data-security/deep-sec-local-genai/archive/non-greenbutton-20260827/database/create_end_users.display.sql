-- Run as ADB admin. Creates both local end users.
-- Uses the shared Stack password; never displays it.

-- 1. Replace either user left by an earlier run.
DROP END USER MARVIN;
DROP END USER EMMA;

-- 2. Create both local end users.
CREATE END USER MARVIN IDENTIFIED BY <shared Stack password>;
CREATE END USER EMMA IDENTIFIED BY <shared Stack password>;

-- 3. Emma is the fixed employee-level comparison user. Marvin receives a
--    data role separately in the next Grant Data Role step.
GRANT DATA ROLE HOL_DATAROLE_EMPLOYEE_ACCESS TO EMMA;
