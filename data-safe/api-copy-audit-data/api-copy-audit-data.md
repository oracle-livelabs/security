# Copy audit data to object storage using the Oracle Data Safe REST API

## Introduction

When you start your target database's audit trail in Oracle Data Safe, Oracle Data Safe begins copying audit records from the database's audit trail into the Oracle Data Safe repository. In this lab, you use the Oracle Data Safe application programming interface (API) to copy Oracle Data Safe's audit data for your target database into object storage.

Estimated Lab Time: 30 minutes

### Objectives

In this lab, you will:

- Create a bucket in your compartment
- Start the audit trail for your target database in Oracle Data Safe
- View the quantity of audit data collected by Oracle Data Safe
- Access Cloud Shell in Oracle Cloud Infrastructure and review the SDK for Java installation
- Configure the SDK
- Compile the Java file
- Obtain the compartment OCID for your target database
- Run the compiled Java file
- Verify that the audit data is copied to your bucket


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console
- Prepared your environment for this workshop (see [Prepare Your Environment](?lab=prepare-environment))
- Registered your target database with Oracle Data Safe (see [Register an Autonomous Database with Oracle Data Safe](?lab=register-autonomous-database))

### Assumptions

Cloud Shell is running the following application versions:
- Java version 11.0.17
- Java(TM) SE Runtime Environment 18.9 (build 11.0.17+10-LTS-269)
- Linux 7.9
- Oracle Cloud Infrastructure Java SDK 3.2.2


## Task 1: Create a bucket in your compartment

Create a bucket to store your audit data. 

1. From the navigation menu in Oracle Cloud Infrastructure, select **Storage**, and then **Buckets**.

2. Select your compartment.

3. Click **Create Bucket**.

    The **Create Bucket** dialog box is displayed.

4. For bucket name, enter **DataSafeAuditData**.

5. Leave the default settings as is, and click **Create**.


## Task 2: Start the audit trail for your target database in Oracle Data Safe

1. From the navigation menu, select **Oracle Database**, and then **Data Safe**.

2. Under **Security Center** on the left, click **Activity Auditing**.

3. Under **Related Resources** on the left, click **Audit Trails**.

4. From the **Compartment** drop-down list on the left, make sure your compartment is selected.

5. On the right, click the name of your target database for the **UNIFIED\_AUDIT\_TRAIL**.

    The **Audit Trail Details** page is displayed.

6. Click **Start**.

    A **Start Audit Trail: UNIFIED\_AUDIT\_TRAIL** dialog box is displayed.

7. Set the start date to the beginning of the current month. 

    - If it's currently the first day of the month, you can select the previous day to be sure you collect all of the data.
    - Do not select the **Auto Purge** option.

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


## Task 4: Access Cloud Shell in Oracle Cloud Infrastructure and review the SDK for Java installation

The Oracle Cloud Infrastructure SDK for Java (oci-java-sdk) provides an SDK for Java that you can use to manage your Oracle Cloud Infrastructure resources.

1. To open Cloud Shell, in the upper-right corner of the Oracle Cloud Infrastructure Console, click the **Developer tools** icon, and then select **Cloud Shell**.

    When you first open Cloud Shell, your current directory is your home directory; for example, `/home/jody_glove`.


2. (Optional) Reset your Cloud Shell environment. The following command erases all the data in your `$HOME` directory on your Cloud Shell machine and resets the `$HOME/.bashrc`, `$HOME/.bash_profile`, `$HOME/.bash_logout`, and `$HOME/.emacs` files back to their default values. Enter **y** at the prompt to confirm.

    ```bash
    $ <copy>csreset --all</copy>
    ```

3. Change to the `/usr/lib64/java-oci-sdk` directory and list its contents.

    ```text
    $ <copy>cd /usr/lib64/java-oci-sdk</copy>
    $ <copy>ls</copy>

    addons  apidocs  buildTools  CHANGELOG.md  CONTRIBUTING.md  examples  lib  LICENSE.txt  NOTICE.txt  README.md  shaded  third-party  THIRD_PARTY_LICENSES.txt
    ```

