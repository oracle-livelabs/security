# Introduction

## About this Workshop

OCI IAM Identity Domains is a comprehensive identity-as-a-service (IDaaS) solution that can be used to address a variety of IAM use cases and scenarios. OCI IAM can be used to manage access for users across numerous cloud and on-premises applications, enabling secure authentication, easy management of entitlements, and seamless SSO for end users.In this workshop, we will deploy the OAS application, App Gateway Server and OCI IAM Identity Domains on OCI using Terraform and then configure the deployed setup using Terraform to leverage the App Gateway feature of Identity Domains to achieve SSO to the OAS Application.
  

The following diagram shows the architecture and the login flow when using the App Gateway to integrate Oracle Analytics Server with OCI IAM. 
 
  ![oas-oci-iam-identity-domains](./images/oas-oci-iam-identity-domains.png "Image 1")

*In a web browser, a user requests access to an application through a URL exposed by App Gateway.
*App Gateway intercepts the request, verifies that the user doesn't have a session with IAM, and then redirects the user's browser to the sign-in page. In step 2, if the user has a session with IAM, it means that the user has already signed in. If so, then an access token is sent to App Gateway, and then the remaining steps are skipped.
*IAM presents the sign-in page or whichever sign-in mechanism has been configured for the domain.
*The user signs in to IAM.
*Upon successful authentication, IAM creates a session for the user and issues an access token to App Gateway.
*App Gateway uses the token to identify the user. It then adds header variables to the request and forwards the request to the application.
*The application receives the header information, validates the user's identity, and starts the user session.


This lab walks you through the steps to get started using **OCI IAM Identity Domains** with a popular use case - **Achieve SSO using App Gateway**. In this workshop, we will follow the steps to deploy the **OAS** application on OCI using *Terraform* via **Resource Manager**. Same Stack will also deploy a **App Gateway Server** and an **OCI IAM Identity Domain**. Once deployed, we will also make some necessary configuration changes in the *App Gateway Server*, *OAS Application Server* and the *Identity Domain* using Terraform. We will carry out some *manual tasks* to complete the configuration in Identity Domains before heading towards the validation of the entire flow. Once validation is done we will be going through the clean up activities/steps using the *Resource Manager*.


*Estimated Time:* 1 Hours


### Objectives

In this workshop, you will learn how to:

* Deploy a Terraform stack to create OAS application, App Gateway Instance and OCI IAM Identity Domain on OCI via Resource manager.
* Create a confidential application in OCI IAM Identity Domain
* Deploy a Terraform stack to configure the deployed App Gateway Instance, OAS Application and OCI IAM Identity Domain
* Validate the setup and test the SSO flow
* Clean up the deployed resources


### Prerequisites
This lab assumes you have:
* A Pay Go tenancy (Not Free) where you have administrative access


## Learn More

* [OCI IAM Identity Domains](https://docs.oracle.com/en-us/iaas/Content/Identity/home.htm)
* [Lear About App Gateway](https://docs.oracle.com/en-us/iaas/Content/Identity/appgateways/understand-app-gateway.htm)


## Acknowledgements
* **Author** - Chetan Soni, Sagar Takkar
* **Lead By** - Deepthi Shetty 
* **Last Updated By/Date** - Chetan Soni August 2023
