# Attack-Defense scenario

## Introduction
In this lab, let's walk through the techniques that attackers use to break into your database and exfiltrate your data.

You will perform different scenarios:
- **as an attacker** - your main objective will be to exfiltrate sensitive data from the target database before encrypting the database as part of a ransomware attack
- **as a defender** - your main objective will be to prevent, detect and mitigate these attacks

![Story of a hack - Architecture](./images/hack-lab_arch.png "Story of a hack - Architecture")

*Estimated Time:* 45 minutes

Watch the video below for a quick walk-through of the lab.
[Oracle facing a Ransomware attack](videohub:1_n8s28bsk)

### Objectives
You will learn how to:
- Prevent, detect and mitigate data exfiltration
- Prevent and detect privileges escalation and abuse
- Prevent and mitigate exploitation of vulnerabilities

### Prerequisites
This lab assumes you have:
<if type="brown">
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment
</if>
<if type="green">
- An Oracle Cloud account
- You have completed:
    - Introduction Tasks
</if>

### Lab Timing (estimated)

| Task No. | Feature                                                 | Approx. Time | Details |
| -------- | ------------------------------------------------------- | ------------ | ------- |
| 1        | Data exfiltration by bypassing database access controls | <15 minutes  |         |
| 2        | Data exfiltration through an application                | <15 minutes  |         |
| 3        | Data exfiltration from the database                     | <15 minutes  |         |

## Task 1: Data exfiltration by bypassing database access controls

Acting while remaining silent is a golden rule for any good attacker. Anything that can be done far away from the target is preferred because the closer the attacker gets to the target, the greater their risk of being caught.

Databases are protected by access controls designed to limit the scope of data access, and audit controls that detect improper activity. The attackers try to avoid those access and audit controls. Once they are on a system and have decided to launch their attack to exfiltrate sensitive data, they first attempt to obtain as much sensitive information as possible without trying to connect to the database.

Several options are available in this case. From the farthest to the closest to the database, here is the collection:
- **From the network** (data-in-transit)
- **From inert and residual files** (backups and exports)
- **From Database data files** (data-at-rest)

![Data exfiltration by bypassing DB access control](./images/hack-lab1.png "Data exfiltration by bypassing DB access control")

## Task 1a: Prevent data exfiltration from the network (data-in-transit)

The attacker can use a packet analyzer, also known as packet sniffer, protocol analyzer, or network analyzer. The best known are **tcpdump** or **Wireshark** (tcpdump with a graphical front-end and integrated sorting and filtering options).

These tools allow an attacker to read or record data passing through a local network. They allow to capture each packet of the Data flowing through the network and to analyze its content.

Tools like tcpdump see everything that passes through the network interface, whether it is the SQL flow between the server and the client. That includes extremely sensitive information like passwords that pass in clear text or any other unencrypted information.

The solution to this problem is to encrypt the network and use secure communication protocols, such as SSH (SFTP, SCP), TLS (HTTPS or FTPS). Unfortunately, all too often internal company networks are not secured and the staff is not sufficiently trained in security aspects. Worse, the network is sometime voluntarily not encrypted because after purchasing some very expensive network probes, these would become useless with an encrypted network and the administrators would no longer be able to carry out their investigations in case of a failure!

To see how easy it is to exfiltrate data from an unencrypted network, let's run a simple SQL query on PDB1 (unsecured database) and run tcpdump to analyze its traffic.

1. Open a terminal session on your **DBSec-Lab** VM as OS user *oracle*

    ```
    <copy>sudo su - oracle</copy>
    ```

    **Note**: If you are using your remote desktop session, double-click on the *Terminal* icon on the desktop to launch a session already logged on as *oracle* user

2. Go to the scripts directory

    ```
    <copy>cd $DBSEC_LABS/story-hack</copy>
    ```

3. Execute a SQL query **on PDB1** and run tcpdump to capture and analyze the packets in transit on the network (wait for the end of the execution)

    ```
    <copy>./sh_extract_data_from_network.sh pdb1</copy>
    ```

    ![Extract data from network on PDB1 (unsecured DB)](./images/hack-lab1a-01.png "Extract data from network on PDB1 (unsecured DB)")

    **Note**:
    - The script output shows you that unencrypted data is flowing over the network! Even if native network encryption is NOT in use the banner entries still include entries for the available security services. Notice that "`Encryption service for Linux`" is available, indicating that the connection COULD be encrypted; however, there is no entry indicating the specific algorithms used by the session. When we look at an encrypted session, the difference will become more evident.

        ![SQL workflow in clear on the network](./images/hack-lab1a-02.png "SQL workflow in clear on the network")

    - The script executes the following SQL query on PDB1: `SELECT firstname, lastname, salary, address_1 FROM employeesearch_prod.demo_hr_employees`

        ![SQL query output on PDB1](./images/hack-lab1a-03.png "SQL query output on PDB1")

    - It captures and analyzes the traffic network generated
    - It displays the result of the analysis

4. Scroll up from the tcpdump output until the SQL Query `SELECT firstname, lastname, salary, address_1 FROM employeesearch_prod.demo_hr_employees`

    ![SQL workflow in clear in tcpdump](./images/hack-lab1a-04.png "SQL workflow in clear in tcpdump")

    **Note**: Because the session is unencrypted, the query results appear in clear-text on the network. It is easy for an attacker to capture and exfiltrate the sensitive data-in-transit!

5. Now, let's have a look at what happens with an encrypted session. We run the same SQL query on PDB2 (the secured database). Again, we will use tcpdump to analyze the session traffic.

6. Execute an SQL query on PDB2 and run tcpdump to capture and analyze the packets in transit on the network (wait for the end of the execution)

    ```
    <copy>./sh_extract_data_from_network.sh pdb2</copy>
    ```

    **Note**:
    - The script checks if the SQL traffic is encrypted. You can see the connection is encrypted because an encryption algorithm was selected for the session. You can still see the default banner information for the available encryption service and the crypto-checksumming (integrity) service. Now, you can also see the algorithm used is "`AES256 Encryption service adapter for Linux`".

        ![SQL workflow encrypted on the network](./images/hack-lab1a-05.png "SQL workflow encrypted on the network")

    - The script executes the following SQL query on PDB2: `SELECT firstname, lastname, salary, address_1 FROM employeesearch_prod.demo_hr_employees`

        ![SQL query output on PDB2](./images/hack-lab1a-06.png "SQL query output on PDB2")

    - It captures and analyzes the traffic network generated
    - It displays the result of the analysis

7. Scroll up from the tcpdump output and confirm that you can't find the SQL Query `SELECT firstname, lastname, salary, address_1 FROM employeesearch_prod.demo_hr_employees`!

    ![SQL workflow encrypted in tcpdump](./images/hack-lab1a-07.png "SQL workflow encrypted in tcpdump")

    **Note**:
    - The `DEMO_HR_EMPLOYEES` table data is still queryable but when it shows up in the tcpdump, the data is unreadable because the session is encrypted!
    - Even with a compromised network, the SQL workflow is secured with no code updates, no application changes, and no network architecture changes! Your sensitive data is protected in transit!
    - Network administrators can continue to use their existing probes to analyze events while being sure that they can't read the data-in-transit

8. Encrypting the SQL traffic for an Oracle Database is fast and easy! It works immediately, with no downtime, application changes, or complex command lines, so why are you waiting to implement it?

9. We protected the SQL traffic using an encryption feature provided natively by the Oracle database, called **Native Network Encryption (NNE)**. Another option for encrypting network traffic would be Transport Layer Security (TLS). We chose NNE because, unlike TLS, NNE doesn't require any changes in the application.

    > To learn more about how to enable NNE, please refer to the "[DB Security - Native Network Encryption] (https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=700)" workshop

## Task 1b: Prevent data exfiltration from inert and residual files (backups and exports)

Although stealing unencrypted data over the network is very easy for the attacker, the data available to steal is limited to only what is traveling over the network. The attacker is passive – and this type of theft does not reveal the underlying data model, making it difficult for the attacker to know what else is available within the database.

The attacker will naturally move closer to the database to get a better idea of what data is available, but always being careful not to set off any alarms. The attacker shifts their focus to inert files of the database. Whether they are backups or export files, they are copied outside the database servers and frequently proliferate throughout the organization. They are almost always unattended or without protective security controls. These files are a real goldmine for attackers because they can contain sensitive data, the structure of the database, and other valuable information.

The attacker may be able to retrieve these files from file shares or backup servers, as email attachments, from tapes, or even from service providers who may have little regard for good security practices or the security implications of these types of files falling into the wrong hands. The attacker can then read the content of those files at their leisure.

Let's see how this type of attack could focus on an export file, but keep in mind that it would work the same way with a backup file.

