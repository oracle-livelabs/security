# Identity and Access Management

## Introduction

Oracle Cloud Infrastructure (OCI) Identity and Access Management (IAM) Service lets you control who has access to your cloud resources. You control the types of access a group of users has and to which specific resources. The purpose of this lab is to give you an overview of the IAM Service components and an example scenario to help you understand how they work together.

Watch the video below for an overview of the lab.
[](youtube:KahdJmhJlYI)

Estimated time: 30 minutes

### Objectives
In this lab, you will:
- Create a compartment
- Create a user
- Create a group
- Create a policy associated to the group
- Add user to the group

### Prerequisites

* An Oracle Cloud Account - please view this workshop's LiveLabs landing page to see which environments are supported.

>**Note:** If you have a **Free Trial** account, when your Free Trial expires, your account will be converted to an **Always Free** account. You will not be able to conduct Free Tier workshops unless the Always Free environment is available. 

**[Click here for the Free Tier FAQ page.](https://www.oracle.com/cloud/free/faq.html)**

## Task 1: Create Compartments

A compartment is a collection of cloud assets, like compute instances, load balancers, databases, etc. By default, a root compartment was created for you when you created your tenancy (i.e. when you registered for the trial account). It is possible to create everything in the root compartment, but Oracle recommends that you create sub-compartments to help manage your resources more efficiently.

1. Click the **Navigation Menu** in the upper left, navigate to **Identity & Security** and select **Compartments**.

	![](https://raw.githubusercontent.com/oracle/learning-library/master/common/images/console/id-compartment.png " ")

   Click **Create Compartment**.
   ![Create a compartment](images/create-compartment.png)

2. Name the compartment **Demo** and provide a short description. Be sure your root compartment is shown as the parent compartment. Press the blue **Create Compartment** button when ready.

   ![Create compartment](images/compartment-details.png)

3. You have just created a compartment for all of your work in this Test Drive.

## Task 2: Manage Users, Groups, and Policies to Control Access

A user's permissions to access services comes from the _groups_ to which they belong. The permissions for a group are defined by policies. Policies define what actions members of a group can perform, and in which compartments. Users can access services and perform operations based on the policies set for the groups of which they are members.

We'll create a user, a group, and a security policy to understand the concept.

1. Click the **Navigation Menu** in the upper left. Navigate to **Identity & Security** and select **Groups**.

	![](https://raw.githubusercontent.com/oracle/learning-library/master/common/images/console/id-groups.png " ")

2. Click **Create Group**.
   
   In the **Create Group** dialog box, enter the following:

     - **Name:** Enter a unique name for your group, such as **oci-group** 
         >**Note:** the group name cannot contain spaces.

     - **Description:** Enter a description, such as **New group for oci users**
     - Click **Create**

   ![Create Group](images/create-group.png)

3. Click your new group to display it. Your new group is displayed.

   ![New group is shown](images/image006.png)

4. Now, let’s create a security policy that gives your group permissions in your assigned compartment. For example, create a policy that gives permission to members of group **oci-group** in compartment **Demo**:

   a) Click the **Navigation Menu** in the upper left. Navigate to **Identity & Security** and select **Policies**.
   	![](https://raw.githubusercontent.com/oracle/learning-library/master/common/images/console/id-policies.png " ")


   b) On the left side, select **Demo** compartment.
   ![Select ***Demo** compartment](images/demo-compartment.png)

      >**Note:** You may need to click on the + sign next to your main compartment name to be able to see the sub-compartment ***Demo***. If you do, and you still don't see the sub-compartment, ***refresh your browser***. Sometimes your browser caches the compartment information and does not update its internal cache.

   c) After you have selected the **Demo** compartment, click **Create Policy**.
      ![](images/img0012.png)

   d) Enter a unique **Name** for your policy (for example, "Policy-for-oci-group").
      >**Note:** the name can NOT contain spaces.

   e) Enter a **Description** (for example, "Policy for OCI Group").

   f) Select **Demo** for compartment.
   
   g) Click **Show manuel editor** and enter the following **Statement**:
     ```
     <copy>Allow group oci-group to manage all-resources in compartment Demo</copy>
     ```

   h) Click **Create**.

   ![Create](images/create-policy.png)

