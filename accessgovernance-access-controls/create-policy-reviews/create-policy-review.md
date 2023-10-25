# Create and Review Policy Review Campaigns

## Introduction

Access Governance Administrators (Pamela Green) can create and review policy review campaign.

* Persona: Access Governance Administrator

*Estimated Time*: 15 minutes

Watch the video below for a quick walk-through of the lab.
[Oracle Video Hub video with no sizing](videohub:1_yivv30ww)

### Objectives

In this lab, you will:

* Create policy review campaigns for OCI IAM Policies
* Examine policy review tasks raised by the campaign
* Evaluate policy review tasks assigned to you as a Campaign Reviewer

## Task 1: Create a Policy Review Campaign

1. From your browser, go to the Oracle Access Governance Console.

2. Enter **Oracle Access Governance Administrator** username and password (Pamela Green)

    **Username:**

    ```
    <copy>pamela.green</copy>
    ```

    **Password:**

    ```
    <copy>Oracl@123456</copy>
    ```

  You will be navigated to the home page of your Oracle Access Governance Console.

3. Frome the home page of Oracle Access Governance, navigate to **Access Reviews** -> **Campaigns**.

  ![Access Governance Homepage](images/navigate-campaign.png)

4. Click on **Create a campaign**

  ![Access Governance Homepage](images/create-a-campaign.png)

5. Under **What type of access review campaign you would like to do?** , select review access to **Oracle Cloud Infrastructure**

      ![Access Governance Homepage](images/select-oci-campaign.png)

6. In the Selection criteria step, select the **Which tenancies?** tile. You will see a list of available cloud tenancies.

      ![Select Cloud provider](images/select-tenancies.png)

7. Select an appropriate cloud tenancy. In this tutorial, select your cloud tenancy. A green tick is marked against your selection.

      ![Select Cloud provider](images/which-tenancy.png)

8. Click on **Refine further**. You can further refine your selection by selecting a specific compartment and a domain, to run domain-specific policy reviews.

      ![Select Cloud provider](images/click-refine.png)

9. Enter the **compartment** details mentioned below and click on **Apply**

      compartment: ag-compartment

      ![Select Cloud provider](images/ag-compartment.png)

10. Move on to the next step to select policies that you want to review. Select **Which policies?** tile. You will see a list of available policies in the domain that you selected.

      ![Access Governance Homepage](images/select-which-policies.png)

11. Select the policies that you want to review. In this tutorial, select the following policies and click **Apply my selections.**

          - auditors-policy
          - network-admins-policy
          - security-admins-policy

      ![Access Governance Homepage](images/select-the-policies.png)

12. Proceed to the **Assign workflow** step. To do this, click **I’m good, go to workflows.** Here, you can define the approval workflow for your review tasks, click **Next.**

      ![Access Governance Homepage](images/choose-workflow.png)

      ![Access Governance Homepage](images/click-next-workflow.png)

13. In the **Add details** step, you can define the frequency (one-time or periodic) at which to run an access review campaign, give a meaningful name to your campaign, add a supporting description, and assign values to additional attributes, such as who owns it and when the campaign should start or end.

14. For this tutorial make the following changes in the **Add details** step:

          **How often do you want this to run?** : One time

          **What do you want to call this campaign?**: Policy-Review-OCI-IAM

          **How do you want to describe this campaign?**: Policy-Review-OCI-IAM

          **Who owns this campaign?**: Me

          **How would you like to schedule your campaign?** : Run now (will start 10 minutes from creation)

15. Click **Next.**

      ![Access Governance Homepage](images/campaign-information.png)

16. The **Review and submit** step displays the information you have added in the previous steps. Select **Create** to create the campaign. Your campaign is scheduled and is displayed on the **Campaigns** page. It will run 10 minutes from creation.

      ![OCI Enter details](images/click-create-new-campaign.png)

      ![OCI Enter details](images/campaign-scheduled.png)

## Task 2: Perform Policy Review Tasks

Here you will review and certify OCI IAM review tasks raised by the campaign created in the previous task.

1. From your browser, go to the Oracle Access Governance Console.

