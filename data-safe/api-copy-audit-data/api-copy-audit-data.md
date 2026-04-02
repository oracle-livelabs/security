# Copy audit data to object storage using the Oracle Data Safe REST API

## Introduction

When you start your target database's audit trail in Oracle Data Safe, Oracle Data Safe begins copying audit records from the database's audit trail into the Oracle Data Safe repository. In this lab, you use the Oracle Data Safe application programming interface (API) to copy Oracle Data Safe's audit data for your target database into object storage.

Note: During this lab, you configure the Oracle Cloud development kit on a compute instance to use the Jarkarta EE8/Jersey 2 HTTP client library.

Estimated Lab Time: 30 minutes

### Objectives

In this lab, you will:

- Create a bucket to store the audit data
- Start the audit trail for your target database in Oracle Data Safe
- View the quantity of audit data collected by Oracle Data Safe
- Provision a compute instance with the Oracle Cloud development kit preinstalled
- Connect to your compute instance
- Create an API key
- Upload your private key (PEM file) to your compute instance
- Create an API configuration file on your compute instance
- Compile a Java program on your compute instance
- Obtain the compartment OCID for your target database
- Run the compiled Java file on your compute instance
- Verify that the audit data is saved to your bucket in object storage


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console
- Prepared your environment for this workshop (see [Prepare Your Environment](?lab=prepare-environment))
- Registered your target database with Oracle Data Safe (see [Register an Autonomous AI Database with Oracle Data Safe](?lab=register-autonomous-database))
- If you are using a Free Tier subscription, you need to be working in your home region. This is necessary in order to create a compute instance with the Oracle Cloud Development kit.

### Assumptions

Cloud Shell is running the following application versions:
- Oracle Linux Server 7.9
- Oracle Cloud Infrastructure Java SDK 3.55.1
- openjdk version 1.8.0_442


## Task 1: Create a bucket to store the audit data

1. From the navigation menu in Oracle Cloud Infrastructure, select **Storage**, and then **Buckets**.

2. Make sure that your compartment is selected.

3. Click **Create Bucket**.

    The **Create Bucket** panel is displayed.

4. For bucket name, enter **DataSafeAuditData**.

5. Leave the default settings as is, and click **Create**.


## Task 2: Start the audit trail for your target database in Oracle Data Safe

1. From the navigation menu, select **Oracle AI Database**, and then **Data Safe - Database Security**.

2. Under **Security center** on the left, click **Activity auditing**.

3. Under **Related resources** on the left, click **Audit trails**.

4. From the **Compartment** drop-down list on the left, make sure your compartment is selected.

5. On the right, click the name of your target database for the **UNIFIED\_AUDIT\_TRAIL**.

    The **Audit Trail Details** page is displayed.

6. Click **Start**.

    A **Start audit trail: UNIFIED\_AUDIT\_TRAIL** dialog box is displayed.

7. Set the start date to the beginning of the current month. 

    - If it's currently the first day of the month, you can select the previous day to be sure you collect all of the data.
    - Do not select the **Auto Purge** option.

8. Click **Start** and wait for one minute. The **Collection state** value remains at **COLLECTING**. 

    Note: You can view sub-states in the work request details section. Sub-state values include **STARTING**, **COLLECTING** and **IDLE**.


## Task 3: View the quantity of audit data collected by Oracle Data Safe

1. In the breadcrumb at the top of the page, click **Activity auditing**.

2. Under **Security center**, click **Audit profiles**.

3. On the right, click the name of your target database.

    The **Audit profile information** page for your target database is displayed.

4. Scroll down the page to the **Compute audit records** section.

5. Click **Collected by Data Safe**.

    The **Show number of collected audit records** dialog box is displayed.

6. Set the **Start month** and **End month** fields to the first and last day of the current month respectively, and click **Show**. 

7. In the **Collected in Data Safe (Online)** column, make note of the number of audit records collected by Oracle Data Safe.



## Task 4: Provision a compute instance with the Oracle Cloud development kit preinstalled

1. From the navigation menu, select **Developer Services**, and then under **Resource Manager**, click **Stacks**. 

