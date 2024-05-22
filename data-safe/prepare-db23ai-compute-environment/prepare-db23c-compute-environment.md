# Prepare your environment

## Introduction

In this lab, you create two compute instances by using Resource Manager in Oracle Cloud Infrastructure. 

- The first compute instance (referred to as **host #1**) has Oracle Database 19c and a Glassfish java application installed.
- The second compute instance (referred to as **host #2**) has Oracle Database 23ai installed.

It's highly recommended that you let Resource Manager create the network and compute resources for you. However, if you prefer to reuse an existing VCN of your own, you can find the steps to create the necessary security rules for it in task 1. 

Estimated Lab Time: 20 minutes

### Objectives

In this lab, you will:

- (Optional) Add security rules to your existing VCN
- Create two compute instances using Resource Manager
- Add your private key to your Cloud Shell instance

### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console at `https://cloud.oracle.com`
- You have the following IAM permissions:

    ```text
    Allow group <your-group-name> to manage data-safe-sql-firewall-family in compartment <your-compartment>
    NEED TO ADD OTHER PERMISSIONS NEEDED FOR THIS LAB
    ```



## Task 1 (Optional): Add security rules to your existing VCN

Only perform this task if you are using your own VCN. If you plan to let Resource Manager create a new VCN for you, you can skip this task.

1. From the navigation menu in Oracle Cloud Infrastructure, select **Networking**, and then **Virtual Cloud Networks**.

2. Select your VCN.

3. Under **Resources**, select **Security Lists**.

4. Click the your security list.

5. Under **Resources** on the left, you can click **Ingress Rules** or **Egress Rules**. To add an egress rule, click **Egress Rules**, and then click the **Add Egress Rules** button. To add an ingress rule, click **Ingress Rules**, and then click the **Add Ingress Rules** button.

6. Add an egress rule with the following settings to allow outbound TCP traffic on all ports:

    ```
    DESTINATION TYPE: CIDR
    DESTINATION CIDR: 0.0.0.0/0
    IP PROTOCOL: TCP
    SOURCE PORT RANGE: All
    DESTINATION PORT RANGE: All
    ```

7. Add an ingress rule with the following settings to allow inbound SSH traffic on port 22:

    ```
    SOURCE TYPE: CIDR
    SOURCE CIDR: 0.0.0.0/0
    IP PROTOCOL: TCP
    SOURCE PORT RANGE: All
    DESTINATION PORT RANGE: 22
    ```

8. Add an ingress rule with the following settings to allow inbound TCP traffic on port 80 for HTTPS:

    ```
    SOURCE TYPE: CIDR
    SOURCE CIDR: 0.0.0.0/0
    IP PROTOCOL: TCP
    SOURCE PORT RANGE: All
    DESTINATION PORT RANGE: 80
    ```


9. Add an ingress rule with the following settings to allow inbound TCP traffic on port 6080 for the noVNC Remote Desktop:

    ```
    SOURCE TYPE: CIDR
    SOURCE CIDR: 0.0.0.0/0
    IP PROTOCOL: TCP
    SOURCE PORT RANGE: All
    DESTINATION PORT RANGE: 6080
    ```


## Task 2: Create two compute instances using Resource Manager

1. Download the stack ZIP file from here: https://objectstorage.us-ashburn-1.oraclecloud.com/p/AUKfPIGuTde04z4OnuaZN2EP0LxNl4hJWI2jZiTw23aWzSoa2_Byvs8OGPw20-dt/n/c4u04/b/livelabsfiles/o/security-library/dbseclabs-v55_sqlfw.zip. You do not need to extract the file.

1. From the OCI navigation menu, click **Developer Services**, and then under **Resource Manager**, click **Stacks**.

2. For **Stack information**: Click **Create stack** and select your ZIP file.

3. Configure variables: Select an availability domain. Select **Need Remote Access via SSH?**. Select **Auto Generate SSH Key Pair?**. Leave the defaults: **VM.Standard.E4.Flex** selected for the instance shape and **2 OCPUs**. Leave **Use Existing VCN** deselected to let Resource Manager create a VCN for you; otherwise, select your own VCN.

   If you change the shape, be sure that you have enough quota available in your tenancy.

4. Review the configuration, and then click **Run apply**. It takes about 15 minutes to create your two compute instances.

    The output in the log looks similar to this:

    ```text
    <copy>
    generated_instance_ssh_private_key = <sensitive>
    hol_host1 = "dbsec-hol-2024-02-16-170304 - [public-ip-host1]"
    hol_host5 = "db23c-hol-2024-02-16-170304 - [public-ip-host2]"
    remote_desktop = "http://public-ip-host1:6080/vnc.html?password=xxx&resize=scale&quality=9&autoconnect=true&reconnect=true"
    workshop_desc = "Oracle TLS Labs Workshop Setup for Database Security on LiveLabs. Provisioned VM instances using shape VM.Standard.E4.Flex" 
    </copy>
    ```


5. Click the **Application Information** tab and review the information available for your two compute instances. You can connect to the first host (which has a 19c database on it) by clicking the Remote Desktop link. You can connect to the second host (which has a 23ai database on it) by using SSH in Cloud Shell.

    ```text
    Host-#1 (DBSeclab):
    dbsec-hol-2024-02-16-170304 - [public-ip-host1]
    Access: Remote Desktop (https://cloud.oracle.com/jobs/ocid1.ormjob.oc1.iad.amaaaaaaknuwtjiak72pr6p24xlohulbc6tvqcbojbosv3bbwfw4kdhn3xva#)
    
    Host-#2 (DB23ai):
    db23c-hol-2024-02-16-170304 - [public-ip-host2]
    Auto Generated SSH Private Key:
    <sensitive> click Unlock
    ```

6. Go to the compute instances in OCI and review the information there too.

## Task 3: Add your private key to your Cloud Shell instance

1. Open Cloud Shell. 

2. (Optional) Reset your Cloud Shell instance.

    ```text
    <copy>csreset --all</copy>
    ```

3. Create a `.ssh` directory.

    ```text
    <copy>$ mkdir ~/.ssh</copy>
    ```

4. Create a file name cloudshellkey using the vi editor.

    ```text
    <copy>vi ~/.ssh/cloudshellkey</copy>
    ```

5. On the **Application information** tab, click **Unlock** to view your private key. Copy your private key data to the vi editor. It's  important that you put **-----BEGIN RSA PRIVATE KEY-----** on the first line, the key code on the second line, and **-----END RSA PRIVATE KEY-----** on the third line. Be careful not to include any code for line breaks.

    Here is an example:

    ```text
    <copy>-----BEGIN RSA PRIVATE KEY-----
    MIIEowIBAAKCAQEAoLeHMmDKzeYdOJYKtxaGvtTjn40X5Hfy6A/Rdem90d59m5u0\nqSXmzGYqX1Yj1tgd6...AQj8uvBC7kW8Fstl
    -----END RSA PRIVATE KEY-----</copy>
    ```

6. Give yourself permission to use the private key.

    ```text
    $ <copy>chmod 600 ~/.ssh/cloudshellkey</copy>
    ```







You may now proceed to the next lab.






