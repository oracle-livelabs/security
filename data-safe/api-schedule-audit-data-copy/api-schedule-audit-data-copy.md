# Schedule the Copying of Audit Data to Object Storage using the Oracle Data Safe REST API

## Introduction

When you start your target database's audit trail in Oracle Data Safe, Oracle Data Safe begins copying audit records from the database's audit trail into the Oracle Data Safe repository. In this lab, you use the Oracle Data Safe application programming interface (API) and crontab on a compute instance to schedule the copying of Oracle Data Safe's audit data for your target database into object storage. 

Estimated Lab Time: 30 minutes

### Objectives

In this lab, you will:

- Create a bucket in your compartment
- Start the audit trail for your target database in Oracle Data Safe
- View the quantity of audit data collected by Oracle Data Safe
- Create SSH keys in Cloud Shell
- Create a virtual cloud network (VCN)
- Create a compute instance using the Oracle Linux Cloud Developer 8 image
- Connect to your compute instance from Cloud Shell
- Create an API key
- Upload your PEM file to your compute instance
- Create a configuration file
- Compile the Java program
- Run the compiled Java class file
- Verify that the audit data is in your bucket
- Create an SH script for cronjob
- Schedule the SH script using crontab
- Remove the scheduled activity in crontab


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console
- Prepared your environment for this workshop (see [Prepare Your Environment](?lab=prepare-environment))
- Registered your target database with Oracle Data Safe (see [Register an Autonomous Database with Oracle Data Safe](?lab=register-autonomous-database))



## Task 1: Create a bucket in your compartment

Create a bucket to store your audit data. You also use the bucket to transfer a PEM file to a compute instance in a later task.

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


## Task 4: Create SSH keys in Cloud Shell

Create an SSH key pair that you can use to connect to your compute instance. The standard name is `cloudshellkey`.

