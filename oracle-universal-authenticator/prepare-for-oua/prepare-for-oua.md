# Prepare your system for Oracle Universal Authenticator

## Introduction

  Oracle Universal Authenticator is a unified authentication solution that provides device authentication and cross-platform single-sign on (SSO) to web-based and desktop applications.

  The Oracle Universal Authenticator hands-on lab requires users to have their own Microsoft Windows 10 or Windows 11 licenses. Users also need to have a Microsoft Entra ID subscription and the appropriate user accounts to join the Windows machines to the Entra ID domain. Additionally, an Android emulator, such as Nox Android Emulator, is required to test push notifications. These software and subscriptions are non-Oracle products and must be acquired independently by the lab participants. Please refer to Prerequisites section for more details.

  This lab focuses setting and configuring the softwares and the components required to perform device based authentication, along with SSO to web and desktop applications.

* Estimated Time: 120 minutes
* Persona: End-User

### Objectives

In this lab, you will:

* Configure Nox Android Emulator with OMA

* Join Demo Windows Image to Entra ID Domain

* Install and Configure OUA

* Creating OAM User and Registering OUA User Preferences

### Prerequisites

This lab assumes you have:

* You have a **Windows 10 computer** with Internet connectivity and the latest version of VirtualBox installed with at least 100GB of free disk space, 32 GB of RAM and 4 cores in order to deploy the VM Demo Windows Image

