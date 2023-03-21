# Creating Compute Instance using Custom Image

## Introduction

In this lab we will use Custom image feature of OCI. These new compute instances will come with all the software packages and updates pre-installed as part of the custom image of OCI.


* Estimated Time: 15 minutes
* Persona: Campaign Administrator


### Objectives

In this lab, you will:
* Create **compute instance** from an existing custom image
* SSH to your **compute instance**

## Task 1: Sign in to OCI Console and create VCN

1. Go to the OCI console. From the OCI services menu, click Compute > Instances.
    
2. Select the compartment assigned to you from the drop down menu on the left part of the screen and click Start VCN Wizard.
3. Click **Create VCN with Internet Connectivity** and click **Start VCN Wizard.**
	![](images/ag-logon.png)
4. Fill out the dialog box:
    
    VCN NAME: Provide a name
    
    COMPARTMENT: Ensure your compartment is selected

    VCN CIDR BLOCK: Provide a CIDR block (10.0.0.0/16)

    PUBLIC SUBNET CIDR BLOCK: Provide a CIDR block (10.0.1.0/24)

    PRIVATE SUBNET CIDR BLOCK: Provide a CIDR block (10.0.2.0/24)

    Click Next

  ![](images/ag-homepage.png)

5. Verify all the information and Click **Create.**

  This will create a VCN with the following components.

  VCN, Public subnet, Private subnet, Internet gateway (IG), NAT gateway (NAT), Service gateway (SG)

6. Click View Virtual Cloud Network to display your VCN details.



## Task 2: Create a compute instance
1. Go to the OCI console. From the OCI services menu, click Compute > Instances.
  ![](images/create-campaign.png)
2. Click **Create Instance.**
  ![](images/select-dimensions.png)
3. Enter a name for your instance and select the compartment you used earlier to create your VCN. Select the Edit button in the Image and shape section.
  ![](images/select-users.png)
4. Click **Change Image.**
  ![](images/select-next.png)
5. In the Browse All Images dialog:

  Image Source: Custom Image

  Compartment: Ensure your compartment is selected

  Click Select Image.
  ![](images/select-applications.png)
6. Click **Change Shape.**
  ![](images/view-charts.png)
7. In the Browse All Shapes dialog:

  Instance Type: Select Virtual Machine

  Shape Series: Intel

  Instance Shape: VM.Standard3.Flex

  Click Select Shape.
  ![](images/configure-workflow.png)
  ![](images/default-workflow.png)
8. Scroll down to the section labeled Networking and select the Edit button.

   Virtual cloud network: Choose the VCN you created in Step 1

   Subnet: Choose the Public Subnet under Public Subnets (it should be named Public Subnet-NameOfVCN)

   Assign a public IPv4 address: Check this option

   Add SSH Keys: Choose 'Generate a key pair for me' and save the public and private key generated. 

   Boot Volume: Leave the default, uncheck values
 ![](images/name-campaign.png)
9. Click **Create.**  
 ![](images/summary.png)
10. Wait for the instance to have the **Running** status. Note down the Public IP of the instance. You will need this later. 
 ![](images/view-created-campaign.png)
11. SSH into your compute instance:

    ssh -i <sshkeyname> opc@<PUBLIC_IP_OF_COMPUTE>

    **HINT:** If 'Permission denied error' is seen, ensure you are using '-i' in the ssh command. You MUST type the command, do NOT copy and paste ssh command.
 13. Enter 'yes' when prompted for security message.
 14. Verify opc@<COMPUTE_INSTANCE_NAME> appears on the prompt.
 12. You may now **proceed to the next lab**. 

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Author** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 
* **Last Updated By/Date** - Anbu Anbarasu, Cloud Platform COE, January 2023