1. Let's say that while performing a search, the attacker finds an old, insecure PDB1 export file (`employeesearch_data_PDB1_20241006.dmp`) that was generated for use by a development or support team. The attacker tries to read the file contents

    ```
    <copy>./sh_extract_data_from_file.sh employeesearch_data_PDB1_20241006.dmp</copy>
    ```

    ![Extract data from UNSECURED export file on PDB1](./images/hack-lab1b-01.png "Extract data from UNSECURED export file on PDB1")

    **Note**:
    - By scrolling the output, you can see that all the schema data and metadata are readable!
    - Because this file wasn't encrypted when it was generated, it's possible to extract its entire content by simply reading it

2. And if the attacker tries to exfiltrate all the email addresses for example, nothing could be easier with the right command line

    ```
    <copy>./sh_extract_data_from_file.sh employeesearch_data_PDB1_20241006.dmp |grep -o '[[:alnum:]+\.\_\-]*@[[:alnum:]+\.\_\-]*' | sort | uniq -i</copy>
    ```

    ![Extract emails from UNSECURED export file on PDB1](./images/hack-lab1b-02.png "Extract emails from UNSECURED export file on PDB1")

3. Now, do the same thing on export file from PDB2 (`employeesearch_data_PDB1_20241006.dmp`). Unlike the export from PDB1, this export was encrypted.

    ```
    <copy>./sh_extract_data_from_file.sh employeesearch_data_PDB2_20241006.dmp</copy>
    ```

    ![Extract data from SECURED export file on PDB2](./images/hack-lab1b-03.png "Extract data from SECURED export file on PDB2")

    **Note**:
    - The output is unreadable!
    - Because this file was encrypted when it was generated, it's impossible to extract usable content

4. And if the attacker tries to exfiltrate all the email addresses, there's nothing but unusable data

    ```
    <copy>./sh_extract_data_from_file.sh employeesearch_data_PDB2_20241006.dmp |grep -o '[[:alnum:]+\.\_\-]*@[[:alnum:]+\.\_\-]*' | sort | uniq -i</copy>
    ```

    ![Extract emails from SECURED export file on PDB2](./images/hack-lab1b-04.png "Extract emails from SECURED export file on PDB2")

5. Here, we have used Data Pump Encryption, one of the database encryption features provide by the **Oracle Advanced Security Option (ASO)**

    ---

    SysAdmin might answer here that it's easy to secure an inert file to avoid this kind of attack and that it's enough to encrypt the export file with utilities like GnuGP or mCrypt - the most well-known file encryption utilities. Unfortunately, what seems to be a good solution in theory is not a good solution in practice.

    Think about it - every time you use these utilities, you will have to encrypt a file that is already in clear text. The risk of compromising the file between generation and encryption during the operation is very real, not to mention the added complexity from an operations standpoint.

    You'll also have to manually generate a unique encryption key that you'll have to store and manage to make sure you can restore the file someday or enter a password. That password becomes something that needs to be securely stored and managed. You can never forget it and will have to pass it on to the end-user who might want to open the file. All this is time-consuming and expensive to maintain and increases the risk of manipulation errors or compromise.

    So, in general, to avoid possible problems, the admins will either use the same password for all the encryptions or store it somewhere to avoid losing it. You'll need to work out procedures for changing the password when the teams change personnel over time. All this represents a heavy load in terms of time, resources, processes, and money. This manual process also represents a real security risk because anything perceived as an operational barrier is seldom maintained over time.

    We prefer to use the native encryption functionalities built into the Oracle Database, like Data Pump encryption for export files and RMAN backup encryption for Oracle Database backups.

    **Benefits of using database encryption**

    Compared to other solutions like GnuPG, mCrypt or third party encryption, database encryption offers multiple advantages:
    - it's native, so no other layer to install; ready-to-use and optimized for the Oracle Database
    - transparent, once initiated, you can automatically create an encrypted export file without the intervention of an Admin
    - non-intrusive, no code or architecture changes are required
    - secure, no password to use, a key is generated automatically
    - centralized for Data Pump, the key is generated by the Oracle Database and stored within the local keystore or in a key manager like Oracle Key Vault (OKV)
    - already encrypted for RMAN backup, no need to generate another key because all the encrypted database blocks are managed by RMAN during the backup process - advantage: the backup is already and automatically encrypted, and all the key are stored within the database keystore
    - Data Pump encryption happens during the export process, so there is no risk of data theft during the time between creating the export and encrypting it because there is no gap

    ---

## Task 1c: Prevent data exfiltration from Database data files (data-at-rest)

If the attacker wants to get MORE data (especially if the inert file breach was over a partial export), or if the prior attacks were blocked, then the attacker will need to start taking more risks. They will need to get closer to their target and remain under the radar of the database access and audit controls. To do this, they will now attack the active data files. These files contain all the data of the database.

Here they have two options:
- try to attack the production server directly
- or attempt to harvest data from non-production servers

Attacking the production server may seem riskier, but they will attack that target if they don't have enough time or think they can get away with it. Suppose the attackers are not in a hurry. In that case, they can take time to explore non-production servers, which are generally less complete and less up-to-date but have the advantage of being little monitored and rarely with the same level of security as production servers.

The technique remains the same in production or development, so let's take a look at how they might go about it on the production server. We'll see later how to secure the non-production data.

### **Option 1: The attacker targets the production server**

We will use a well-known Linux command "strings" to view data in the datafiles associated with the EMPDATA_PROD tablespace. Strings is an OS command that operates directly on the database files, bypassing database access and audit controls.

1. On PDB1, the `EMPDATA_PROD` tablespace is unsecured and its associated datafiles is named `empdata_prod.dbf`

    ```
    <copy>./sh_extract_data_from_file.sh ${DATA_DIR}/pdb1/empdata_prod.dbf</copy>
    ```

    ![Extract data from UNSECURED datafile on PDB1](./images/hack-lab1c-01.png "Extract data from UNSECURED datafile on PDB1")

    **Note**:
    - By scrolling the output, you can see that all the schema data and metadata are visible!
    - Because this datafile is not encrypted, it's easy to extract its entire contents by simply reading it
    - Beware, even if this datafile is located on an encrypted disk array or encrypted by a third-tier software, the content of the file is still available to a privileged user like root or oracle

<!--
    !!! BELOW, SECTION TO CHANGE ASAP !!!
    -----
    --
-->
2. On PDB2, encrypt the `EMPDATA_PROD` tablespace to secure it and execute the same extraction command on the datafile to see now if you can exfiltrate sensitive data

    ```
    <copy>
    sqlplus -s ${DBUSR_SYSTEM}/${DBUSR_PWD}@pdb2 <<EOF
    set lines 2000
    col algorithm       format a10
    col encrypted       format a10
    col file_name       format a45
    col pdb_name        format a20
    col online_status   format a15
    col tablespace_name format a30
    col location        format a100
    
    prompt
    prompt . Check if the tablespace EMPDATA_PROD is encrypted or not
    select tablespace_name, encrypted from dba_tablespaces where tablespace_name = 'EMPDATA_PROD';

    prompt
    prompt . Encrypt the tablespace EMPDATA_PROD
    ALTER TABLESPACE empdata_prod ENCRYPTION ONLINE ENCRYPT;

    prompt
    prompt . Check if the tablespace EMPDATA_PROD is encrypted now
    select tablespace_name, encrypted from dba_tablespaces where tablespace_name = 'EMPDATA_PROD';

    prompt
    prompt . Display where to find the new location of the tablespace after encrypting it
    select b.name tablespace_name, c.ENCRYPTIONALG algorithm, d.name location
      from v\$tablespace b, v\$encrypted_tablespaces c, v\$datafile d
     where c.con_id = b.con_id
       and b.ts# = c.ts#
       and b.ts# = d.ts#;

    exit;
    EOF
    </copy>
    ```
    
    ```
    <copy>
    read -p "File Location: " file_name && ./sh_extract_data_from_file.sh $file_name
    </copy>
    ```

    ![Extract data from SECURED datafile on PDB2](./images/hack-lab1c-02.png "Extract data from SECURED datafile on PDB2")

    **Note**:
    - The output is unreadable!
    - Because this datafile is encrypted at the database block level it's impossible to extract its content without going through an authorized, audited, database session
<!--
    --
    -----
    !!! END OF CHANGE !!!
-->

