# Initialize the Environment

## Introduction

In this lab we will review and setup all components required to successfully upgrade IAM 11.1.2.3 to 12.2.1.4 version.

*Estimated Lab Time*:  30 minutes

### Objectives
- Initialize the IAM 11.1.2.3 baseline workshop environment.

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup

## Task 1: Validate That Required Processes are Up and Running

1. Now with access to your remote desktop session, proceed as indicated below to validate your environment before you start executing the subsequent labs. The following Processes should be up and running:

    - Database Listener
        - LISTENER
    - Database Server Instance
        - orcl

    ![Remote desktop landing page](./images/login.png " ")

2. Run the following from the *Terminal* session, to validate that the expected processes are up.

    - Database service
        ```
        <copy>
        systemctl status oracle-database.service
        </copy>
        ```

        ![terminal db service status check](./images/db-service-status.png " ")

    - IAM Service
        ```
        <copy>
        systemctl status oracle-iam.service
        </copy>
        ```
        ![terminal iam service status check](./images/iam-service-status.png " ")

    If all expected processes are shown in your output as seen above, then your environment is ready for the next task.


3. Test the base installation by accessing the *Identity Manager Admin Console* ,which has been pre-launched on the *Chrome* window on your remote desktop session, using the below credentials :

    ```
    URL: <copy>http://wsidmhost.idm.oracle.com:7778/oim</copy>
    ```
    ```
    User: <copy>xelsysadm</copy>
    ```
    ```
    Password: <copy>IAMUpgrade12c##</copy>
    ```

    ![Identity Manager Admin Console login](./images/login1.png " ")


    ![Identity Manager Admin Console home page](./images/oim-landing.png " ")


## Task 2: Review the ReadMe.txt and Binaries

1. Review environment details to learn more about the setup. Navigate to the file browser as shown below and open *ReadMe.txt*.

    ![review readme.txt](./images/review.png " ")

2. For your convenience, all software binaries needed throughout the workshop have been staged on the instance. Refer to the details below to review

    - Review 12c Binaries
    ```
    <copy>ls -ltrh /home/oracle/Downloads/12cbits </copy>
    ```
    - Review 11g Binaries
    ```
    <copy>ls -ltrh /home/oracle/Downloads/11gbits </copy>
    ```
    ![folder structure of binaries](./images/review2.png " ")


You may now [proceed to the next lab](#next).


## Appendix 1: Managing Startup Services

1. Database service (Database and Standard Listener).

    - Start

    ```
    <copy>
    sudo systemctl start oracle-database
    </copy>
    ```
    - Stop

    ```
    <copy>
    sudo systemctl stop oracle-database
    </copy>
    ```

    - Status

    ```
    <copy>
    systemctl status oracle-database
    </copy>
    ```

    - Restart

    ```
    <copy>
    sudo systemctl restart oracle-database
    </copy>
    ```
2. IAM service

    - Start

    ```
    <copy>
    sudo systemctl start oracle-iam.service
    </copy>
    ```
    - Stop

    ```
    <copy>
    sudo systemctl stop oracle-iam.service
    </copy>
    ```

    - Status

    ```
    <copy>
    systemctl status oracle-iam.service
    </copy>
    ```

    - Restart

    ```
    <copy>
    sudo systemctl restart oracle-iam.service
    </copy>
    ```


## Learn More
Use these links to get more information about Oracle Identity and Access Management:
- [Oracle Identity Management 12.2.1.4.0](https://docs.oracle.com/en/middleware/idm/suite/12.2.1.4/index.html).

## Acknowledgements
* **Author** - Anbu Anbarasu, Director, Cloud Platform COE
* **Contributors** -  Eric Pollard - Sustaining Engineering, Ajith Puthan - IAM Support, Rene Fontcha
* **Last Updated By/Date** - Sahaana Manavalan, LiveLabs Developer, NA Technology, May 2022
