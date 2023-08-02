# Introduction

## About this Workshop

OCI IAM Identity Domains is a comprehensive identity-as-a-service (IDaaS) solution that can be used to address a variety of IAM use cases and scenarios. OCI IAM can be used to manage access for users across numerous cloud and on-premises applications, enabling secure authentication, easy management of entitlements, and seamless SSO for end users. In this workshop, we will show that how you can use the OCI IAM Linux Pluggable Authentication Module (PAM) to integrate your Linux environment with OCI IAM Identity Domains to perform end user authentication with first and second factor authentication.

 The graphic below shows the high level architecture of Linux PAM setup with OCI IAM.

  ![Architecture](./images/architecture-diagram.png "Architecture")
  
This lab walks you through the steps to get started using **OCI IAM Identity Domains** with the use case - **Authenticate to Linux environment using Linux Pluggable Authentication Module (PAM) module of OCI IAM**. In this workshop, we will follow the steps to deploy a **Linux Server**  on OCI using *Terraform* via **Resource Manager**. Same Stack will also deploy an **OCI IAM Identity Domain**. Once deployed, we will also make some necessary configuration changes in the *Linux Server* and the *Identity Domain* using Terraform. We will carry out some *manual tasks* to complete the configurations in Identity Domains before heading towards the validation of the entire flow. Once validation is done we will be going through the clean up activities/steps using the *Resource Manager*.


*Estimated Workshop Time:* 1 Hours


### Objectives

In this workshop, you will learn how to:

* Deploy a Terraform stack to create a Linux server and OCI IAM Identity Domain on OCI via Resource manager.
* Create a confidential application in OCI IAM Identity Domain.
* Deploy a Terraform stack to configure the Linux Instance and OCI IAM Identity Domain.
* Test the authentication flow *with MFA*.
* Clean up the deployed resources.


### Prerequisites
This lab assumes you have:
* A Pay Go tenancy (Not Free) where you have administrative access


## Learn More

* [OCI IAM Identity Domains](https://docs.oracle.com/en-us/iaas/Content/Identity/home.htm)
* [OCI IAM Linux PAM Module](https://docs.oracle.com/en/cloud/paas/identity-cloud/uaids/manage-linux-authentication-using-linux-pam-module.html#GUID-8FE587F4-D44C-47C1-BBE2-3D32886D0553)


## Acknowledgements
* **Author** - Gautam Mishra, Aqib Bhat
* **Contributor** - Deepthi Shetty
* **Last Updated By/Date** - Gautam Mishra July 2023