2. Click **Create stack**.

    The **Create stack** page is displayed. You first need to complete **Step 1 Stack information**.

3. Select **Template**.

4. In the **Stack configuration** section, click **Select template**.

    The **Browse templates** panel is displayed.

5. Click the **Architecture** tab. Scroll down and select **Oracle Cloud development kit**. Click **Select template**.

6. (Optional) Enter a different name for the stack.

7. Select your compartment. 

8. Leave the default terraform version and working directory as is.

9. Click **Next**.

    Now you need to complete **Step 2 Configure variables**.

10. Leave the default instance shape set to **VM.Standard.E2.1.Micro**.

11. Leave **Auto-generate SSH key pair** selected.

12. Leave **Compute instance to access all resources at tenancy level** selected.

13. Click **Next**.

    Now you need to complete **Step 3 Review**.

14. Review the configuration, and if it is correct, select the **Run apply** check box at the bottom of the page, and click **Create**.

    The **Job details** page is displayed. The new stack is displayed on the **Stack details** page. 

15. Wait for your compute instance to be provisioned.

    When the instance is provisioned (indicated by a "Succeeded" status for the apply job), installation of the development kit items begins. The installation process takes a few minutes. If you connect to the instance before the installation finishes, then a warning message indicates that the installation is still in progress. Once the items are installed on the instance, you can immediately use them.

16. To obtain information about your compute instance, click the **Application information** tab. From here you can copy connectivity information, including the following:

    - Compute instance public IP
    - Generated private key for SSH access
    - Compartment ID for your compute instance


## Task 5: Connect to your compute instance

To connect to your compute instance, you first need to copy your private key to Cloud Shell.

1. To open Cloud Shell, in the upper-right corner of the Oracle Cloud Infrastructure Console, click the **Developer tools** icon, and then select **Cloud Shell**.

    When you first open Cloud Shell, your current directory is your home directory; for example, `/home/jody_glove`.


2. (Optional) Reset your Cloud Shell environment. The following command erases all the data in your `$HOME` directory on your Cloud Shell machine and resets the `$HOME/.bashrc`, `$HOME/.bash_profile`, `$HOME/.bash_logout`, and `$HOME/.emacs` files back to their default values. Enter **y** at the prompt to confirm.

    ```bash
    $ <copy>csreset --all</copy>
    ```

3. Create an `.ssh` directory in your home directory on your Cloud Shell machine.

    ```bash
    $ <copy>mkdir ~/.ssh</copy>
    ```

4. Create a file named `cloudshellkey` to store your private key data.

    ```bash
    $ <copy>vi ~/.ssh/cloudshellkey</copy>
    ```

5. On the **Application information** tab, click **Unlock** to view your private key. Copy your private key data to the vi editor. It is important that you put **-----BEGIN RSA PRIVATE KEY-----** on the first line, the key code on the second line, and **-----END RSA PRIVATE KEY-----** on the third line. Be careful not to include any code for line breaks. To save, press **Escape**, enter **:wq**, and then press **Enter**.

    Here is an example:

    ```
    <copy>-----BEGIN RSA PRIVATE KEY-----
    MIIEowIBAAKCAQEAoLeHMmDKzeYdOJYKtxaGvtTjn40X5Hfy6A/Rdem90d59m5u0\nqSXmzGYqX1Yj1tgd6...AQj8uvBC7kW8Fstl
    -----END RSA PRIVATE KEY-----</copy>
    ```

6. Give only yourself permission to use the private key. This step is important; otherwise, you will not be able to connect to your compute instance.

    ```
    $ <copy>chmod 600 ~/.ssh/cloudshellkey</copy>
    ```

7. Enter the following command to connect to your compute instance. Substitute `compute-instance-public-ip` with your own. If connectivity is refused or you are prompted for a passphrase, check that your private key file (`cloudshellkey`) does not contain any line return code. You do not require a passphrase to connect.

     ```
    $ <copy>ssh -i ~/.ssh/cloudshellkey opc@compute-instance-public-ip</copy>
    ```


## Task 6: Create an API key

