
# Deploy the stack to configure EBS, EBS Asserter and Identity Domain

## Introduction

Using this stack we will be able to configure **EBS, EBS Asserter Server and Identity Domain**. As part of this stack, a confidential application will be created under **Identity Domain** and sample users will be created.

## Objectives

1.	Configure **EBS Application - 12.2.11**
2. 	Configure **EBS Asserter Server**
3.	Create the **Confidential Application** under **Identity Domain** 

## Prerequisites

Once the **Stack2- Configure.zip** is downloaded, unzip the zip file and replace the the content of the **.pem** files (ebs.pem and ebsasserter.pem) with your respective content of the private key.

## Task 1: Deploy the Configuration Stack via Resource Manager

1. Once logged in to OCI Console, navigate to **Developer Services** then select **Stacks** under **Resource Manager**. Now click on **Create Stack**

**Note** Please do not select the **Root** compartment while creating the stack

![Capture 1](./images/image10.png "Capture 1")
	
![Capture 2](./images/image11.png "Capture 2")
 
2. On the Create Stack Wizard, select the **Stack 2- Configure.zip** option and then browse to upload the **Deploy** stack that you downloaded in the previous lab. Now click on **Next**

	![Image 1](./images/image1.jpg "Image 1")
	
	![Image 2](./images/image2.jpg "Image 2")
	
	![Image 3](./images/image3.jpg "Image 3")
	
**Note** The stack automatically picks up the working directory, provides the stack with a name and the working compartment gets selected. The Stack Name and Compartment can be changed if required.

3. Now, on the **Configure variables** section, fill in the below mentioned values, then click on **Next**

	1. *Public IP address of your asserter Server*
	2. *Public IP address of your EBS Server*
   	3. *Enter WebLogic password* . **Note** This is the same password that you have placed in the secret of your vault which gets used in Stack1 - Deploy.zip
    4. *Identity Domain URL* - Domain URL of the Deployed Domain . **Note** Remove **:443** from the end of the Domain URL.
    5. *Client ID* - Please enter the Client ID of your IDCS Confidential App
    6. *Client Secret* - Please enter the Client Secret of your IDCS Confidential App

	![Capture 3](./images/image12.png "Capture 3")
	
	
4. Now on the **Review Details** check for the configurations and then click on **Create** . Make sure the **Run Apply** is not selected.

	![Capture 4](./images/image13.png "Capture 4")
	
9. From the created stack now click on the **Plan** option. You should get an **Success** output.

	![Image 7](./images/image7.jpg "Image 7")
	
	![Image 8](./images/image8.jpg "Image 8")
	
9. From the created stack now click on the **Apply** option. You should get an **Success** output.	

	![Image 9](./images/image9.jpg "Image 9")

**Note** The stack might take around 15 mins for execution. Please wait until the **job** succeeds.

	
## Conclusion
 
In this lab, we were able to successfully deploy and configure EBS Application, EBS Asserter Server and Identity Domain. 

 You may now **proceed to the next lab.**

## Acknowledgements
* **Author** - Gautam Mishra, Aqib Bhat, Samratha S P
* **Contributor** - Chetan Soni, Sagar Takkar
* **Supported By** - Deepak Rao Narasimha Gajendragad
* **Lead By** - Deepthi Shetty 
* **Last Updated By/Date** - Gautam Mishra May 2023