3. This time, we have used another database encryption feature provide natively by the Oracle database called **Transparent Data Encryption (TDE)**. TDE is included with all Oracle Database cloud services and is available with Oracle Enterprise Edition databases.

    ---

    **Benefits of using Oracle Transparent Data Encryption (TDE)**
    - As a security administrator, you have peace of mind knowing that sensitive data is secured in the event that the storage media or data file is stolen - Data is encrypted within the database and therefore safe everywhere in Oracle Database ecosystem the data is copied to (including clones of the database, backups, etc)
    - Using TDE helps you address encryption-related regulatory compliance issues
    - You don't need to modify applications to use TDE. Data is transparently encrypted as it is added to the database, and transparently decrypted for authorized database sessions
    - You can encrypt data with zero downtime on production systems by using "Online Table Redefinition," or you can encrypt it offline during maintenance periods (see "Oracle Database Administrator's Guide" for more information about "Online Table Redefinition")
    - Oracle Database automates TDE master encryption key and keystore management operations. The user or application does not need to manage TDE master encryption keys and the keys are never exposed to the clients, reducing the chances for loss or theft of the keys

    > To learn more about how to use TDE, please refer to the "[DB Security - ASO (Transparent Data Encryption & Data Redaction)] (https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=703)" workshop

    ---

### **Option 2: The attacker focuses on the non-production (test or development) database servers**

If the attacker has more time, they will avoid attacking the production database in order to reduce their risk of discovery. Hackers often focus on non-production systems because those usually have fewer active security controls and less stringent monitoring. For each production database, we see an average of four non-production databases (development, test, integration, UAT, validation, stage, support, etc). In many cases, the test databases are just production clones and contain the same data. Because developers must be close to actual production conditions, they require non-production environments to be as faithful as possible to the production database.

Applying production-quality levels of security to non-production databases is unworkable in many cases. In addition to the additional cost to secure these extra environments, developers frequently require full access to the system during the development and testing process.

The simplest and safest solution is to implement a good baseline level of security, including auditing and assessment. And then work to make the content of these databases functional, so that the teams can work correctly, but without any sensitive information so that you are not worried about data compromise. We will use data masking to remove the security risk from these non-production clones. Masking is cheaper than implementing production-quality controls. Masking allows you to invest the minimum security resources in these databases without risk of disclosing your sensitive data.

![Data Masking concept](./images/hack-lab1c-03.png "Data Masking concept")

Imagine that you decide to refresh your development database every Monday from the production database. That means that your development database will become as sensitive as your production environment as soon as it is refreshed. Your datafiles are exposed to exactly the same attack that we saw earlier.

1. Let's **refresh the development from production on PDB1 with no masking script**

    ```
    <copy>./sh_refresh_dev_from_prod.sh pdb1 nomasking</copy>
    ```

    ![Refresh UNSECURED DEV data on PDB1](./images/hack-lab1c-04.png "Refresh UNSECURED DEV data on PDB1")

    **Note**: Because the data is not masked in development, you can see the same sensitive data that is in production!

2. Next, for example, **extract only the email of the User 73** (`Craig.Hunt@oracledemo.com`) from the development datafile `empdata_dev.dbf` **on PDB1**, as seen in the previous attack

    ```
    <copy>strings ${DATA_DIR}/pdb1/empdata_dev.dbf |grep -o 'Craig.Hunt@oracledemo.com'</copy>
    ```

    ![Extract data from UNSECURED DEV datafile on PDB1](./images/hack-lab1c-05.png "Extract data from UNSECURED DEV datafile on PDB1")

    **Note**:
    - The database file is readable as expected, and you can see the email address. Hence, production-sensitive data is vulnerable in the development environment!
    - Of course, here, you exfiltrated only a single email address, but an attacker could exfiltrate any other dataset they wanted by using the same method
    - To be secured, you would need to implement, maintain, and monitor strong security solutions in the development environment

<!--
    !!! BELOW, SECTION TO CHANGE ASAP !!!
    -----
    --
   
    <copy>./sh_extract_data_from_file.sh ${DATA_DIR}/pdb1/empdata_dev.dbf |grep -o 'Craig.Hunt@oracledemo.com'</copy>
    
    --
    -----
    !!! END OF CHANGE !!!
-->

3. Now, let's see what happens if you **mask the sensitive data during the duplication process in Dev on PDB2**

    ```
    <copy>./sh_refresh_dev_from_prod.sh pdb2 masking</copy>
    ```

    ![Refresh SECURED DEV data on PDB2](./images/hack-lab1c-06.png "Refresh SECURED DEV data on PDB2")

    **Note**:
    - Here, we apply a masking script during the data refresh process that removes risk from sensitive data by replacing it with non-sensitive, usually artificial, data:
        - Set a new value to `CREATIONDATE` from a specific date range
        - Apply the format "xxxxx@email.com" to EMAIL
        - Set random values to `PHONEMOBILE` by preserving the original format (3 digits - 3 digits - 4 digits)
        - Hide `SALARY`
        - Set random values to `SSN` by preserving the original format (3 digits - 2 digits - 4 digits)
        - Set a realistic new value to `CORPORATE_CARD` from credit card number library
    - Now, the **data is masked in development and is different from what is in production**!

4. Next, try again to **extract only the email of the user 73** (`Craig.Hunt@oracledemo.com`) from the development datafile `empdata_dev.dbf` **on PDB2**

    ```
    <copy>strings ${DATA_DIR}/pdb2/empdata_dev.dbf |grep -o 'Craig.Hunt@oracLedemo.com'</copy>
    ```

    ![Extract data from SECURED DEV datafile on PDB2](./images/hack-lab1c-07.png "Extract data from SECURED DEV datafile on PDB2")

    **Note**:
    - **There's no result!**
    - Although the datafile is still readable as expected - remember, we didn't encrypt the development env - but now, because the data is masked in development, even if the attacker actually connects to the database, there's no longer sensitive data to be stolen!

<!--
    !!! BELOW, SECTION TO CHANGE ASAP !!!
    -----
    --
   
    <copy>./sh_extract_data_from_file.sh ${DATA_DIR}/pdb2/empdata_dev.dbf |grep -o 'Craig.Hunt@oracledemo.com'</copy>
    
    --
    -----
    !!! END OF CHANGE !!!
-->

5. Here, we have used the data masking capability provided by the Oracle Database, called **Data Masking and Subsetting (DMS)**.

    ---

    Oracle Data Masking and Subsetting (DMS) generates a scalable masking script with a highly efficient and robust mechanism for creating consistent and realistic masked data. No need to manually create a complex masking script to maintain, just define the masking rules and DMS generates the masking script for you.

    **Benefits of using DMS**
    - Maximize the business value of data by masking sensitive information
    - Minimize the compliance boundary by not proliferating the sensitive production information
    - Lower the storage costs on test and development environments by subsetting data
    - Automate the discovery of sensitive data and parent-child relationships
    - Provide a comprehensive library of masking formats, masking transformations, subsetting techniques, and select application templates
    - Maintain your masking script easily over time according to the evolution of the schemas structures
    - Mask and subset data in-Database or on-the-file by extracting the data from a source database
    - Mask and subset Oracle Databases hosted on-premises, in the Oracle Cloud, and in third-party clouds
    - Preserve data integrity during masking and subsetting and offers many more unique features
    - Integrate with select Oracle testing, security, and integration products

    > To know more about DMS, please refer to the "[DB Security - Data Masking and Subsetting] (https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=704)" workshop. The Oracle Data Safe cloud service also provides Data Masking capability. If you'd like more information on using Oracle Data Safe please refer to the "[Get Started with Oracle Data Safe Fundamentals] (https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=598)" workshop

    ---

## Task 2: Data exfiltration through an application

Next, our attackers will attempt to indirectly retrieve data from the database by attacking an application connected to the database. Their risk of detection goes up because (hopefully) the application is being monitored for this type of attack using tools like Web Application Firewall (WAF).

![Data exfiltration from the App](./images/hack-lab2.png "Data exfiltration from the App")

Possibly the attacker has access to your application, even with a simple user account. Or they may not even have that – if the application developers did not do a good job of securely coding their application it's possible that the attacker can steal data from the login screen without ever actually completing an application authentication.

Hackers use two common techniques when attacking the database through an application:
- **SQL Injection**
- **Sensitive data harvesting**

## Task 2a: Detect and mitigate a SQL Injection

SQL Injection (SQLi) is a code injection technique used to attack data-driven applications by inserting malicious SQL statements into entry fields.

SQLi is a well-known cyber attack representing one of the most commonly used attack techniques. SQLi's ability to exploit security holes can be potent if properly used. SQLi exploits security holes in an application that interacts with a database. The SQL injection attack consists of tricking the application into modifying a valid SQL query by injecting an unanticipated response to an input variable, often through a form. The hacker can thus retrieve data from the database that the application developer never intended to expose. In some cases, the attacker can even update or delete data, create new user accounts, or escalate privileges, thus compromising the system's security.

Every day someone discovers a new SQLi vulnerability - even in some of the most well-known applications. Secure coding practices, periodic developer training, and comprehensive code audits can prevent new applications from being released with SQLi vulnerabilities. Many older applications contain unpatched SQLi vulnerabilities.

In this lab, you will perform a "UNION-based" SQL injection attack on an application that is NOT securely developed! You'll see how a SQLi attack works and then see how to block it.

