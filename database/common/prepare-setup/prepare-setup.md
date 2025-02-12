# Environment Setup

## Introduction
This lab will show you how to set up a Oracle Resource Manager (ORM) stack that will generate the Oracle Cloud objects needed to run your workshop.

Estimated Time: 25 minutes

### Objectives
- Download Oracle Resource Manager (ORM) Stack zip file
- Create a Stack: Compute + Networking (New VCN) or Compute only (Existing VCN)
- Terraform Apply

### Prerequisites
This lab assumes you have:
- An Oracle Cloud account
- SSH Keys (optional)

## Task 1: Download Oracle Resource Manager (ORM) stack zip file
1.  Click on the link below to download the Resource Manager zip file you need to build your environment:

<if type="aso">
    - [`dbseclabs-init-vm-aso.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-aso.zip)
</if>
<if type="avdf">
    - [`dbseclabs-avdf.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_avdf.zip)
</if>
<if type="data-masking-subsetting">
    - [`dbseclabs-init-vm-dms.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v90_init-vm-dms.zip)
</if>
<if type="data-safe">
    - [`dbseclabs-init-vm-dsop.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-dsop.zip)
</if>
<if type="database-vault">
    - [`dbseclabs-init-vm-dbv.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-dbv.zip)
</if>
<if type="dbsat">
    - [`dbseclabs-init-vm-dbsat.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-dbsat.zip)
</if>
<if type="key-vault">
    - [`dbseclabs-okv.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v63_okv.zip)
</if>
<if type="key-vault_ssh">
    - [`dbseclabs-okv_ssh.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_okv_ssh.zip)
</if>
<if type="label-security">
    - [`dbseclabs-init-vm-ols.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-ols.zip)
</if>
<if type="nne">
    - [`dbseclabs-init-vm-nne.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-nne.zip)
</if>
<if type="priv-analysis">
    - [`dbseclabs-init-vm-pa.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-pa.zip)
</if>
<if type="sqlfw">
    - [`dbseclabs-sqlfw.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v63_sqlfw.zip)
</if>
<if type="story-hack">
    - [`dbseclabs-storyhack.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v71_storyhack.zip)
</if>
<if type="tsdp">
    - [`dbseclabs-init-vm-tsdp.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-tsdp.zip)
