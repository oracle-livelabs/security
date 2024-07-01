# Create  OCI Policies, VCN, Groups and Compartments

## Introduction

As an end-user having access to the sample web application, you can authenticate into the app with Email OTP as the second factor authentication. This lab will walk through the flow of providing username and password along with Email OTP received as part of the email client.

As one of the demo users, which is already pre-seeded in the environment, you will access the sample web application. Upon entering username and password, you would be redirected to choose email OTP for the second factor authentication. You would grab the OTP from the pre-configured web email client. Upon providing the OTP, you would be successfully he sample web application.

* Estimated Time: 15 minutes
* Persona: End-User

## Objectives

In this lab, you will:

* Deploy VirtualBox Demo Windows Image for OUA

* Deploy Nox Android Emulator with OMA

* Join Demo Windows Image to Entra ID Domain

* Install and Configure OUA

* Creating OAM User and Registering OUA User Preferences

## Prerequisites

This lab assumes you have:

* You have a Windows 10 computer with the latest version of VirtualBox installed and at least 100GB of free disk space, 32 GB of RAM and 4 cores in order to deploy the VM Demo Windows Image.

* You have administrative access to a Microsoft Entra ID domain in order to create Entra ID users.

* Optionally, you have administrative access to a Microsoft Office 365 subscription in order to assign Office 365 licenses to Entra ID users.

* You must deploy the Nox Android Emulator with OMA in order to perform the passwordless authentication use case which requires OMA push notifications.

  *Note:* The deployment of Virtual and Nox Android Emulator were tested on a Windows 10 machine. Although, you can use a Mac computer to deploy those components, the instructions in this document only apply to Windows OS.

## Task 1: Deploy VirtualBox Demo Windows Image for OUA

1. Download the VirtualBox Demo Window Image in your Windows computer. Do so by opening a PowerShell command window as administrator.

    ```
    <copy>
    wget -Outfile demo-oua-win11.ova https://objectstorage.us-ashburn-1.oraclecloud.com/p/JTOVmxD0o83oc6kTfGXaJhyfj2dnAQ_95EGdom3CwK9AHZt1hxsKJ5LogXvBPsIR/n/orasenatdpltsecitom05/b/so92-bucket/o/demo-oua-win11.ova
    </copy>
    ```

    *Note:* Depending on your internet speed, the download can take 60 minutes or more.

2. Once downloaded, start VirtualBox and from the menu, select File -> Import Appliance.

3. Select image demo-oua-win11.ova, click Next and then accept the default values or made changes as needed to the memory and CPU cores assigned to the new VM.

4. Click Finish to start the import process.

5. Once the the VM is imported. Check the VM networking settings: select the VM, from the menu click on Settings -> Network -> Adapter 1. Make sure the Bridge adapter is linked to your existing network interface or wireless connection and save the changes.

6. Start the imported VM. Login to Window 11 as administrator using the administrator credentials.

    Windows User

    ```
    <copy>
    admin
    </copy>
    ```

    Password

    ```
    <copy>
    #demOr@cle6699
    </copy>
    ```

## Task 2: Deploy Nox Android Emulator with OMA [CHECK IT : OPTIONAL/INCOMPLETE FOR NOW]

1. Download the Nox Android Emulator and Image in your Windows computer. Do so by opening a PowerShell command window as administrator. Enter the below command :

    ```
    <copy>
    #demOr@cle6699
    </copy>
    ```

## Task 3: Join Demo Windows Image to Entra ID Domain

1. Once in Windows 11 as administrator, proceed to join your Windows 11 device to an existing Entra ID domain.

    *Note:* If you do not have an existing Entra ID user account, create a new user using Entra ID administrative console.

2. From Window 11 desktop, type settings in the search box located in the taskbar. Open Settings -> Accounts -> Access work or school.

3. Click in the Connect button. In the Set up access work or school account window, clink in the link Join this device to Microsoft Entra ID.

4. Provide the Entra ID user credentials.

    ```
    Entra ID User : <UPN>
    Entra ID User Password  : <user_password>
    ```

5. In the confirmation window, click Join and then click Done.

6. Logout from Windows 11. Proceed to complete the registration by login back again this time using the Entra ID user (select Other user in the Windows login page).

