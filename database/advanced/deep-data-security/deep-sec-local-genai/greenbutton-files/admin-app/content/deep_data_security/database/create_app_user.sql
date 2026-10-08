-- This file intentionally creates no database objects.
--
-- Customer Sales App connects directly to Oracle as MARVIN.
-- the password entered at sign-in. Oracle Deep Data Security evaluates
-- MARVIN's end-user identity and active data roles for that session.
-- Flask receives only the rows and columns Oracle authorizes for MARVIN.
set echo off

prompt Customer Sales App uses direct database authentication as MARVIN.
prompt Oracle verifies the sign-in password for that session.
prompt Deep Sec evaluates MARVIN's active data roles and grants.
prompt Flask only gets the rows and columns Oracle authorizes.
prompt No database objects are created by this step.