1. Open Cloud Shell. When you first open Cloud Shell, you are in your home directory; for example, `/home/jody_glove`.`

2. (Optional) Reset your Cloud Shell environment. The following command erases all the data in your `$HOME` directory on your Cloud Shell machine and resets the `$HOME/.bashrc`, `$HOME/.bash_profile`, `$HOME/.bash_logout`, and `$HOME/.emacs` files back to their default values.

    ```
    $ <copy>csreset --all</copy>
    ```

3. Create a `.ssh` directory in your home directory on your Cloud Shell machine.

    ```
    $ <copy>mkdir ~/.ssh</copy>
    ```

4. Change to the `.ssh` directory.

    ```
    $ <copy>cd ~/.ssh</copy>
    ```

5. To verify which directory you are currently working in, enter the following command.

    ```
    $ <copy>pwd</copy>
    
    /home/your-user-name/.ssh
    ```

6. While you are in the `.ssh` directory, generate an SSH key pair. The following command generates two keys: a private key named `cloudshellkey` and a public key named `cloudshellkey.pub`. Please use the `cloudshellkey` naming convention as it is a LiveLabs standard. When prompted to enter a passphrase, simply click **Enter** twice to not enter a passphrase.

    ```
    $ <copy>ssh-keygen -b 2048 -t rsa -f cloudshellkey</copy>
    ```

7. Confirm the private key and public key files exist in the `.ssh` directory.

    ```
    $ <copy>ls</copy>

    cloudshellkey cloudshellkey.pub
    ``` 



8. Show the contents of the public key. Later, you copy this to the clipboard and paste it into the SSH keys box when creating the compute instance.

    ```
    $ <copy>cat cloudshellkey.pub</copy>
    ```
 
9. Leave Cloud Shell open.


## Task 5: Create a virtual cloud network (VCN)

1. From the navigation menu in OCI, select **Networking**, and then **Virtual Cloud Networks**.

2. Select your compartment.

3. Click **Create VCN**.

4. For **Name**, enter **labVCN**.

5. Select your compartment. 

6. For **IPV4 CIDR Block**, enter **10.0.0.0/24**.

7. Leave the **USE DNS HOSTNAMES IN THIS VCN** check box selected.

8. For **DNS label**, enter **labvcn**.

9. Click **Create VCN**.

10. Click **Create Subnet**.

11. For name, enter **lab-public-subnet1**.

12. Select your compartment.

13. For subnet type, leave **Regional** selected.

14. For **CIDR block**, enter **10.0.0.0/24**.

15. For subnet access, leave **Public Subnet** selected.

16. Leave the **USE DNS HOSTNAMES IN THIS SUBNET** check box selected.

17. For **DNS label**, enter **subnet1**.

18. Click **Create Subnet**.

19. On the left, click **Internet Gateways**.

20. Click **Create Internet Gateway**. The **Create Internet Gateway** dialog box is displayed.

21. For name, enter **livelabs-igw**.

22. Select your compartment.

23. Click **Create Internet Gateway**.

24. On the left, click **Route Tables**.

25. In the list of route tables, click **Default Route Table for labVCN**.

26. Click **Add Route Rules**.

    The **Add Route Rules** dialog box is displayed.

27. For target type, select **Internet Gateway**.

28. For destination CIDR block, enter **0.0.0.0/0**.

29. For target internet gateway, select **livelabs-igw**.

30. Click **Add Route Rules**.


## Task 6: Create a compute instance using the Oracle Linux Cloud Developer 8 image

The Oracle Linux Cloud Developer Image is supported on all Compute shapes, except the GPU shapes. A minimum of 8 GB of memory is required for this image for all standard and flexible shapes. The one exception is the VM.Standard.E2.1.Micro shape, which only has 1 GB of memory allocated to it. Because of the small memory size in the VM.Standard.E2.1.Micro shape, some graphical intensive programs are not installed in the image. 

1. From the navigation menu for Oracle Cloud Infrastructure, select **Compute**, and then **Instances**.

2. Select your compartment, for example, **DataSafeAuditData**.

3. Click **Create instance**.

4. Enter a name for your compute instance, for example, **MyCompute**.

5. Leave placement as is.

6. In the **Image and shape** section, click **Edit**. 

7. Click **Change image**. For image source, select **Platform images**. In the **Image name** column, select **Oracle Linux Cloud Developer**. Select the **I have reviewed and accept the following documents: Oracle LInux Cloud Developer Image Terms of Use** check box. Click **Select image**.

8. Click **Change shape**. Select the **Ampere** shape series. Select the **VM.Standard.A1.Flex** image selected. Scroll down and enter **8** GB of memory. Click **Select Shape**. 

9. For networking, click **Edit**, leave **Select existing virtual cloud network** selected. For **Virtual cloud network in <your compartment>**, select **labVCN**. For **Subnet in <your compartment>**, select **lab-public-subnet1**. For **Public IP Address**, leave **Assign a public IPv4 address** selected.

10. For SSH keys, select **Paste public keys**. Return to Cloud Shell and copy the entire SSH public key to the clipboard. It starts with `ssh-rsa` and ends with something similar to `jody_glove@1e3ebc618797`. In the SSH keys box, paste your public key. Make sure that there are no hard returns. You can run cat `.ssh/cloudshellkey.pub` to get the public key.

11. In the Boot volume section, leave the defaults as is.

12. Click **Create**. Your compute instance is provisioned in less than a minute and its page is displayed.


## Task 7: Connect to your compute instance from Cloud Shell

1. If you've navigated away from your compute instance page, you can find it again by doing this: From the navigation menu in Oracle Cloud Infrastructure, select **Compute**, and then **Instances**. Select your compartment. Click the name of your compute instance.

2. On the **Instance Information** tab under **Instance Access**, copy the public IP address to the clipboard.

3. In Cloud Shell, enter the following `SSH` command to connect to your compute instance, replacing `public-ip-address` with the one you just copied to the clipboard.

    ```
    $ <copy>ssh -i ~/.ssh/cloudshellkey opc@public-ip-address</copy>
    ```

    You receive a message stating that the authenticity of your compute instance can't be established. Do you want to continue connecting?


4. Enter **yes** to continue.

    The public IP address of your compute instance is added to the list of known hosts on your Cloud Shell machine. The terminal prompt becomes [opc@<your-compute-name> ~]$, where opc is your user account on your compute instance. You are now connected to your new compute instance.


## Task 8: Create an API key

There are three parts to configuring the SDK: create an API key, create a configuration file, and upload a PEM file to your compute instance. To use the SDK for Java, you must have a key pair used for signing API requests, with the public key uploaded to Oracle. Only the user calling the API should be in possession of the private key.


1. Begin by creating an API key. In the upper-right corner of the Oracle Cloud Infrastructure Console, click the **Profile** icon, and then click your username.

2. On the left, click **API Keys**.

3. Click **Add API Key**.

    The **Add API Key** dialog box is displayed.

4. Leave **Generate API Key Pair** selected, click **Download Private Key**, and save your key (PEM file) to a local directory on your computer. 

5. Click **Add**.

    The **Configuration File Preview** dialog box is displayed. This dialog shows you a preview of the configuration file.

6. Copy the configuration file contents to a temporary text file. You will need it later. It content looks similar to this:

    ```
    [DEFAULT]
    user=ocid1.user.oc1...
    fingerprint=your-fingerprint
    tenancy=ocid1.tenancy.oc1...
    region=eu-frankfurt-1
    key_file=<path to your private keyfile> # TODO
    ```

6. Click **Close**.

7. In Cloud Shell, switch to the root user. and make an `.oci` directory.

    ```
    $ <copy>sudo su -</copy>
    ```

8. Create an `.oci` directory.

    ```
    # <copy>mkdir ~/.oci</copy>
    ```

## Task 9: Upload your PEM file to your compute instance

Upload your PEM file into object storage, and then copy it to your compute instance.

1. From the navigation menu in Oracle Cloud Infrastructure, select **Storage**, and then **Buckets**. Select your compartment, for example, **DataSafeAuditData**. Click the name of your bucket.
   
    The **Bucket Details** page is displayed.

2. Scroll down to the **Objects** section and click **Upload**.

    The **Upload Objects** panel is displayed.

3. Drag your private key file to the **Choose Files from your Computer** area, and click **Upload**.

4. Click **Close**.

5. At the end of the row for your PEM file listing, click the 3 dots, and then select **Create Pre-Authenticated Request**. 

    The **Create Pre-Authenticated Request** panel is displayed.

6. Click **Create Pre-Authenticated Request**.

    The **Pre-Authenticated Request Details** dialog box is displayed.

7. Copy the **Pre-Authenticated Request URL** to the clipboard and paste into a temporary local text file. *IMPORTANT: * You will not be able to view this URL again after you close the dialog box.

8. Click **Close**.

9. In Cloud Shell, change to the `.oci` directory.

    ```
    # <copy>cd ~/.oci</copy>
    ```

10. Use the `WGET` command to copy your PEM file from object storage into the .oci directory. 

    ```
    # <copy>wget full-url-to-PEM-file</copy>
    ```

11. List the contents of the directory to ensure the file is present.

    ```
    # <copy>ls</copy>
    ```

## Task 10: Create a configuration file

In this task, you create a configuration file named `config` in the `oci` directory for the SDK, and then add the API content that you obtained from the API key (which you created in a previous task). Correct the last line by adding the actual path to your PEM file on your compute instance. The java file that you compile in a subsequent step assumes that there is a default OCI config file (`~/.oci/config`) and a profile defined in that file called `DEFAULT`.

1. Using the vi editor and while you are still in the `.oci` directory, create a configuration file.

    ```
    # <copy>vi config</copy>
    ```

2. Paste the configuration file contents (earlier you pasted this content into a temporary text file) into the `config` file. The content looks similar to this:

   ```
    [DEFAULT]
    user=ocid1.user.oc1...
    fingerprint=your-fingerprint
    tenancy=ocid1.tenancy.oc1...
    region=eu-frankfurt-1
    key_file=<path to your private keyfile> # TODO
    ```

4. Modify the last line to be the path to your PEM file on your compute instance. In the example below, substitute `your-PEM-file-name` with your own PEM file name.

    ```
    <copy>key_file=~/.oci/your-PEM-file-name</copy>
    ```

5. Save and close the file (press **Escape**, enter **:wq**, and press **Return**).

6. List the contents of the current directory and ensure that your config file is there.

    ```
    # <copy>ls</copy>
    ```


## Task 11: Compile the Java program

The Oracle Linux Cloud Developer image comes with the SDK and Java software already installed. The SDK provides several example files, including a java program containing Oracle Data Safe REST API commands. This file is called `DataSafeRestAPIClientExample.java` and resides in the `/usr/lib64/java-oci-sdk/examples` directory on your compute instance. The purpose of the java file is to copy audit data from the Oracle Data Safe repository into object storage. You can also download this file from GitHub: wget https://raw.githubusercontent.com/oracle/oci-java-sdk/master/bmc-examples/src/main/java/DataSafeRestAPIClientExample.java.

The OCI jar file is located in `/usr/lib64/java-oci-sdk/lib/oci-java-sdk-full-<version>.jar`, and third-party libraries are in `/usr/lib64/java-oci-sdk/third-party/lib`. To compile the java file, you can use the `javac` command.

1. Switch to the `/usr/lib64/java-oci-sdk/examples` directory and list its content. 

    ```
    # <copy>cd /usr/lib64/java-oci-sdk/examples
    # ls</copy>
    ```


2. Review the `DataSafeRestAPIClientExample.java` file. 

    ```
    # <copy>cat DataSafeRestAPIClientExample.java</copy>
    ```

3. Verify the version of the `oci-java-sdk-full-version.jar` file. In this example, the version is 2.27.0.

    ```
    # <copy>cd /usr/lib64/java-oci-sdk/lib
    ls</copy>

    oci-java-sdk-full-2.27.0.jar  oci-java-sdk-full-2.27.0-javadoc.jar  oci-java-sdk-full-2.27.0-sources.jar
    ```

4. Switch to the `/usr/lib64/java-oci-sdk` directory.

    ```
    # <copy>cd /usr/lib64/java-oci-sdk</copy>
    ```

5. Compile the file. Be sure to use the correct version in the `oci-java-sdk-full-version.jar` file. It’s very common that a Java program depends on one or more external libraries (JAR files). Use the flag `-classpath` (or `cp`) to tell the compiler where to look for external libraries. By default, the compiler looks in bootstrap classpath and in the `CLASSPATH` environment variable.

    ```
    # <copy>javac -cp lib/oci-java-sdk-full-2.27.0.jar:third-party/lib/* examples/DataSafeRestAPIClientExample.java</copy>
    ```

    Note: There is no output after the file is compiled. You are simply returned to the prompt.


6. List the files in the `examples` directory and confirm that you now have a class file named `DataSafeRestAPIClientExample.class`.

    ```
    # <copy>ls</copy>
    ```

## Task 12: Run the compiled Java class file

Run the `DataSafeRestAPIClientExample.class` file to test that it runs without errors before you schedule it. The program requires two inputs, which you can define upfront:

- The name of the bucket in which to store the copied audit data
- The compartment OCID of your target database

1. Run the following commands to set two variables. Substitute `compartment-ocid-for-target-database` with your own OCID.

    ```
    # <copy>export BUCKET=DataSafeAuditDataBucket
    export COMPARTMENT=compartment-ocid-for-target-database</copy>
    ```

2. Make sure that you are still in the `/usr/lib64/java-oci-sdk/lib/examples` directory.

3. Run the following command to run the class file.

    ```
    # <copy>java -cp examples:lib/oci-java-sdk-full-2.27.0.jar:third-party/lib/* DataSafeRestAPIClientExample $BUCKET $COMPARTMENT</copy>
    ```

## Task 13: Verify that the audit data is in your bucket

1. From the navigation menu in OCI, select **Storage**, and then **Buckets**.

2. Select your compartment.

3. Click the name of your bucket, for exmaple, **DataSafeAuditData**.

    The **Bucket Details** page for your bucket is displayed.

4. Scroll down to the **Objects** section.

5. Notice that you now have a line item named `auditeventjson` that contains the text `noofrecords_<some-number>`. This is the audit data copied from the Oracle Data Safe repository. `<some-number>` is the number of copied audit records.


## Task 14: Create an SH script for cronjob

Now that you've verified that the compiled java program works fine, you are ready to schedule it using cronjob on your compute instance. The Cron daemon is a built-in Linux utility that runs processes on your system at a scheduled time. Cron reads the crontab (cron tables) for predefined commands and scripts. You need to be the root user or a user with sudo privileges to create a cron job.

In this task, you create an SH script that contains the variables and the Java command to run the Java program. In the next task, you schedule the SH script.

1. Change to the `/usr/local/bin` directory.

    ```
    # <copy>cd /usr/local/bin</copy>
    ```

2. Using the vi editor, create the SH file.

    ```
    # <copy>vi datasafejob.sh</copy>
    ```

3. Add the following content to the SH file:

    ```
    <copy>#!/bin/bash

    export BUCKET=DataSafeAuditDataBucket

    export COMPARTMENT=ocid1.compartment.oc1..aaaaaaaaagz53obpmrdli3lcdl5u36wd6nkrbi4kpvduvyqlmm4w2krpediq

    java -cp /usr/lib64/java-oci-sdk/lib/oci-java-sdk-full-2.27.0.jar:/usr/lib64/java-oci-sdk/third-party/lib/*:/usr/lib64/java-oci-sdk/examples DataSafeRestAPIClientExample $BUCKET $COMPARTMENT</copy>
    ```

    Note: Notice that we used a slightly different Java command in this step than in a previous task. To execute the class file from anywhere, we need to include the path to the `examples` directory in the class path.

4. Save and close the file (press **Escape**, enter **:wq**, and press **Return**).

5. Add permissions to the script.

    ```
    # <copy>chmod 777 datasafejob.sh</copy>
    ```

## Task 15: Schedule the SH script using crontab

Start by scheduling the SH script to run every minute so that you can test that the scheduling works. After confirming, change the schedule to be at 2AM every day.

1. To edit the cron job, enter the following command:

    ```
    # <copy>crontab -e</copy>
    ```

2. Test that scheduling works by running the script every minute. Add the following to the first line and then save (press **Escape**, enter **:wq**, and press **Return**):


    ```
    <copy>* * * * * /usr/local/bin/datasafejob.sh</copy>
    ```

3. Generate some activity for Data Safe to audit. To do this, access Database Actions for your target database. Download the `load-data-safe-sample-data_admin.sql` script and open it in a text editor, such as NotePad. Copy the entire script to the clipboard and paste it into the worksheet in Database Actions. On the toolbar, click the **Run Script** button and wait for the script to finish running.


4. Return to your bucket and view the audit data being collected each minute.

5. In Cloud Shell, access crontab.

    ```
    # <copy>crontab -e</copy>
    ```

6. Change the schedule to be at 2AM every day and then save the file (press **Escape**, enter **:wq**, and press **Return**). 

    In the example below, the 02*** indicates that the cron job runs any time the system clock shows 2am.  7**** indicates the cron job initiates every time the system clock shows 7 in the minutes position. 

    ```
    <copy>0 2 * * * /usr/local/bin/datasafejob.sh</copy>
    ```


## Task 16: Remove the scheduled activity in crontab

1. Access crontab.

    ```
    # <copy>crontab -e</copy>
    ```

2. Delete the content.

3. Save your changes (press **Escape**, enter **:wq**, and press **Return**).


## Learn More
- [Activity Auditing Overview](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=UDSCS-GUID-741E8CFE-041E-46C4-9C04-D849573A4DB7)
- [Audit Trails](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=UDSCS-GUID-8E684604-879A-4312-8FF6-519ECD67D179)
- [Oracle Linux Cloud Developer Image](https://docs.oracle.com/en-us/iaas/oracle-linux/developer/index.htm)
- [Configuring the SDK](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/javasdk.htm)
- [Oracle Data Safe Command Line Reference](https://docs.oracle.com/en-us/iaas/tools/oci-cli/3.22.2/oci_cli_docs/cmdref/data-safe.html)
- [Oracle Data Safe API Reference and Endpoints](https://docs.oracle.com/en-us/iaas/api/#/en/data-safe/20181201/)



## Acknowledgements
- **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Contributors** - Richard Evans, Anna Haikl, Russ Lowenthal, Archana Rao
- **Last Updated By/Date** - Jody Glover, January 22, 2023