1. Open a new Web browser tab and launch the HR app **On PDB1** (unsecured):
    <if type="green">
    - **On PDB1** (unsecured) to this URL: *`http://dbsec-lab:8080/hr_prod_pdb1`*
    </if>
    <if type="brown">
    - If you are working from a remote desktop (usually the case for this lab):
        - **On PDB1** (unsecured) to this URL: *`http://dbsec-lab:8080/hr_prod_pdb1`*
    - If you are working through a public IP address (often the case if you launched this lab in your own tenancy):
        - **On PDB1**: *`http://<YOUR_DBSEC-LAB_VM_PUBLIC_IP>:8080/hr_prod_pdb1`*
    </if>
    
    **Note**: Remember, this application is deliberately poorly developed to allow attacks such as SQL injection attacks

2. Login to th application as *`hradmin`* with the password "*`Oracle123`*"

    ```
    <copy>hradmin</copy>
    ```

    ```
    <copy>Oracle123</copy>
    ```

    ![HR App - Menu](./images/hack-lab2a-01.png "HR App - Menu")

    ![HR App - Login screen](./images/hack-lab2a-02.png "HR App - Login screen")

3. Click **Search Employees**

4. Click [**Search**]

    ![HR App - Search ALL employees](./images/hack-lab2a-03.png "HR App - Search ALL employees")

    **Note**: All rows are returned because, remember, you allowed everything!

5. Now, tick the **checkbox "Debug"** to see the SQL query behind this form

    ![HR App - Debug mode](./images/hack-lab2a-04.png "HR App - Debug mode")

6. Click [**Search**] again

    ![HR App - Debug mode results](./images/hack-lab2a-05.png "HR App - Debug mode results")

    **Note:**
    - Now, you can see the SQL query executed by this form which displays the results
    - This query gives you the information of the number of columns requested, their name, the tables in use, and their relationship. That information helps you know what database columns relate to which columns in the application's user interface.

7. Now, based on this information, you can use a "UNION-based" SQL injection query to display sensitive data you want to extract. Here, we will use this query to extract `USER_ID, MEMBER_ID, PAYMENT_ACCT_NO` and `ROUTING_NUMBER` from the `DEMO_HR_SUPPLEMENTAL_DATA` table.

    ```
    <copy>
    ' UNION SELECT userid, ' ID: '|| member_id, 'SQLi', '1', '1', '1', '1', '1', '1', 0, 0, payment_acct_no, routing_number, sysdate, sysdate, '0', 1, '1', '1', 1 FROM demo_hr_supplemental_data --
    </copy>
    ```

8. Copy the SQL Injection query, **paste it directly into the field "Position"** on the Search form on both Web App and tick the "Debug" checkbox

    ![HR App - SQL Injection](./images/hack-lab2a-06.png "HR App - SQL Injection")

    **Note:**
    - Don't forget the "`'`" before the UNION key word to close the SQL clause "LIKE"
    - Don't forget the "`--`" at the end to disable rest of the application's original query

9. Click [**Search**]

    ![HR App - SQL Injection results in Debug mode on PDB1](./images/hack-lab2a-07.png "HR App - SQL Injection results in Debug mode on PDB1")

    **Note:**
    - Now, because the source code of the app is exposed to this kind of attack, instead of the results as usual, you can see sensitive information that the application developer never intended to expose to you!
    - Of course, you can modify this UNION query and extract different columns if you want.
    - The key is to ensure the number of returned values continues to match the original source query.


<!--
-----------------------------------------------------------------------------
--  !!! BELOW, SECTION TO CHANGE ASAP !!!
-----------------------------------------------------------------------------
-->  
10. Now, we will configure **PDB2** to prevent this kind of attack

11. Go back to your terminal session and configure a new Glassfish Application connection string for PDB2 to proxy through the Database Firewall

    ```
    <copy>
    sudo sed -i -e 's|pdb1|pdb2|g' /u01/app/glassfish/hr_prod_pdb2/WEB-INF/classes/hr.properties
    sudo sed -i -e 's|15223|15224|g' /u01/app/glassfish/hr_prod_pdb2/WEB-INF/classes/hr.properties.fw
    sudo sed -i -e 's|15223|15224|g' /home/oracle/DBSecLab/livelabs/story-hack/hr_prod_pdb2_dbfw.properties
    ./sh_start_proxy_glassfish.sh
    </copy>
    ```

    ![Set HR App with Database firewall](./images/hack-lab2a-08.png "Set HR App with Database firewall")

12. Next, open a new Web browser tab and launch the HR app on **PDB2**

    <if type="green">
    - **On PDB2** (secured) to this URL: *`http://dbsec-lab:8080/hr_prod_pdb2`*
    </if>
    <if type="brown">
    - If you are working from a remote desktop (usually the case for this lab):
        - **On PDB2** (secured) to this URL: *`http://dbsec-lab:8080/hr_prod_pdb2`*
    - If you are working through a public IP address (often the case if you launched this lab in your own tenancy):
        - **On PDB2**: *`http://<YOUR_DBSEC-LAB_VM_PUBLIC_IP>:8080/hr_prod_pdb2`*
    </if>
    
    **Note**:
    - To help you differentiate between the applications, the HR App menu is grey on PDB1 and in red on PDB2.
    - Remember, this application is deliberately poorly developed to allow attacks such as SQL injection attacks.

13. Verify the Glassfish Application connection string go through the Database Firewall
    - Login as *`hradmin`* with the password "*`Oracle123`*"

        ![Login to HR App](./images/hack-lab2a-09.png "Login to HR App")

        ![HR App - Login](./images/hack-lab2a-02.png "HR App - Login")

    - In the top right hand corner of the App, click on the **Weclome HR Administrator** link to view the **Session Details** page

        ![Check HR App Session details](./images/hack-lab2a-10.png "Check HR App Session details")

    - Now, you should see that the **IP Address** row has changed from **10.0.0.150** to **10.0.0.152**, which is the IP Address of the DB Firewall VM

        ![Check HR App IP address](./images/hack-lab2a-11.png "Check HR App IP address")

14. Train the DB Firewall for Expected SQL Traffic (here, we will train the Oracle Database Firewall so we can monitor, and block, non-authorized SQL commands)

    - Open a web browser window to *`https://av`* to access to the Audit Vault Web Console
    
        **Note**: If you are not using the remote desktop you can also access this page by going to *`https://<AVS-VM_@IP-Public>`*
    
    - Login to Audit Vault Web Console as *`AVAUDITOR`* (use the new password you did reset in the "Initialize Environment" lab earlier)
    
        ````
        <copy>AVAUDITOR</copy>
        ````

         **Note**: If you have not retrieved the password for the `AVAUDITOR` user in the AVDF console, you can do so with the following command:

        ```
        <copy>echo $AVUSR_PWD</copy>
        ```
    
    - When you paste that default password into the AVDF console login, it will prompt you to reset your password

        ![AVDF - Login](./images/hack-lab2a-12.png "AVDF - Login")

    - On top, click on the **Policies** tab

    - Click the **Database Firewall Policies** sub-menu on left

        ![Database Firewall Monitoring](./images/hack-lab2a-13.png "Database Firewall Monitoring")

    - Check the **Log unique** option to enable the Database Firewall Policy, then click [**Deploy**]

        ![Enable Database Firewall Policy](./images/hack-lab2a-14.png "Enable Database Firewall Policy")

        **Note:**
        - Log unique policies enable you to log statements for offline analysis that include each distinct source of SQL traffic. Be aware that if you apply this policy, even though it stores fewer statements than if you had chosen to log all statements, it can still use a significant amount of storage for the logged data.
        - Log unique policies log SQL traffic specifically for developing a new policy. The logged data enables the Analyzer to understand how client applications use the database and enables rapid development of a policy that reflects actual use of the database and its client applications.

    - Select the targets to be covered by this policy (here *pdb2*) and click [**Deploy**]

        ![Select targets for Database Firewall Policy](./images/hack-lab2a-15.png "Select targets for Database Firewall Policy")

    - Now, refresh the page to see the "Log unique" policy deployed for the target pdb2

        ![Database Firewall Policy deployed for pdb2](./images/hack-lab2a-16.png "Database Firewall Policy deployed for pdb2")

    - Now, generate Glassfish Application Traffic

        - Go back to your Glassfish App web page and **Logout** explicitly to train the DB Firewall

            ![HR App - Logout](./images/hack-lab2a-17.png "HR App - Logout")

        - Login as *`hradmin`* with the password "*`Oracle123`*"

            ![HR App - Login](./images/hack-lab2a-02.png "HR App - Login")

        - Click **Search Employees**

            ![Search Employees](./images/hack-lab2a-03.png "Search Employees")

        - In the **HR ID** field enter "*`164`*" and click [**Search**]

            ![Search Employee UserID 164](./images/hack-lab2a-18.png "Search Employee UserID 164")

        - Clear the **HR ID** field and click [**Search**] again to see all rows

            ![Search Employee](./images/hack-lab2a-03.png "Search Employee")

        - Enter the following information in the **Search Employee** fields

            - HR ID: *`196`*
            - Active: *`Active`*
            - Employee Type: *`Full-Time Employee`*
            - Position: *`Administrator`*
            - First Name: *`William`*
            - Last Name: *`Harvey`*
            - Department: *`Marketing`*
            - City: *`London`*

                ![Search Employees Criteria](./images/hack-lab2a-19.png "Search Employees Criteria")

        - Click [**Search**]

        - Click on "**Harvey, William**" to view the details of this employee

            ![Search Employee](./images/hack-lab2a-20.png "Search Employee")