4. Make note that the OCI jar file is located in: `/usr/lib64/java-oci-sdk/lib/oci-java-sdk-full-3.2.1.jar`, and third-party libraries are in `/usr/lib64/java-oci-sdk/third-party/lib`.

5. Change to the `examples` directory and list its content. Notice that there is a `DataSafeRestAPIClientExample.java` file. Using Oracle Data Safe REST API commands, this Java program copies audit data from a specified compartment to a specified bucket in object storage. 

    ```text
    $ <copy>cd examples</copy>
    $ <copy>ls</copy>

    ...
    DataSafeRestAPIClientExample.java
    ...
    ```

6. Open `DataSafeRestAPIClientExample.java` and examine the code. The steps in the program are as follows:

    - Periodic auditEvents rest api invocation 
    - Upload auditEvents to Objectstore
    - Upload lastEvent cursor

    ```text
    $ <copy>cat DataSafeRestAPIClientExample.java</copy>
    ```



## Task 5: Configure the SDK

Oracle Cloud Infrastructure SDKs require basic configuration information, like user credentials and tenancy OCID. In this task, you provide this information by using a configuration file.

1. Create a directory named `.oci`, give yourself `read/write/execute` permissions on it, and then switch to it.

    ```bash
    $ <copy>mkdir ~/.oci</copy>
    $ <copy>chmod 777 ~/.oci</copy>
    $ <copy>cd ~/.oci</copy>
   ```

2. In the upper-right corner of the Oracle Cloud Infrastructure Console, click the **Profile** icon, and then click your username.

3. On the left, click **API Keys**.

4. Click **Add API Key**.

    The **Add API Key** dialog box is displayed.

5. Leave **Generate API Key Pair** selected, click **Download Private Key**, and save your key to a local directory on your computer. 

6. Click **Add**.

    The **Configuration File Preview** dialog box is displayed showing you a preview of the configuration file.

7. Copy the configuration file contents to a temporary local text file. Be sure to include `[DEFAULT]`. It should look similar to this:

    ```text
    [DEFAULT]
    user=ocid1.user.oc1...
    fingerprint=ff:35...
    tenancy=ocid1.tenancy.oc1...
    region=eu-frankfurt-1
    key_file=<path to your private keyfile> # TODO
    ```

8. Click **Close**.

    The new API key is listed under **API Keys**.

9. Return to Cloud Shell.

10. In Cloud Shell in the upper-right corner, click the **Cloud Shell Menu** icon, and select **Upload**.

    The **File Upload to your Home Directory** dialog box is displayed.

11. Drag your private key file to the dialog box, and click **Upload**. 

    Your file is uploaded to your home directory.

12. To close the **File Transfers** dialog box, click **Hide**.

13. Move your private key file to the `~/.oci` directory. In the example below, replace `your-private-key-file.pem` with your own private key file name.

    ```bash
    $ <copy>mv ~/your-private-key-file.pem ~/.oci/your-private-key-file.pem</copy>
    ```

14. Create a configuration file in the `~/.oci` directory using the vi editor.

    ```bash
    $ <copy>vi config</copy>
    ```

15. Paste the configuration file contents into the `config` file. The content should look similar to the following code.

    ```text
    [DEFAULT]
    user=ocid1.user.oc1...
    fingerprint=ff:35...
    tenancy=ocid1.tenancy.oc1...
    region=eu-frankfurt-1
    key_file=<path to your private keyfile> # TODO
    ```

16. Modify the last line to be the path to your private key file. In the example below, substitute `your-private-key-file.pem` with your own private key file name. 

    ```text
    $ <copy>key_file=~/.oci/your-private-key-file.pem</copy>
    ```

17. Save and close (press **Escape**, and then enter **:wq**).


## Task 6: Compile the Java file

