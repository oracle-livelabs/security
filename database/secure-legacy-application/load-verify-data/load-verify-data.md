# Load and verify the data in the Glassfish application

## Introduction

In this lab, we will populate the Glassfish application with data and then verify that the HR application still functions appropriately. This will involve loading the `EMPLOYEESEARCH_PROD` schema objects to the ATP instance.

### Objectives

In this lab, you will complete the following tasks:

- Create the `EMPLOYEESEARCH_PROD` schema using `SQL*Plus` from the Glassfish App Server.
- Update the connection string.
- Start the Glassfish application.
- Verify the HR app functions using the Glassfish app **public IP**.

### Prerequisites

This lab assumes you have:
- Oracle Cloud Infrastructure (OCI) tenancy account
- Completion of the following previous labs: 
    - Configure the Autonomous Database instance
    - Connect to the legacy Glassfish HR application

## Task 1: Create the EMPLOYEESEARCH_PROD schema using SQL*Plus from the Glassfish App Server and startup the Glassfish application.

1. Execute the `load_app_data.sh` script to load data into your ATP instance.

    ```
    <copy>./load_app_data.sh</copy>
    ```

    ![Load app data](images/sla-017.png "Load app data")

2. Update the application connection string using the `update_app_connection_string.sh` script.

    ```
    <copy>./update_app_connection_string.sh</copy>
    ```

    ![Update connection string](images/update-connection-string.png)

3. Start the Glassfish application using the `startGlassfish.sh` script.

    ```
    <copy>./startGlassfish.sh</copy>
    ```

    ![Start glassfish app](images/glassfish-start.png)

    *Note: If you click the Production or development links, they will not be accessible until after the next step, allowing ingress on port 8080*

## Task 2: Verify the HR app functions using the Glassfish app public IP.

1. Minimize your Cloud Shell terminal and navigate back to you Glassfish app instance in OCI using the hamburger menu under **Compute>Instances**.

    ![Running instance](images/sla-015.png "Running instance")

2. Under the section **Networking**, select the subnet it created for you.

    ![Find subnet](images/sla-018.png "Find subnet")

3. Under **Security**, select the **Default Security List** for your subnet.

    ![Select defualt SL](images/sla-019.png "Select security list")

4. Under **Security Rules**, select **Add Ingress Rules**.

    ![Ingress rule](images/sla-020.png "Ingress rules")

5. Fill in the information according to the image below and select **Add Ingress Rules**.

    ![Add ingress rule](images/sla-021.png "Add ingress rule")

6. Navigate back to your Cloud Shell terminal. Locate the output of the `startGlassfish.sh` script and find both the **Production** and **Development** URLs given to you at the conclusion of the output. 

    ![Start glassfish app](images/glassfish-start.png)

    ![Open myhrapp](images/front-page-prod.png)

    ![Open myhrapp](images/front-page-dev.png)

**Apply the following steps to both the production and development environments:**

7. Navigate to the menu bar at the top of the page and select **Login**. Use the following login information to sign into the Glassfish application.

    ```
    Username:<copy>hradmin</copy>
    ```

    ```
    Password:<copy>Oracle123</copy>
    ```

8. Once logged in, verify that the data is found in the Glassfish application by navigating to **Search Employees** at the menu bar on the right hand side. Under the search parameters, locate the row **Active** and select **Active** then select **Search** to view the data.

    ![Search employees](images/search-emp.png)

    ![Select active emp](images/select-active.png)

    ![Open myhrapp](images/verify-data.png)

9. Using the menu at the top of the page, select **Home** to navigate back to the home page.

You may now **proceed to the next lab.**

## Acknowledgements

- **Author** - Ethan Shmargad, Product Manager
- **Contributers** - Richard Evans, Senior Principle Product Manager
- **Last Updated By/Date** - Ethan Shmargad, April 2025