15. Now, build the DB Firewall Allow-List Policy

    - Go back to Audit Vault Web Console as *`AVAUDITOR`* to create a Database Firewall Policy

        ![AVDF - Login](./images/hack-lab2a-12.png "AVDF - Login")

    - Click the **Policies** tab

    - Click the **Database Firewall Policies** sub-menu on left

    - Click [**Create**]

        ![Create a Database Firewall Policy](./images/hack-lab2a-21.png "Create a Database Firewall Policy")

    - Create the Database Firewall Policy with the following information

        - Policy Name: *`HR Policy`*
        - Target Type: *`Oracle Database`*
        - Description: *`This policy will protect the My HR App`*

            ![Database Firewall Policy parameters](./images/hack-lab2a-22.png "Database Firewall Policy parameters")

        - Click [**Save**]

    - Now, create the context of this policy by clicking [**Sets/Profiles**]

        ![Create the context of this policy](./images/hack-lab2a-23.png "Create the context of this policy")

    - In the **SQL Cluster Sets** subtab, click [**Add**]

        ![Add SQL Cluster Sets](./images/hack-lab2a-24.png "Add SQL Cluster Sets")

    - In the **Add SQL Cluster Set** screen, create the list of known queries as following

        - Name: *`HR SQL Cluster`*
        - Description: *`Known SQL statements for HR App`*
        - Target: *`pdb2`*
        - Show cluster for: *`Last 24 Hours`* (or make this `Last Week`)
        - Click [**Go**]

            ![SQL Cluster Sets parameters](./images/hack-lab2a-25.png "SQL Cluster Sets parameters")

        - Click [**Actions**] and select "*`ALL`*" in **Row per page** option to display all the results

            ![Option to display all the results](./images/hack-lab2a-26.png "Option to display all the results")

        - Check the **Select all** box next to the "**Cluster ID**" Header to add all "trained" queries into the SQL Clusters

            ![Select all trained queries to put into the SQL Clusters](./images/hack-lab2a-27.png "Select all trained queries to put into the SQL Clusters")

        - Click [**Save**]

    - Click [**Back**]

        ![Go back](./images/hack-lab2a-28.png "Go back")

    - Select the **SQL Statement** sub-tab and click [**Add**]

        ![Add SQL Statement](./images/hack-lab2a-29.png "Add SQL Statement")

    - Complete the **SQL Statement** with the following information to allow the **HR SQL Cluster** created previoulsy (here we consider that these queries are official and can be executed)

        - Rule Name: *`Allows HR SQL`*
        - Description: *`Allowed SQL statements for HR App`*
        - Cluster Set(s): *`HR SQL Cluster`*
        - Action: *`Pass`*
        - Logging Level: *`Don't Log`*
        - Threat Severity: *`Minimal`*

            ![SQL Statement parameters](./images/hack-lab2a-30.png "SQL Statement parameters")

        - Click [**Save**]

    - Finally, select the **Default** tab to specify what the DB Firewall policy has to do you if you are not in the context definied previously (here we will block all the "black-listed" queries and we will return a blank result)

        ![Specify the default action to do by the DB Firewall policy](./images/hack-lab2a-31.png "Specify the default action to do by the DB Firewall policy")

        - Click on **Default Rule** under the Rule Name, to edit the Default rule, and enter the following information
            - Action: *`Block`*
            - Logging Level: *`One-Per-Session`*
            - Threat Severity: *`Moderate`*
            - Substitution SQL: *`SELECT 100 FROM dual WHERE 1=2`*

                ![Default action parameters](./images/hack-lab2a-32.png "Default action parameters")

        - Click [**Save**]

    - Your HR Policy should look like this:

        ![HR Policy](./images/hack-lab2a-33.png "HR Policy")

    - Click [**Save**]

    - Once created, the policy is **automatically published**, but now you have to deploy it

        ![HR Policy published](./images/hack-lab2a-34.png "HR Policy published")

    - Check the **HR Policy** option, then click [**Deploy**]

        ![HR Policy deployment](./images/hack-lab2a-35.png "HR Policy deployment")

    - Select the targets to be covered by this policy (here *pdb2*) and click [**Deploy**] 

        ![Select targets for Database Firewall Policy](./images/hack-lab2a-36.png "Select targets for Database Firewall Policy")

    - Now, refresh the page to see the "HR Policy" policy deployed for the target pdb2

        ![Database Firewall Policy deployed for pdb2](./images/hack-lab2a-37.png "Database Firewall Policy deployed for pdb2")

16. Once the DB Firewall Policy is enabled, we will validate the impact on the Glassfish App
    - Go back to your Glassfish App web page and logout

        ![Logout to HR App](./images/hack-lab2a-17.png "Logout to HR App")

    - Login as *`hradmin`* with the password "*`Oracle123`*"

        ![Login to HR App](./images/hack-lab2a-09.png "Login to HR App")

        ![HR App - Login](./images/hack-lab2a-02.png "HR App - Login")

    - Click **Search Employees**

    - Click [**Search**]

        ![Search employees](./images/hack-lab2a-03.png "Search employees")

        **Note**: All rows are returned... Remember, all "official" queries from the HR App have been allowed in **HR SQL Cluter** in your DB Firewall policy

    - Even if you add a search criteria and query again, you can access to the result (here we **filter by "HR ID = 196"** for example)

        ![Filter by HR ID = 196](./images/hack-lab2a-19.png "Filter by HR ID = 196")

