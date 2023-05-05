# Prepare Setup

## Introduction
This lab will show you how to make necessary changes in the EBS application to enable the Single Sign On feature. Also, we will be creating an Admin user in EBS application and on OCI Identity Domain, which will be used for testing the SSO flow.  

*Estimated Lab Time:* 20 minutes

### Objectives

-   Create Oracle E-Business Suite's System Administrator in OCI IAM Identity Domain
-	Update Oracle E-Business Suite's System Administrator Email Address
-	Update Oracle E-Business Suite Profiles
-	Restart EBS Application 

### Prerequisites
This lab assumes you have:
- You have successfully carried out the previous labs 
- JDK 8 or later installed on your local system 

<!--
## Task 1: Create an Application User on Oracle E-Business Suite

Create a user for the E-Business Suite Asserter to communicate with Oracle E-Business Suite.

1.  Login as administrator (for example, sysadmin) to the [Oracle E-Business Suite application](http://demoebs.example.com:8000/OA_HTML/AppsLogin)

   **Sample Output:**  ![Image 1](./images/image1.png "Image 1")
	

2.  In the Oracle **E-Business Suite Home** page, scroll down the **Navigator**, expand **User Management**, and then click **Users**.

	**Sample Output:**  ![Image 2](./images/image2.png "Image 2")
	
3. In the **User Management** page, select **User Account** from the **Register drop-down** menu, and then click **Go**.

	**Sample Output:**  ![Image 3](./images/image3.png "Image 3")
	
4. In the Create User Account page, enter the following details to create a new user, and then click **Submit**.

	1. **User Name**: Provide a user name.
	2. **Password**: Provide a password.
	3. **Description**: EBS Asserter Service User
	4. **Password Expire**: None
	
	**Sample Output:**  ![Image 4](./images/image4.png "Image 4")
	
**Note**: The User Name you create in this step is used later in this tutorial. 

5. After the A new user account has been created. message appears, click **Assign Roles**, and then click **Assign Roles** in the **Update User page**.

	**Sample Output:**  ![Image 5](./images/image5.png "Image 5")
	
6. In the Search and Select: **Assign Roles** window, search by **Code** **UMX|APPS_SCHEMA_CONNECT**. Select **Apps Schema Connect Role**, and then click **Select**.

	**Sample Output:**  ![Image 6](./images/image6.png "Image 6")
	
7. In the Update User page, provide **justification** as **EBS Asserter Service User**, and then click **Save**.

	**Sample Output:**  ![Image 7](./images/image7.png "Image 7")
	
8. After the user is created, log off Oracle E-Business Suite application,and then log in using the user name and password you provided in step 4 to reset the user password.

	**Sample Output:**  ![Image 8](./images/image8.png "Image 8")
-->
		
## Task 1: Create Oracle E-Business Suite's System Administrator in OCI IAM Identity Domain

Create an user in Oracle IAM Identity Domain that corresponds to the System Administrator in your Oracle E-Business Suite (EBS), otherwise the system administrator won't be able to login to the EBS console after EBS configured to use OCI IAM Identity Domain for authentication.

1. Sign in to your OCI IAM Identity Domains to access the **OCI console**. Once logged in, **Navigate** to **Domains** under **Identity and Security**. Now select your **Identity Domain** provisioned previously.

	![Image 9](./images/image9.png "Image 9")
	
2. Click on the **Users**, In the **Add User window**, provide the following values, and then click **Create**.
	1. **First Name**: EBS
	2. **Last Name**: Sysadmin
	3. Uncheck Use the email address as the user name.
	4. **User Name**: sysadmin
	5. **Email**: Provide the email address set to the SYSADMIN account in your Oracle E-Business Suite.
	
	![Image 10](./images/image10.png "Image 10")


## Task 2: Update Oracle E-Business Suite's System Administrator Email Address

Update the email address of the SYSADMIN user in Oracle E-Business Suite to match the email address you provided to the corresponding user in Oracle Identity Cloud Service.

1. Login as administrator (for example, sysadmin) to the Oracle E-Business Suite application. 

2. In the Oracle E-Business Suite Home page, scroll down the **Navigator**, expand **User Management**, and then click **Users**.

3. In the **User Maintenance** page, search by User Name **SYSADMIN**, and click the **update icon** for the **SYSADMIN** user.

	![Image 11](./images/image11.png "Image 11")
	
4. Update the **Email** field value with the same email address you provided during the creation of the system administrator user in OCI IAM Identity Domain, and then click **Apply**.

	![Image 12](./images/image12.png "Image 12")
	
5. Close Oracle E-Business Suite application.

##Task 3: Update Oracle E-Business Suite Profiles

*Follow these steps to configure Oracle E-Business Suite to redirect non-E-Business-Suite-authenticated users to E-Business Suite Asserter instead of using the Oracle E-Business Suite local login page.*

1. Access **Oracle Applications Administration** page in **Oracle E-business Suite**, click the Core Services tab, and then click **Profiles tab**

	![Image 13](./images/image13.png "Image 13")
	
2. Enter **App%Agent%** in the Search, Profile Values, Code field, and then click **Find**

	![Image 14](./images/image14.png "Image 14")
	
3. 	On the Define Profile Values: **Application Authenticate Agent** page enter **E-Business Suite Asserter's URL- 		 https://ebsasserter.example.com:7004/ebs** in the Site Value field, and then **save it**.

	![Image 14](./images/image14.png "Image 14")
	
4. Back to the **Profiles tab**, enter **%SSO%Type%** in the Search, update the **APPS_SSO** code entry from **SSWA to SSWAw/SSO**, and **save** the profile.

	![Image 15](./images/image15.png "Image 15")
	
5 Back to the **Profiles tab**, enter **%Oracle Applications Session%** in the Search, update the value from **HOST** to **DOMAIN** and **save** the profile.

![Image 16](./images/image16.png "Image 16")

**Note** To run the EBS Application and update these Profile vaules you need to have JAVA installed on your Local System.

##Task 4: Restart Oracle E-Business Suite

Once the Profiles changes are done, SSH to the EBS Server and execute the below commands

```
$ sudo hostname demoebs.example.com
# sudo su - oracle
$ /u01/install/APPS/scripts/stopapps.sh
$ /u01/install/APPS/scripts/startapps.sh

```

**Note** Please use the above mentioned Hostname as wherever required.

 You may now **proceed to the next lab.**

## Acknowledgements
* **Author** - Gautam Mishra, Aqib Bhat, Samratha S P
* **Contributor** - Chetan Soni, Sagar Takkar
* **Supported By** - Deepak Rao Narasimha Gajendragad
* **Lead By** - Deepthi Shetty 
* **Last Updated By/Date** - Gautam Mishra May 2023

