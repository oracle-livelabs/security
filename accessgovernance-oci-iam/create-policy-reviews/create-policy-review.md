# Create Policy Review Campaigns

## Introduction

Access Governance Administrators (Pamela Green) can create policy review campaign.

* Estimated Time: 15 minutes
* Persona: Administrator

### Objectives

In this lab, you will:
* Create policy review campaigns for OCI IAM Policies



## Task 1: Create a Policy Review Campaign

1.  On the **Oracle Access Governance** console home page, scroll down and select the **“Let’s create some work and define a new campaign”** tile. Alternatively, you can select **Navigation Menu -> Access Reviews -> Campaigns.** On the **Campaigns** page, click the **Create a campaign** button.

  ![Access Governance Homepage](images/ag-homepage-campaign.png)


  * In the Selection criteria step, select the **Which cloud providers?** tile. You will see a list of available cloud tenancies.

  ![Select Cloud provider](images/select-cloud-providers.png)

  * Select an appropriate cloud tenancy. In this tutorial, select your cloud tenancy. A green tick is marked against your selection. You can further refine your selection by selecting a specific compartment and a domain, to run domain-specific policy reviews.

  ![Select Cloud provider](images/green-tick-cloud-provider.png)

  * Move on to the next step to select policies that you want to review. Select **Which policies?** tile. You will see a list of available policies in the domain that you selected.

  ![Access Governance Homepage](images/select-which-policies.png)

  * Select the policies that you want to review. In this tutorial, select the following policies and click **Apply my selections.**

      - auditors-policy
      - network-admins-policy
      - security-admins-policy

    ![Access Governance Homepage](images/select-the-policies.png)
    

  * Proceed to the **Assign workflow** step. To do this, click **I’m good, go to workflows.** Here, you can define the approval workflow for your review tasks, click **Next.**

  ![Access Governance Homepage](images/choose-workflow.png)

  ![Access Governance Homepage](images/click-next-workflow.png)



  * In the **Add details** step, you can define the frequency (one-time or periodic) at which to run an access review campaign, give a meaningful name to your campaign, add a supporting description, and assign values to additional attributes, such as who owns it and when the campaign should start or end.


  * For this tutorial make the following changes in the **Add details** step:

      **How often do you want this to run?** : One time

      **What do you want to call this campaign?**: Policy-Review-OCI-IAM

      **How do you want to describe this campaign?**: Policy-Review-OCI-IAM

      **Who owns this campaign?**: Me

      **How would you like to schedule your campaign?** : Run now (will start 10 minutes from creation)


  * Click **Next.**

  ![Access Governance Homepage](images/campaign-information.png)

  * The **Review and submit** step displays the information you have added in the previous steps. Select **Create** to create the campaign. Your campaign is scheduled and is displayed on the **Campaigns** page. It will run 10 minutes from creation. 


  ![OCI Enter details](images/click-create-new-campaign.png)

  ![OCI Enter details](images/campaign-scheduled.png)



  You may now **proceed to the next lab**. 

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 
* **Last Updated By/Date** - Anbu Anbarasu, May 2023
