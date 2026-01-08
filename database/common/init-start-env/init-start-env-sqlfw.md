# Initialize Environment

## Introduction

In this lab we will review and startup all components required to successfully run this workshop.

Estimated Time: 10 minutes maximum.

### Objectives
- Initialize the workshop environment.

### Prerequisites
This lab assumes you have:
<if type="brown">
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
</if>
<if type="green">
- An Oracle Cloud account
- You have completed:
    - Introduction Tasks
</if>

**Note:** All screenshots for SSH terminal type tasks featured throughout this workshop were captured using the *MobaXterm* SSH Client as described in this step. As a result when executing such tasks from within the graphical remote desktop session, skip steps requiring you to login as user *oracle* using *sudo su - oracle*, the reason being that the remote desktop session is under user *oracle*.

## Task 1 - Check access to Glassfish app

1. Verify the application functions as expected

   **Note**: For this lab, Glassfish app is connected to the 23ai database **`FREEPDB1`** (installed on the DB23ai VM)

2. Open a Web Browser at the URL *`http://dbsec-lab:8080/hr_prod_pdb1`* to access to **your Glassfish App**

   **Notes:** If you are not using the remote desktop you can also access this page by going to *`http://<YOUR_DBSEC-LAB_VM_PUBLIC_IP>:8080/hr_prod_pdb1`*
    
3. Login to the application as *`hradmin`* with the password "*`Oracle123`*"

    ```
    <copy>hradmin</copy>
    ```

    ```
    <copy>Oracle123</copy>
    ```

    ![SQLFW](./images/init-start-env-sqlfw-002.png "HR App - Login")

    ![SQLFW](./images/init-start-env-sqlfw-003.png "HR App - Login")

4. In the top right hand corner of the App, **click** on the **Welcome HR Administrator** link and you will be sent to a page with session data

    ![SQLFW](./images/init-start-env-sqlfw-004.png "HR App - Settings")

5. On the **Session Details** screen, you will see how the application is connected to the database. This information is taken from the **userenv** namespace by executing the `SYS_CONTEXT` function.

    ![SQLFW](./images/init-start-env-sqlfw-005.png "HR App - Session details")

6. Now, you should see **FREEPDB1** as the **`DB_NAME`** and **dbsec-lab** as the **HOST**

    ![SQLFW](./images/init-start-env-sqlfw-006.png "HR App - Check the targetted database")

You may now **proceed to the next lab**.

## Acknowledgements
- **Author** - Rene Fontcha, LiveLabs Platform Lead, NA Technology
- **Contributors** - Marion Smith, Technical Program Manager
- **Last Updated By/Date** - Angeline Dhanarani, Database Security PM - January 2026