To use the SDK for Java on your compute instance, you must have a key pair used for signing API requests, with the public key uploaded to Oracle. Only the user calling the API should be in possession of the private key.

There are three parts to configuring the SDK: create an API key, upload the private key to your compute instancee, and create a configuration file. This task covers the first part.


1. In the upper-right corner of the Oracle Cloud Infrastructure Console, click the **Profile** icon, and then click your username.

2. Click the **Tokens and keys** tab.

3. Click **Add API key**.

    The **Add API key** panel is displayed.

4. Leave **Generate API key pair** selected, click **Download private key**, and save your private key (PEM file) to a local directory on your computer. 

5. Click **Add**.

    The **Configuration File Preview** panel is displayed, showing you a preview of the configuration file.

6. Copy the configuration file contents to a temporary text file because you need it in a later task. Be sure to include `[DEFAULT]`. The content looks similar to this:

    ```text
    <copy>[DEFAULT]
    user=ocid1.user.oc1...
    fingerprint=your-fingerprint
    tenancy=ocid1.tenancy.oc1...
    region=eu-frankfurt-1
    key_file=<path to your private keyfile> # TODO</copy>
    ```

7. Click **Close**.


## Task 7: Upload your private key (PEM file) to your compute instance

This task covers the second part for configuring the SDK on your compute instance: Upload your private key (PEM file) into object storage, and then copy it to the `.oci` directory on your compute instance.

1. From the navigation menu in Oracle Cloud Infrastructure, select **Storage**, and then **Buckets**. Select your compartment. Click the name of your bucket.
   
    The **Bucket Details** page is displayed.

2. Scroll down to the **Objects** section and click **Upload**.

    The **Upload Objects** panel is displayed.

3. Drag your private key file to the **Choose Files from your Computer** area, and click **Upload**.

4. Click **Close**.

5. At the end of the row for your private key file listing, click the three dots, and then select **Create Pre-Authenticated Request**. 

    The **Create Pre-Authenticated Request** panel is displayed.

6. Click **Create Pre-Authenticated Request**.

    The **Pre-Authenticated Request Details** dialog box is displayed.

7. Copy the **Pre-Authenticated Request URL** to the clipboard and paste it into a temporary local text file. *IMPORTANT: You will not be able to view this URL again after you close the dialog box.*

8. Click **Close**.

9. In Cloud Shell, create a `.oci` directory.

    ```text
    $ <copy>mkdir ~/.oci</copy>
    ```

10. Change to the `.oci` directory.

    ```text
    $ <copy>cd ~/.oci</copy>
    ```

11. Use the `WGET` command to copy your private key file from object storage into the `.oci` directory. Replace `pre-authenticated-request-url` with your own url.

    ```text
    $ <copy>wget pre-authenticated-request-url</copy>
    ```

12. List the contents of the directory and verify that the private key file is listed.

    ```text
    $ <copy>ls</copy>

    your-private-key-file-name
    ```


## Task 8: Create an API configuration file on your compute instance

This task covers the third (and last) part for configuring the SDK on your compute instance: Create a configuration file named `config` in the `.oci` directory for the SDK, and then add the API content that you obtained from the API key (which you created in a previous task). In the config file, correct the last line by adding the actual path to your private key file on your compute instance. The java file that you compile in a subsequent task looks for this config file in `~/.oci/config` with a profile named `DEFAULT`.

1. While you are still in the `.oci` directory, use the vi editor to create a configuration file.

    ```text
    $ <copy>vi config</copy>
    ```

2. Paste the configuration file contents into the `config` file. Note: Earlier you pasted this content into a temporary text file. The content looks similar to the following code. Be sure to include `[DEFAULT]` at the top.

   ```text
    <copy>[DEFAULT]
    user=ocid1.user.oc1...
    fingerprint=your-fingerprint
    tenancy=ocid1.tenancy.oc1...
    region=eu-frankfurt-1
    key_file=<path to your private keyfile> # TODO</copy>
    ```

3. Modify the last line to be the path to your PEM file on your compute instance. In the example below, substitute `your-private-key-file-name` with your own private key file name.

    ```text
    <copy>key_file=~/.oci/your-private-key-file-name</copy>
    ```

