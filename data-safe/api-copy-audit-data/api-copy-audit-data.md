# Copy audit data to object storage using the Oracle Data Safe REST API

## Introduction

When you start your target database's audit trail in Oracle Data Safe, Oracle Data Safe begins copying audit records from the database's audit trail into the Oracle Data Safe repository. In this lab, you use the Oracle Data Safe application programming interface (API) to copy Oracle Data Safe's audit data for your target database into object storage.

Estimated Lab Time: 30 minutes

### Objectives

In this lab, you will:

- Create a bucket in your compartment
- Start the audit trail for your target database in Oracle Data Safe
- View the quantity of audit data collected by Oracle Data Safe
- Access Cloud Shell in Oracle Cloud Infrastructure and install the SDK
- Configure the SDK
- Review and compile the java example that has Oracle Data Safe REST API commands
- Run the compiled java file
- Verify that the audit data is copied to your bucket


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console
- Prepared your environment for this workshop (see [Prepare Your Environment](?lab=prepare-environment))
- Registered your target database with Oracle Data Safe (see [Register an Autonomous Database with Oracle Data Safe](?lab=register-autonomous-database))



## Task 1: Create a bucket in your compartment

Create a bucket to store your audit data. 

1. From the navigation menu in Oracle Cloud Infrastructure, select **Storage**, and then **Buckets**.

2. Select your compartment.

3. Click **Create Bucket**.

    The **Create Bucket** dialog box is displayed.

4. For bucket name, enter **DataSafeAuditData**.

5. Leave the default settings as is, and click **Create**.


## Task 2: Start the audit trail for your target database in Oracle Data Safe

1. Click **View** to access Security Center in Oracle Data Safe.

2. Under **Security Center** on the left, click **Activity Auditing**.

3. Under **Related Resources** on the left, click **Audit Trails**.

4. From the **Compartment** drop-down list on the left, make sure your compartment is selected.

5. On the right, click the name of your target database for the **UNIFIED\_AUDIT\_TRAIL**.

    The **Audit Trail Details** page is displayed.

6. Click **Start**.

    A **Start Audit Trail: UNIFIED\_AUDIT\_TRAIL** dialog box is displayed.

7. Set the start date to the beginning of the current month.

8. Click **Start**. Wait for **Collection State** to change from **STARTING** to **COLLECTING** and then to **IDLE**. It takes about a minute.


## Task 3: View the quantity of audit data collected by Oracle Data Safe

1. In the breadcrumb at the top of the page, click **Activity Auditing**.

2. Under **Security Center**, click **Audit Profiles**.

3. On the right, click the name of your target database.

    The **Audit Profile Details** page for your target database is displayed.

4. Scroll down the page to the **Compute Audit Volume** section.

5. Click **Collected by Data Safe**.

    The **Compute Collected Volume** dialog box is displayed.

6. Set the **Start Month** and **End Month** fields to the first and last day of the current month respectively, and click **Compute**. Make note of the number of audit records collected by Oracle Data Safe.


## Task 4: Access Cloud Shell in Oracle Cloud Infrastructure and install the SDK

In Cloud Shell, download the SDK to a directory named `oci`. Unzip the SDK into the `oci` directory.

1. In the upper-right corner of the Oracle Cloud Infrastructure Console, click the **Developer tools** icon, and then select **Cloud Shell** icon to open Cloud Shell.

    When you first open Cloud Shell, you are in your home directory; for example, `/home/jody_glove`.

2. Make a directory named `oci`, give yourself `read/write/execute` permissions on it, and then switch to it.

    ```
    <copy>mkdir oci
    chmod 777 ~/oci
    cd </copy>
   ```

3. Download the SDK and unzip it in the `oci` directory.

    ```
    <copy>wget https://github.com/oracle/oci-java-sdk/releases/download/v3.2.0/oci-java-sdk-3.2.0.zip
    unzip oci-java-sdk-3.2.0.zip</copy>
    ```


## Task 5: Configure the SDK

Create a configuration file in your `oci` directory (`~/.oci/config`).

1. In the upper-right corner of the Oracle Cloud Infrastructure Console, click the **Profile** icon, and then click your username.

2. On the left, click **API Keys**.

3. Click **Add API Key**.

    The **Add API Key** dialog box is displayed.

4. Leave **Generate API Key Pair** selected, click **Download Private Key**, and save your key to a local directory on your computer. 

    The **Configuration File Preview** dialog box is displayed showing you a preview of the configuration file.

5. Copy the configuration file contents to a temporary text file. It should look similar to this:

    ```
    [DEFAULT]
    user=ocid1.user.oc1...
    fingerprint=ff:35...
    tenancy=ocid1.tenancy.oc1...
    region=eu-frankfurt-1
    key_file=<path to your private keyfile> # TODO
    ```