The name of the Java file that you compile in this task is `DataSafeRestAPIClientExample.java`. Use the `javac` command to compile the file. The following two variables are already set in Cloud Shell. You can use these when compiling and running the Java program.

- `$OCI_JAVA_SDK_LOCATION` = `/usr/lib64/java-oci-sdk`
- `$OCI_JAVA_SDK_FULL_JAR_LOCATION` = `/usr/lib64/java-oci-sdk/lib/oci-java-sdk-full-3.2.1.jar`


1. Copy `DataSafeRestAPIClientExample.java` to your current directory (`~/.oci`).

    ```text
    $ <copy>cp $OCI_JAVA_SDK_LOCATION/examples/DataSafeRestAPIClientExample.java .</copy>
    ```

2. (Temporary fix) Open the file in the vi editor and replace the contents with the following code.

    ```
    $ <copy>vi DataSafeRestAPIClientExample.java</copy>

    /**
     * Copyright (c) 2016, 2023, Oracle and/or its affiliates.  All rights reserved.
     * This software is dual-licensed to you under the Universal Permissive License (UPL) 1.0 as shown at https://oss.oracle.com/licenses/upl or Apache License 2.0 as shown at http://www.apache.org/licenses/LICENSE-2.0. You may choose either license.
    */
    import java.io.BufferedReader;
    import java.io.ByteArrayInputStream;

    import java.io.InputStreamReader;
    import java.nio.charset.StandardCharsets;
    import java.text.DateFormat;
    import java.text.SimpleDateFormat;
    import java.time.Instant;

    import java.util.Calendar;
    import java.util.Date;
    import java.util.HashMap;
    import java.util.Map;
    import java.util.concurrent.atomic.AtomicBoolean;
    import java.util.stream.Collectors;

    import com.fasterxml.jackson.core.JsonProcessingException;

    import com.fasterxml.jackson.databind.ObjectMapper;

    import com.oracle.bmc.ConfigFileReader;
    import com.oracle.bmc.Region;

    import com.oracle.bmc.auth.ConfigFileAuthenticationDetailsProvider;
    import com.oracle.bmc.datasafe.DataSafeClient;
    import com.oracle.bmc.datasafe.model.AuditEventSummary;
    import com.oracle.bmc.datasafe.requests.ListAuditEventsRequest;
    import com.oracle.bmc.datasafe.responses.ListAuditEventsResponse;
    import com.oracle.bmc.objectstorage.ObjectStorage;
    import com.oracle.bmc.objectstorage.ObjectStorageClient;
    import com.oracle.bmc.objectstorage.requests.GetNamespaceRequest;
    import com.oracle.bmc.objectstorage.requests.GetObjectRequest;
    import com.oracle.bmc.objectstorage.requests.PutObjectRequest;
    import com.oracle.bmc.objectstorage.responses.GetObjectResponse;
    import com.oracle.bmc.objectstorage.transfer.UploadConfiguration;
    import com.oracle.bmc.objectstorage.transfer.UploadManager;

    public class DataSafeRestAPIClientExample {
        /**
        * The entry point for the example.
        *
        * @param args Arguments to provide to the example. The following arguments are expected:
        *     <ul>
        *       <li>The first is the name of bucket where auditEvents from DataSafe will be copied
        *       <li>The second argument is the OCID of the compartment only auditEvents in specified
        *           compartment OCID and its subcompartments for which the user has INSPECT permissions
        *           directly or indirectly
        *     </ul>
        */
        String configurationFilePath = "~/.oci/config";

        String profile = "DEFAULT";

        public static void main(String[] args) throws Exception {
            if (args.length != 2) {
                throw new IllegalArgumentException(
                        "Unexpected number of arguments received. Consult the script header comments for expected arguments");
            }
            String bucketName = args[0];
            String compartmentId = args[1];

            /**
            * Configuring the AuthenticationDetailsProvider. It's assuming there is a default OCI
            * config file "~/.oci/config", and a profile in that config with the name "DEFAULT". Make
            * changes to the following line if needed and use ConfigFileReader.parse(CONFIG_LOCATION,
            * CONFIG_PROFILE);
            */
            final ConfigFileReader.ConfigFile configFile = ConfigFileReader.parseDefault();

            final ConfigFileAuthenticationDetailsProvider provider =
                    new ConfigFileAuthenticationDetailsProvider(configFile);

            
        ObjectStorageClient objStoreClient =
                        ObjectStorageClient.builder().build(provider);

            objStoreClient.setRegion(Region.EU_FRANKFURT_1);
            System.out.println("Getting the namespace\n\n");
            com.oracle.bmc.objectstorage.responses.GetNamespaceResponse namespaceResponse =
                    objStoreClient.getNamespace(GetNamespaceRequest.builder().build());
            String namespaceName = namespaceResponse.getValue();

            System.out.println("Namespace: " + namespaceName + "\n\n"); // its tenancy name
            /* Get the cursor object */

            GetObjectRequest gor =
                    GetObjectRequest.builder()
                            .namespaceName(namespaceName)
                            .bucketName(bucketName)
                            .objectName("cursor")
                            .build();
            System.out.println(
                    "Getting content for object cursor " + " from bucket: " + bucketName + "\n\n");

            String result = "FAILED";

            try {
                GetObjectResponse response = objStoreClient.getObject(gor);
                result =
                        new BufferedReader(new InputStreamReader(response.getInputStream()))
                                .lines()
                                .collect(Collectors.joining("\n"));
            } catch (com.oracle.bmc.model.BmcException e) {
                System.out.println("ignore");
            }
            System.out.println(
                    "Finished reading content for object cursor, last upload's last auditEvent record's timecollected "
                            + result
                            + "\n\n");

            DataSafeClient datasafeClient =
                        DataSafeClient.builder().build(provider);

            ListAuditEventsResponse eventList = null;

            long count = 0;
            DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
            String endDate = dateFormat.format(Date.from(Instant.now()));
            String strDate = null;
            /*
            * when no prev data is uploaded we start pushing from 1 day before collected
            * data
            */
            if (result.equals("FAILED")) {

                Calendar cal = Calendar.getInstance();
                cal.add(Calendar.DATE, -1);
                Date OnedayBefore = cal.getTime();

                strDate = dateFormat.format(OnedayBefore);
                System.out.println(strDate);

                eventList =
                        datasafeClient.listAuditEvents(
                                ListAuditEventsRequest.builder()
                                        .compartmentId(compartmentId)
                                        .compartmentIdInSubtree(true)
                                        .accessLevel(ListAuditEventsRequest.AccessLevel.Accessible)
                                        .limit(10000)
                                        .scimQuery(
                                                "(timeCollected gt \""
                                                        + strDate
                                                        + "\") and (timeCollected le \""
                                                        + endDate
                                                        + "\")")
                                        .sortOrder(ListAuditEventsRequest.SortOrder.Asc)
                                        .sortBy(ListAuditEventsRequest.SortBy.TimeCollected)
                                        .build());

            } else {
                Date date = dateFormat.parse(result);
                strDate = dateFormat.format(date);
                eventList =
                        datasafeClient.listAuditEvents(
                                ListAuditEventsRequest.builder()
                                        .compartmentId(compartmentId)
                                        .compartmentIdInSubtree(true)
                                        .accessLevel(ListAuditEventsRequest.AccessLevel.Accessible)
                                        .limit(10000)
                                        .scimQuery(
                                                "(timeCollected gt \""
                                                        + strDate
                                                        + "\") and (timeCollected le \""
                                                        + endDate
                                                        + "\")")
                                        .build());
            }
            System.out.println(
                    "Querying for auditEvents with timeCollected Start = "
                            + strDate
                            + ", End = "
                            + endDate
                            + "\n\n");

            System.out.println(
                    "Count" + eventList.getAuditEventCollection().getItems().size() + "\n\n");
            if (eventList.getAuditEventCollection().getItems().size() > 0) {
                ObjectMapper mapper = com.oracle.bmc.http.client.Serialization.getObjectMapper();
                StringBuffer sb = new StringBuffer();
                AtomicBoolean isFirst = new AtomicBoolean(true);
                count = eventList.getAuditEventCollection().getItems().size();
                eventList
                        .getAuditEventCollection()
                        .getItems()
                        .forEach(
                                it -> {
                                    try {
                                        if (isFirst.get()) {
                                            isFirst.set(false);
                                        } else {
                                            sb.append("\n");
                                        }
                                        sb.append(mapper.writeValueAsString(it));

                                    } catch (JsonProcessingException e) {
                                        e.printStackTrace();
                                    }
                                });
                if (count > 0)
                    uploadtoOS(
                            "auditeventjson"
                                    + Instant.now()
                                    + " _noofrecords_ "
                                    + count
                                    + " Start ="
                                    + strDate
                                    + ", End="
                                    + endDate,
                            sb.toString(),
                            bucketName,
                            namespaceName);
            }
            if (count >= 1) {
                AuditEventSummary lastrecord =
                        eventList.getAuditEventCollection().getItems().get((int) (count - 1));
                // upload the lastrecord's timecollected so that we start the next run's push to
                // after that
                uploadtoOS(
                        "cursor",
                        dateFormat.format(lastrecord.getTimeCollected()),
                        bucketName,
                        namespaceName);
            }
            objStoreClient.close();
            datasafeClient.close();
        }

        private static void uploadtoOS(
                String fileName, String value, String bucketName, String namespaceName)
                throws Exception {
            final ConfigFileReader.ConfigFile configFile = ConfigFileReader.parseDefault();

            final ConfigFileAuthenticationDetailsProvider provider =
                    new ConfigFileAuthenticationDetailsProvider(configFile);
            
        ObjectStorageClient client =
                                ObjectStorageClient.builder().build(provider);

            client.setRegion(Region.EU_FRANKFURT_1);
            byte[] byteVal = value.getBytes(StandardCharsets.UTF_8);

            UploadConfiguration uploadConfiguration =
                    UploadConfiguration.builder()
                            .allowMultipartUploads(false)
                            .allowParallelUploads(true)
                            .build();
            UploadManager uploadManager = new UploadManager(client, uploadConfiguration);

            Map<String, String> metaData = new HashMap<>();
            metaData.put("RequestId", "datasafeAuditEvents" + Instant.now());
            PutObjectRequest request =
                    PutObjectRequest.builder()
                            .opcMeta(metaData)
                            .bucketName(bucketName)
                            .namespaceName(namespaceName)
                            .objectName(fileName)
                            .contentType("text/plain")
                            .contentLanguage("en")
                            .contentEncoding("utf-8")
                            .build();

            UploadManager.UploadRequest uploadDetails =
                    UploadManager.UploadRequest.builder(
                                    new ByteArrayInputStream(byteVal), byteVal.length)
                            .allowOverwrite(true)
                            .build(request);
            UploadManager.UploadResponse response = uploadManager.upload(uploadDetails);
            System.out.println(
                    "Upload complete at  "
                            + new Date()
                            + " of "
                            + fileName
                            + "  OpcRequestId: "
                            + response.getOpcRequestId()
                            + "\n\n");
        }
    }
    ```

    Note: Fixes applied to the original file include:
    - Line 77: `ObjectStorage objStoreClient = new ObjectStorageClient(provider);` is replaced with `ObjectStorageClient objStoreClient = ObjectStorageClient.builder().build(provider);`
    - Line 112: `DataSafeClient datasafeClient = new DataSafeClient(provider);` is replaced with `DataSafeClient datasafeClient = DataSafeClient.builder().build(provider);`
    - Line 235: `ObjectStorage client = new ObjectStorageClient(provider);` is replaced with `ObjectStorageClient client = ObjectStorageClient.builder().build(provider);`