4. Save and close the file (press **Escape**, enter **:wq**, and press **Enter**).

5. List the contents of the current directory and ensure that your `config` file is there.

    ```text
    $ <copy>ls</copy>

    config  your-private-key-file-name
    ```

6. Give only yourself permission to use the private key and config files. Substitute `your-private-key-file` with the name of your own private key file.


    ```
    $ <copy>chmod 600 ~/.oci/your-private-key-file</copy>
    $ <copy>chmod 600 ~/.oci/config</copy>
    ```

## Task 9: Compile a Java program on your compute instance

The Oracle Cloud development kit comes with the Java SDK already installed. The OCI jar file is located in `/usr/lib64/java-oci-sdk/lib/oci-java-sdk-full-<version>.jar`, and third-party libraries are in `/usr/lib64/java-oci-sdk/third-party/lib`. To compile a Java file, use the `javac` command. 

In this task, you compile an example Java program named `DataSafeRestAPIClientExample.java`, which is included with the SDK installation. The purpose of this program is to copy audit data from the Oracle Data Safe repository into a specified object storage bucket. If needed, you can also download the program directly from Github by running the following command: `wget https://raw.githubusercontent.com/oracle/oci-java-sdk/master/bmc-examples/src/main/java/DataSafeRestAPIClientExample.java`.

1. Find the version of the `oci-java-sdk-full-version.jar` file and make note of it. You will need it in later steps. In this example, the version is 3.55.1.

    ```text
    $ <copy>ls /usr/lib64/java-oci-sdk/lib</copy>

    oci-java-sdk-full-3.55.1.jar  oci-java-sdk-full-3.55.1-javadoc.jar  oci-java-sdk-full-3.55.1-sources.jar
    ```

2. Copy the example Java program `DataSafeRestAPIClientExample.java` to your current directory (`~/.oci`).

    ```text
    $ <copy>cp /usr/lib64/java-oci-sdk/examples/DataSafeRestAPIClientExample.java .</copy>
    ```

3. Review the program in the vi editor.
   
    ```text
    $ <copy>vi DataSafeRestAPIClientExample.java</copy>
    ```

4. (Temporary fix) In the program, substitute `Region.EU_FRANKFURT_1` with `provider.getRegion()`. You need to make this change on lines 73 and 231. Save the change (press **Escape**, enter **:wq**, and then press **Enter**.)

    This is the correct code:

    ```text
    <copy>ObjectStorage objStoreClient = 
        ObjectStorageClient.builder().region(provider.getRegion()).build(provider);</copy>
    ```
5. Change to the third-party libarary directory.

    ```text
    $ <copy>cd /usr/lib64/java-oci-sdk/third-party/lib/</copy>
    ```