2. Enter **Oracle Access Governance Campaign Reviewer** username and password (Pamela Green)

    **Username:**

    ```
    <copy>pamela.green</copy>
    ```

    **Password:**

    ```
    <copy>Oracl@123456</copy>
    ```

  You will be navigated to the home page of your Oracle Access Governance Console.

  3. On the Oracle Access Governance Console home page, from the navigation menu, select **Access Reviews -> My Access Reviews.**

  4. To view review tasks created by your policy review campaign, click the **Access control review tasks** tab. You will see all policy access review tasks assigned to you as a reviewer. Oracle Access Governance uses in-house analytic-based Intelligence system to provide accept/review recommendations.

  ![Access Governance Homepage](images/access-control-review-tasks.png)

  5. For this tutorial, let’s check the recommendations given by Oracle Access Governance.

* network-admins-policy is marked for Review
* security-admins-policy is marked for Review
* auditors-policy is marked to Accept

  6. Let’s check out the Insights generated by Oracle Access Governance. For **auditors-policy**, click the corresponding **Actions** links under the **Insights** column.

  7. On the **Insights** page, you can view our recommendation for the policy review task. On the left-panel, you can view the policy information. On the right, you can view a complete list of actionable and non actionable policy statements, view policy details to see who and what the policy statement is granting access to, and make appropriate decisions on each statement.

    ![Access Governance Homepage](images/view-policy.png)

  8. Beside the Policy statement, click on the view button to view the resources associated with the policies. Click on Summmary and Details to view the information. Click Close.

     ![Access Governance Homepage](images/summary.png)

     ![Access Governance Homepage](images/details.png)

  9. To make a review decision, you can either revoke all or accept all actionable statements in that policy at once, or make decision individually on each policy statement. For this tutorial, let us validate 2 usecases:

    **Usecase 1:**  Revoke policy statement from a policy - **auditors-policy**

      - Let’s revoke the policy statement **Allow group ag-domain/Auditors to read audit-events in compartment ag-compartment** from the policy  **auditors-policy**. 

      ![Access Governance Homepage](images/auditor-policy.png)

      - Click on the cross button under Actions column for the policy statement **Allow group ag-domain/Auditors to read audit-events in compartment ag-compartment**

      ![Access Governance Homepage](images/click-revoke-auditor-policy.png)

      - Click on **Apply**

      ![Access Governance Homepage](images/click-apply-auditor-policy.png)

      -  Enter justification for why you revoke the access review items and accept the remaining items then click on **Submit** This will trigger the auto-remediation process in the Oracle Access Governance system.

      ![Access Governance Homepage](images/policy-review-list-new.png)

    **Usecase 2:**  Revoke an entire policy - **security-admins-policy**

      - Let's revoke the entire policy **security-admins-policy** 

       ![Access Governance Homepage](images/security-policy.png)

      - Click on the Revoke All button. 

       ![Access Governance Homepage](images/revoke-all-security-policy.png)

      - Click **Apply.** The **Confirmation** dialog box is displayed.

        ![Access Governance Homepage](images/apply-security-policy.png)

  * Provide justification and then click **Submit.** The closed loop access remediation will take place automatically.

  10. (Optional) Login to the Identity domain: ag-domain OCI console as the Identity Domain Administrator. Naviagte to Identity & Security -> Identity -> Policies.

* Verify the entire policy - **security-admins-policy** has been revoked from the list of policies successfully.

   Before performing the policy review:

  ![Access Governance Homepage](images/before-security-policy.png)

   After performing the policy review:

   ![Access Governance Homepage](images/after-security-policy.png)

* Verify the policy statement - **Allow group ag-domain/Auditors to read audit-events in compartment ag-compartment** of the policy -  **auditors-policy** has been revoked successfully.

  Before performing the policy review:

   ![Access Governance Homepage](images/before-auditor-policy.png)

  After performing the policy review:

   ![Access Governance Homepage](images/after-auditor-policy.png)

  This concludes the tutorial on create and perform OCI IAM policy reviews.

  You may now **proceed to the next lab**.

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgements

* **Authors** - Anuj Tripathi, Anbu Anbarasu
* **Last Updated By/Date** - Anuj Tripathi, October 2023
