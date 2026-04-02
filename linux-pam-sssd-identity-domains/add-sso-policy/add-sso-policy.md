
# Create a SSO Policy to introduce MFA

## Introduction
This lab will show you how to add a Single Sign On Policy to include MFA in the rule.

*Estimated Time:* 5 minutes

### Objectives

-   Create a Single Sign On (SSO) Policy.
-	Assign the confidential application to SSO policy.

		
## Task 1: Create a Single Sign On (SSO) Policy and Add the application

1. Sign in to your OCI IAM Identity Domains to access the **OCI console**. Once logged in, **Navigate** to **Domains** under **Identity and Security**. Now select your **Identity Domain** provisioned previously.

    	![identity&security](./images/identity-security.png "identity&security")

    	![domains](./images/domains.png "domains")
    	
2. Click on the **Domain policies** -> **Sign-on policies**, and then click **Create Sign-on policy**.
    	
    	![sign-on-policy](./images/sign-on-policy.png "sign-on-policy")

3. Provide a *name* of the policy and click **Create sign-on policy**. In the **Sign-on rules** section, click on **Add sign-on rule** to a new rule to the policy. Provide an appropriate **RuleName** and then scroll down to the **Actions** section to select **Any Factor** and **Everytime** in the *Frequency* option.

    	![policy-name](./images/policy-name.png "policy-name")

    	![add-sign-on-rule](./images/add-sign-on-rule.png "add-sign-on-rule")

    	![frequency](./images/frequency.png "frequency")

4. Click on **Applications** section and then **Add app** to select the *confidential app* which got created earlier by the *Stack2 -Deploy*. Once done, select **Close** and then **Activate Sign-on policy**.

	![add-app-to-policy](./images/add-app-to-policy.png "add-app-to-policy")

	![add-app](./images/add-app.png "add-app")

	![activate](./images/activate-policy.png "activate")


 You may now **proceed to the next lab.**

## Acknowledgements
* **Author** - Gautam Mishra, Aqib Bhat
* **Contributor** - Deepthi Shetty 
* **Last Updated By/Date** - Gautam Mishra Mar 2026