6. Add third-party JAR files to the third-party library directory for the HTTP client libary (Jakarta EE 8/Jersey 2). After you run the commands below, you should have 26 files in the current directory.

    ```text
    <copy>sudo wget https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/2.17.1/jackson-core-2.17.1.jar
    sudo wget https://repo1.maven.org/maven2/com/fasterxml/jackson/datatype/jackson-datatype-jsr310/2.17.1/jackson-datatype-jsr310-2.17.1.jar
    sudo wget https://repo1.maven.org/maven2/jakarta/ws/rs/jakarta.ws.rs-api/2.1.1/jakarta.ws.rs-api-2.1.1.jar
    sudo wget https://repo1.maven.org/maven2/jakarta/ws/rs/jakarta.ws.rs-api/2.1.6/jakarta.ws.rs-api-2.1.6.jar
    sudo wget https://repo1.maven.org/maven2/javax/annotation/javax.annotation-api/1.3.2/javax.annotation-api-1.3.2.jar
    sudo wget https://repo1.maven.org/maven2/javax/inject/javax.inject/1/javax.inject-1.jar
    sudo wget https://repo1.maven.org/maven2/org/apache/httpcomponents/httpclient/4.5.13/httpclient-4.5.13.jar
    sudo wget https://repo1.maven.org/maven2/org/apache/httpcomponents/httpcore/4.4.13/httpcore-4.4.13.jar
    sudo wget https://repo1.maven.org/maven2/org/glassfish/jersey/connectors/jersey-apache-connector/2.35/jersey-apache-connector-2.35.jar
    sudo wget https://repo1.maven.org/maven2/org/glassfish/jersey/core/jersey-common/2.35/jersey-common-2.35.jar
    sudo wget https://repo1.maven.org/maven2/org/glassfish/jersey/core/jersey-client/2.35/jersey-client-2.35.jar
    sudo wget https://repo1.maven.org/maven2/org/glassfish/jersey/inject/jersey-hk2/2.35/jersey-hk2-2.35.jar 
    sudo wget https://repo1.maven.org/maven2/org/glassfish/hk2/hk2-locator/2.6.1/hk2-locator-2.6.1.jar
    sudo wget https://repo1.maven.org/maven2/org/glassfish/hk2/hk2-api/2.6.1/hk2-api-2.6.1.jar
    sudo wget https://repo1.maven.org/maven2/org/glassfish/hk2/hk2-utils/2.6.1/hk2-utils-2.6.1.jar
    sudo wget https://repo1.maven.org/maven2/org/glassfish/jersey/media/jersey-media-json-jackson/2.35/jersey-media-json-jackson-2.35.jar
    sudo wget https://repo1.maven.org/maven2/com/oracle/oci/sdk/oci-java-sdk-common-httpclient/3.55.1/oci-java-sdk-common-httpclient-3.55.1.jar
    sudo wget https://repo1.maven.org/maven2/com/oracle/oci/sdk/oci-java-sdk-common-httpclient-jersey/3.55.1/oci-java-sdk-common-httpclient-jersey-3.55.1.jar
    sudo wget https://repo1.maven.org/maven2/commons-logging/commons-logging/1.2/commons-logging-1.2.jar</copy>
    ```

7. Change to the .oci directory.

    ```
    $ <copy>cd ~/.oci</copy>
    ```

8. Compile the `DataSafeRestAPIClientExample.java` file. Be sure to use the correct version in the `oci-java-sdk-full-<version>.jar` file name. The example below uses version 3.55.1. It’s very common that a Java program depends on one or more external libraries (JAR files). Use the flag `-classpath` (or `-cp`) to tell the compiler where to look for external libraries. Note that there is no output after the file is compiled. You are simply returned to the prompt.

    ```text
    $ <copy>javac -cp /usr/lib64/java-oci-sdk/lib/oci-java-sdk-full-3.55.1.jar:/usr/lib64/java-oci-sdk/third-party/lib/* DataSafeRestAPIClientExample.java</copy>
    ```
9. Confirm that you now have a class file named `DataSafeRestAPIClientExample.class`.

    ```text
    $ <copy>ls</copy>

    config    DataSafeRestAPIClientExample.class    DataSafeRestAPIClientExample.java    your-private-key-file
    ```


## Task 10: Obtain the compartment OCID for your target database

1. From the navigation menu in Oracle Cloud Infrastructure, select **Oracle AI Database**, and then **Data Safe - Database Security**. 

2. On the left, click **Target databases**. 

3. On the left, select your compartment.

4. On the right, click the name of your target database. 

    The **Target database information** page is displayed.
    
5. On the **Target database information** tab, make note of the compartment name. You need this name is step 7. 

6. From the navigation menu, select **Identity & Security**, and then on the right under **Identity**, select **Compartments**. 

7. Click the name of your compartment.

    The **Compartment details** page is displayed.

8. On the **Compartment Information** tab, click the **Copy** link next to **OCID** and paste the OCID into a temporary local text file. You need this OCID for the next task.



## Task 11: Run the compiled Java class file on your compute instance

The `DataSafeRestAPIClientExample.class` program requires two inputs, which you can define upfront:

- **BUCKET**: The name of the bucket in which to store the copied audit data
- **COMPARTMENT**: The compartment OCID of your target database

