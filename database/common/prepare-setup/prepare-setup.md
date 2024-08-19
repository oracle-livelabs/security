# Prepare Setup

## Introduction
This lab will show you how to download the Oracle Resource Manager (ORM) stack zip file needed to setup the resource(s) needed to run this workshop. This workshop requires compute instance(s) running the Database Security marketplace image(s) and a Virtual Cloud Network (VCN).

Estimated Time: 20 minutes

### Objectives
-   Download ORM stack
-   Configure an existing Virtual Cloud Network (VCN)

### Prerequisites
This lab assumes you have:
- An Oracle Cloud account

## Task 1: Download Oracle Resource Manager (ORM) stack zip file
1.  Click on the link below to download the Resource Manager zip file you need to build your environment:

<if type="basics">
    - [`dbseclabs-v62_init-vm.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm.zip)
</if>
<if type="advanced">
    - [`dbseclabs-v62_advanced.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_advanced.zip)
</if>
<if type="aso">
    - [`dbseclabs-v62_init-vm-aso.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-aso.zip)
</if>
<if type="avdf">
    - [`dbseclabs-v62_avdf.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_avdf.zip)
</if>
<if type="data-masking-subsetting">
    - [`dbseclabs-v62_init-vm-dms.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-dms.zip)
</if>
<if type="data-safe">
    - [`dbseclabs-v62_init-vm-dsop.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-dsop.zip)
</if>
<if type="database-vault">
    - [`dbseclabs-v62_init-vm-dbv.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-dbv.zip)
</if>
<if type="dbsat">
    - [`dbseclabs-v62_init-vm-dbsat.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-dbsat.zip)
</if>
<if type="key-vault">
    - [`dbseclabs-v631_okv.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v631_okv.zip)
</if>
<if type="key-vault_ssh">
    - [`dbseclabs-v62_okv_ssh.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_okv_ssh.zip)
</if>
<if type="label-security">
    - [`dbseclabs-v62_init-vm-ols.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-ols.zip)
</if>
<if type="nne">
    - [`dbseclabs-v62_init-vm-nne.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-nne.zip)
</if>
<if type="priv-analysis">
    - [`dbseclabs-v62_init-vm-pa.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-pa.zip)
</if>
<if type="sqlfw">
    - [`dbseclabs-v63_sqlfw.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v63_sqlfw.zip)
</if>
<if type="story-hack">
    - [`dbseclabs-v45_storyhack.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v45_storyhack.zip)
</if>
<if type="tsdp">
    - [`dbseclabs-v62_init-vm-tsdp.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-tsdp.zip)
</if>
<if type="unified-auditing">
    - [`dbseclabs-v62_init-vm-ua.zip`](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v62_init-vm-ua.zip)
</if>

2.  Save in your downloads folder

We strongly recommend using this stack to create a self-contained/dedicated VCN with your instance(s). Skip to *Step 3* to follow our recommendations. If you would rather use an exiting VCN then proceed to the next step as indicated below to update your existing VCN with the required Egress rules.

## Task 2: Adding Security Rules to an Existing VCN   
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

## Task 3: Setup Compute   
Using the details from the two steps above, proceed to the lab *Environment Setup* to setup your workshop environment using Oracle Resource Manager (ORM) and one of the following options:
  -  Create Stack:  *Compute + Networking*
  -  Create Stack:  *Compute only* with an existing VCN where security lists have been updated as per *Step 2* above

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Hakim Loumi, Database Security PM
* **Contributors** - Rene Fontcha, Master Principal Solutions Architect, NA Technology
* **Last Updated By/Date** - Hakim Loumi, Database Security PM - May 2024
