# Oracle Key Vault (OKV) - SSH scenario

## Introduction
This workshop introduces the advanced features and functionality of Oracle Key Vault (OKV). It gives the user an opportunity to learn how to configure this appliance to manage SSH keys.

*Estimated Lab Time:* 35 minutes

*Version tested in this lab:* Oracle OKV 21.8 and DBEE 23.4

### Video Preview
Watch a preview of "*LiveLabs - Oracle Key Vault*" [](youtube:4VR1bbDpUIA)

### Objectives
- Connect an application by using SSH key pair stored in the Oracle Key Vault appliance

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment

### Lab Timing (estimated)

| Step No. | Feature | Approx. Time | Details |
|--|------------------------------------------------------------|-------------|--------------------|
| 1| (Mandatory) Prerequisites | 5 minutes||
|2a| Set Remote Server Access Controls with OKV | 10 minutes||
|2b| Set Remote Client Access Controls with OKV | 10 minutes||
|2c| SSH Key Management with OKV | 5 minutes||
| 3| Reset the OKV Lab Config | <5 minutes||

## Task 1: (Mandatory) Prerequisites

1. **Before beginning this lab**, make sure you can connect to each VM in both directions with the SSH key paris already set within the VMs!

    - Click on each NoVNC Remote Desktop link available in the Labs details to open a web browser tabs for each of them

        ![Key Vault](./images/okv_ssh-001.png "SSH Server - NoVNC Remote Desktop")

        ![Key Vault](./images/okv_ssh-002.png "SSH Client - NoVNC Remote Desktop")

    - On the **SSH Server** remote desktop (here *`DBSEC-LAB`* with private IP *`10.0.0.150`*). This tab will be the main one for the duration of the lab

        - Open a Terminal session as OS user *opc*

            ````
            <copy>
            sudo su - opc
            </copy>
            ````

            **Note**: If you are using a remote desktop session, double-click on the *Terminal* icon on the desktop to launch a session

        - Make sure you have access to SSH Client VM (here *`DB23AI`* with private IP *`10.0.0.155`*) as OPC

            ````
            <copy>
            ssh -i ~/.ssh/id_rsa opc@10.0.0.155
            </copy>
            ````

            ![Key Vault](./images/okv_ssh-003.png "SSH Server VM access to SSH Client VM")

        - If so, please close the SSH session

            ````
            <copy>
            exit
            </copy>
            ````

    - On the **SSH Client** remote desktop (here *`DB23AI`* with private IP *`10.0.0.155`*)

        - Open a Terminal session as OS user *opc*

            ````
            <copy>
            sudo su - opc
            </copy>
            ````

            **Note**: If you are using a remote desktop session, double-click on the *Terminal* icon on the desktop to launch a session

        - Make sure you have access to SSH Client VM (here *`DBSEC-LAB`* with private IP *`10.0.0.150`*) as OPC

            ````
            <copy>
            ssh -i ~/.ssh/id_rsa opc@10.0.0.150
            </copy>
            ````

            ![Key Vault](./images/okv_ssh-004.png "SSH Client VM access to SSH Server VM")

        - If so, please close the SSH session

            ````
            <copy>
            exit
            </copy>
            ````

    - Now, you can confirm that, with the SSH key pair preset, you can connect to the VMs with the command ssh

2. **Reset the randomly generated password** (when you login to the Key Vault console for the first time, you will be asked to change the default password)

    - Open a web browser window to *`https://kv`* to access to the Key Vault Web Console

        **Note**: If you are not using the remote desktop you can also access this page by going to *`https://<OKV-VM_@IP-Public>`*

    - Login to Key Vault Web Console as *`KVRESTADMIN`* (use the password randomly generated)

        ````
        <copy>
        KVRESTADMIN
        </copy>
        ````

        ![Key Vault](./images/okv_ssh-100.png "OKV - Login")

        **Note**:
        - A new password for all the OKV users is randomly generated during the deployment of the Livelabs
        - This default password is available in the Labs details or by executing the following command line as *`oracle`* user:

            ````
            <copy>
            sudo - su oracle
            echo $OKVUSR_PWD
            </copy>
            ````

    - Set your new password
    
        ![Key Vault](./images/okv_ssh-101.png "OKV - Login")

    - Click [**Save**]

    - Logout


