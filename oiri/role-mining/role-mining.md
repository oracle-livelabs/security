# Role Mining and Analyzing Candidate roles

## Introduction

This lab walks you through the steps involved in performing Role Mining and analyzing candidate roles in OIRI.

*Estimated Lab Time*: 15 minutes

### Objectives

In this lab, you will:
* Perform Role Mining
* Review and Analyze Candidate Roles

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment
    - Lab: Deploy Kubernetes Cluster and Start OIG Server
    - Lab: Deploy OIRI in the local Kubernetes Node
    - Lab: Import Data into OIRI from OIG

## Task 1: Create a Role mining task

1. On the Identity Role Intelligence home page, in the Start something new tile, click *Create a new Task*. Alternatively, you can click the Application Navigation menu icon, and click *All Tasks*, and then click New Task on the top right of the page.
The New Task page to select the data for creating a new role mining task appears.

    ![](images/1-mining.png)


2. In the Users tab you can optionally apply a number of filters and select a group of users that you want to include in the role mining task.
All the users are selected by default if we do not apply any filters. Let us include all users for this workshop.

    ![](images/2-mining.png)


3. Click the Applications tab. The applications are listed in this tab based on the user selection on the Users tab. We can observe that we have an Application called *Document Access*.

    ![](images/3-mining.png)


4. Click the Entitlements tab. The entitlements are listed in this tab based on the user and application selection on the Users and Applications tabs.
The Entitlements tab lists the entitlements that have been assigned to users. This tab does not list all the entitlements in the OIRI database.

    ![](images/4-mining.png)


5. Click *Mine Roles* to mine the roles based on the user, application, and entitlement selection in the role mining task.
The *Save Task and Mine Roles* dialog box appears with the following options:
  - Name: Enter a name for the role mining task. This is a required field.
  - Description: Enter a description for the role mining task.
  - Fine-tuning slider: Drag to minimize or maximize the number of candidate roles. Dragging the slider to the left minimizes the number of candidate roles. In other words, more users will get the permissions provided by the roles. Whereas, dragging the slider to the right maximizes the number of candidate roles. In other words, less misaligned entitlements and users provided by the roles.

    ![](images/5-mining.png)

    Click on *Mine Roles* to run the role mining task and discover candidate roles. A message appears stating that a request for running the task has been submitted.

    ![](images/6-mining.png)  


## Task 2: Review candidate roles

1. In the Manage Tasks page, search for the role mining task that you submitted.

2. Click on *Refresh* until the task status shows that it has been completed, then click *View Candidate Roles*.
The Results for role mining task page appears. In this page, the line at the top provides a summary of the role mining task run. It indicates the number of users and entitlements for which the task has been run, and how many candidate roles have been identified.

    ![](images/13-mining.png)

    ![](images/7-mining.png)


3. The candidate roles are listed in the Candidate Roles section. Notice the roles listed under *Review not started*.


4. For any candidate role listed, Click *Review Role* to open the Review and Adjust a Candidate Role page that lets you review and modify the candidate role before exporting and publishing.
For example, Click on the first candidate role with 70 users and 1 entitlement.

    ![](images/8-mining.png)

5. The *Review and adjust a Candidate Role* page appears.

6. The Entitlements horizontal bar shows the number of entitlements that are part of the candidate role out of the total number of entitlements included in the role mining task. To view the entitlements, click *Show*.
Notice that the Entitlement (Sales Document Access in this example) is displayed.

    ![](images/9-mining.png)

    ![](images/10-mining.png)

7. Click the Go Back icon to navigate back to the Review and Adjust Candidate Role page.

    ![](images/11-mining.png)


8. The Users horizontal bar shows the number of users that are part of the candidate role out of the total number of users included in the role mining task. To view the users, click *Show*. Review the users included in the role mining task. Click the Go Back icon to navigate back to the Review and Adjust Candidate Role page.

    ![](images/12-mining.png)



You may now [proceed to the next lab](#next).

## Acknowledgements
* **Author** - Keerti R, Brijith TG, Anuj Tripathi, NATD Solution Engineering
* **Contributors** -  Keerti R, Brijith TG, Anuj Tripathi
* **Last Updated By/Date** - Keerti R, NATD Solution Engineering, June 2021
