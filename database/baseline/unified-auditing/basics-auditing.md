# Unified Audit Basics: Beginner’s Delight

## Introduction
This workshop helps you get started with essentials and is the foundation step for anyone getting started with Unified Auditing (or) aiming to achieve parity with default legacy audit settings that is de-supported in Oracle Database 23ai. Learn how you can start auditing the most common security-relevant events that are absolutely critical to monitor in the database or needed to demonstrate compliance with most regulations. This lab will cover the policy provisioning for such essential auditable events in the database and validate that audits are triggered with a workload.


*Estimated Lab Time:* 15 minutes

*Version tested in this lab:* Oracle DBEE 19.23

### Objectives
- Get started auditing the most common security-relevant events

    **Note**:
    The workshop leverages the following to audit the absolutely critical auditable actions in the database
    - Always-on mandatory audits
    - Predefined unified audit policies
    - Custom policy to track database schema modification attempts
    - Custom policy to track activities of administrative database users

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment
    - Lab: Configure Database for Audit


## Task 1: Leverage always-on mandatory audits

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

    ````
    <copy>sudo su - oracle</copy>
    ````

    **Note**: Only **if you are using a remote desktop session**, just double-click on the Terminal icon on the desktop to launch a session directly as oracle, so, in that case **you don't need to execute this command**!

2. Go to the scripts directory

    ````
    <copy>cd $DBSEC_LABS/unified-auditing</copy>
    ````

3. Display the always-on mandatory audited events in **`UNIFIED_AUDIT_TRAIL`**

    ````
    <copy>./ua_mandatory_audits.sh</copy>
    ````

    - Mandatorily audited activities will have audit policy by name ORA$MANDATORY in the **`UNIFIED_AUDIT_POLICIES`** column of the **`UNIFIED_AUDIT_TRAIL`** view

        ![Unified Auditing](./images/ua-001.png "Display the mandatorily audited activities")

        **Note**: The mandatorily audited security-sensitive database activities in the Oracle Database cannot be disabled. 

## Task 2: Leverage predefined audits

In this lab, you will ensure the following predefined unified audit policies are enabled if not done already

| Step No. | Predefined audit policy | Significance |
|--|------------------------------------------------------------|-------------|
| 1 | `ORA_SECURECONFIG` | Audits secure configuration audit options |
| 2 | `ORA_LOGIN_LOGOUT` | Audits logon and logoff failures |
| 3 | `ORA_DV_SCHEMA_CHANGES` | Audits Oracle Database Vault DVSYS and LBACSYS schema objects |
| 4 | `ORA_DV_DEFAULT_PROTECTION` |  Audits the Oracle Database Vault default realms and command rules |
| 5 | `ORA_ACCOUNT_MGMT` | Audits commonly used user account and privilege settings |

**Note**: The predefined policies **`ORA_SECURECONFIG`** and **`ORA_LOGIN_LOGOUT`** is enabled by default on most of the databases if they are created from 12.2 and above. Depending on database version and flavors such as autonomous, your might see additional predefined audit policies enabled by default.


1. Check if the following predefined unified audit policies are enabled by default: **`ORA_SECURECONFIG`, `ORA_LOGIN_LOGOUT`, `ORA_DV_SCHEMA_CHANGES` and `ORA_DV_DEFAULT_PROTECTION`**. Enable if it is not.

    ````
    <copy>./ua_query_predefined_enabled_policies.sh</copy>
    ````

    ![Unified Auditing](./images/ua-007.png "Check if predefined audit policies are enabled")

    **Note**: If it is not enabled, **EXECUTE the next script** to enable for all users!

    ````
    <copy>./ua_enable_predefined_policies.sh</copy>
    ````

    ![Unified Auditing](./images/ua-009.png "Ensure predefined audit policies are enabled")


2. Enable predefined unified audit policy **`ORA_ACCOUNT_MGMT`** for all users
  
   ````
    <copy>./ua_enable_accountmgmnt_policies.sh</copy>
    ````
 ![Unified Auditing](./images/ua-012.png "Policy to track acct mgmt changes")

## Task 3: Audit database schema structure modification attempts

Create and enable a custom audit policy to audit schema structure modification attempts for all users.

   ````
    <copy>./ua_enable_schema_mod_attempts.sh</copy>
    ````
 ![Unified Auditing](./images/ua-013.png "Policy to track schema modification changes")


