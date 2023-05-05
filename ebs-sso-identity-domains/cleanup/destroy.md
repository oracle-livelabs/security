# Destroy

## Introduction

This lab will show you how you can carry out the cleanup activities for the entire Live Lab.


### Objectives

-   Manual deactivation of the Applications and the Identity Domain
-   Destroy the Stack 1 and 2 for performing the cleanup of the resources.


## Task 1: Deactivate the confidential applications and the Identity Domain

In this task you will be carrying out the prerequisites before destroying Stack 1 and 2. You will be *manually deactivating* the applications and Identity Domain on the OCI console.

![Image 8](./images/image8.png "Image 8")

![Image 9](./images/image9.png "Image 9")

![Image 10](./images/image10.png "image10")
		
## Task 2: Destroy the Stack 1 - Destroy for performing the cleanup of the resources.

With this task, we will be deleting all the resources that got created as part of **Deploy** lab.

1. Log in to Oracle Cloud
2. Open up the hamburger menu in the left-hand corner.  Click **Developer Services**, choose **Resource Manager > Stacks**.

![Image 1](./images/image1.png "Image 1")
  
3. Choose the compartment in which you created the **Stack 1- Deploy** and select it.  

![Image 2](./images/image2.png "Image 2")

4. Click on **Destroy** and confirm again as prompted on the lower-right.  

![Image 3](./images/image3.png "Image 3")

5. Wait for the job to complete and review the output.  

![Image 4](./images/image4.png "Image 4")
![Image 5](./images/image5.png "Image 5")

## Task 3: Destroy the Stack 2 - Configure for performing the cleanup of the resources.

Now that you have successfully destroyed all the resources provisioned for your workshop, you can now safely delete the **Stack -2 Configure** to return the environment to it original state.

1. Follow the breadcrumbs links in the upper-left and click on **Stack Details**, the **More Actions > Delete Stack**.  

![Image 6](./images/image6.png "Image 6")

![Image 7](./images/image7.png "Image 7")


This completes the workshop.

## Acknowledgements
* **Author** - Gautam Mishra, Aqib Bhat, Samratha S P
* **Contributor** - Chetan Soni, Sagar Takkar
* **Supported By** - Deepak Rao Narasimha Gajendragad
* **Lead By** - Deepthi Shetty 
* **Last Updated By/Date** - Gautam Mishra May 2023