* You have installed [7-Zip](https://www.7-zip.org/) utility in your Windows host machine

* You have a **Windows 10/11 virtual image** running as a VM inside VirtualBox

* You have administrative access to a **Microsoft Entra ID domain** in order to create Entra ID users

* Optionally, you have administrative access to a Microsoft Office 365 subscription in order to assign Office 365 licenses to Entra ID users.

  ***Note*** :The deployment of VirtualBox and other components was tested on a Windows machine. Although, you can use a Mac computer to deploy those components, the instructions in this document only apply to Windows OS

## Task 1: Download and Configure Nox Android Emulator for OMA

1. Download [Nox Android Emulator](https://support.bignox.com/en/win-release) in your host Windows computer.
   You can download the one with support for Android 7 (e.g. V7.0.5.9)

   ***Note :*** This is required in order to perform the passwordless authentication use case which requires OMA push notifications.

2. Nox Player use adware, so a way to prevent this from happening, add below firewall rules
   In your Windows taskbar, click on Start icon and type cmd.exe, make sure to select Run as administrator. Then, in the command window run the following commands:

    ```
      <copy>
      netsh advfirewall firewall add rule name="Nox Block In" dir=in action=block remoteip=220.181.0.0-220.181.255.255,183.128.0.0-183.143.255.255,182.92.0.0-182.92.255.255,101.200.0.0-101.201.255.255,211.151.0.0-211.151.255.255,198.11.128.0-198.11.191.255,124.160.0.0-124.160.255.255,140.205.0.0-140.205.255.255,110.173.192.0-110.173.223.255,121.52.224.0-121.52.255.255,178.162.216.0-178.162.219.255

      netsh advfirewall firewall add rule name="Nox Block Out" dir=out action=block remoteip=220.181.0.0-220.181.255.255,183.128.0.0-183.143.255.255,182.92.0.0-182.92.255.255,101.200.0.0-101.201.255.255,211.151.0.0-211.151.255.255,198.11.128.0-198.11.191.255,124.160.0.0-124.160.255.255,140.205.0.0-140.205.255.255,110.173.192.0-110.173.223.255,121.52.224.0-121.52.255.255,178.162.216.0-178.162.219.255
      </copy>
    ```

    Type exit to close cmd.exe

3. Use the **7-Zip** utility to unpack the file **nox\_setup\_v7.0.5.9\_full\_intl.exe** in your computer. This will create a folder **nox\_setup\_v7.0.5.9\_full\_intl**

4. Go to **bin** sub-folder and run **MultiPlayerManager.exe** or Nox Asst

5. Click on **Multi-Drive Manager** icon located in the left panel. Then click on **Add Emulator** button and select **Android 7 64-bit**

6. Select the image and click on System settings (gear icon). Make sure to select **540x960** under **Resolution settings**. Click Save settings, OK.

7. Under System Settings, navigate inside General, select **Root** checkbox under **Startup Items**. Save the settings.

8. Click on More (3-dots icon) and select Create shortcut. This will add a shortcut to your Windows desktop to directly start the the image with the emulator. Proceed to exit Nox Asst by closing the window.

9. From your Windows desktop click on the shortcut **NoxPlayer** to start the emulator with the Android 7 image. Once the emulator is started, withing the emulator, use Google Play Store to install **Oracle Mobile Authenticator** and **Google Chrome** mobile apps

10. From the android emulator, click File Manager (folder icon). In File Manager, click in the Hamburger icon and select **/Root**. Go to **etc** folder, then scroll down and click on hosts file, and select **Open as text**.

  In the Open with... window, click on JUST ONCE. Proceed to enter or paste the hosts entries for OUA server.
  E.g. add or copy the following entries:

    ```
      <PUBLIC_IP>    so92-srv1.oracledemo.com iamdb.oracledemo.com oud.oracledemo.com oam.oracledemo.com aso.oracledemo.com oaa.oracledemo.com ora.oracledemo.com oim.oracledemo.com mail.oracledemo.com
      <PUBLIC_IP>    oiri.oracledemo.com grafana.oracledemo.com prometheus.oracledemo.com oap.oracledemo.com oudsm.oracledemo.com ade.oracledemo.com demodb.oracledemo.com
    ```

    ***Note :*** PUBLIC_IP is the public IP address of the compute instance noted in **Lab 2 -> Task 1**. In Windows, you need to split the hostname entries in two lines due to a length limitation.

    Click on the Save icon, then close File Explorer (click in the Task icon, located at the bottom of the black bar right to the emulator window). This will minimize the File Explorer window, you can close it by clicking the X icon.

## Task 2: Join Demo Windows Image to Entra ID Domain

1. Access the Windows 11 guest VM as administrator, proceed to join your Windows 11 VM to an existing Entra ID domain.

    ***Note :*** This step presumes you have an Entra ID user account, if not, create a new user using Entra ID administrative console and come back to perform this step.

2. From Window 11 VM, type **Settings** in the search box located in the taskbar. **Open Settings -> Accounts -> Access work or school**. Click **Connect**

3. In the Set up access work or school account window, clink on the link **Join this device to Microsoft Entra ID**

4. Provide the Entra ID user credentials (as mentioned in Task 1).

    ```
    Entra ID User : <UPN>
    Entra ID User Password  : <user_password>
    ```

5. In the confirmation window, click **Join** and then click **Done**

6. Logout from Windows 11 guest VM. Proceed to complete the registration by logging back this time using the Entra ID user (select **Other user** in the Windows login page).

7. As you login for the first time with the Entra ID user, you will be required to setup a second factor (E.g. using Microsoft Authenticator) and define a PIN for security reasons.

## Task 3: Installing and Configuring OUA

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

2. Once in the Windows guest VM, type **Notepad++** in the search box located in the taskbar. Open the Notepad++ tool (already installed) to edit the Windows hosts file.

  Using Notepad++, edit the following file:

  **C:\Windows\System32\drivers\etc\hosts**

   ***Note :*** Replace **PUBLIC_IP** with the IP of the compute instance noted in **Lab 2 -> Task 1**

    ```
    <copy>
    <PUBLIC_IP>    so92-srv1.oracledemo.com iamdb.oracledemo.com oud.oracledemo.com oam.oracledemo.com aso.oracledemo.com oaa.oracledemo.com ora.oracledemo.com oim.oracledemo.com mail.oracledemo.com
    <PUBLIC_IP>    oiri.oracledemo.com grafana.oracledemo.com prometheus.oracledemo.com oap.oracledemo.com oudsm.oracledemo.com ade.oracledemo.com demodb.oracledemo.com
    </copy>
    ```

3. Proceed to install OUA by downloading the Oracle\_Universal\_Authenticator\_<version.zip\> from [Oracle Software Delivery Cloud](https://edelivery.oracle.com/).

  Alternatively, it can be downloaded from the location referenced in document ID 2723908.1 on My Oracle Support.
  Extract the zip file to a working directory **WORKDIR (e.g. C:\Temp\V1043799-01)** on the installation host. The Oracle Universal Authenticator.msi will be extracted.

  Right-click on zip file **Oracle Universal Authenticator.msi** and select **Run as Administrator**

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

5. Once the installation completes, click **Finish** but choose **No** to not reboot the computer.

6. From Window 11 guest VM, type **regedit** in the search box located in the taskbar. Open Registry Editor.

7. Within Registry Editor, expand **Computer\HKEY\_LOCAL\_MACHINE\SOFTWARE\Oracle\Oracle Universal Authenticator** and update the parameters as below :

    host

    ```
    <copy>http://oaa.oracledemo.com</copy>
    ```

    port

    ```
    <copy>80 (Decimal)</copy>
    ```

8. Exit Registry Editor.

9. Register the OUA certificate. In your Windows taskbar, click on Start icon and type cmd.exe, make sure to select Run as administrator. Change directory to the **WORKDIR** referred in step 3 above and run the following command :

    ```
    <copy>
    powershell.exe -ExecutionPolicy Bypass "C:\Temp\V1043799-01\AddCertificate.ps1"
    </copy>
    ```

  ***Note :*** Kindly ignore the error with source already registered.

10. Type exit to close cmd.exe. Proceed to reboot the Windows computer.

## Task 4: Creating OAM User and Registering OUA User Preferences

1. OUA users must be created in the OAM directory, e.g. OUD. We will use Oracle Directory Services Manager (ODSM) console to create a new OAM user and add it to the **OAA-App-User** users group.

    ***Note :*** These steps will be performed using the host Windows machine.

    Using a text editor, modify the following LDIF file and update the attributes corresponding to the new user: **dn, givenName, uid, sn, mail, orclSAMAccountName and cn**. Update **dn** and **uniquemember** for the group membership.

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

3. Within ODSM, click on **Data Browser** tab. Under **Data Tree**, click the Import LDIF icon (blue arrow pointing down). Select the LDIF file edited in the previous steps and click OK.

4. Once the import is completed, expand **Root -> dc=oracledemo,dc=com -> ou=iam -> cn=users**, and make sure the new user is listed.

5. Now, expand **Root -> dc=oracledemo,dc=com -> ou=iam -> cn=groups**. Select group **cn=OAA-App-User**. In the right panel expand Member Information, and make sure the new user is listed. Proceed to exit ODSM.

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

    * Open OMA on your mobile device

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

* [Oracle Universal Authenticator Product Documentation](https://docs.oracle.com/en/middleware/idm/universal-authenticator/)

* [Oracle Universal Authenticator System Architecture](https://docs.oracle.com/en/middleware/idm/universal-authenticator/ouaad/system-architecture-and-components.html)

* [Oracle Advanced Authentication](https://docs.oracle.com/en/middleware/idm/advanced-authentication/oaarm/introducing-oaa.html)

## Acknowledgements

* **Created By/Date** - Anuj Tripathi, North America Platform Specialist (IAM/Cloud), July 2024

* **Last Updated By** - Anuj Tripathi, July 2024
