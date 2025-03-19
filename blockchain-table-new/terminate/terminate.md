# Terminate Oracle Autonomous Database

## **Introduction**

You can permanently delete (terminate) instances that you no longer need. Terminating an Oracle Autonomous Database permanently deletes the database data. However, automatic backups are not deleted if you have chosen Recovery Appliance or NFS as a backup destination. You can delete automatic backups directly from the Recovery Appliance or NFS.

This lab walks you through the steps to terminate an available or stopped Oracle Autonomous Database instance. For the purpose of this lab, an Always Free demo Oracle Autonomous Transaction Processing database instance named BLOCKCHAIN-TABLE-DEMO is provisioned in a compartment.

* Estimated Time: 5 minutes

Watch the video below for a quick walk-through of the lab.
[Terminate Oracle Autonomous Database](videohub:1_1j35699z:medium)

### Objectives

- Terminate an available or stopped Oracle Autonomous Database instance.

### Prerequisites

- Should have an Oracle Autonomous Database instance provisioned with Lifecycle Status - Available or Stopped.
- To provision an Oracle Autonomous Database, there are detailed instructions in Lab 1 of this workshop.

## Task 1: Terminate a Provisioned Oracle Autonomous Database Instance

1. If you are using an Oracle Cloud trial account, in the Oracle Cloud console, you need to be in the region where your Oracle Autonomous Database resources are provisioned. You can see your current default **Region** in the top right-hand corner of the page. To change the default region, click the **Region** drop-down and choose the region where your Oracle Autonomous Database resource is provisioned.

    ![Select region on the far upper-right corner of the page.](./images/lab5-task1-1.png " ")

2. Click the navigation menu, select **Oracle Database** and choose **Autonomous Database**.

    ![Select ATP.](./images/lab5-task1-2.png " ")

3. From the compartment filter select the **Compartment** where your Oracle Autonomous Database resource is provisioned. 

    In this lab, as **BLOCKCHAIN-TABLE-DEMO** is an Oracle Autonomous Transaction Processing database that is already provisioned.

    ![Choose compartment](./images/lab5-task1-3.png " ")

4. From the databases displayed, click **Display Name** of the database you wish to terminate.

    In this lab, we are terminating the available **BLOCKCHAIN-TABLE-DEMO** Oracle Autonomous Transaction Processing database instance. Click **BLOCKCHAIN-TABLE-DEMO**.

    ![Click display name](./images/lab5-task1-4.png " ")

5. Click **More Actions**.

    ![Click More Actions](./images/lab5-task1-5.png " ")

6. From the more actions drop-down, scroll down and click **Terminate**.

    ![Click Terminate](./images/lab5-task1-6.png " ")

7. Confirm that you wish to terminate your Oracle Autonomous Database in the confirmation dialog. Type the database name in the input field and click **Terminate Autonomous Database**.

    In this lab, type **BLOCKCHAIN-TABLE-DEMO** and click **Terminate Autonomous Database**.

    ![Click Terminate Autonomous Database](./images/lab5-task1-7.png " ")

8.  Your instance will begin to terminate. The Lifecycle State will turn from Available to Terminating.

    ![Terminating](./images/lab5-task1-8.png " ")

9. After a few minutes, once the instance is terminated, the Lifecycle state will change from Terminating to Terminated.

    ![Terminated](./images/lab5-task1-9.png " ")

    You have successfully terminated an Oracle Autonomous Database instance.

## Learn More

* Click [here](https://docs.oracle.com/en-us/iaas/exadata/doc/eccmanagingadbs.html#GUID-A00BC3BB-3AE6-4FBF-AEAF-2D9C14CD1D9A) to know more about Managing Oracle Autonomous Databases.

## Acknowledgements

* **Contributors** - Amit Ketkar, Pavas Navaney, Vinay Pandhariwal 
* **Created By/Date** - Vinay Pandhariwal, March 2025
* **Last Updated By/Date** - Vinay Pandhariwal, March 2025