6. Click **Close**.

7. Return to Cloud Shell.

8. Switch to your home directory and create a directory named `datasafe_keyfile`.

    ```
    <copy>cd $HOME
    mkdir datasafe_keyfile</copy>
    ```

9. Create a configuration file in the `oci` directory using the vi editor.

    ```
    <copy>vi ~/oci/config</copy>
    ```

10. Paste the configuration file contents.

11. Modify the last line to be the path to your key file. In the example below, substitute `your-pem-file.pem` with your own PEM file name. 

    ```
    <copy>key_file=datasafe_keyfile/your-pem-file.pem</copy>
    ```

12. Save and close (press **Escape**, and then enter **:wq**).


13. In Cloud Shell in the upper-right corner, click the **cloud Shell** menu icon, and select **Upload**.

    The **File Upload to your Home Directory** dialog box is displayed.

14. Drag your PEM file to the dialog box, and click **Upload**. 

    Your file is uploaded to your home directory.

15. After the file is successfully transferred, click **Hide** to close the dialog box.

16. Move the file to the `datasafe_keyfile` directory. In the example below, replace `your-pem-file.pem` with your own PEM file name.

    ```
    <copy>mv ~/your-pem-file.pem ~/datasafe_keyfile/your-pem-file.pem</copy>
    ```


## Task 6: Review and compile the java example that has Oracle Data Safe REST API commands

The name of the Java file is `DataSafeRestAPIClientExample.java`. Use the `javac` command to compile the file.

1. Review the file:

    ```
    <copy>cat ~/oci/examples/DataSafeRestAPIClientExample.java</copy>
    ```

    If you don't have this class file, you can download it here from GitHub:

    ```
    <copy>wget https://raw.githubusercontent.com/oracle/oci-java-sdk/master/bmc-examples/src/main/java/DataSafeRestAPIClientExample.java</copy>
    ```

2. Switch to the `oci` directory.

    ```
    <copy>cd ~/oci/examples</copy>
    ```

3. Compile the file.

    ```
    <copy>javac -cp .:$OCI_JAVA_SDK_FULL_JAR_LOCATION:$OCI_JAVA_SDK_LOCATION/third-party/lib/*:$HOME/oci/lib/oci-java-sdk-full-3.2.0.jar DataSafeRestAPIClientExample.java</copy>
    ```

    The file compiles without any output in the console.

## Task 7: Run the compiled java file


1. Run the following commands to set the variables. In the example below, replace `your-compartment-ocid` with the OCID of the compartment for your target database.

    ```
    <copy>export BUCKET=DataSafeAuditData
    export COMPARTMENT=your-compartment-ocid</copy>
    ```

2. Run the `DataSafeRestAPIClientExample.class` file.

    ```
    <copy>java -cp .:$OCI_JAVA_SDK_FULL_JAR_LOCATION:$OCI_JAVA_SDK_LOCATION/third-party/lib/*:$HOME/oci/lib/oci-java-sdk-full-3.2.0.jar DataSafeRestAPIClientExample $BUCKET $COMPARTMENT</copy>
    ```

## Task 8: Verify that the audit data is copied to your bucket

1. From the navigation menu in OCI, select **Storage**, and then **Buckets**.

2. Select your compartment.

3. Click the name of your bucket.

    The **Bucket Details** page for your bucket is displayed.

4. Scroll down to the **Objects** section.

5. Notice that you now have a line item named `auditeventjson` that contains the text `noofrecords_<some-number>`. This is the audit data copied from the Oracle Data Safe repository. `<some-number>` is the number of copied audit records.


## Learn More

- [Activity Auditing Overview](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=UDSCS-GUID-741E8CFE-041E-46C4-9C04-D849573A4DB7)
- [Audit Trails](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=UDSCS-GUID-8E684604-879A-4312-8FF6-519ECD67D179)
- [Downloading and installing the Java SDK](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/javasdkgettingstarted.htm)
- [oci-java-sdk on GitHub](https://github.com/oracle/oci-java-sdk)
- [Configuring the SDK](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/javasdk.htm)
- [Oracle Data Safe Command Line Reference](https://docs.oracle.com/en-us/iaas/tools/oci-cli/3.22.2/oci_cli_docs/cmdref/data-safe.html)
- [Oracle Data Safe API Reference and Endpoints](https://docs.oracle.com/en-us/iaas/api/#/en/data-safe/20181201/)


## Acknowledgements
- **Author** - Jody Glover, Consulting User Assistance Developer, Database 
- **Consultants** - Richard Evans, Anna Haikl, Archana Rao
- **Last Updated By/Date** - Jody Glover, January 22, 2023



































