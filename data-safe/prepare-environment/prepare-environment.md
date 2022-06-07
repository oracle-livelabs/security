---
inject-note: true
---

# Prepare Your Environment

## Introduction

To do this workshop, you need access to an Oracle Data Safe service in a region of your tenancy and a target database. This workshop uses an Autonomous Transaction Processing (ATP) database.

To complete most of the preparation tasks, you need to be a tenancy administrator. If you are a regular user in your organization's tenancy, enlist the help of a tenancy administrator. If you are using an Oracle-provided environment such as LiveLabs, you do not need to prepare an environment because Oracle provides you one with everything you need.


Estimated Lab Time: 15 minutes

### Objectives

In this lab, you will:

- Enable Oracle Data Safe in a region of your tenancy
- Create a compartment
- Create a user group and add the user account to the group
- Create an IAM policy for the user group
- Provision an Autonomous Transaction Processing database


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console at `https://cloud.oracle.com`


## Task 1: Enable Oracle Data Safe in a region of your tenancy

As a tenancy administrator or an Oracle Data Safe administrator, enable Oracle Data Safe in a tenancy region.

> **Note**: If Oracle Data Safe is already enabled in the desired region of your tenancy, or you are working in an Oracle-provided environment, you can skip this task.

1. In Oracle Cloud Infrastructure, at the top of the page on the right, select the region in your tenancy in which you want to enable Oracle Data Safe. Usually, you leave your home region selected, for example, **US East (Ashburn)**.

   ![Select Home region](images/select-region.png "Select Home region")

2. From the navigation menu, select **Oracle Database**, and then **Data Safe**.

    The **Overview** page is displayed.

3. Click **Enable Data Safe** and wait a couple of minutes for the service to enable. When it's enabled, a confirmation message is displayed in the upper-right corner.

    ![Enable Data Safe button](images/enable-data-safe-button.png "Enable Data Safe button")


## Task 2: Create a compartment

As a tenancy administrator, create a compartment in IAM in which to store Oracle Data Safe resources. From here on in, we refer to the compartment created in this task as "your compartment."

> **Note**: If you have an existing compartment in your tenancy that you can use, or you are using an Oracle-provided environment, you can skip this task.

1. From the navigation menu, select **Identity & Security**, and then **Compartments**.

    The **Compartments** page in IAM is displayed.

2. Click **Create Compartment**.

    The **Create Compartment** dialog box is displayed.

3. Enter a name for your compartment, for example, `dsc01` (short for Data Safe compartment 1).

4. Enter a description for the compartment, for example, **Compartment for the Oracle Data Safe Workshop**.

5. Click **Create Compartment**.


## Task 3: Create a user group and add the user account to the group

As a tenancy administrator, create a user group and add the user account (Oracle Cloud account) to the group.

> **Note**: If you are a tenancy administrator or you are using an Oracle-provided environment, you can skip this task.

1. From the navigation menu, select **Identity & Security**, and then **Groups**.

    The **Groups** page in IAM is displayed.

2. Click **Create Group**.

    The **Create Group** dialog box is displayed.

3. Enter a name for the group, for example, `dsg01` (short for Data Safe group 1).

4. Enter a description for the group, for example, **User group for data safe user 1**. A description is required.

5. (Optional) Create a tag.

6. Click **Create**.

    The **Group Information** tab is displayed.

7. Under **Group Members**, click **Add User to Group**.

    The **Add User to Group** dialog box is displayed.

8. From the drop-down list, select the user for this workshop, and then click **Add**.

    The user account is listed as a group member.


## Task 4: Create an IAM policy for the user group

As a tenancy administrator, create an IAM policy that grants the user permission to create and manage all Oracle Data Safe resources and use the Autonomous Database in the user's compartment.

> **Note**: If you are a tenancy administrator or you are using an Oracle-provided environment, you can skip this task.

1. From the navigation menu, select **Identity & Security**, and then **Policies**.

    The **Policies** page in IAM is displayed.

2. Under **COMPARTMENT**, leave the **root** compartment selected.

3. Click **Create Policy**.

    The **Create Policy** page is displayed.

4. Enter a name for the policy. It is helpful to name the policy after a group name, for example, `dsg01 `.

5. Enter a description for the policy, for example, **Policy for Data Safe group 1**.

6. From the **COMPARTMENT** drop-down list, select the **root** compartment.

7. In the **Policy Builder** section, move the **Show manual editor** slider to the right to display the policy field.

8. In the policy field, enter the following policy statements. Substitute `{group name}` and `{compartment name}` with the appropriate values.

    ```
    <copy>
    Allow group {group name} to manage data-safe-family in compartment {compartment name}
    Allow group {group name} to manage autonomous-database in compartment {compartment name}
    </copy>
    ```

    The first statement allows the user group to register an Oracle Database with Oracle Data Safe and create and manage Oracle Data Safe resources in the specified compartment. The second statement is allows the user group to use an Autonomous Database with Oracle Data Safe.

9. Click **Create**.


## Task 5: Provision an Autonomous Transaction Processing database

As a tenancy administrator or user with appropriate permissions to manage an Autonomous Database, create an Autonomous Transaction Processing (ATP) database in your compartment. You also require quota in your tenancy to create an Autonomous Database.

> **Note**: If you plan to use an existing ATP database in your tenancy, or you are using an Oracle-provided environment, you can skip this task.

1. From the navigation menu, select **Oracle Database**, and then **Autonomous Transaction Processing**.

2. In the **Filters** section on the left, make sure your workload type is **Transaction Processing** or **All** so that you can view your database listing after you create it.

3. From the **Compartment** drop-down list, select your compartment.

4. Click **Create Autonomous Database**.

5. On the **Create Autonomous Database** page, provide basic information for your database:

    - **Compartment** - If needed, select your compartment.
    - **Display name** - Enter a memorable name for the database for display purposes, for example, **ad01** (short for Autonomous Database 1).
    - **Database Name** - Enter **ad01**. It's important to use letters and numbers only, starting with a letter. The maximum length is 14 characters. Underscores are not supported.
    - **Workload Type** - Select **Transaction Processing**.
    - **Deployment Type** - Leave **Shared Infrastructure** selected.
    - **Always Free** - Select this option by moving the slider to the right.
    - **Database version** - Leave **19c** selected.
    - **OCPU Count** - You get **1** OCPU.
    - **Storage** - You get 0.02TB of storage.
    - **Password** and **Confirm Password** - Specify a password for the `ADMIN` database user and jot it down. The password must be between 12 and 30 characters long and must include at least one uppercase letter, one lowercase letter, and one numeric character. It cannot contain your username or the double quote (") character.
    - **Access Type** - Leave **Allow secure access from everywhere** selected.
    - **License Type** - Select **License Included**.

6. Click **Create Autonomous Database**. The **Autonomous Database Details** page is displayed.

7. Wait a few minutes for your instance to provision. When it is ready, **AVAILABLE** is displayed below the large ATP icon.





## Learn More

- [Oracle Cloud Infrastructure documentation](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [Try Oracle Cloud](https://www.oracle.com/cloud/free/)
- [Provision Autonomous Data Warehouse](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/user/autonomous-provision.html#GUID-0B230036-0A05-4CA3-AF9D-97A255AE0C08)



## Acknowledgements

- **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Last Updated By/Date** - Jody Glover, February 26, 2022
