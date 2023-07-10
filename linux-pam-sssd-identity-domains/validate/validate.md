# Validate

## Introduction

This lab will show you how you can test the Authentication into Linux Server Using OCI IAM.


### Objectives

-   Change the default password
-	Validate the authentication into Linux Server Using OCI IAM


## Task 1: Change Default Password for the OCI IAM POSIX Users

1. Below are the users who were created as sample SSO test users. 

	![Image 2](./images/image2.png "Image 2")
	
	**Default Password** - "Welcome@1234567890"

2. Login to the OCI console using the newly created domain and enter the credentials of the *POSIX* user.
		
	![Image 3](./images/image3.png "Image 3")

3. Reset the default password.

	![Image 4](./images/image4.png "Image 4")

4. Enable *Secure Verification* and enroll your mobile device.

	![Image 5](./images/image5.png "Image 5")

	![Image 6](./images/image6.png "Image 6")

5. Click on **Done** and then proceed with *Task 2*.

	![Image 7](./images/image7.png "Image 7")



## Task 2: Validate the Authentication with MFA

Once the **Stack 2- Configure** is successfully deployed, kindly carry out the steps mentioned below.

- SSH into your Linux environment where the OCI IAM Linux Pluggable Authentication Module (PAM) is installed.
- When prompted enter the password for the OCI IAM *POSIX* user. A *PUSH* notification is then sent to the enrolled mobile device. Tap **Allow** on the notification and then hit **Enter** on the screen.
	
	![Image 1](./images/image1.png "Image 1")

## Conclusion

In this Lab, we were able to successfully change the password of the test user and validated user authentication along with a *Second* factor into the Linux Server using the Identity Domain. 

 You may now **proceed to the next lab.**

 
## Acknowledgements
* **Author** - Gautam Mishra, Aqib Bhat
* **Lead By** - Deepthi Shetty 
* **Last Updated By/Date** - Gautam Mishra July 2023