3. From the `~/.oci` directory, compile `DataSafeRestAPIClientExample.java`.

    ```text
    $ <copy>javac -cp $OCI_JAVA_SDK_FULL_JAR_LOCATION:$OCI_JAVA_SDK_LOCATION/third-party/lib/* DataSafeRestAPIClientExample.java</copy>
    ```


## Task 7: Obtain the compartment OCID for your target database

1. From the navigation menu, select **Oracle Database**, and then **Autonomous Transaction Processing**. 

2. Under **List scope** on the left, make sure that your compartment is selected. 

3. On the right, click the name of your database. On the **Autonomous Database information** tab, find the compartment information. 

4. From the navigation menu, select **Identity and Security**, and then on the right under **Identity**, select **Compartments**. 

5. Click the name of your compartment.

    The **Compartment details** page is displayed.

6. On the **Compartment Information** tab, click the **Copy** link next to **OCID** and paste the OCID into a temporary local text file. You need the OCID for the next task.


## Task 8: Run the compiled Java file


1. Return to Cloud Shell and run the following commands to set two variables. In the example below, replace `your-compartment-ocid` with the compartment OCID for your target database.

    ```bash
    $ <copy>export BUCKET=DataSafeAuditData</copy>
    $ <copy>export COMPARTMENT=your-compartment-ocid</copy>
    ```