## Task 2a: Set Remote Server Access Controls with OKV
In this lab, we will introduce remote server access controls by centrally managing users public keys

1. Go back on the **OKV Web Console** and logon as KVRESTADMIN with your new password

    ````
    <copy>
    KVRESTADMIN
    </copy>
    ````

    ![Key Vault](./images/okv_ssh-100.png "OKV - Login")

2. Create an SSH Server endpoint dbseclab as KVRESTADMIN

    - Click on "Endpoint" tab

        ![Key Vault](./images/okv_ssh-010.png "OKV Console Endpoint")

    - Click Add

        ![Key Vault](./images/okv_ssh-011.png "Add Endpoint")

    - Fill it out: "dbseclab" / "SSH Server" / Hostname : "10.0.0.150" / "Linux"

        ![Key Vault](./images/okv_ssh-012.png "Add Endpoint - Form")

    - Click Register

3. Create an SSH Server wallet **`opc_at_dbseclab`**

    - Click on "Key & Wallets" tab

        ![Key Vault](./images/okv_ssh-013.png "Key & Wallets tab")

    - Click Create

    - Fill it out: `opc_at_dbseclab` / select `SSH Server` / Host user: `opc`

        ![Key Vault](./images/okv_ssh-014.png "Key & Wallets - Form")

    - Click Save

    - Click on the "Edit" pencil icon to the right

        ![Key Vault](./images/okv_ssh-014.png "Key & Wallets - Edit")

    - Click Add next to Wallet Access Settings

        ![Key Vault](./images/okv_ssh-015.png "Add Wallet")

    - Select Endpoints from the drop-down menu

        ![Key Vault](./images/okv_ssh-016.png "Add Wallet")

    - select the `dbseclab` endpoint, and under **Select Access Level**, click the `Read Only` and `Manage Wallet` radio buttons

        ![Key Vault](./images/okv_ssh-012.png "Wallet - Form")

    - Scroll up and click “Save”

    - Click Endpoint tab

4. Download the OKV Client binaries

    - Copy the Enrollment Token of the "dbseclab" endpoint (here: 6IFiWts18puYDnJH)
    
    - Click on the user name "KVRESTADMIN" in the top right corner and select "Logout" from the drop-down menu

    - Back on the Login page, click on "Endpoint Enrollment and Software Download" link
    
    - On this page, paste the enrollment token into the text field
    
    - Click on the “Submit Token” button
    
    - If the token is valid, the other text fields are populated with the information that was entered earlier when the endpoint was created
    
    - Then click “Enroll”
    
    - Download the okvclient.jar file into **/tmp** on DBSECLAB VM

5. Go back to **your terminal session on SSH Server** (DBSECLAB VM) as opc to configure the OKV binaries

    - Create okv repo

        ````
        <copy>
        sudo mkdir -pvm700 /opt/okv
        export JAVA_HOME=/opt/oracle/product/23ai/dbhomeFree/jdk
        sudo $JAVA_HOME/bin/java -jar /tmp/okvclient.jar -d /opt/okv        
        </copy>
        ````

    - Edit okvsshendpoint.conf
    
        ````
        <copy>
        sudo vi /opt/okv/conf/okvsshendpoint.conf
        </copy>
        ````

    - Uncomment and change these 2 lines [user1] as following:

        ````
        <copy>
        [ opc ]
        ssh_server_wallet=opc_at_dbseclab
        </copy>
        ````

    - Edit sshd_config
    
        ````
        <copy>
        sudo vi /etc/ssh/sshd_config
        </copy>
        ````

    - Uncomment and change these 2 lines as following:

        ````
        <copy>
        AuthorizedKeysCommand /opt/okv/bin/okv_ssh_ep_lookup_authorized_keys get_authorized_keys_for_user %u %f %k
        AuthorizedKeysCommandUser root
        </copy>
        ````

    - Restart sshd service
    
        ````
        <copy>
        sudo systemctl restart sshd
        </copy>
        ````

    - Check the sshd service for keyscommand
    
        ````
        <copy>
        sudo sshd -T | grep keyscommand
        </copy>
        ````

