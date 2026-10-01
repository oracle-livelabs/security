# Download the latest security assessment by using the Oracle Data Safe CLI

[comment]: <> (A policy is required to access Cloud Shell)

## Introduction

 You can use the command line interface (CLI) in Cloud Shell to perform tasks in Oracle Data Safe. Cloud Shell is a small virtual machine running a Linux shell and is accessible in your tenancy in the Oracle Cloud Infrastructure Console. It's ready and free to use in your tenancy (within monthly tenancy limits). If you want to perform complex tasks using the CLI, it's useful to create an SH script that contains all of your CLI commands. 
 
 In this lab, you use the CLI to refresh the latest Security Assessment report for your target database and download the report to a directory on your Cloud Shell machine. Begin by familiarizing yourself with the command line interface (CLI) documentation for Oracle Data Safe.

Estimated Lab Time: 20 minutes

### Objectives

In this lab, you will:

- Review the documentation for the Oracle Data Safe CLI
- Access Cloud Shell
- Build and test your CLI commands one at a time
- Create an SH file with all of your CLI commands
- Run the SH file and view the security assessment report


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console
- Prepared your environment for this workshop (see [Prepare Your Environment](?lab=prepare-environment))
- Registered your target database with Oracle Data Safe (see [Register an Autonomous AI Database with Oracle Data Safe](?lab=register-autonomous-database))


## Task 1: Review the documentation for the Oracle Data Safe CLI

