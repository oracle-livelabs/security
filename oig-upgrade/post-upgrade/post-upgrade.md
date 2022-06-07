# Post-Upgrade tasks

## Introduction

This lab walks you through the steps to restart the servers and complete the one-hop upgrade process.

*Estimated Lab Time*: 20 minutes

### Objectives

In this lab, you will:
* Restart the servers to complete the upgrade
* Verify the upgrade process

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment
    - Lab: Pre-Upgrade Requirements
    - Lab: One-Hop Upgrade

## Task 1: Start the 12c Admin Server and Managed Servers

1. Navigate to the 12c domain directory and Start the servers in the order given below

    ```
    <copy>cd /u01/oracle/middleware12c/user_projects/domains/iam12c_domain/bin</copy>
    ```

2. Start the Admin Server

    ```
    <copy>nohup ./startWebLogic.sh &</copy>
    ```

3. Once the Admin Server starts up, access the Weblogic console from your browser. Click on the bookmark *Workshop Links* and click on *WLS12c* "OR" paste the following URL in the browser:

    ```
    <copy>http://onehopiam:7005/console</copy>
    ```
    ```
    Username: <copy>weblogic</copy>
    ```
    ```
    Password: <copy>Welcom@123</copy>
    ```

4. On the Weblogic console, Click on *Servers* under *Environment* and notice that all servers(OIM,SOA) are in the ‘SHUTDOWN’ state

5. Open another tab in the terminal. Navigate to the *`/u01/oracle/middleware12c/user_projects/domains/iam12c_domain/bin`* path and start the SOA server

    ```
    <copy>nohup ./startManagedWebLogic.sh soa_server1 t3://onehopiam:7005 -Dbpm.enabled=true &</copy>
    ```

    Refresh the Weblogic console and notice that the SOA server is now in the ‘RUNNING’ state. It may take about 5-8 minutes for the SOA server to start.

6. Open another tab in the terminal. Navigate to the *`/u01/oracle/middleware12c/user_projects/domains/iam12c_domain/bin`* path and start the OIM server

    ```
    <copy>nohup ./startManagedWebLogic.sh oim_server1 t3://onehopiam:7005 &</copy>
    ```

    This time, OIM bootstrap process will be executed, and after successful bootstrap, OIM Managed Server will be shut down automatically.

7. After the OIM server is shutdown automatically, verify that no OIM processes are running by issuing the following command:

    ```
    <copy>ps -ef |grep oim_server1</copy>
    ```

8. Stop the SOA Server. Navigate to the *`/u01/oracle/middleware12c/user_projects/domains/iam12c_domain/bin`* path and stop the SOA server

    ```
    <copy>./stopManagedWebLogic.sh soa_server1</copy>
    ```

9. Stop the Admin Server

    ```
    <copy>./stopWebLogic.sh</copy>
    ```

## Task 2: Verify the Upgrade Process

1. Run the *startDomain12c.sh* script to restart the 12c Domain. The Admin server will take about 3-4 mins to start. It may take about 10mins for the SOA and OIM servers to start.

    ```
    <copy>cd /u01/scripts</copy>
    ```

    ```
    <copy>./startDomain12c.sh</copy>
    ```
2. Access the 12c Weblogic console from your browser. Click on the bookmark *Workshop Links* and click on *WLS12c* "OR" paste the following URL in the browser:

    ```
    <copy>http://onehopiam:7005/console</copy>
    ```
    ```
    Username: <copy>weblogic</copy>
    ```
    ```
    Password: <copy>Welcom@123</copy>
    ```

    On the Weblogic console, Click on *Servers* under *Environment* and verify that all servers(OIM,SOA) are in the ‘RUNNING’ state.  

4. Access the Identity Self Service console. Click on the bookmark *Workshop Links* and click on *OIG12c* "OR" paste the following URL in the browser:

    ```
    <copy>http://onehopiam:14005/identity</copy>
    ```
    ```
    Username: <copy>xelsysadm</copy>
    ```
    ```
    Password: <copy>Welcom@123</copy>
    ```

5. Click on *xelsysadm* on the top right corner and Click on *About* from the dropdown. Verify that the OIM version is 12c

    ![](images/1-identity.png)

6. Click on *Manage* on the top right corner. Then, click on *Users* and notice that the three users *TUSER1, TUSER2, TUSER3* are migrated from 11g to 12c.

    ![](images/2-users.png)

One-hop upgrade to Oracle Identity Manager 12c is complete.


## Acknowledgements
* **Author** - Keerti R, Brijith TG, Anuj Tripathi, NATD Solution Engineering
* **Contributors** -  Keerti R, Brijith TG, Anuj Tripathi
* **Last Updated By/Date** - Keerti R, NATD Solution Engineering, June 2021