6. Now, let's register your public key into OKV

    - Extract your public key from the `authorized_keys` file

        ````
        <copy>
        cd
        sudo grep "opc@db23ai" /home/opc/.ssh/authorized_keys > /home/opc/.ssh/id_rsa_ME.pub
        </copy>
        ````
        
    - Convert Client's existing public key from RSA to PKCS8 format

        ````
        <copy>
        sudo cat /home/opc/.ssh/id_rsa_ME.pub
        sudo ssh-keygen -e -m PKCS8 -f /home/opc/.ssh/id_rsa_ME.pub > /home/opc/.ssh/id_pkcs8_ME.pub
        sudo cat /home/opc/.ssh/id_pkcs8_ME.pub
        </copy>
        ````

    - Upload your public key (in PKCS8 format) to OKV

        ````
        <copy>
        sudo /opt/okv/bin/okvutil upload -l /home/opc/.ssh/id_pkcs8_ME.pub -t SSH_PUBLIC_KEY -U opc -g opc_at_dbseclab -L 2048
        </copy>
        ````

    - Set SELinux to `Permissive` if it is set to `Enforcing`

        ````
        <copy>
        sudo getenforce
        sudo setenforce 0
        sudo getenforce
        </copy>
        ````

    - Make this change permanent

        ````
        <copy>
        sudo sed -i 's|SELINUX=enforcing|SELINUX=permissive|' /etc/selinux/config
        </copy>
        ````

7. Go back on the **OKV Web Console** to change the Wallet Access mode to Read Only

    - Open Key and Wallets tab

    - Click on the wallet `opc_at_dbseclab` to confirm that your public key is there

    - Click on the Edit pencil next to Access Settings

    - Under Wallet Access Settings, click on the Edit pencil

    - Deselect the Manage Wallet radio button, and click Save

    - From now on, the dbseclab endpoint has only Read Only privileges on the SSH Server wallet `opc_at_dbseclab`

8. Go back to **your terminal session on SSH Server** (DBSECLAB VM) as opc to remove your SSH key pairs from the VM

    - Move the old authorized_keys file as well as all SSH keys into a backup directory

        ````
        <copy>
        sudo mkdir -pv ~/.ssh/.backup
        sudo mv -v ~/.ssh/authorized_keys ~/.ssh/backup
        sudo mv -v ~/.ssh/id_* ~/.ssh/backup
        </copy>
        ````

    - Double-check that SSH key pair are no longer available

        ````
        <copy>
        sudo tree -n ~/.ssh
        </copy>
        ````

9. Go back on the **OKV Web Console** to remove the public key from the SSH Server Wallet

    - Navigate to Keys & Wallets

    - Click on Wallets

    - Click on the SSH Server wallet’s name `opc_at_dbseclab`
    
        **Note**: The Wallet Contents appears

    - Click on the Edit pencil next to Wallet Contents

    - Scroll down to see the Wallet Contents

        **Note**: In this example, now we have only one public keys in the SSH Server wallet: a key created IN OKV by DBSECLAB

    - Click the checkbox of the public key that was created IN OKV by DBSECLAB

    - Then click on Remove Objects to remove the public key from the SSH Server Wallet


## Task 2b: Set Remote Server Access Controls with OKV
In this second part, we will manage users' private keys in OKV making those private keys non-extractable

1. Go back on the **OKV Web Console** and logon as KVRESTADMIN with your new password

    ````
    <copy>KVRESTADMIN</copy>
    ````

    ![Key Vault](./images/okv_ssh-100.png "OKV - Login")


2. Create a Wallet that will store an SSH key pair for you

    - Click on Keys & Wallets tab

    - Click Create

    - Fill it out as following: *`MY_SSH_KEYS`* / "General"

    - Click Save