</if>
<if type="unified-auditing">
    - [`dbseclabs-init-vm-ua.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-ua.zip)
</if>

2.  Save in your downloads folder

Now, proceed to deploy your workshop environment using Oracle Resource Manager (ORM) stack where you have 2 options:

Task 2A: Create Stack: Compute + Networking (recommended)
Task 2B: Create Stack: Compute Only

## Task 2A: Create Stack: Compute + Networking (recommended)   

1. Identify the ORM stack zip file downloaded in the previous task
2. Log in to Oracle Cloud
3. Open up the hamburger menu in the top left corner. Click **Developer Services**, and choose **Resource Manager > Stacks**. Choose the compartment in which you would like to install the stack. Click **Create Stack**.

4. Select **My Configuration**, choose the **.Zip file** button, click the **Browse** link, and select the zip file that you downloaded or drag-n-drop for the file explorer.

5. Click **Next**.

6. Enter or select as shown below:

    - **Instance Count:** Accept the default, **1**, unless you intend to create more than one (e.g. for a team)

    - **Select an availability domain:** Select an availability domain from the dropdown list.

    - **Need Remote Access via SSH?** In this step you have 3 options to select from:

        - Option (A) - Keep Unchecked for Remote Desktop only Access - The Default

        - Option (B) - Check *Need Remote Access via SSH?* and keep *Auto Generate SSH Key Pair* unchecked to enable remote access via SSH protocol, then provide the SSH public key(s).

            - SSH Public Key: Select from the following two options
                - *Paste SSH Keys:* Paste the plaintext key strings or
                - *Choose SSH Key Files:* Drag-n-drop or browse and select valid public keys of openssh format from your computer

Notes:
1. This assumes that you already have an RSA-type SSH key pair available on the local system where you will be connecting from. If you don't and for more info on creating and using SSH keys for your specific platform and client, please refer to the guide Generate SSH Keys
2. If you used the Oracle Cloud Shell to create your key, make sure you paste the pub file in a notepad, and remove any hard returns. The file should be one line or you will not be able to login to your compute instance

    - Option (C) - Check *Need Remote Access via SSH?* and *Auto Generate SSH Key Pair* to have the keys auto-generated for you during provisioning. If you select this option you will be provided with the private key post provisioning.

Depending on the quota you have in your tenancy you can choose from standard Compute shapes or Flex shapes. Please visit the Appendix: Troubleshooting Tips for instructions on checking your quota
    - **Use Flexible Instance Shape with Adjustable OCPU Count?:** Keep the default as checked (unless you plan on using a fixed shape)
    - **Instance Shape:** Keep the default or select from the list of Flex shapes in the dropdown menu (e.g VM.Standard.E4.Flex).
    - **Instance OCPUS:** Accept the default shown. e.g. (**4**) will provision 4 OCPUs and 64GB of memory. You may also elect to reduce or increase the count by selecting from the dropdown. e.g. [2-24]. Please ensure you have the capacity available before increasing.

If don't have the required quota for Flex Shapes or you prefer to use fixed shapes, follow the instructions below. Otherwise, skip to the next step.

**Use Flexible Instance Shape with Adjustable OCPU Count?:** Unchecked
**Instance Shape**: Accept the default shown or select from the dropdown. e.g. VM.Standard2.2

7. For this section we will provision a new VCN with all the appropriate ingress and egress rules needed to run this workshop. If you already have a VCN, make sure it has all of the correct ingress and egress rules and skip to the next section.

    - **Use Existing VCN?:** Accept the default by leaving this unchecked. This will create a new VCN.
8. Click **Next**.

9. Select **Run Apply** and click **Create**.

10. Your stack has now been created and the *Apply* action triggered is running to deploy your environment!

You may now proceed to Task 3 (skip Task 2B).

## Task 2B: Create Stack: Compute only  
If you just completed Task 2A, please proceed to Task 3. If you have an existing VCN and are comfortable updating its configurations, please add the security rules to your VCN as described below:

Note: We recommend letting our stack create the VCN to reduce the potential for errors.

This workshop requires a certain number of ports to be available, a requirement that can be met by using the default ORM stack execution that creates a dedicated VCN. In order to use an existing VCN the following ports should be added to Egress rules

| Port | Description          |
| :--- | :------------------- |
| 22   | SSH                  |
| 80   | Application (http)   |
| 6080 | noVNC Remote Desktop |
{: title="Required Ports"}

| Port  | Description               |
| :---- | :------------------------ |
| 443   | Application (https)       |
| 7803  | Oracle Enterprise Manager |
| 8080  | Glassfish Application     |
| 50002 | Glassfish Application     |
{: title="Optional Ports - For Apps Access outside of noVNC remote desktop"}

1.  Go to *Networking >> Virtual Cloud Networks*
2.  Choose your network
3.  Under Resources, select Security Lists
4.  Click on Default Security Lists under the Create Security List button
5.  Click Add Ingress Rule button
6.  Enter the following:  
    - Source CIDR: 0.0.0.0/0
    - Destination Port Range: *Refer to above table(s)*
7.  Click the Add Ingress Rules button

## Task 3: Review Stack Details  

1. Review the Stack Job Details.

2. Your public IP address(es), instance name(s), and remote desktop URL are displayed. Congratulations, your environment has been created! 

## Task 4: Access Remote Desktop  

For ease of execution of this workshop, your VM instance has been pre-configured with a remote desktop accessible using any modern browser on your laptop or workstation. Proceed as detailed below to log in.

1. Navigate to **Stack Details** -> **Application Information** tab, and click the **Remote Desktop** URL.

This should take you directly to your remote desktop in a single click.

Remote desktop displayed

Note: While rare, you may see an error on the browser - *“Deceptive Site Ahead”* or similar depending on your browser type as shown below.
Public IP addresses used for LiveLabs provisioning come from a pool of reusable addresses and this error is because the address was previously used by a compute instance long terminated, but that wasn't properly secured, got bridged, and was flagged. You can safely ignore and proceed by clicking on *Details*, and finally, on *Visit this unsafe site*.

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Hakim Loumi, Database Security PM
* **Contributors** - Rene Fontcha, Master Principal Solutions Architect, NA Technology
* **Last Updated By/Date** - Kajal Singh, Database Security PM - January 2025
