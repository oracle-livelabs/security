# Mark the Identities for Access Governance

## Introduction

Access Governance Administrators (Pamela Green) will activate the identities.

* Persona: Access Governance Administrator

*Estimated Time*: 15 minutes

Watch the video below for a quick walk-through of the lab.
[Oracle Video Hub video with no sizing](videohub:1_kch622zw)

### Objectives

In this lab, you will:

* Activate the Identities

### Prerequisites

This lab assumes you have:

A valid Oracle OCI tenancy, with OCI administrator privileges.

## Task 1: Sign in to Oracle Access Governance Console

1. From your browser, navigate to the Oracle Access Governance Console using the URL specified in *Lab 2: Task 1: Step 4*


2. Enter **Oracle Access Governance Administrator** username and password (Pamela Green)

    **Username:**
    ```
    <copy>pamela.green</copy>
    ```

    **Password:**
    
    The password you have set for the user in *Lab 1: Task 2: Step 5*


  You will be navigated to the home page of your Oracle Access Governance Console.


## Task 2: Activate the Identities

In this task, you will select the identities that you want to include in your service.

1. In the Oracle Access Governance Console, navigate to Service Administration -> Manage Identities

  ![Navigate Manage Identities](images/navigate-to-manage-identities.png)

2. Select **Any** condition match option.

   ![Manage Identities page](images/selec-any-condition.png)

3. Select the below options for the condition to match the identities that you want to include.

      * Select attribute: Status
      * Select operator: Contains
      * Attribute value: Active

    Hit **Enter**

4. Click on **Preview Summary based on the rule above**. The identities that match the rule will be visible.

5. Close the pop-up and click on **Save**

  ![Manage Identities page](images/preview-identities-user.png)

  You may now **proceed to the next lab**.

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgements

* **Authors** - Anuj Tripathi, Anbu Anbarasu
* **Last Updated By/Date** - Indira Balasundaram 29 May 2024