3. Create an endpoint for your workstation

    - Click on Endpoints tab

    - Click Add

    - Fill it out as following: "DB23ai" / Other / "Linux"

    - Click Register

4. Create an SSH Server wallet **`opc_at_dbseclab`**

    - Click on "Keys & Wallets" tab

    - Click on the wallet name *`MY_SSH_KEYS`*

    - Then click on the “Edit” pencil in “Access Settings”

    - In “Wallet Access Settings”, click on “Add”

    - Select “Endpoints” from the drop-down menu

    - Click the checkbox next to "DB23AI" endpoint and confirm only “Read Only” is selected

    - Scroll up and click “Save”

    - Navigate to “Keys & Secrets” sub-menu on the left

    - Click on “Create”

    - Click on “SSH Key Pair”

    - Enter the name "ME" into the first text field, and select the wallet that you just created
    
        **Note**:
        - Leave the other values as they are
        - The deactivation time is set to 2 years from now
    
    - Click on “Create”
    
    - Click on the Wallets submenu on the left
    
    - Click on *`MY_SSH_KEYS`*
    
    - Under WALLET CONTENTS, move the horizontal slider to the right to expose the key-ID of the public key; click on the key-ID of the public key
    
    - Click on “Add Wallet Membership”
    
    - Click the check box of the SSH Server wallet `opc_at_dbseclab`
    
    - Click on the “Add” button

4. Download the OKV Client binaries

    - Click on Endpoints tab

    - Copy the enrollment token (here: 0KOqCvbI8nPqdtri)

    - Then click on “KVRESTADMIN” in the top right corner and log out

    - On the Login page, click on “Endpoint Enrollment and Software Download”

    - Copy the enrollment token into the Enrollment Token text field and click on “Submit Token”. If the token is valid, the remaining fields will be populated with information that was entered when the endpoint was created

    - Click on “Enroll”

    - Download the okvclient.jar file into /tmp **on DBSECLAB VM**

5. Go back to **your terminal session on SSH Client** (DB23AI VM) as opc to configure the OKV binaries

    - Move okvclient.jar file into /tmp from DBSECLAB VM to DB23AI VM

        ````
        <copy>
        cd /tmp
        sudo scp -i ~/.ssh/id_rsa opc@10.0.0.150:/tmp/okvclient.jar .
        </copy>
        ````

    - Install OKV Client software

        ````
        <copy>
        cd /tmp
        sudo scp -i ~/.ssh/id_rsa opc@10.0.0.150:/tmp/okvclient.jar .
        cd
        export JAVA_HOME=/opt/oracle/product/23ai/dbhomeFree/jdk
        $JAVA_HOME/bin/java -jar /tmp/okvclient.jar -d .
        </copy>
        ````

    - Verify that DB23AI endpoint can see the SSH key pair that KVRESTADMIN created

        ````
        <copy>
        ./bin/okvutil list -a
        </copy>
        ````

    - Move the old authorized_keys file as well as all SSH keys into a backup directory

        ````
        <copy>
        mkdir -pv /home/opc/.ssh/.backup
        mv -v /home/opc/.ssh/authorized_keys /home/opc/.ssh/.backup
        mv -v /home/opc/.ssh/id_* /home/opc/.ssh/.backup
        </copy>
        ````

    - Double-check that SSH key pair are no longer available

        ````
        <copy>
        tree -n /home/opc/.ssh
        </copy>
        ````

## Task 2c: SSH Key Management with OKV

1. Still on the SSH Client (DB23AI VM) terminal session, logon to **DBSECLAB VM** as opc **with OKV SSH Key** (enter *`NULL`* explicitly as label)

    ````
    <copy>
    export OKV_HOME=/home/opc
    ssh -I $OKV_HOME/lib/liborapkcs.so opc@10.0.0.150
    </copy>
    ````

2. Then, close the SSH session on DBSECLAB VM to go back to DB23AI workstation

    ````
    <copy>
    exit
    </copy>
    ````