7. As you login for the first time with an Entra ID user, you will be required to setup a second factor (E.g. using Microsoft Authenticator) and define a PIN for security reasons.

## Task 4: Installing and Configuring OUA

1. Login to Window 11 as administrator using the administrator credentials as specified below :

  Windows User
    ```
    <copy>
    Local\admin
    </copy>
    ```

  Password
    ```
    <copy>
    #demOr@cle6699
    </copy>
    ```

2. Add the following entries in the hosts file.

   *Note :* The file location is ***C:\Windows\System32\drivers\etc\hosts***

   *Note :* Replace ***PUBLIC_IP*** with the IP of the OUA compute instance noted from the OCI console

    ```
    <copy>
    <PUBLIC_IP>    so92-srv1.oracledemo.com iamdb.oracledemo.com oud.oracledemo.com oam.oracledemo.com aso.oracledemo.com oaa.oracledemo.com ora.oracledemo.com oim.oracledemo.com mail.oracledemo.com
    <PUBLIC_IP>    oiri.oracledemo.com grafana.oracledemo.com prometheus.oracledemo.com oap.oracledemo.com oudsm.oracledemo.com ade.oracledemo.com demodb.oracledemo.com
    </copy>
    ```

3. Proceed to install OUA. Open Windows Explorer and go to folder C:\Temp\V1042569-01. Right-click on file Oracle Universal Authenticator.msi an select Run as Administrator.

4. During install, enter the following parameter values :

    Server

    ```
    <copy>https://so92-srv1.oracledemo.com</copy>
    ```

    Endpoint

    ```
    <copy>/oaa-drss</copy>
    ```

    Port

    ```
    <copy>30774</copy>
    ```

    API User

    ```
    <copy>OAAINSTALL_OAA_DRSS</copy>
    ```

    API Key

    ```
    <copy>drssapikeytobesetduringinstallation</copy>
    ```

5. Once the installation completes, click Finish but choose No to not reboot the computer.

6. From Window 11 desktop, type regedit in the search box located in the taskbar. Open Registry Editor.

7. Within Registry Editor, expand Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Oracle\Oracle Universal Authenticator and update the parameters as below :

    host

    ```
    <copy>http://oaa.oracledemo.com</copy>
    ```

    port

    ```
    <copy>80 (Decimal)</copy>
    ```

8. Exit Registry Editor.

9. Register the OUA certificate. In your Windows taskbar, click on Start icon and type cmd.exe, make sure to select Run as administrator. Then, in the command window run the following commands :

    ```
    <copy>
    cd C:\Temp\V1042569-01
    powershell.exe -ExecutionPolicy Bypass "C:\Temp\V1042569-01\AddCertificate.ps1"
    </copy>
    ```

  *Note :* Kindly ignore the error with source already registered.

10. Type exit to close cmd.exe. Proceed to reboot the Windows computer.

## Task 5: Creating OAM User and Registering OUA User Preferences

1. OUA users must be created in the OAM directory, e.g. OUD. We will use Oracle Directory Services Manager (ODSM) console to create a new OAM user and added to the OAA-App-User users group.

   Using a text editor, modify the following LDIF file and update the attributes corresponding to the new user: dn, givenName, uid, sn, mail, orclSAMAccountName and cn. Update dn and uniquemember for the group membership.

    ```
    <copy>
    dn: cn=pwalker,cn=users,ou=iam,dc=oracledemo,dc=com
    changetype: add
    objectClass: orclUserV2
    objectClass: oblixorgperson
    objectClass: person
    objectClass: inetOrgPerson
    objectClass: organizationalPerson
    objectClass: oblixPersonPwdPolicy
    objectClass: orclAppIDUser
    objectClass: orclUser
    objectClass: orclIDXPerson
    objectClass: top
    objectClass: OIMPersonPwdPolicy
    givenName: Paul
    uid: pwalker
    orclIsEnabled: ENABLED
    sn: Walker
    userPassword: Oracle123
    mail: pwalker@oracledemo.com
    orclSAMAccountName: pwalker
    cn: pwalker
    postalcode: DemoAppUsrOua
    obpasswordchangeflag: false
    obpsftid: true
    ds-pwp-password-policy-dn: cn=FAPolicy,cn=pwdPolicies,cn=Common,cn=Products,cn=OracleContext,ou=iam,dc=oracledemo,dc=com

    dn: cn=OAA-App-User,cn=groups,ou=iam,dc=oracledemo,dc=com
    changetype: modify
    add: uniquemember
    uniquemember: cn=pwalker,cn=users,ou=iam,dc=oracledemo,dc=com
    </copy>
    ```