5. Create a New User

   a) Click the **Navigation Menu** in the upper left, navigate to **Identity & Security** and select **Users**.

	![](https://raw.githubusercontent.com/oracle/learning-library/master/common/images/console/id-users.png " ")

   b) Click **Create User**.

   In the **Create User** dialog box, enter the following:

      - **Name:** Enter a unique name or email address for the new user (for example, **User01**).
      _This value is the user's login name for the Console and it must be unique across all other users in your tenancy._
      - **Description:** Enter a description (for example, **New oci user**).
      - **Email:**  Preferably use a personal email address to which you have access (GMail, Yahoo, etc).

    Click **Create**.

      ![New user form](images/user-form.png)

6. Set a Temporary Password for the newly created User.

   a) From the list of users, click on the **user that you created** to display its details.

   b) Click **Create/Reset Password**.  

      ![Reset password](images/image009.png)

   c) In the dialog, click **Create/Reset Password**.

      ![Reset password](images/create-password.png)

   d) The new one-time password is displayed.
      Click the **Copy** link and then click **Close**. Make sure to copy this password to your notepad.

      ![](images/copy-password.png)

   e) Click **Sign Out** from the user menu and log out of the admin user account completely.

      ![Sign out](images/sign-out.png)

7. Sign in as the new user using a different web browser or an incognito window.

   a) Open a supported browser and go to the Console URL:  [https://cloud.oracle.com](https://cloud.oracle.com).

   b) Click on the portrait icon in the top-right section of the browser window, then click **Sign in to Oracle Cloud**.

   c) Enter the name of your cloud account (aka your tenancy name, not your user name), then click the **Next** button.

   ![Enter tenancy name](images/cloud-account-name.png)

   d) This time, you will sign in using **Oracle Cloud Infrastructure Direct Sign-In** box with the user you created. Note that the user you created is not part of the Identity Cloud Services.

   e) Enter the password that you copied. Click **Sign In**.

      ![Enter your password](images/sign-in.png)

      >**Note:** Since this is the first-time sign-in, the user will be prompted to change the temporary password, as shown in the screenshot below.

   f) Set the new password. Click **Save New Password**.
      ![Set the new password](images/image015.png)

8. Verify user permissions.

   a) Click the **Navigation Menu** in the upper left. Click **Compute** and then click **Instances**.

   ![](https://raw.githubusercontent.com/oracle/learning-library/master/common/images/console/compute-instances.png " ")

   b) Try to select any compartment from the left menu.

   c) The message “**You don’t have permission to view these resources**” appears. This is normal as you did not add the user to the group where you associated the policy.
      ![Error message can be ignored](images/no-permission.png)

   d) Sign out of the Console.

9. Add User to a Group.

      a) Sign back in with the ***admin*** account.
      
      b) Click the **Navigation Menu** in the upper left. Navigate to **Identity & Security** and select **Users**. From the **Users** list, click the user account that you just created (for example, `User01`)  to go to the User Details page.
         ![](https://raw.githubusercontent.com/oracle/learning-library/master/common/images/console/id-users.png " ")
      
      c) Under the **Resources** menu on the left, click **Groups**, if it's not already selected.

      d) Click **Add User to Group**.
         ![](images/image020.png)

      e) From the **Groups** drop-down list, select the **oci-group** that you created.

      f) Click **Add**.
         ![Press the Add button](images/add-user-to-group.png)

      g) Sign out of the Oracle Cloud website.

10. Verify user permissions when a user belongs to a specific group.

      a) Sign in with the local **User01** account you created. Remember to use the latest password you assigned to this user.

      b) Click the **Navigation Menu**. Click **Compute** and then click **Instances**.

      c) Select compartment **Demo** from the list of compartments on the left.

      ![Select ***Demo***](images/select-demo.png)

      d) There is no message related to permissions and you are allowed to create new instances.

      e) Click the **Navigation Menu**. click **Identity & Security** and select **Groups**.

      f) The message **“Authorization failed or requested resource not found”** appears. This is expected, since your user has no permission to modify groups. 
      >**Note:** You may instead get the "An unexpected error occurred" message instead. That is also fine.

      ![](images/group-error.png)

      g) Sign out.

*Congratulations! You have successfully completed the lab.*

## Acknowledgements

- **Author** - Rajeshwari Rai, Prasenjit Sarkar 
- **Contributors** - Arabella Yao, Product Manager, Database Product Management
- **Last Updated By/Date** - Arabella Yao, January 2022