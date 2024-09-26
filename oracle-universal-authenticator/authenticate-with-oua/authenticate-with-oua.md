# Authenticate with Oracle Universal Authenticator

## Introduction

OUA leverages Oracle Advanced Authentication (OAA) to extend device authentication with MFA, strengthening your organizations security framework, and preventing phishing attacks.

OUA has two software components: a client deployed on the user's devices, such as a desktop computer running Microsoft Windows, and a server component based on a microservices architecture that provides administration, self-service, device runtime support, device platform security, and identity provider gateway services.

This lab focuses on demonstrating some scenarios specific to the OUA sign-on experience.

* Estimated Time: 30 minutes
* Persona: End-User

### Objectives

In this lab, you will:

* Perform first time Login and OAM user association with Entra ID user

* Unified SSO with Windows and OAM Protected Applications

* Unified SSO with OAA Step Up Authentication

* Passwordless Authentication with Windows and OAM Protected Applications

### Prerequisites

This lab assumes you have completed the previous lab and:

* Joined Windows virtual machine to an Entra ID Domain

* Installed and Configured OUA

* Created OAM User and Registered OUA User Preferences

* Deployed Nox Android Emulator with OMA

## Task 1: First Time Login and Entra ID Domain User Association

1. Login to the Windows guest VM using the new OAM user created in the previous use case.
   Select Login with Oracle at the login window and enter the OAM username created in the previous use case, e.g.:

    ```
    Username : tuser1
    ```

   Press the Enter key, then you are prompted to enter the OAM user password and credentials for the Entra ID user:

    ```
    Password: Oracle123
    Windows Username: azuread\<UPN>
    Windows Password: <password>
    ```

   Press the Enter key.

   Then you are prompted to choose a second factor. select Enter OTP... and press the Arrow key.

    ```
    Choose a method to login : Enter OTP...
    ```

  Then use OMA from your mobile device to get the OTP code, enter the code and press the Enter key to login.

  ***Note :*** Entering the OAM and Entra ID user credentials is only required the first time to link the OAM and Entra ID user accounts as well as to store the credentials, subsequent logins will only require the OAM user credential and any configured 2nd factor.

2. Once logged in to Windows guest desktop, confirm that the logged in user is in fact an Entra ID user. Click on the Windows icon (located in the left of the search box in the taskbar) to see the user name.

## Task 2: Unified SSO with Windows and OAM Protected Applications

1. Login to the Windows VM using the new OAM user created in the previous use cases.
   Select Login with Oracle at the login window and enter the OAM user credentials. e.g.:

    ```
    Username : tuser1
    Password : Oracle123
    ```

   Then you are prompted to choose a second factor. select Enter OTP... and press the Arrow key.

    ```
    Choose a method to login : Enter OTP...
    ```

   Then use OMA on your mobile device get the OTP code, enter the code and press Enter key to login.

2. Once in the Windows desktop, proceed to open the Chrome browser. Since the OUA browser plugin was installed previously, the first time you access Chrome, you must enable the plugin.

3. Click the 3-dots (located at the top right corner of the browser window) and select **Extensions -> Manage Extensions**. In the Manage Extensions page click in the **Enable** switch under the **Oracle Universal Authenticator** tile.

4. Once the plugin is enabled, proceed to test SSO with OAM protected applications.
   E.g. open a new tab in the browser and access sample application Bank App:

    ```
    <copy>
    http://ade.oracledemo.com/bankapp/index.html
    </copy>
    ```

   You should be able to access the protected application without having to enter the OAM user credentials.

  *Note :* Optionally you can enable the plugin in other installed browsers like Microsoft Edge and Mozilla Firefox and test SSO with the protected application.

  *Note :* If the Firefox plugin is not listed under Add-ons and Themes -> Extensions, click in the gear icon and select Install Add-on From File... and choose path C:\Program Files\Oracle\Oracle Universal Authenticator\firefox\<<oua_extension@oracle.com.xpi>> to add the plugin. Then in the plugin tile, click in the 3-dots -> Manage -> Permissions and enable Access your data for all websites.

5. Proceed to close your browser and logout from Windows.

  *Note :* At this point, you should sign out from the application as you would be authenticating again with a different MFA factor.

## Task 3: Passwordless Authentication with Windows and OAM Protected Applications

1. From your Windows desktop click on the shortcut **NoxPlayer** to start the emulator with the Android 7 image

2. Once the Android emulator is started, within Android click on the Google Chrome icon

3. In the browser window, enter the URL in the Search or type web address box to access the OUA self-service console.
  E.g. use the following URL and credentials:

    ```
    URL         : http://oaa.oracledemo.com/oaa/rui
    Username    : tuser1
    Password    : Oracle123
    ```

4. In the consent page, click on Allow button to continue.

5. Once in the **OUA self-service** console, click on **Manage** button under **My Authenticators** tile

6. In the Authenticator Factors page, click on **Add Authenticator** Factor list-box and select **OMA Push Notification Challenge**. Write down the **userid** number and click on **Register here** link

7. In the Login Required window, enter the OAM user and as password the userid number and click the Sign In button. The new user should be added to the Accounts page in OMA

8. Click on the Tasks icon (located at the bottom of black bar, right side of the emulator window) and select the Chrome browser

9. Back in the OUA self-service console (Add Mobile Device), click Done

10. In the Authenticator Factors page, click on the **3-dots** under OMA Push Notification Challenge tile and select **Set As Default**. Make sure **Default** text with a green circle is listed in the OMA Push Notification Challenge tile

11. Proceed to logout from the OUA self-service console

12. Click the Tasks icon and go back to the OMA window in your Android emulator

13. Login to the Windows VM using the OAM user created in the previous use cases.
  Select Login with Oracle at the login window and enter the OAM username. e.g.:

    ```
    Username : tuser1
    ```

    Since OMA Push Notification Challenge is set as default, OUA will not show the list-box to choose a second factor, instead will show a message (see below) and send a notification to OMA and wait for approval.

    ```
    Approve login on device
    ```

    Go back to the Android emulator and check if OMA has received a notification (bell icon), if so, proceed to open the notification and **Allow the request**.

    Once the OMA response is processed, back in the Windows VM, the OAM user should be able to access the Windows desktop

14. Once in the Windows desktop, proceed to open the Chrome browser. If you enable the OUA browser plugin in the previous use case, then skip the next step to enable it.

15. If this is your first time accessing Chrome, you must enable the OUA browser plugin. Click the **3-dots** (located at the top right corner of the browser window) and select **Extensions -> Manage Extensions**. In the Manage Extensions page click on the Enable switch under the Oracle Universal Authenticator tile.

16. If the OUA plugin is enabled, proceed to test SSO with OAM protected applications.
    E.g. open a new tab in the browser and enter the following URL:

    ```
    <copy>
    http://ade.oracledemo.com/bankapp/index.html
    </copy>
    ```

    You should be able to access the protected application without having to enter the OAM user credentials.

17. Proceed to logout from Windows.

  You may now **proceed to the next lab**.

## Learn More

* [Oracle Universal Authenticator Product Documentation](https://docs.oracle.com/en/middleware/idm/universal-authenticator/)

* [Oracle Universal Authenticator System Architecture](https://docs.oracle.com/en/middleware/idm/universal-authenticator/ouaad/system-architecture-and-components.html)

* [Oracle Advanced Authentication](https://docs.oracle.com/en/middleware/idm/advanced-authentication/oaarm/introducing-oaa.html)

## Acknowledgements

* **Created By/Date** - Anuj Tripathi, North America Platform Specialist (IAM/Cloud), July 2024

* **Last Updated By** - Anuj Tripathi, Aug 2024