## Task 4: Audit administrative database user accounts (including SYS)

Create and enable the unified audit policy **`ORA_ALL_TOPLEVEL_ACTIONS`** to audit administrative database user accounts. Enable the policy for the following users
- Users with administrative SYS* privileges,
- users granted DBA role,
- Non-admin privileged users with virtue of their job function

    ````
    <copy>./ua_audit_admin_users.sh</copy>
    ````

    ![Unified Auditing](./images/ua-028.png "Create the Unified Audit Policy for Admin users")

## Task 5: Disable legacy audits if it exists

If your database is upgraded to 23ai from prior release, there is possibility of redundant legacy audit settings. It is highly recommended to ensure legacy audit settings are removed.

1. Check the presence of legacy audit settings in the database

    ````
    <copy>./check_legacy_audits.sh</copy>
    ````

    ![Unified Auditing](./images/ua-028.png "Check Legacy audits")

      **Note**: If it is non-zero results, **EXECUTE the next script** to remove them in the database.

    ````
    <copy>./delete_legacy_audits.sh</copy>
    ````
    
    ![Unified Auditing](./images/ua-007.png "Remove legacy audits")

## Task 6: Generate audit events and validate

1. Run the script to generate auditable events

    ````
    <copy>./trigger_workload_scripts_basic_lab.sh</copy>
    ````

    ![Unified Auditing](./images/ua-008.png "trigger workloads")

2. Examine the contents of the **`UNIFIED_AUDIT_TRAIL`**

   ````
    <copy>./examine_unified_audit_trail.sh</copy>
    ````

![Unified Auditing](./images/ua-0010.png "examine unified audit")

You may now proceed to the next lab!

## **Appendix**: About the Product
### **Overview**

In unified auditing, the unified audit trail captures audit information from a variety of sources.

Unified auditing enables you to capture audit records from the following sources:
- Audit records (including SYS audit records) from unified audit policies and AUDIT settings
- Fine-grained audit records from the `DBMS_FGA` PL/SQL package
- Oracle Database Real Application Security audit records
- Oracle Recovery Manager audit records
- Oracle Database Vault audit records
- Oracle Label Security audit records
- Oracle Data Mining records
- Oracle Data Pump
- Oracle SQL*Loader Direct Load

The unified audit trail, which resides in a read-only table in the AUDSYS schema in the SYSAUX tablespace, makes this information available in a uniform format in the `UNIFIED_AUDIT_TRAIL` data dictionary view, and is available in both single-instance and Oracle Database Real Application Clusters environments. In addition to the user SYS, users who have been granted the `AUDIT_ADMIN` and `AUDIT_VIEWER` roles can query these views. If your users only need to query the views but not create audit policies, then grant them the `AUDIT_VIEWER` role.

When the database is writeable, audit records are written to the unified audit trail. If the database is not writable, then audit records are written to new format operating system files in the `$ORACLE_BASE/audit/$ORACLE_SID` directory.

### **Benefits of the Unified Audit Trail**
- After unified auditing is enabled, it does not depend on the initialization parameters that were used in previous releases.
- The audit records, including records from the SYS audit trail, for all the audited components of your Oracle Database installation are placed in one location and in one format, rather than your having to look in different places to find audit trails in varying formats.
- The management and security of the audit trail is also improved by having it in single audit trail.
- Overall auditing performance is greatly improved. By default, the audit records are automatically written to an internal relational table in the AUDSYS schema.
- You can create named audit policies that enable you to audit the supported components listed at the beginning of this section, as well as SYS administrative users. Furthermore, you can build conditions and exclusions into your policies.
- If you are using an Oracle Audit Vault and Database Firewall environment, then the unified audit trail greatly facilitates the collection of audit data, because all of this data will come from one location.

## Want to Learn More?
Technical Documentation:
- [Introduction to Auditing](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/introduction-to-auditing.html)  
- [Monitoring Database Activity with Auditing](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/part_6.html)

Video:
- *Understanding Unified Auditing (February 2019)*[](youtube:8spLhyj3iC0)

## Acknowledgements
- **Author** - Angeline Dhanarani, Database Security PM
- **Contributors** - Angeline Dhanarani
- **Last Updated By/Date** - Angeline Dhanarani, Database Security PM - Nov 2024