1. In a browser, open the [Oracle Data Safe Command Line Reference](https://docs.oracle.com/en-us/iaas/tools/oci-cli/3.22.2/oci_cli_docs/cmdref/data-safe.html).

2. Scroll down the page and review the available commands. The list is sorted based on resources:

    - alert
    - alert-policy
    - alert-summary
    - audit-archive-retrieval
    - audit-event-summary
    - audit-policy
    - ...

3. To view the description and available commands for a resource, click the resource's name.

4. To view details for a command, click the command's name. Review its description. In the **Usage** section, you are provided with sample code that you can use as a starting point. Notice its structure: It starts with `oci data-safe`, then the resource name, then the command for the resource, and then `[OPTIONS]` if any exist. Options can be required or optional. The **Required Parameters** section informs you of any parameters that you must specify in the command.  The **Optional Parameters** section describes parameters that you can add to the command, if needed. 

    For example, the `alerts-update` command is structured as follows:

    ```text
    <copy>oci data-safe alert alerts-update [OPTIONS]</copy>
    ```

5. When specifying required or optional parameters, be aware that you need to include the name of the parameter and then follow with the value. For example, to close all the alerts for a target database, you could issue the following command (substitute `your-compartment-ocid` and `your-target-database-OCID` with your own values):

    ```text
    <copy>oci data-safe alert alerts-update --compartment-id your-compartment-ocid --status CLOSED --target-id your-target-database-OCID</copy>
    ```

6. Scroll down to the end of the page to view examples. 

## Task 2: Access Cloud Shell


1. To open Cloud Shell, in the upper-right corner of the Oracle Cloud Infrastructure Console, click the **Developer tools** icon, and then select **Cloud Shell**.

2. If prompted to run a tutorial, enter **N** to skip the tutorial.

   Your current directory is your home directory; for example, `/home/jody_glove`. For this lab, we can work in the home directory (`~/`).

3. To verify your current directory, enter `pwd`.

4. (Optional) If you use Cloud Shell often and want to start fresh, you can reset it. The following command erases all the data in your `$HOME` directory on your Cloud Shell machine and resets the `$HOME/.bashrc`, `$HOME/.bash_profile`, `$HOME/.bash_logout`, and `$HOME/.emacs` files back to their default values. Enter **y** at the prompt to confirm.

    ```bash
    $ <copy>csreset --all</copy>
    ```


## Task 3: Build and test your CLI commands one at a time

Identify the commands and values that are required for the SH script and test each one in Cloud Shell.

1. Create a variable that defines your compartment OCID.

    To do this, first find your compartment OCID: From the navigation menu in Oracle Cloud Infrastructure, select **Identity & Security**, and then on the right under **Identity**, click **Compartments**. Click the name of your compartment. On the **Compartment Information** tab, click **Copy** next to **OCID**. In Cloud Shell, enter the following command, replacing `your-compartment-ocid` with your own OCID.

    ```text
    $ <copy>export compartment_id=your-compartment-ocid</copy>
    ```

2. Create a variable that defines your Oracle Data Safe target database OCID (not your Autonomous AI Database OCID!). 

    To do this, first find your target database OCID: From the navigation menu, select **Oracle AI Database**, and then **Data Safe - Database Security**. Under **Data Safe** on the left, click **Target databases**. Under **List scope** on the left, select your compartment. On the right, click the name of your target database. On the **Target database information** tab, click **Copy** next to **OCID**. In Cloud Shell, enter the following command, replacing `your-target-database-ocid` with your own OCID.

    ```text
    $ <copy>export target_id=your-target-database-ocid</copy>
    ```

3. Create a variable that defines the file name for your downloaded Security Assessment report.

    To do this, in Cloud Shell, enter the following command, replacing `your-download-file-name` with a name of your choice. Include .pdf or .xls, depending on the file format you want. Note: It is possible to specify a path; for example, `~/examples/myreport.pdf`. However, let's keep it simple and just use the home directory (so no path is required).

    ```text
    $ <copy>export file_name=your-download-file-name</copy>
    ```

4. Create a variable that defines the report format (PDF or XLS) you want for the downloaded security assessment. 

    To do this, in Cloud Shell, enter the following command, replacing `PDF-or-XLS` with **PDF** or **XLS**.

    ```text
    $ <copy>export format=PDF-or-XLS</copy>
    ```

5. Create a security assessment and obtain its OCID. 

    To do this, in Cloud Shell, enter the following command as is. Wait for the security assessment to be created (about 1 minute).

    ```text
    $ <copy>security_assessment_id=$(oci data-safe security-assessment create --compartment-id $compartment_id --target-id $target_id --query data.id --raw-output)</copy>
    ```

     Notice how we are using the `security-assessment create` CLI command with the `--query data.id` and `--raw-output` parameters. If you need to obtain metadata about a resource, you can learn which metadata values are available by including the `--query data` and `--raw-output` parameters. For example, if the above statement used `--query data` instead of `--query data.id`, the output value would include all possible key-value pairs:

     ```json
     <copy>{"compartment-id": "ocid1.compartment.oc1...", "defined-tags": { "Oracle-Tags": { "CreatedBy": "jody.glove..", "CreatedOn": "2023-01-30T20:40:53.671Z" } }, "description": null, "display-name": "SA_1675111253797", "freeform-tags": {}, "id": "ocid1.datasafesecurityassessment.oc1...", "ignored-assessment-ids": null, "ignored-targets": null, "is-baseline": false, "is-deviated-from-baseline": null, "last-compared-baseline-id": null, "lifecycle-details": null, "lifecycle-state": "CREATING", "link": null, "schedule": null, "schedule-security-assessment-id": null, "statistics": null, "system-tags": {}, "target-ids": [ "ocid1.datasafetargetdatabase.oc1..." ], "target-version": null, "time-created": "2023-01-30T20:40:53.797000+00:00", "time-updated": "2023-01-30T20:40:53.797000+00:00", "triggered-by": "USER", "type": "SAVED" }</copy>
      ```

6. Verify that the security assessment is created in Oracle Data Safe. 

    To do this, from the navigation menu, select **Oracle AI Database**, and then **Data Safe - Database Security**. Under **Data Safe** on the left, click **Security assessment**. Click the **Target summary** tab, locate the line that has your target database, and click **View report**. At the top of the latest security assessment page, click **View history**. Make sure that your compartment is selected. Find the new security assessment for your target database that was generated by the CLI command in the previous step.
    
    You should have at least two security assessments. The first one was automatically created by Oracle Data Safe when you registered your target database. The second one is the one you just created via the command line. If the second one isn't listed, you may need to wait a little longer.

7. Generate the security assessment PDF.

    Before you can download a security assessment, you must first generate it. To do this, return to Cloud Shell and enter the following command as is. Notice how we make use of the variables that we defined in earlier steps (`$format` and `$security_assessment_id`). Wait for the report to generate (about 1 minute).

    ```text
    $ <copy>oci data-safe security-assessment generate-security-assessment-report --format $format --security-assessment-id $security_assessment_id</copy>
    ```

8. Download the security assessment PDF to your home directory in Cloud Shell.

    To do this, in Cloud Shell, enter the following command as is. Notice how we make use of the variables that we defined in earlier steps (`$file_name`, `$format`, and `$security_assessment_id`). Wait for the report to download (about 1 minute).

    ```text
    $ <copy>oci data-safe security-assessment download-security-assessment-report --file $file_name --format $format --security-assessment-id $security_assessment_id</copy>
    ```

9. Verify the PDF is downloaded to your Cloud Shell machine.

    ```text
    $ <copy>ls</copy>

    your-download-file-name
    ```

10. Remove the PDF file by entering the following command. Substitute `your-download-file-name` with your own PDF file name.

    ```text
    $ <copy>rm your-download-file-name</copy>
    ```


## Task 4: Create an SH file with all of your CLI commands

Create an SH file and add all the commands that you tested in the previous task. Be sure to use your own values for the variables.

1. In Cloud Shell, open the vi editor and create a file called `example.sh`. 

    ```text
    $ <copy>vi example.sh</copy>
    ```

2. Paste all of your commands into the file. Insert two `sleep` commands - one after you create the PDF report and another after you generate it so that the program allows time for the operations to complete; otherwise, you will get errors. You can also write to the console (using `echo`) before the `sleep` commands to inform the user of the wait time.

    ```text
    <copy>export compartment_id=ocid1.compartment.oc1...
    export target_id=ocid1.datasafetargetdatabase.oc1...
    export file_name=MyLatestSecurityAssessment.pdf
    export format=PDF
    security_assessment_id=$(oci data-safe security-assessment create --compartment-id $compartment_id --target-id $target_id --query data.id --raw-output)
    echo "Waiting for 2 minutes to allow time for the latest security assessment to be refreshed."
    sleep 120
    oci data-safe security-assessment generate-security-assessment-report --format $format --security-assessment-id $security_assessment_id
    echo "Waiting for 1 minute to allow time for a PDF report to be generated."
    sleep 60
    oci data-safe security-assessment download-security-assessment-report --file $file_name --format $format --security-assessment-id $security_assessment_id</copy>
    ```

3. Save and exit the file (Press **Escape**, enter **:wq**, and press **Enter**).

4. Grant permissions on the file.

    ```text
    $ <copy>chmod 777 example.sh</copy>
    ```



## Task 5: Run the SH file and view the security assessment report

When you run the SH file, the latest security assessment is downloaded to your Cloud Shell machine. From there, you can download it to your local computer for viewing.

1. Enter the following command to run the SH file. Wait for three minutes for the script to run.

    ```text
    $ <copy>./example.sh</copy>
    ```
2. If you get a service error message that implies a step needs more time, increase the appropriate `sleep` value in your SH script.

3. List the files in your home directory.

    ```
    $ <copy>ls</copy>

    example.sh  your-download-file-name
    ```
4. In the upper-right corner of Cloud Shell, click the **Cloud Shell Menu** icon (cog wheel), and select **Download**.

    A **Download file** dialog box is displayed.

5. Enter the name of your PDF file, and then click **Download**.

    The file is downloaded to the browser.

6. Open the PDF file, if needed, and review the assessment report. Close the browser tab when you're finished.

7. Close Cloud Shell and click **Exit** to confirm.

You may now **proceed to the next lab**.

## Related Resources

- [Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm)
- [Oracle Data Safe CLI](https://docs.oracle.com/en-us/iaas/tools/oci-cli/3.22.2/oci_cli_docs/cmdref/data-safe.html)
- [Using the CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliusing.htm#Managing_CLI_Input_and_Output)

## Acknowledgements
- **Author** - Jody Glover, Consulting User Assistance Developer, Database 
- **Consultants** - Bettina Schaeumer
- **Last Updated By/Date** - Jody Glover, October 20, 2025