3. Add OKV SSH key (enter *`NULL`* explicitly as passphrase)

    ````
    <copy>
    eval `ssh-agent -P "$OKV_HOME/lib/*"`
    ssh-add -D
    ssh-add -s $OKV_HOME/lib/liborapkcs.so -t 14400
    </copy>
    ````

4. Now, logon to DBSECLAB VM as opc **without OKV SSH Key**

    ````
    <copy>
    ssh opc@10.0.0.150
    </copy>
    ````

    **Note**: As you can see now, you can connect to DBSECLAB VM directly through OKV, without any local SSH Key pair, neither local OKV SSH Key

5. Then, close the SSH session on DBSECLAB VM to go back to DB23AI workstation

6. Go back to the **OKV Web Console** to play with the key registered

    - Navigate to “Keys & Wallets”

    - Click on “Wallets”

    - Click on the SSH Server wallet’s name "opc_at_dbseclab"; the “Wallet Contents” appears

    - Click on the “Edit” pencil next to “Wallet Contents”

    - Scroll down to see the Wallet Contents

        **Note**: In this example, now we have only one public keys in the SSH Server wallet: a key created IN OKV by KVRESTADMIN

    - Click the checkbox of the public key that was created IN OKV by DBSECLAB
    
    - Then click on “Remove Objects” to remove the public key from the SSH Server Wallet
    
    - Go back to your terminal session on DB23AI VM to test the connection to DBSECLAB VM
    
        ````
        <copy>
        ssh opc@10.0.0.150
        </copy>
        ````

        **Note**: Public key **authentication fails** because the remote server no longer finds the public key that matches DB23AI private key
    
    - Back to the OKV Web interface, click on “Add Objects” next to “Wallet Contents”
    
    - A list of private and public keys appears, check the checkbox that corresponds to Client public key that was created in OKV by KVRESTADMIN
    
    - click on “Save”
    
    - Go back to your terminal session on DB23AI VM to test the connection to DBSECLAB VM

        ````
        <copy>
        ssh opc@10.0.0.150
        </copy>
        ````

        **Note**: Public key **authentication is successful** again!


## Task 3: Reset the OKV Lab Config

1. ...

You may now proceed to the next lab!

## **Appendix**: About the Product
### **Overview**

Oracle Key Vault is a full-stack, security-hardened software appliance built to centralize the management of keys and security objects within the enterprise.

Oracle Key Vault is a robust, secure, and standards-compliant key management platform, where you can store, manage, and share your security objects.

![Key Vault](./images/okv-concept.png "Key Vault Concept")

Security objects that you can manage with Oracle Key Vault include as encryption keys, Oracle wallets, Java keystores (JKS), Java Cryptography Extension keystores (JCEKS), and credential files.

Oracle Key Vault centralizes encryption key storage across your organization quickly and efficiently. Built on Oracle Linux, Oracle Database, Oracle Database security features like Oracle Transparent Data Encryption, Oracle Database Vault, Oracle Virtual Private Database, and Oracle GoldenGate technology, Oracle Key Vault's centralized, highly available, and scalable security solution helps to overcome the biggest key-management challenges facing organizations today. With Oracle Key Vault you can retain, back up, and restore your security objects, prevent their accidental loss, and manage their lifecycle in a protected environment.

Oracle Key Vault is optimized for the Oracle Stack (database, middleware, systems), and Advanced Security Transparent Data Encryption (TDE). In addition, it complies with the industry standard OASIS Key Management Interoperability Protocol (KMIP) for compatibility with KMIP-based clients.

You can use Oracle Key Vault to manage a variety of other endpoints, such as MySQL TDE encryption keys.

Starting with Oracle Key Vault release 18.1, a new multi-master cluster mode of operation is available to provide increased availability and support geographic distribution.

The multi-master cluster nodes provide high availability, disaster recovery, load distribution, and geographic distribution to an Oracle Key Vault environment.

An Oracle Key Vault multi-master cluster provides a mechanism to create pairs of Oracle Key Vault nodes for maximum availability and reliability.

![Key Vault](./images/okv-cluster-concept.png "Key Vault Multi-Master Concept")