2. Login to ODSM console using the below URL and import the LDIF file.

    ```
    <copy>
    http://oudsm.oracledemo.com/oudsm
    </copy>
    ```

    User Name

    ```
    <copy>cn=Directory Manager</copy>
    ```

    Password

    ```
    <copy>Oracle123</copy>
    ```

3. Within ODSM, click on Data Browser tab. In the Data Tree tab, click the Import LDIF icon (blue arrow pointing down). Select the LDIF file edited in the previous steps and click OK.

4. Once the import is completed, expand Root -> dc=oracledemo,dc=com -> ou=iam -> cn=users, and make sure the new user is listed.

5. Now, expand Root -> dc=oracledemo,dc=com -> ou=iam -> cn=groups. Select group cn=OAA-App-User. In the right panel expand Member Information, and make sure the new user is listed. Proceed to exit ODSM.

6. Register the OUA user preferences, do so by running the corresponding REST API endpoint to assign the factors.

  E.g. login as root user to the OUA compute VM and access the OAA management container.

    ```
    <copy>kubectl exec -it oaamgmt-0 -n oracle-oaa-system -- /bin/bash</copy>
    ```

7. Run the following cURL command to register Email and OMA as second factors for a new user. Replace the values for attributes userId , omatotpsecretkey and email with values corresponding to the new user created in the previous steps:

    ```
    <copy>
    curl -k --location --request POST 'http://oaa.oracledemo.com/oaa/runtime/preferences/v1' \
    --header 'Content-Type: application/json' \
    --header 'Authorization: Basic b2FhaW5zdGFsbC1vYWE6YXBpa2V5dG9iZXNldGR1cmluZ2luc3RhbGxhdGlvbg==' \
    -d \
    '{
      "userId": "pwalker",
      "groupId": "myoaaprotectedapp1",
      "factorsRegistered": [
        {
          "factorKey": "ChallengeOMATOTP",
          "isPreferred": false,
          "factorAttributes": [
            {
              "factorAttributeName": "omatotpsecretkey",
              "factorAttributeValue": [
                {
                  "value": "DemoAppUsrOua",
                  "name": "Device1",
                  "isEnabled": true
                }
              ]
            }
          ]
        },
        {
          "factorKey": "ChallengeEmail",
          "isPreferred": false,
          "factorAttributes": [
            {
              "factorAttributeName": "email",
              "factorAttributeValue": [
                {
                  "value": "pwalker@oracledemo.com",
                  "name": "Device1",
                  "isEnabled": true
                }
              ]
            }
          ]
        }
      ]
    }
    </copy>
    ```

8. Register the TOTP key (omatotpsecretkey) with Oracle Mobile Authenticator (OMA). Use the following instructions:

    * Open OMA in your Android emulator or mobile device

    * If this is the first time accessing OMA, click on Add Account, otherwise tap the plus (+) icon at the bottom of the screen

    * Then tap on Enter key manually link

    * In Select Account Type, choose Oracle. Then, enter the following information:

        ```
        Company    : Oracle
        Account    : <new_user>
        Key        : DemoAppUsrOua
        ```

    * Tap on Save button to register the account.

9. Proceed to verify the user preferences by logging in to the OUA self-service console with the new user.

      E.g. use the following URL and credentials:

      ```
      URL       : http://oaa.oracledemo.com/oaa/rui
      Username  : <new_user>
      Password  : <password>
      ```

10. Once you verify the factors assigned to the user, proceed to exit from the OUA self-service console.

You may now **proceed to the next lab**.

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments

* **Authors** - Anuj Tripathi

* **Last Updated By/Date** - Anuj Tripathi, North America Platform Specialist, June 2024