17. Block a SQL Injection Attack

    - Tick the **checkbox "Debug"** to see the SQL query behind this form

        ![See the SQL query executed behind the form](./images/hack-lab2a-04.png "See the SQL query executed behind the form")

    - Click [**Search**] again

        ![Search employees](./images/hack-lab2a-05.png "Search employees")

        **Note:**
        - Now, you can see the official SQL query executed by this form which displays the results
        - This query gives you the information of the number of columns requested, their name, their datatype and their relationship

    - Now, based on this information, you can create our "UNION-based" SQL Injection query to display all sensitive data you want extract directly from the form. Here, we will use this query to extract `USER_ID', 'MEMBER_ID', 'PAYMENT_ACCT_NO` and `ROUTING_NUMBER` from `DEMO_HR_SUPPLEMENTAL_DATA` table.

        ````
        <copy>
        ' UNION SELECT userid, ' ID: '|| member_id, 'SQLi', '1', '1', '1', '1', '1', '1', 0, 0, payment_acct_no, routing_number, sysdate, sysdate, '0', 1, '1', '1', 1 FROM demo_hr_supplemental_data --
        </copy>
        ````

    - Copy the SQL Injection query, **paste it directly into the field "Position"** on the Search form and **tick the "Debug" checkbox**

        ![Copy/Paste the SQL Injection query](./images/hack-lab2a-06.png "Copy/Paste the SQL Injection query")

        **Note:**
        - Don't forget the "`'`" before the UNION key word to close the SQL clause "LIKE"
        - Don't forget the "`--`" at the end to disable rest of the query

    - Click [**Search**]

        ![Search employees](./images/hack-lab2a-38.png "Search employees")

        **Note**:
        - Unlike PDB1, which returned all sensitive data from the UNION request, **PDB2 returns no rows**.
        - Remember, this is because the UNION query has not been added into the Allow-list in the DB Firewall policy... as simple as that!

18. Now, go back to your terminal session to restore the initial Glassfish Application connection string for PDB2 without DB Firewall

    ```
    <copy>
    ./sh_stop_proxy_glassfish.sh
    </copy>
    ```

    ![HR App - SQL Injection](./images/hack-lab2a-39.png "Set HR App without Database firewall")

19. Here, we have used the SQL Firewalling feature provide by **Oracle Audit Vault and Database Firewall (AVDF)** or **Oracle SQL Firewall**

    > To learn more about how to use the Database Firewall to protect against SQL injection, please refer to the "[DB Security - Audit Vault and DB Firewall] (https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=711)" or "[DB Security - Oracle SQL Firewall] (https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=3875)" workshops

<!--
-----------------------------------------------------------------------------
--                        END OF SECTION TO CHANGE                         --
-----------------------------------------------------------------------------
-->

## Task 2b: Detect and mitigate the sensitive data harvesting

Many older applications expose data to the user that is no longer appropriate. Older applications were often developed when privacy concerns were not as important as they are now and when privacy regulations were not as stringent. It may not be practical to modify the applications, but you can still control the display of sensitive data within those applications.

1. Go back to your HR App on both env (PDB1 and PDB2) and click on **Search Employees**

    ![HR App - Search employees link](./images/hack-lab2b-01.png "HR App - Search employees link")

2. We'll filter on the employee "Alice HARPER" for example by entering **77 as HR ID** value and click [**Search**]

    ![HR App - Search UserID 77](./images/hack-lab2b-02.png "HR App - Search UserID 77")

3. Now, click on the **Full Name** link of this employee to see her details

    ![HR App - UserID 77](./images/hack-lab2b-03.png "HR App - UserID 77")

    - **On PDB1** (unsecured), as you can see, sensitive data like the `SSN` or `SIN` is readable by an authorized user. Or by a user the application THINKS is authorized (perhaps this session is a hacker using compromised account credentials)!

        ![HR App - SIN value for UserID 77 on PDB1](./images/hack-lab2b-04.png "HR App - SIN value for UserID 77 on PDB1")

    - **On PDB2** (secured), even with the same user, the same privileges, the same application, from the same server, the column `SIN` is no longer available!

        - Create the policy
        
            ```
            <copy>./sh_create_redact_policy.sh</copy>
            ```

            **Note**: Here, we'll create a policy to prohibit all access to sensitive data for any connection that does not come from a private IP address

        - check the effect on the App
        
            ![HR App - SIN value for UserID 77 on PDB2](./images/hack-lab2b-05.png "HR App - SIN value for UserID 77 on PDB2")

            **Note**: To see the effects, you need to connect to the App from the server's public IP address

4. Here, we have used the data redaction feature provide natively by the Oracle database, called **Data Redaction**

    **Note**:
    - Because we've decided that application users have no need to view extremely sensitive information like `SSN`/`SIN`, we placed a redaction policy on the database table that controls the conditions under which the data is allowed to leave the database
    - Because Data Redaction is part of the database, there is no need to modify the application to hide this sensitive data. Just create a Data Redaction policy on the table that holds your sensitive column and refresh the application screen to see the effects

    ---

    **Benefits of Using Oracle Data Redaction**
    - You have different styles of redaction from which to choose
    - Because the data is redacted at runtime, Data Redaction is well suited to environments in which data is constantly changing
    - You can create the Data Redaction policies in one central location and easily manage them from there
    - The Data Redaction policies enable you to create a wide variety of policy conditions based on `SYS_CONTEXT` values, which can be used at runtime to decide when the Data Redaction policies will apply to the results of the application user's query

    > To learn more about how to use Data Redaction, please refer to the "[DB Security - ASO (Transparent Data Encryption & Data Redaction)] (https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=703)" workshop

    ---

## Task 3: Data exfiltration from the database

Our attacker now switches their attention to a direct attack on the database.

![Data exfiltration from the Database](./images/hack-lab3.png "Data exfiltration from the Database")

Hackers use four common techniques when attacking the database directly:
- **Exploiting known vulnerabilities in the database**
- **Abusing existing privileges**
- **Taking advantage of insufficient or permissive access controls**
- **Acting as an Admin (privilege escalation or abuse of power)**

Because the database is directly attacked, this type of attack exposes the hacker to the highest level of detection risk!

## Task 3a: Prevent and mitigate exploit known vulnerabilities of the database

A missing patch, a known security issue not fixed, a too permissive configuration, poorly managed users, default passwords that were never changed, users with too many rights - the number of potential vulnerabilities can be intimidating.

Good security requires periodic evaluation of the vulnerabilities to which your database is exposed. Failure to periodically validate that your database is securely configured usually exposes you to configuration drift, which may expose you to increased risk.

As the number of databases you are responsible for grows, the complexity of validating and tracking that configuration also grows. A set of tools that continuously assess your databases can help you deal with rising complexity and scale.

Oracle provides you with several easy-to-use and efficient tools that allow you to identify risks to which your databases are exposed and make recommendations on how to remediate those risks:
- One such tool is **Oracle Data Safe** (a hybrid Cloud service included at no additional cost with all Oracle Database services in the Oracle Cloud)
- Another is **Oracle Database Security Assessment Tool (DBSAT)** available to all Oracle customers (on-premises and in the cloud) through My Oracle Support note 2138254.1.

1. These tools assess your databases to inform you of your risk level

    ![Data Safe - Global dashboard](./images/hack-lab3a-01.png "Data Safe - Global dashboard")

    ![Data Safe - Risk level](./images/hack-lab3a-02.png "Data Safe - Risk level")

2. They generate complete and intuitive reports based on color codes and quick and easy-to-use graphs

3. They also alert you to configuration drift by comparing current configuration with your established security and user baseline.

    ![Data Safe - Baseline comparaison](./images/hack-lab3a-03.png "Data Safe - Baseline comparaison")

4. You are thus quickly and efficiently informed of any risk to be remedied without wasting time and without the risk of forgetting. These assessment tools also help with compliance requirements for safeguarding data privacy and protecting data.

    ![Data Safe - Patch check](./images/hack-lab3a-04.png "Data Safe - Patch check")

    ---

    **Benefits of Using Oracle DBSAT**
    - Quickly identify sensitive data
    - Scan for security configuration issues in your databases
    - Promote security best practices
    - Improve the security posture of your Oracle Databases
    - Reduce the attack surface and exposure to risk
    - Provide input to auditors

    **Benefits of Using Oracle Data Safe**
    - All the DBSAT benefits
    - Configuration drift detection
    - Multi-cloud and hybrid global overview (all your Oracle databases located on-premises, on the Oracle Cloud or third-party clouds)
    - User assessment and user account drift detection
    - Data Masking capacity
    - Audit collection, including reporting, analysis, and alerting

    > To learn more about how to use Data Safe and the Database Security Assessment Tool, please refer to the "[Get Started with Oracle Data Safe Fundamentals] (https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/workshop-attendee-2?p210_workshop_id=598)" or "[DB Security - Database Security Assessment Tool] (https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/workshop-attendee-2?p210_workshop_id=699)" workshops

    ---

## Task 3b: Detect and prevent abuses of existing privileges

Most database attacks involve using compromised account credentials – the attacker just logs into the database with a stolen username and password. The hacker can leverage whatever privileges are granted to that account to steal data – which means that over-privileged accounts are a serious security risk. In far too many situations, administrators grant users privileges they do not need because no one is quite sure what privileges are required. A hacker abuses those additional privileges to access data or perform activity that the account would never usually need to do.

Let's see how this risk could be avoided. Rather than try to guess what privileges an account needs or doesn't need, we will monitor the account's use of privileges to know what unnecessary privileges were granted to the account.

1. Go back to your terminal session on your **DBSec-Lab** VM as OS user *oracle*

2. Start a privilege analysis capture **on PDB1**

    ```
    <copy>./sh_pa_start_capture.sh pdb1</copy>
    ```

    ![Privilege Analysis - Start capture on PDB1](./images/hack-lab3b-01.png "Privilege Analysis - Start capture on PDB1")

    **Note**:
    - "Y" means the capture is started, and EVERY database sessions will be analyzed until the capture ends
    - The database will record which privileges are used during each session

3. Now, let's generate a workload with HR App on PDB1

    - Go back to your HR web application

    - Login as *`hradmin`* with the password "*`Oracle123`*"

        ```
        <copy>hradmin</copy>
        ```

        ```
        <copy>Oracle123</copy>
        ```

        ![HR App - Menu](./images/hack-lab2a-01.png "HR App - Menu")

        ![HR App - Login screen](./images/hack-lab2a-02.png "HR App - Login screen")

    - Click **Search Employees**

    - Click [**Search**]

        ![HR App - Search ALL employees](./images/hack-lab2a-03.png "HR App - Search ALL employees")

4. Go back to your terminal session to stop the capture to generate a report

    ```
    <copy>./sh_pa_stop_capture.sh pdb1</copy>
    ```

    ![Privilege Analysis - Stop capture on PDB1](./images/hack-lab3b-02.png "Privilege Analysis - Stop capture on PDB1")

    **Note**: You generated a report named "**All database Capture**"

5. Now, open the DB Admin Console (OEM Cloud Control) to view the report

    <if type="green">
    - Open a Web Browser at the URL *`https://dbsec-lab:7803/em`*
    </if>

    <if type="brown">
    - Open a Web Browser at the URL *`https://dbsec-lab:7803/em`*

        **Notes:** If you are not using the remote desktop you can also access this page by going to *`https://<YOUR_DBSEC-LAB_VM_PUBLIC_IP>:7803/em`*
    </if>

    - Login to Oracle Enterprise Manager 13c Console as *`SYSMAN`* with the password "*`Oracle123`*"

        ```
        <copy>SYSMAN</copy>
        ```

        ```
        <copy>Oracle123</copy>
        ```

        ![Privilege Analysis - Login screen](./images/hack-lab3b-03.png "Privilege Analysis - Login screen")

    - Expand all the databases and click on **cdb_PDB1**

        ![OEM Cloud Control - Targets overview](./images/hack-lab3b-04.png "OEM Cloud Control - Targets overview")

    - In the menu, select **Security** and **Privileges Analysis**

        ![OEM Cloud Control - Privileges Analysis menu](./images/hack-lab3b-05.png "OEM Cloud Control - Privileges Analysis menu")

    - Check "**Named**" and select "**PA_ADMIN**" as Credential Name

        ![OEM Cloud Control - Privileges Analysis login](./images/hack-lab3b-06.png "OEM Cloud Control - Privileges Analysis login")

    - Click [**Login**]

    - Select our report generated during the capture (here "**All database Capture**") and click [**View Report**]

        ![OEM Cloud Control - Privileges Analysis captures](./images/hack-lab3b-07.png "OEM Cloud Control - Privileges Analysis captures")

    - You can see all users that connected to the database during the capture period, along with the privileges used

        ![OEM Cloud Control - Privileges Analysis global report](./images/hack-lab3b-08.png "OEM Cloud Control - Privileges Analysis global report")

    - Click on the "**Used**" tab to see all the privileges used during the capture and by whom

        ![OEM Cloud Control - Privileges Analysis Used report](./images/hack-lab3b-09.png "OEM Cloud Control - Privileges Analysis Used report")

        **Note**: The Export to Spreadsheet button allows you to provide this information to persons who can make decisions about granting or revoking rights

    - You can also view unused privileges – these may be privileges the accounts don't need. If so, removing these unnecessary privileges is an excellent way to shrink the amount of damage these accounts could do if they were compromised. Click on the "**Unused**" tab to see all the privileges that were unused during the capture and by whom

        ![OEM Cloud Control - Privileges Analysis Unused report](./images/hack-lab3b-10.png "OEM Cloud Control - Privileges Analysis Unused report")

        **Note**: We can clearly see if a user has too many rights, or rights that they don't need to perform their tasks

    - Drop the capture **on PDB1**

        ```
        <copy>./sh_pa_drop_capture.sh pdb1</copy>
        ```

        ![Privilege Analysis - Drop capture on PDB1](./images/hack-lab3b-11.png "Privilege Analysis - Drop capture on PDB1")