2. Run `DataSafeRestAPIClientExample.class`. You can ignore the error about failing to load the `org.slf4j.impl.StaticLoggerBinder` class. Review the output. One of the lines tells you the count of audit records copied into object storage.

    ```text
    $ <copy>java -cp $OCI_JAVA_SDK_FULL_JAR_LOCATION:$OCI_JAVA_SDK_LOCATION/third-party/lib/*:$OCI_JAVA_SDK_LOCATION/third-party/jersey/lib/*:$OCI_JAVA_SDK_LOCATION/lib/jersey/oci-java-sdk-common-httpclient-jersey-3.2.1.jar:$OCI_JAVA_SDK_LOCATION/third-party/lib/slf4j-api-1.7.33.jar:$HOME/.oci DataSafeRestAPIClientExample $BUCKET $COMPARTMENT</copy>

    SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".
    SLF4J: Defaulting to no-operation (NOP) logger implementation
    SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details.
    Getting the namespace


    Namespace: frmwj0cqbupb


    Getting content for object cursor  from bucket: Test


    ignore
    Finished reading content for object cursor, last upload's last auditEvent record's timecollected FAILED


    2023-01-25T01:03:57.410Z
    Querying for auditEvents with timeCollected Start = 2023-01-25T01:03:57.410Z, End = 2023-01-26T01:03:57.410Z


    Countx


    Upload complete at  Thu Jan 26 01:03:59 UTC 2023 of auditeventjson2023-01-26T01:03:58.877047Z _noofrecords_x Start =2023-01-25T01:03:57.410Z, End=2023-01-26T01:03:57.410Z  OpcRequestId: fra-1:i53...


    Upload complete at  Thu Jan 26 01:03:59 UTC 2023 of cursor  OpcRequestId: fra-1:97Q...
    ```


## Task 9: Verify that the audit data is copied to your bucket

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
- [Oracle Data Safe API Reference and Endpoints](https://docs.oracle.com/en-us/iaas/api/#/en/data-safe/20181201/)
- [Oracle Cloud Infrastructure Java SDK Packages and Classes](https://docs.oracle.com/en-us/iaas/tools/java/3.2.2/)
- [Data Safe API](https://docs.oracle.com/en-us/iaas/api/#/en/data-safe/20181201/)

## Acknowledgements
- **Author** - Jody Glover, Consulting User Assistance Developer, Database 
- **Consultants** - Richard Evans, Anna Haikl, Archana Rao
- **Last Updated By/Date** - Jody Glover, January 25, 2023



































