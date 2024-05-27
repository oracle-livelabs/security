# Schedule the copying of audit data to object storage using the Oracle Data Safe REST API

## Introduction

When you start your target database's audit trail in Oracle Data Safe, Oracle Data Safe begins copying audit records from the database's audit trail into the Oracle Data Safe repository. In this lab, you use the Oracle Data Safe application programming interface (API) and crontab on a compute instance to schedule the copying of Oracle Data Safe's audit data for your target database into object storage. 

Estimated Lab Time: 10 minutes

### Objectives

In this lab, you will:

- Create an SH script for cronjob
- Schedule the script to run every minute
- Schedule the script to run at 2AM every day
- Remove the scheduled activity in crontab


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console
- Prepared your environment for this workshop (see [Prepare Your Environment](?lab=prepare-environment))
- Registered your target database with Oracle Data Safe (see [Register an Autonomous Database with Oracle Data Safe](?lab=register-autonomous-database))
- Completed the [Copy Audit Data to Object Storage using the Oracle Data Safe REST API](?lab=api-copy-audit-data) lab. This lab is a continuation of that lab.



## Task 1: Create an SH script for cronjob

The Cron daemon is a built-in Linux utility that runs processes on your system at a scheduled time. Cron reads the crontab (cron tables) for predefined commands and scripts. You need to be the `root` user or a user with `sudo` privileges to create a cron job.

In this task, you create an SH script that contains the variables and Java command to run the example Data Safe Java program. In the next task, you schedule the SH script.

1. In Cloud Shell, switch to the `root` user.

    ```bash
    $ <copy>sudo su -</copy>
    ```


2. Change to the `/usr/local/bin` directory.

    ```text
    # <copy>cd /usr/local/bin</copy>
    ```

3. Using the vi editor, create an SH file named `datasafejob.sh`.

    ```text
    # <copy>vi datasafejob.sh</copy>
    ```

4. Add the following content to the SH file. To run the class file from anywhere, we need to include the path to the `examples` directory in the class path. Again, we are using `oci-java-sdk-full-3.33.0.jar`. Be sure to use the correct version on your system. Substitute `compartment-ocid-for-target-database` with your own compartment OCID.

    ```text
    <copy>#!/bin/bash

    export BUCKET=DataSafeAuditData

    export COMPARTMENT=compartment-ocid-for-target-database

    java -cp /usr/lib64/java-oci-sdk/lib/oci-java-sdk-full-3.33.0.jar:/usr/lib64/java-oci-sdk/third-party/lib/*:/usr/lib64/java-oci-sdk/third-party/jersey/lib/*:/usr/lib64/java-oci-sdk/lib/jersey/oci-java-sdk-common-httpclient-jersey-3.33.0.jar:/home/opc/.oci DataSafeRestAPIClientExample $BUCKET $COMPARTMENT</copy>
    ```

4. Save and close the file (press **Escape**, enter **:wq**, and press **Enter**).

5. Add permissions to the script.

    ```text
    # <copy>chmod 777 datasafejob.sh</copy>
    ```

## Task 2: Schedule the SH script to run every minute

Start by scheduling the SH script to run every minute so that you can test that the scheduling works. After confirming, change the schedule to be at 2AM every day.

1. To edit the cron job, enter the following command:

    ```text
    # <copy>crontab -e</copy>
    ```

2. Add the following to the first line and then save (press **Escape**, enter **:wq**, and press **Enter**):


    ```text
    <copy>* * * * * /usr/local/bin/datasafejob.sh</copy>
    ```

3. Generate some activity for Oracle Data Safe to audit. To do this, access Database Actions for your target database. Download the [**load-data-safe-sample-data_admin.sql**](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/load-data-safe-sample-data_admin.sql) script and open it in a text editor, such as NotePad. Copy the entire script to the clipboard and paste it into the worksheet in Database Actions. On the toolbar, click the **Run Script** button and wait for the script to finish running.


4. Return to your bucket and view the audit data being collected each minute. It can take up to ten minutes for the audit data objects to be displayed.

    ![Audit records objects](images/audit-records-objects.png "Audit records objects")



## Task 3: Schedule to script to run at 2AM every day

1. In Cloud Shell, access crontab.

    ```text
    # <copy>crontab -e</copy>
    ```

2. Replace the existing text with the following text, and then save the file (press **Escape**, enter **:wq**, and press **Enter**). In the example below, `0 2 * * *` indicates that the cron job runs any time the system clock shows 2am. 

    ```text
    <copy>0 2 * * * /usr/local/bin/datasafejob.sh</copy>
    ```


## Task 4: Remove the scheduled activity in crontab

1. Access crontab.

    ```text
    # <copy>crontab -e</copy>
    ```

2. Delete the content.

3. Save your changes (press **Escape**, enter **:wq**, and press **Enter**).

4. Close Cloud Shell.

You may now **proceed to the next lab**.

## Learn More
- [Activity Auditing Overview](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=UDSCS-GUID-741E8CFE-041E-46C4-9C04-D849573A4DB7)
- [Audit Trails](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=UDSCS-GUID-8E684604-879A-4312-8FF6-519ECD67D179)
- [Oracle Linux Cloud Developer Image](https://docs.oracle.com/en-us/iaas/oracle-linux/developer/index.htm)
- [Getting Started (with SDK for Java)](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/javasdkgettingstarted.htm)
- [oci-java-sdk (on GitHub)](https://github.com/oracle/oci-java-sdk)
- [SDK for Java (configuring the SDK)](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/javasdk.htm)
- [Data Safe API (reference and endpoints)](https://docs.oracle.com/en-us/iaas/api/#/en/data-safe/20181201/)
- [Oracle Cloud Infrastructure Java SDK (packages and classes)](https://docs.oracle.com/en-us/iaas/tools/java/3.2.2/)


## Acknowledgements
- **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Contributors** - Richard Evans, Anna Haikl, Russ Lowenthal, Archana Rao, Bettina Schaeumer
- **Last Updated By/Date** - Jody Glover, February 6, 2024





