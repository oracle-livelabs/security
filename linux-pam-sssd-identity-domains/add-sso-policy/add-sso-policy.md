# Prepare Setup

## Introduction
This lab will show you how to add a Single Sign On Policy to include MFA in the rule.

*Estimated Lab Time:* 5 minutes

### Objectives

-   Create a Single Sign On (SSO) Policy.
-	Assign the confidential application to SSO policy.

		
## Task 1: Create a Single Sign On (SSO) Policy and Add the application

1. Sign in to your OCI IAM Identity Domains to access the **OCI console**. Once logged in, **Navigate** to **Domains** under **Identity and Security**. Now select your **Identity Domain** provisioned previously.

	![Image 1](./images/image1.png "Image 1")

	![Image 2](./images/image2.png "Image 2")
	
2. Click on the **Sign-on policies**, and then click **Create Sign-on policy**.
	
	![Image 3](./images/image3.png "Image 3")

3. In the **Add Policy** section, provide a *name* of the policy. Provide an appropriate **RuleName** and then scroll down to the **Actions** section to select **Any Factor** and **Everytime** in the *Frequency* option.

	![Image 4](./images/image4.png "Image 4")

	![Image 5](./images/image5.png "Image 5")

	![Image 6](./images/image6.png "Image 6")

4. Clieck Next to **Add Apps** section and select the *confidential app* which got created earlier by the *Stack2 -Deploy*. Once done, select **Close** and then **Activate Sign-on policy**.

	![Image 7](./images/image7.png "Image 7")

	![Image 8](./images/image8.png "Image 8")

	![Image 9](./images/image9.png "Image 9")


 You may now **proceed to the next lab.**

## Acknowledgements
* **Author** - Gautam Mishra, Aqib Bhat
* **Lead By** - Deepthi Shetty 
* **Last Updated By/Date** - Gautam Mishra July 2023

