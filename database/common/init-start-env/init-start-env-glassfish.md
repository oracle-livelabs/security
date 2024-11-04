# Initialize Environment

## Introduction

In this lab we will review and startup all components required to successfully run this workshop.

Estimated Time: 10 minutes maximum.

### Objectives
- Initialize the workshop environment.

### Prerequisites
This lab assumes you have:
<if type="brown">
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
</if>
<if type="green">
- An Oracle Cloud account
- You have completed:
    - Introduction Tasks
</if>

**Note:** All screenshots for SSH terminal type tasks featured throughout this workshop were captured using the *MobaXterm* SSH Client as described in this step. As a result when executing such tasks from within the graphical remote desktop session, skip steps requiring you to login as user *oracle* using *sudo su - oracle*, the reason being that the remote desktop session is under user *oracle*.

## Task 1: Validate That Required Processes are up and running

1. Now with access to your remote desktop session, proceed as indicated below to validate your environment before you start executing the subsequent labs. The following Processes should be up and running:

    - My HR Applications on Glassfish

2. Open new browser tabs and confirm successful rendering of *My HR Applications* listed below.

    - PDB1

        ```
        Prod: <copy>http://dbsec-lab:8080/hr_prod_pdb1</copy>
        ```

        ```
        Dev: <copy>http://dbsec-lab:8080/hr_dev_pdb1</copy>
        ```

    - PDB2

        ```
        Prod: <copy>http://dbsec-lab:8080/hr_prod_pdb2</copy>
        ```

        ```
        Dev: <copy>http://dbsec-lab:8080/hr_dev_pdb2</copy>
        ```

    **Note**: If all are successful, then your environment is ready.  

3. If you are still unable to get all links above to render successfully, open a terminal session and proceed as indicated below to validate the services.

    - Database services (All databases and Standard Listener)

        ```
        <copy>
        sudo systemctl status oracle-database
        </copy>
        ```

        ![DB Service Status](images/db-service-status.png "DB Service Status")

    - DBSec-lab Service (My HR Applications on Glassfish)

        ```
        <copy>
        sudo systemctl status oracle-dbsec-lab
        </copy>
        ```

        ![DBSecLab Service Status](images/dbsec-lab-service-status.png "DBSecLab Service Status")

4. If you see questionable output(s), failure or down component(s), restart the corresponding service(s) accordingly

    - Database and Listener

        ```
        <copy>
        sudo systemctl restart oracle-database
        </copy>
        ```

    - DBSec-lab Service

        ```
        <copy>
        sudo systemctl restart oracle-dbsec-lab
        </copy>
        ```

You may now **proceed to the next lab**.

<if type="brown">
## Appendix: External access
If for any reason you want to login from a location that is external to your remote desktop session such as your workstation/laptop, then refer to the details below.

1. My HR Applications on Glassfish

    - PDB1
      - Prod        : `http://<YOUR_DBSECLAB-VM_PUBLIC-IP>:8080/hr_prod_pdb1`
      - Dev         : `http://<YOUR_DBSECLAB-VM_PUBLIC-IP>:8080/hr_dev_pdb1`   (bg: red)
    - PDB2
      - Prod        : `http://<YOUR_DBSECLAB-VM_PUBLIC-IP>:8080/hr_prod_pdb2`  (menu: red)
      - Dev         : `http://<YOUR_DBSECLAB-VM_PUBLIC-IP>:8080/hr_dev_pdb2`   (bg: red & menu: red)
</if>

## Acknowledgements
- **Author** - Rene Fontcha, LiveLabs Platform Lead, NA Technology
- **Contributors** - Marion Smith, Hakim Loumi
- **Last Updated By/Date** - Hakim Loumi, Database Security PM - November 2024