1. Run the following commands to set the two inputs. Substitute `compartment-ocid-for-target-database` with your own OCID.

    ```text
    $ <copy>export BUCKET=DataSafeAuditData</copy>
    $ <copy>export COMPARTMENT=compartment-ocid-for-target-database</copy>
    ```

2. Run the following command to run the class file. The example below uses `oci-java-sdk-full-3.55.1.jar`, but be sure to use the version that is on your system. You can ignore the error about failing to load the `org.slf4j.impl.StaticLoggerBinder` class. 

    ```text
    $ <copy>java -Xmx2g -cp /usr/lib64/java-oci-sdk/lib/oci-java-sdk-full-3.55.1.jar:/usr/lib64/java-oci-sdk/third-party/lib/*:/usr/lib64/java-oci-sdk/third-party/lib/oci-java-sdk-common-httpclient-jersey-3.55.1.jar:. DataSafeRestAPIClientExample $BUCKET $COMPARTMENT</copy>
    ```

3. Review the output. The third last output line tells you the count of audit records copied into object storage. Your value may be different. If your count is equal to zero, delete any cursors in your bucket and repeat step 3.

    ```text
    <copy>SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".
    SLF4J: Defaulting to no-operation (NOP) logger implementation
    SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details.
    Getting the namespace


    Namespace: ...


    Getting content for object cursor  from bucket: DataSafeAuditData


    ignore
    Finished reading content for object cursor, last upload's last auditEvent record's timecollected FAILED


    2025-06-03T19:13:52.436Z
    Querying for auditEvents with timeCollected Start = 2025-06-03T19:13:52.436Z, End = 2025-06-04T19:13:52.436Z


    Count57


    Upload complete at  Wed Jun 04 19:14:28 GMT 2025 of auditeventjson2025-06-04T19:14:26.126Z _noofrecords_ 57 Start =2025-06-03T19:13:52.436Z, End=2025-06-04T19:13:52.436Z  OpcRequestId: iad-1:jHMqzRM-6TUldkUOAKz...


    Upload complete at  Wed Jun 04 19:14:29 GMT 2025 of cursor  OpcRequestId: iad-1:3HM-YBp8D8BC7otS...</copy>

    
    ```


## Task 12: Verify that the audit data is saved to your bucket in object storage

1. From the navigation menu in Oracle Cloud Infrastructure, select **Storage**, and then **Buckets**.

2. Select your compartment.

3. Click the name of your bucket.

    The **Bucket Details** page for your bucket is displayed.

4. Scroll down to the **Objects** section.

5. Notice that you now have a line item named `auditeventjson` that contains the text `noofrecords_<some-number>`. This is the audit data copied from the Oracle Data Safe repository. `<some-number>` is the number of copied audit records.

    ```text
    <copy>auditeventjson2025-06-04T19:14:26.126Z _noofrecords_ 57 Start =2025-06-03T19:13:52.436Z, End=2025-06-04T19:13:52.436Z</copy>
    ```


You may now **proceed to the next lab**.

## Learn More

- [Activity Auditing Overview](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=UDSCS-GUID-741E8CFE-041E-46C4-9C04-D849573A4DB7)
- [Audit Trails](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=UDSCS-GUID-8E684604-879A-4312-8FF6-519ECD67D179)
- [Getting Started (with SDK for Java)](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/javasdkgettingstarted.htm)
- [oci-java-sdk (on GitHub)](https://github.com/oracle/oci-java-sdk)
- [SDK for Java (configuring the SDK)](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/javasdk.htm)
- [Data Safe API (reference and endpoints)](https://docs.oracle.com/en-us/iaas/api/#/en/data-safe/20181201/)
- [Oracle Cloud Infrastructure Java SDK (packages and classes)](https://docs.oracle.com/en-us/iaas/tools/java/3.2.2/)
- [Preinstalling the Oracle Cloud Development Kit](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/devtools.htm)
- [Regions and Availability Domains](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm)

## Acknowledgements
- **Author** - Jody Glover, Consulting User Assistance Developer, Database 
- **Consultants** - Richard Evans, Bettina Schaeumer, Archana Rao, Anna Haikl 
- **Last Updated By/Date** - Jody Glover, October 20, 2025

