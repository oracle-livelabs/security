-- Run as ADB ADMIN. This revokes only Marvin's manager data role.
-- The manager data grant remains defined and can be used again if the role is restored.

REVOKE DATA ROLE HOL_DATAROLE_MANAGER_ACCESS FROM MARVIN;

-- Marvin retains HOL_DATAROLE_EMPLOYEE_ACCESS when it is still granted.
