# Download the Latest Security Assessment by using the Oracle Data Safe CLI

## Introduction

 You can use the command line interface (CLI) in Cloud Shell to perform tasks in Oracle Data Safe. Cloud Shell is a small virtual machine running a Linux shell, and is accessible in your tenancy in the Oracle Cloud Infrastructure Console. It's ready and free to use in your tenancy (within monthly tenancy limits). If you want to perform complex tasks using the CLI, it's useful to create an SH script that contains all of your CLI commands. 
 
 In this lab, you use the CLI to refresh the latest Security Assessment report for your target database and download it to a directory on your Cloud Shell machine. Begin by taking a look at the command line interface (CLI) documentation for the Oracle Data Safe service.

Estimated Lab Time: 15 minutes

### Objectives

In this lab, you will:

- Review the documentation for the Oracle Data Safe CLI
- Access Cloud Shell
- Gather information to build your CLI commands
- Create an SH file
- Run the SH file and view the report


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console
- Prepared your environment for this workshop (see [Prepare Your Environment](?lab=prepare-environment))
- Registered your target database with Oracle Data Safe (see [Register an Autonomous Database with Oracle Data Safe](?lab=register-autonomous-database))


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

5. When specifying required or optional parameters, be aware that you need to include the name of the parameter and then follow with the value. For example, suppose you want to quickly close all the alerts for a target database. You could issue the following statement in Cloud Shell.

    ```text
    <copy>oci data-safe alert alerts-update --compartment-id your-compartment-ocid --status CLOSED --target-id your-target-database-OCID</copy>
    ```

6. Scroll down the end of the page to view examples. 

## Task 2: Access Cloud Shell


1. To open Cloud Shell, in the upper-right corner of the Oracle Cloud Infrastructure Console, click the **Developer tools** icon, and then select **Cloud Shell**.

    When you first open Cloud Shell, your current directory is your home directory; for example, `/home/jody_glove`.


2. (Optional) If you use Cloud Shell often and want to start fresh, you can reset it. The following command erases all the data in your `$HOME` directory on your Cloud Shell machine and resets the `$HOME/.bashrc`, `$HOME/.bash_profile`, `$HOME/.bash_logout`, and `$HOME/.emacs` files back to their default values. Enter **y** at the prompt to confirm.

    ```bash
    $ <copy>csreset --all</copy>
    ```

3. For this lab, we can work in the home directory (`~/`).

4. Keep Cloud Shell open because you return to it in a later task.


## Task 3: Gather information to build your CLI commands

In this task, you identify the commands and values that are required for the next task.

1. To find your compartment OCID, from the navigation menu in Oracle Cloud Infrastructure, select **Identity & Security**, and then on the right under **Identity**, click **Compartments**. Click the name of your compartment. On the **Compartment Information** tab, click **Copy** next to **OCID**. Paste the OCID into a temporary text file. Modify the text as follows to define a variable called `compartment_id`:

    ```text
    export compartment_id=your-compartment-ocid
    ```

2. To find your target database OCID in Oracle Data Safe (this is not your database OCID!), from the navigation menu, select **Oracle Database**, and then **Data Safe**. Under **Data Safe** on the left, click **Target Databases**. Under **List Scope** on the left, select your compartment. On the right, click the name of your target database. On the **Target Database Details** tab, click **Copy** next to **OCID**. Paste the OCID into the temporary text file. Modify the text as follows to define a variable called `target_id`. Replace `your-target-database-ocid` with your own OCID.

    ```text
    export target_id=your-target-database-ocid
    ```

3. Think of a file name for your downloaded Security Assessment report and enter it into your temporary text file. Modify the text as follows to define a variable called `file_name`. Replace `your-download-file-name` with your own name. Include .pdf or .xls, depending on the file format you want. 

    Note: It is possible to specify a path to download the file to a specific directory; for example, `~/examples/myreport.pdf`.For our example here, we will keep it simple and just use the home directory (so no path is required).

    ```text
    export file_name=your-download-file-name
    ```

4. Specify the report format (PDF or XLS). To do that, add a line to your text file that defines a variable called `format`, as shown below. Replace `pdf-or-xls` with **PDF** or **XLS**.

    ```text
    export format=pdf-or-xls
    ```

5. To find the security assessment OCID, you create the assessment and extract the OCID information from it. Add the following line of code to your text file as is. Notice how we are using the `security-assessment create` CLI command with the `--query data.id` and `--raw-output` parameters.

    ```text
    security_assessment_id=$(oci data-safe security-assessment create --compartment-id $compartment_id --target-id $target_id --query data.id --raw-output)
    ```

6. Before you can download a security assessment, you must first generate it. Add the following line of code to your text file as is. Notice how we make use of the variables that we defined in earlier steps (`$format` and `$security_assessment_id`).

    ```text
    oci data-safe security-assessment generate-security-assessment-report --format $format --security-assessment-id $security_assessment_id
    ```

7. Configure the code line that downloads the security assessment report. You can use the following code as is. Notice how we make use of the variables that we defined in earlier steps (`$file`, `$format`, and `$security_assessment_id`).

    ```text
    oci data-safe security-assessment download-security-assessment-report --file $file --format $format --security-assessment-id $security_assessment_id
    ```

## Task 4: Create an SH file

Create an SH file to hold all of your commands that you have in your local text file. Be sure to use your own values for the variables.

1. In Cloud Shell, open the vi editor and create a file called `example.sh`. 

    ```text
    $ <copy>vi example.sh</copy>
    ```

2. Paste all of your code lines into the file. Insert two `sleep` commands - one after you create the report and another after you generate it so that the program allows time for the operations to complete; otherwise, you will get errors. You can also write to the console (using `echo`) before the `sleep` commands to inform the user of the wait time.

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
    oci data-safe security-assessment download-security-assessment-report --file $file_name --format $format --security-assessment-id $security_assessment_id
    ```

3. Save and exit the file (Press **Escape**, enter **:wq**, and press **Enter**).

4. Grant permissions on the file.

    ```text
    $ <copy>chmod 777 example.sh</copy>
    ```



## Task 5: Run the SH file and view the report

When you run the SH file, the latest security assessment is downloaded to your cloud shell machine. From there, you can download it to your local computer for viewing.

1. Enter the following command to run the SH file:

    ```text
    $ <copy>./example.sh</copy>
    ```
2. If you get a service error message that indicates a step needs more time, increase the `sleep` value in your SH script.

3. List the files in your home directory.

    ```
    $ <copy>ls</copy>

    MyLatestSecurityAssessment.pdf
    ```
4. In the upper-right corner of Cloud Shell, click the **Cloud Shell Menu** icon, and select **Download**.

    A **Download File** dialog box is displayed.

5. Enter the name of your file, and then click **Download**.

    The file is downloaded and opens.

6. Review the assessment report and then close it.



## Related Resources

- [Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm)
- [Oracle Data Safe CLI](https://docs.oracle.com/en-us/iaas/tools/oci-cli/3.22.2/oci_cli_docs/cmdref/data-safe.html)
- [Using the CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliusing.htm#Managing_CLI_Input_and_Output)

## Acknowledgements
- **Author** - Jody Glover, Consulting User Assistance Developer, Database 
- **Consultants** - Bettina Schaeumer
- **Last Updated By/Date** - Jody Glover, January 26, 2023