6. In this exercise, we have used a feature provided natively in the Oracle Database, called **Privilege Analysis**

    > To learn more about how to use Privilege Analysis, please refer to the "[DB Security - Privilege Analysis] (https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=701)" workshop


## Task 3c: Prevent insufficient or permissive access controls

Another way to steal data is to connect directly to the database without going through an approved application. In some cases, business users will request the ability to login to the database to see data that is too difficult to extract from the application – a legitimate business need. Each of these accounts becomes another point of vulnerability for a hacker to exploit. In both cases (hacker and legitimate business user) the risk is increased if the database does not restrict access to data that the business users should not be able to view.

1. Go back to your terminal session and execute a query on sensitive data **on PDB1** with application User `EMPLOYEESEARCH_PROD`

    ```
    <copy>./sh_query_employee_data.sh pdb1 EMPLOYEESEARCH_PROD</copy>
    ```

    ![View EMPLOYEESEARCH_PROD sensitive data on PDB1](./images/hack-lab3c-01.png "View EMPLOYEESEARCH_PROD sensitive data on PDB1")

    **Note**: As you can see, outside of the approved HR App, the sensitive data `BONUS_AMOUNT` is still readable!

2. Now, create a policy to protect the sensitive data, then execute the same query **on PDB2**

    - Create the policy
    
        ```
        <copy>./sh_create_redact_policy.sh</copy>
        ```

        **Note**: Here, we'll create a policy to prohibit all access to sensitive data for any connection that does not come from a private IP address

    - Check the effect on the App
        
        ```
        <copy>./sh_query_employee_data.sh pdb2 EMPLOYEESEARCH_PROD</copy>
        ```

        ![View EMPLOYEESEARCH_PROD sensitive data on PDB2](./images/hack-lab3c-02.png "View EMPLOYEESEARCH_PROD sensitive data on PDB2")

        **Note**:
        - A trusted path has been created to be sure that the users will only use the official web app
        - Sensitive column `BONUS_AMOUNT` columns is invisible to adhoc query tools like SQL*Plus, even for the schema owner!
        - `SIN` is also redacted for this secured database, we did this earlier to help block the proliferation of sensitive data

3. To confirm that the `BONUS_AMOUNT` is still there, have a look on the **UserID 6 (Lillian)** and go back to your HR App **on PDB2**

    <if type="green">
    - Open a Web Browser at the URL *`http://dbsec-lab:8080/hr_prod_pdb2`*
    </if>

    <if type="brown">
    - Open a Web Browser at the URL *`http://dbsec-lab:8080/hr_prod_pdb2`*

        **Notes:** If you are not using the remote desktop you can also access this page by going to *`http://<YOUR_DBSEC-LAB_VM_PUBLIC_IP>:8080/hr_prod_pdb2`*
    </if>

    - Login as *`hradmin`* with the password "*`Oracle123`*"

        ```
        <copy>hradmin</copy>
        ```

        ```
        <copy>Oracle123</copy>
        ```

        ![HR App - Menu](./images/hack-lab2a-01.png "HR App - Menu")

        ![HR App - Login screen](./images/hack-lab2a-02.png "HR App - Login screen")

    - Click **Search Employees**

    - Enter **6** in the field **HR ID** and click [**Search**]

        ![HR App - Search UserID 6](./images/hack-lab3c-03.png "HR App - Search UserID 6")

    - Click on the employee

        ![HR App - SIN value for UserID 6 on PDB2](./images/hack-lab3c-04.png "HR App - SIN value for UserID 6 on PDB2")

        **Note**: Remember, `SIN` is unreadable because we blocked it earlier in this workshop

    - Open the "**Supplemental Data**" tab

        ![HR App - BONUS_AMOUNT value for UserID 6 on PDB2](./images/hack-lab3c-05.png "HR App - BONUS_AMOUNT value for UserID 6 on PDB2")

        **Note**:
        - `BONUS_AMOUNT` is still readable from within the application because the redaction policy set up for this column displays the data only for the trusted path
        - Connections from outside of the trusted path (like our direct SQL login) are not allowed to see the sensitive data

4. Here again, we have used **Data Redaction**, a feature of Oracle Advanced Security (ASO)

    > To learn more about how to use Data Redaction, please refer to the "[DB Security - ASO (Transparent Data Encryption & Data Redaction)] (https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=703)" workshop

    ---

<!--
    !!! BELOW, SECTION TO CHANGE ASAP !!!
    -----
    --
   
Task 3d: Detect and prevent abuse of power

Finally, the attackers will take the gloves off and will attack with heavy artillery, by acting directly on the database to increase their privileges and exfiltrate sensitive data. Their objective is simple, to obtain as many rights as possible to steal the most data possible. They may try to grant additional privileges to accounts they have compromised, or create new accounts to use in follow-on attacks.

### **Option 1: Escalation of privileges**

1. Go back to your terminal session and create/grant/drop users to check if you are informed about it

    - **On PDB1**

        ```
        <copy>./sh_create_users_alert.sh pdb1</copy>
        ```

        ![Create/Grant/Drop users to check alerts On PDB1](./images/hack-lab3d-01.png "Create/Grant/Drop users to check alerts On PDB1")

    - **On PDB2**

        ```
        <copy>./sh_create_users_alert.sh pdb2</copy>
        ```

        ![Create/Grant/Drop users to check alerts on PDB2](./images/hack-lab3d-01.png "Create/Grant/Drop users to check alerts on PDB2")

2. Next, open the Database Audit Console to check the alert messages

    - On the right web browser window on your remote desktop, switch to the tab preloaded with the Oracle Audit Vault Web Console:
    
        <if type="green">
        - Open a Web Browser at the URL *`https://av`*
        </if>

        <if type="brown">
        - Open a Web Browser at the URL *`https://av`*

            **Notes:** If you are not using the remote desktop you can also access this page by going to *`http://<YOUR_AVS_VM_PUBLIC_IP>`*
        </if>

    - Login to Audit Vault Web Console as *`AVAUDITOR`* with your password set in the "**Initialize Environment**" steps

        ```
        <copy>AVAUDITOR</copy>
        ```

        ![Audit Vault web console - Login screen](./images/hack-lab3d-02.png "Audit Vault web console - Login screen")

    - Click on the "**Alerts**" tab

        ![Audit Vault web console - Main Dashboard](./images/hack-lab3d-03.png "Audit Vault web console - Main Dashboard")

    - As you can see, an alert called "USER CHANGES" has been activated

        ![Audit Vault web console - Alerts](./images/hack-lab3d-04.png "Audit Vault web console - Alerts")

        **Note**:
        - But only the alerts are only available for the activity on PDB2 because PDB1 does not follow best practices and audit creation of, or changes to, user accounts
        - The alert page synchronizes at regular intervals, so if you don't see the alerts, please wait a moment and refresh your browser

