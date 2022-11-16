# Configure the Autonomous Database instance

## Introduction

In this lab, we will explore the Oracle Cloud Platform (OCI) and configure the Autonomous Transaction Processing database instance (ATP).

For more information on the Autonomous Transaction Processing database click [here](https://www.oracle.com/autonomous-database/autonomous-transaction-processing/).

### Objectives

In this lab, you will complete the following tasks:

- Create an ATP database instance.

### Prerequisites

This lab assumes you have:
- Oracle Cloud Infrastructure (OCI) Tenancy Account

## Task 1: Create an ATP database instance.

1. With OCI open, navigate to the ATP portal by selecting the hamburger menu in the top left corner, which will allow for you to select **Oracle Database** and then, **Autonomous Transaction Processing.**

    ![Select ATP from OCI menu](images/select-atp-menu.png) 

2. Select **Create Autonomous Database.**

    ![Select Create Autonomous Database](images/create-autonomous-database.png) 

3. Enter a display name and database name.  

    ![Enter database name](images/name-database.png) 

4. Create a password for admin credentials.

    ![Enter admin credentials](images/atp-password.png) 

5. Change network access to **allowed IPs and VCNs only** and change IP notation type to **CIDR Block. Input the CIDR value of 0.0.0.0/0 into the blank field.** 

    ![Enter admin credentials](images/secure-access.png) 

6. Select **License included** and then select **Create Autonomous Database** at the bottom.

    ![Create ADB button at the bottom](images/create-atp.png)

7. Navigate back to the ATP instance you created. At the top of the page, select **DB Connection**.

    ![Navigate to DB connection](images/db-connection.png)

8. Scroll down to the **Connection Strings** section of the menu. Under TLS Authentication, make sure **TLS** is selected, not **Mutual TLS**. Then, copy the first connection string to a clipboard of your choice. You will save this string in a particular location in the following steps.

    ![Copy connection string](images/copy-connection-string.png)

You may now **proceed to the next lab.**

## Acknowledgements

- **Author** - Ethan Shmargad, North America Specialists Hub
- **Creator** - Richard Evans, Senior Principle Product Manager
- **Last Updated By/Date** - Ethan Shmargad, September 2022