Oracle Key Vault supports two types of mode for cluster nodes: read-only restricted mode or read-write mode.

- **Read-only restricted mode**

  In this mode, only non-critical data can be updated or added to the node. Critical data can be updated or added only through replication in this mode. There are two situations in which a node is in read-only restricted mode:
    - A node is read-only and does not yet have a read-write peer.
    - A node is part of a read-write pair but there has been a breakdown in communication with its read-write peer or if there is a node failure. When one of the two nodes is non-operational, then the remaining node is set to be in the read-only restricted mode. When a read-write node is again able to communicate with its read-write peer, then the node reverts back to read-write mode from read-only restricted mode.

- **Read-write mode**

This mode enables both critical and non-critical information to be written to a node. A read-write node should always operate in the read-write mode.

You can add read-only Oracle Key Vault nodes to the cluster to provide even greater availability to endpoints that need Oracle wallets, encryption keys, Java keystores, certificates, credential files, and other objects.

An Oracle Key Vault multi-master cluster is an interconnected group of Oracle Key Vault nodes. Each node in the cluster is automatically configured to connect with all the other nodes, in a fully connected network. The nodes can be geographically distributed and Oracle Key Vault endpoints interact with any node in the cluster.

This configuration replicates data to all other nodes, reducing risk of data loss. To prevent data loss, you must configure pairs of nodes called read-write pairs to enable bi-directional synchronous replication. This configuration enables an update to one node to be replicated to the other node, and verifies this on the other node, before the update is considered successful. Critical data can only be added or updated within the read-write pairs. All added or updated data is asynchronously replicated to the rest of the cluster.

After you have completed the upgrade process, every node in the Oracle Key Vault cluster must be at Oracle Key Vault release 18.1 or later, and within one release update of all other nodes. Any new Oracle Key Vault server that is to join the cluster must be at the same release level as the cluster.

The clocks on all the nodes of the cluster must be synchronized. Consequently, all nodes of the cluster must have the Network Time Protocol (NTP) settings enabled.

Every node in the cluster can serve endpoints actively and independently while maintaining an identical dataset through continuous replication across the cluster. The smallest possible configuration is a 2-node cluster, and the largest configuration can have up to 16 nodes with several pairs spread across several data centers.

### **Benefits of Using Oracle Key Vault**
- Oracle Key Vault helps you to fight security threats, centralize key storage, and centralize key lifecycle management
- Deploying Oracle Key Vault in your organization will help you accomplish the following:
- Manage the lifecycle for endpoint security objects and keys, which includes key creation, rotation, deactivation, and removal
- Prevent the loss of keys and wallets due to forgotten passwords or accidental deletion
- Share keys securely between authorized endpoints across the organization
- Enroll and provision endpoints easily using a single software package that contains all the necessary binaries, configuration files, and endpoint certificates for mutually authenticated connections between endpoints and Oracle Key Vault
- Work with other Oracle products and features in addition to Transparent Data Encryption (TDE), such as Oracle Real Application Clusters (Oracle RAC), Oracle Data Guard, pluggable databases, and Oracle GoldenGate. Oracle Key Vault facilitates the movement of encrypted data using Oracle Data Pump and transportable tablespaces, a key feature of Oracle Database
- Oracle Key Vault multi-master cluster provides additional benefits, such as:
- Maximum key availability by providing multiple Oracle Key Vault nodes from which data may be retrived
- Zero endpoint downtime during Oracle Key Vault multi-master cluster maintenance

## Want to Learn More?
Technical Documentation:
- [Oracle Key Vault](https://docs.oracle.com/en/database/oracle/key-vault/21.8/index.html)
- [Oracle Key Vault - Multimaster](https://docs.oracle.com/en/database/oracle/key-vault/21.8/okvag/multimaster_concepts.html)

Video:
- *Introducing Oracle Key Vault 21 (January 2021)* [](youtube:SfXQEwziyw4)

## Acknowledgements
- **Author** - Hakim Loumi, Database Security PM
- **Contributors** - Peter Wahl
- **Last Updated By/Date** - Hakim Loumi, Database Security PM - May 2024