3. Here, we have used the data auditing features provided by the Oracle Database, called **Unified Audit**, to create a record of the activity. We also collected the audit data using **Audit Vault and Database Firewall (AVDF)**, so that we can receive alerts, analyze activity, and run reports.

    ---
    
    In addition to being informed of significant activity in near real-time, AVDF allows you to move audit data from the database to a tamper-resistant repository that protects audit data from deletion or alteration. Having a single place to analyze activity across all databases greatly facilitates investigating an incident. AVDF makes it easier to provide reports demonstrating regulatory compliance or even just understanding what happened on the database.

    > To learn more about how to use the features used here, please refer to the "[DB Security - Audit Vault and DB Firewall] (https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=711)" and "[DB Security - Unified Auditing] (https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=702)" workshops

    ---


    --
    -----
    !!! END OF CHANGE !!!
-->

## Task 3d: Prevent abuse of power

<!-- **Option 2: Abuse of power** -->

Attackers want the broadest, most privileged access they can obtain. Database Administrator (DBA) accounts are usually the most privileged accounts in a database.

DBAs are human, and it is possible to compromise their accounts. Your planning should include how to react if that compromise happens. If you are not ready to detect or prevent the attack, then the game is already lost!

Fortunately, Oracle Database provides controls to prevent unauthorized privileged users from accessing sensitive data. Oracle Database can also prevent unauthorized database changes, even by the DBA!

1. If we take the example of exfiltrating data from the application user with SQL*Plus and let's see what happens with a super-user

    - **On PDB1**

        - **As an application user** (the schema owner `EMPLOYEESEARCH_PROD`)

            ```
            <copy>./sh_query_employee_data.sh pdb1 EMPLOYEESEARCH_PROD</copy>
            ```

            ![View EMPLOYEESEARCH_PROD sensitive data on PDB1](./images/hack-lab3d-05.png "View EMPLOYEESEARCH_PROD sensitive data on PDB1")

        - **As DBA** (SYS as sysdba)

            ```
            <copy>./sh_query_employee_data.sh pdb1 SYS</copy>
            ```

            ![View EMPLOYEESEARCH_PROD sensitive data as DBA on PDB1](./images/hack-lab3d-06.png "View EMPLOYEESEARCH_PROD sensitive data as DBA on PDB1")

        **Note**: Sensitive data is open for DBAs to view on this unsecured database!

    - **On PDB2**

        - **As application user** (the schema owner `EMPLOYEESEARCH_PROD`)

            ```
            <copy>./sh_query_employee_data.sh pdb2 EMPLOYEESEARCH_PROD</copy>
            ```

            ![View EMPLOYEESEARCH_PROD sensitive data on PDB2](./images/hack-lab3d-07.png "View EMPLOYEESEARCH_PROD sensitive data on PDB2")

            **Note**: Remember that some sensitive data is redacted because the schema owner, `EMPLOYEESEARCH_PROD`, has not accessed the data using a trusted path

        - **As a DBA** (SYS as sysdba)

            ```
            <copy>./sh_query_employee_data.sh pdb2 SYS</copy>
            ```

            ![View EMPLOYEESEARCH_PROD sensitive data as DBA on PDB2](./images/hack-lab3d-08.png "View EMPLOYEESEARCH_PROD sensitive data as DBA on PDB2")

        **Note**: DBAs are usually exempt from redaction policies – by default all DBAs have the `EXEMPT_REDACTION_POLICY` privilege. They can even see `SIN` (which we redacted to prevent sensitive data from being shown in an application earlier in this lab).

<!--
    !!! BELOW, SECTION TO CHANGE ASAP !!!
    -----
    --
   
    Enable and Start DB Vault automatically or in a script
    
    --
    -----
    !!! END OF CHANGE !!!
-->
2. To prevent this attack, let's protect sensitive objects in the `EMPLOYEESEARCH_PROD` schema on PDB2 from malicious activity, even by privileged users like database administrators!

    ```
    <copy>
    ./sh_dbv_enable_cdb.sh
    ./sh_dbv_start_realm.sh pdb2
    </copy>
    ```

    ![DB Vault - Create a REALM to protect EMPLOYEESEARCH_PROD schema on PDB2](./images/hack-lab3d-09.png "DB Vault - Create a REALM to protect EMPLOYEESEARCH_PROD schema on PDB2")

    **Note**:
    - We’ve just enabled Database Vault, and a Database Vault security realm now protects all objects in the `EMPLOYEESEARCH_PROD` schema from unauthorized users, including the database administrators
    - Database Vault also implemented separation of duties, and DBAs can no longer create users or control security policies
    - Only authorized users can access application data, with their access controlled by Data Redaction policies and audited using Unified Auditing
    - Security realms can protect individual objects, commands, or entire schemas
    - With security realms, it is possible to leave the door open only for a trusted path (correct application, IP ranges, hours of the day, etc) and to close unacceptable access automatically or manually according

3. Execute the SQL query on PDB2 again. Remember that a security realm now protects the data

    - **As an application user** (the schema owner `EMPLOYEESEARCH_PROD`)

        ```
        <copy>./sh_query_employee_data.sh pdb2 EMPLOYEESEARCH_PROD</copy>
        ```

        ![View EMPLOYEESEARCH_PROD sensitive data on PDB2](./images/hack-lab3c-02.png "View EMPLOYEESEARCH_PROD sensitive data on PDB2")

        **Note**: Redaction policies protect some of the sensitive data – we haven't changed how the application user sees the data

    - **As a DBA** (SYS as sysdba)

        ```
        <copy>./sh_query_employee_data.sh pdb2 SYS</copy>
        ```

        ![View EMPLOYEESEARCH_PROD sensitive data as DBA on PDB2](./images/hack-lab3d-10.png "View EMPLOYEESEARCH_PROD sensitive data as DBA on PDB2")

    **Note**:
    - Access to sensitive data is controlled, even for database administrators
    - As long as the security realm is active, objects within the realm are invisible to any users not explicitly authorized to access the realm
    - Realms can be easily armed (enabled) or disarmed (disabled) automatically or manually by the security administrator - who is not the DBA

4. When you are ready to continue, you can drop the realm on PDB2

    ```
    <copy>./sh_dbv_drop_realm.sh pdb2</copy>
    ```

    ![DB Vault - Drop the REALM on PDB2](./images/hack-lab3d-11.png "DB Vault - Drop the REALM on PDB2")

5. Here, we have used one of the advanced access control features provided by the Oracle Database, called **Database Vault**

    ---

    **Benefits of using Database Vault**
    - Addresses compliance regulations to secure data from misuse
    - Protects against inappropriate data access by privileged users
    - Implements a customizable separation of duty model
    - Helps you design flexible security policies for your database
    - Addresses database consolidation and cloud environment security concerns
    - Controls the exposure of sensitive application data to those without a true need-to-know
    - Works in a Multitenant Environment, increasing security for consolidation

    > To learn more about how to use Database Vault, please refer to the "[DB Security - Database Vault] (https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=682)" workshop

    ---

**Now you have reached the end of this lab!**

We started with a fictitious attacker who planned to execute a ransomware attack on our organization. Ransomware attacks usually involve both data theft AND denial of service. The controls we've discussed in this lab are targeted at preventing data theft – and would hopefully give your organization enough confidence that stolen data was unusable by the attackers. That can make the difference between being forced to pay a ransom and being willing NOT to pay the ransom because the extortion component of the ransomware attack is gone. Read on to learn more about ransomware attacks, or if you aren't interested, feel free to proceed to the next lab.

## Learn More?
Read more about ransomware here:
- [US Cybersecurity and Infrastructure Security Agency (CISA)’s Stop Ransomware campaign] (https://www.cisa.gov/stopransomware)
- [European Union Agency for Cybersecurity (ENISA)] (https://www.enisa.europa.eu/topics/csirts-in-europe/glossary/ransomware)
- [CertNZ (New Zealand)] (https://www.cert.govt.nz/individuals/common-threats/ransomware/)

To learn more about the capabilities discussed in this workshop and to learn how to set them up, you visit these two comprehensive workshops:
- [DB Security Basics](https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=698)
- [DB Security Advanced](https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=726)

## Acknowledgements
- **Author** - Hakim Loumi, Database Security Senior Principal PM
- **Contributors** - Russ Lowenthal, Database Security VP
- **Last Updated By/Date** - Hakim Loumi, Database Security PM - December 2024