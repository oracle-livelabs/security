# Configure Database for Audit

## Introduction
This workshop introduces you to best practice recommendations of audit trail management to ensure efficient performance and optimum use of the disk space. The recommendations include
- Dedicated tablespace for unified audit trail
- Reasonable unified audit trail partition interval
- Periodic purge of the unified audit trail

*Estimated Lab Time:* 10 minutes

*Version tested in this lab:* Oracle DBEE 19.23

### Objectives
In this lab, you will:
- Designate a dedicated tablespace for unified audit trail
- Set reasonable unified audit trail partition interval
- Archive audit records and purge the unified audit trail

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment

### Lab Timing (estimated)
| Step No. | Feature | Approx. Time |
|--|------------------------------------------------------------|-------------|
| 1 | Designate a dedicated tablespace for unified audit trail | 5 minutes |
| 2 | Set reasonable unified audit trail partition interval | 5 minutes |
| 3 | Archive audit records and purge the unified audit trail | 5 minutes |


## Task 1: Designate a dedicated tablespace for unified audit trail
Storing audit records in a separate dedicated tablespace will improve system performance. In this task, we will create a dedicated ASSM (auto segment space managed) tablespace for Unified auditing, and relocate the unified audit trail to the newly created one.

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

    ````
    <copy>sudo su - oracle</copy>
    ````

    **Note**: Only **if you are using a remote desktop session**, just double-click on the Terminal icon on the desktop to launch a session directly as oracle, so, in that case **you don't need to execute this command**!

2. Go to the scripts directory

    ````
    <copy>cd $DBSEC_LABS/unified-auditing</copy>
    ````

3. Create a dedicated ASSM (auto segment space managed) tablespace and relocate

    ````
    <copy>./ua_create_relocate_tablespace.sh</copy>
    ````
    - Effective for newer audit records, older audit records will remain in older tablespace.

        ![Unified Auditing](./images/ua-001.png "Display the audit settings")

        **Note**: Screenshot shows the newly created dedicated tablespace for Unified auditing.


## Task 2: Set reasonable unified audit trail partition interval 
Set the audit trail partition interval such that each partition has manageable set of audit records. This helps in both reading audit records quickly as well as audit trail cleanups since older partitions can be dropped much more quickly than deleting partial set of rows in a partition.

1. Set the partition interval to 1 day 

    ````
    <copy>./ua_audit_partition_interval.sh</copy>
    ````

    ![Unified Auditing](./images/ua-007.png "Identify the connections we trust")

    **Note**: 
    - AUDSYS.AUD$UNIFIED table is interval partitioned with default interval of 1 month until 19c, and default interval of 1 day above 19c. 
    - The next partition is created only after current/active partition’s HIGH_VALUE is reached. Therefore, it might take a while for the newer partition to appear.


## Task 3: Archive audit records and purge the unified audit trail
To maintain the integrity and reliability of audit data, keep only minimal required audit data locally and move audit data to a dedicated repository outside of the source database (such as Oracle AVDF or Data Safe) for long-term audit data retention and detailed analysis. It is recommended to periodically purge old audit records at source. In this task, we will create a scheduler purge job that performs cleanup at a specified time interval honouring the last archive timestamp. The `DBMS_AUDIT_MGMT` package provides utilities to set archive timestamp, purge the audit trail and schedule a purge job.

1. Create the scheduler job for purging. The job will purge the audit data which is 7 days old and this job will run on daily basis at 9 PM.

    ````
    <copy>./ua_purge_audit.sh</copy>
    ````

    ![Unified Auditing](./images/ua-018.png "Create the role MGR_ROLE")

You may now proceed to the next lab!

## **Appendix**: About Unified Auditing
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
- **Last Updated By/Date** - Angeline Dhanarani, Database Security PM - November 2024