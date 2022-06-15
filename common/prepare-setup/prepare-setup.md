# Prepare Setup

## Introduction
This lab will show you how to download the Oracle Resource Manager (ORM) stack zip file needed to setup the resource(s) needed to run this workshop. This workshop requires compute instance(s) running the Database Security marketplace image(s) and a Virtual Cloud Network (VCN).

*Estimated Lab Time:* 15 minutes

### Objectives
-   Download ORM stack
-   Configure an existing Virtual Cloud Network (VCN)

### Prerequisites
This lab assumes you have:
- An Oracle Cloud account

## Task 1: Download Oracle Resource Manager (ORM) stack zip file
1.  Click on the link below to download the Resource Manager zip file you need to build your environment:

<if type="avdf">
    - [dbsec-mkplc-avdf.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/HYXXlohY2BB5PUqBLunrMtm-ou2ZIciE5WxLOM0VbBKQs0QEEV_F2gKLYV12cFcd/n/natdsecurity/b/stack/o/dbsec-mkplc-avdf.zip)
</if>
<if type="basics">
    - [dbsec-mkplc-basics.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/yGgqrthkE0Io7m40mZ9E9P2zopZJg4Y24B8TBj72wPQk79YCCBNyjsmC-MmbDYWU/n/natdsecurity/b/stack/o/dbsec-mkplc-basics.zip)
</if>
<if type="fundamentals">
    - [dbsec-mkplc-fundamentals.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/p-Mb77uhoggHTuMrZOq-oDUyetQXvs9PeMyL9ReCqNWfTN3EkzmHoFo7LfufhZq9/n/natdsecurity/b/stack/o/dbsec-mkplc-fundamentals.zip)
</if>
<if type="key-vault">
    - [dbsec-mkplc-key-vault.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/rE6JIMXpOwAzK4gO6kEKv1ICs9nnGM6bOlpCkj71ipBt0Dtdufx6999pIEVgHqn0/n/natdsecurity/b/stack/o/dbsec-mkplc-key-vault.zip)
</if>
<if type="aso">
    - [dbsec-mkplc-vm01-aso.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/xEJEBlJhGWlbGlP2byjmRngqqA_6c41QoQErLfA7uBebcUAS4PjdJTFaDUv7kp-B/n/natdsecurity/b/stack/o/dbsec-mkplc-vm01-aso.zip)
</if>
<if type="data-masking-subsetting">
    - [dbsec-mkplc-vm01-data-masking-subsetting.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/dmd_8omLf3ELElkRIw_P0_iSsqxnS0pkeyO_t9XjmGVxKQ0KDexGMFOnbcJIAB3L/n/natdsecurity/b/stack/o/dbsec-mkplc-vm01-data-masking-subsetting.zip)
</if>
<if type="database-vault">
    - [dbsec-mkplc-vm01-database-vault.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/i-s1WT5M2QKEaTau4uETMh5WKFWx5ge5_27_AeTEFFG6IZaClky5WS53HoHJDgrP/n/natdsecurity/b/stack/o/dbsec-mkplc-vm01-database-vault.zip)
</if>
<if type="data-safe">
    - [dbsec-mkplc-vm01-data-safe.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/i5Y5Aw1HrFU3Pli2EyRt9babAXAuTJkULeWYdPRblEQv8X0dTTvQgoWhIOQG8S7o/n/natdsecurity/b/stack/o/dbsec-mkplc-vm01-data-safe.zip)
</if>
<if type="dbsat">
    - [dbsec-mkplc-vm01-dbsat.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/QCMNJEix6fNLEtQvzKKqIMqmuXarwOo9O8LxjWY0i6aVEz1QbpBfY_Pyfyi_yBB1/n/natdsecurity/b/stack/o/dbsec-mkplc-vm01-dbsat.zip)
</if>
<if type="label-security">
    - [dbsec-mkplc-vm01-label-security.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/xKq45SkNwCkBS2BM97LGLresVFnrMgvq4QMvnXCVHCrhz3wNPH35eQ5M76WJJDVO/n/natdsecurity/b/stack/o/dbsec-mkplc-vm01-label-security.zip)
</if>
<if type="nne">
    - [dbsec-mkplc-vm01-nne.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/rQUrZ_tn4VRdQdO_vp9KbN1RZMmeyJPo4ifyzYGgAPRcB_ppvPJ4U-EMbYjf4put/n/natdsecurity/b/stack/o/dbsec-mkplc-vm01-nne.zip)
</if>
<if type="priv-analysis">
    - [dbsec-mkplc-vm01-priv-analysis.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/d4RqsYQ5fUYEhQUWrh3l_Tj2Co9XT5K7sULbDC1BrTkVN36segiiKYOcpWIQtvTl/n/natdsecurity/b/stack/o/dbsec-mkplc-vm01-priv-analysis.zip)
</if>
<if type="tsdp">
    - [dbsec-mkplc-vm01-tsdp.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/l3z-aNRSuctZUUFQ-cX6StRG5oudCNPPTg41n9mUZPFthb2DRBhlV1YX7Lkp4jsB/n/natdsecurity/b/stack/o/dbsec-mkplc-vm01-tsdp.zip)
</if>
<if type="unified-auditing">
    - [dbsec-mkplc-vm01-unified-auditing.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/JQRhvTofnls-Nhn8Kem3hmickM5YY4vvO1NXSyVNTdOfPnLwLXnZt2etZYiM8vlQ/n/natdsecurity/b/stack/o/dbsec-mkplc-vm01-unified-auditing.zip)
</if>

2.  Save in your downloads folder.

We strongly recommend using this stack to create a self-contained/dedicated VCN with your instance(s). Skip to *Step 3* to follow our recommendations. If you would rather use an exiting VCN then proceed to the next step as indicated below to update your existing VCN with the required Egress rules.

## Task 2: Adding Security Rules to an Existing VCN   
This workshop requires a certain number of ports to be available, a requirement that can be met by using the default ORM stack execution that creates a dedicated VCN. In order to use an existing VCN the following ports should be added to Egress rules

| Port           |Description                            |
| :------------- | :------------------------------------ |
| 22             | SSH                                   |
| 80             | Application (http)                    |
| 443            | Application (https)                   |
| 6080           | noVNC Remote Desktop                  |
| 7803           | Oracle Enterprise Manager             |
| 8080           | Glassfish Application                 |
| 50002          | Glassfish Application                 |

1.  Go to *Networking >> Virtual Cloud Networks*
2.  Choose your network
3.  Under Resources, select Security Lists
4.  Click on Default Security Lists under the Create Security List button
5.  Click Add Ingress Rule button
6.  Enter the following:  
    - Source CIDR: 0.0.0.0/0
    - Destination Port Range: *Refer to above table*
7.  Click the Add Ingress Rules button

## Task 3: Setup Compute   
Using the details from the two steps above, proceed to the lab *Environment Setup* to setup your workshop environment using Oracle Resource Manager (ORM) and one of the following options:
  -  Create Stack:  *Compute + Networking*
  -  Create Stack:  *Compute only* with an existing VCN where security lists have been updated as per *Step 2* above

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Rene Fontcha, Master Principal Solutions Architect, NA Technology
* **Contributors** - Kay Malcolm, Product Manager, Database Product Management
* **Last Updated By/Date** - Marion Smith, Technical Program Manager, April 2022
