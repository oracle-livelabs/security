# Prevent and Detect Fraud with Immutable and Blockchain Tables on Oracle Autonomous Database

## About this Workshop

Data integrity and security are critical in today's digital era, where organizations handle vast amounts of sensitive information. While traditional security mechanisms like passwords, privileges, and encryption focus on keeping unauthorized users out, they often fail to address scenarios where authorized insiders or sophisticated attackers compromise data integrity. To bridge this gap, Oracle introduces **Immutable Tables** and **Blockchain Tables**, two powerful features designed to enhance in-database data security.

This LiveLab is designed to provide participants with hands-on experience in leveraging these technologies to ensure data remains tamper-resistant and cryptographically secure within the database. Through structured exercises and SQLcl commands, participants will explore the unique functionalities of Immutable and Blockchain Tables.

#### Flow of the LiveLab:
1. **Immutable Tables with Retention-Based Data Protection**
    - Understand the core concept of immutability and how Immutable Tables prevent modification or deletion after insertion.
    - Learn the parameters required to create Immutable Tables, their management commands, and failure scenarios (e.g., trying to delete rows).

2. **Blockchain Tables with Cryptographic Verifiability**
    - Extend the principles of immutability with cryptographic chaining of rows for enhanced tamper detection.
    - Learn how to create Blockchain Tables, insert data, and verify table integrity using SQLcl commands.
    - Understand practical applications in fraud prevention, financial audit trails, and regulatory compliance.

3. **Advanced Features: Row Signing and Certificate Management**
    - Configure Oracle Wallets and certificates to enable digital signing of individual rows in a Blockchain Table.
    - Sign blockchain table rows using user certificates and validate authenticity using built-in verification commands.
    - Understand countersignatures, delegate signing, and signature verification flows.

4. **Blockchain table Digest Operations and Verification**
    - Learn how to generate last-rows or filtered row digests and produce cryptographically signed snapshots.
    - Use signed and unsigned digests to verify blockchain table integrity and detect unauthorized changes.

5. **Blockchain Table Backed Flashback Journals for Regular Tables**
    - Learn how to enable blockchain table based tracking of regular tables using the BLOCKCHAIN FLASHBACK ARCHIVE.
    - Understand how Oracle automatically stores row change histories in blockchain history tables.

In this LiveLab, we will be using [**SQLcl commands**](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/24.4/sqcug/blockchain_table.html) to perform various operations on Immutable and Blockchain Tables, offering a seamless and interactive way to work with these advanced database features. While the same functionality can be achieved through **PL/SQL packages** such as `DBMS_IMMUTABLE_TABLE` and `DBMS_BLOCKCHAIN_TABLE` (as detailed in the [documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_blockchain_table.html)), SQLcl simplifies the process by providing user-friendly commands tailored for these operations. This approach makes it more convenient for users to create tables, manage certificates, verify data integrity, and perform other tasks without delving into complex PL/SQL scripts. By leveraging SQLcl, participants can focus on understanding the core concepts and functionalities of Immutable and Blockchain Tables while efficiently executing commands.

By the end of this LiveLab, you will:
- Understand the difference between Immutable Tables and Blockchain Tables.
- Learn how to configure certificates and wallets, and implement cryptographic signing and verification, including user signatures, delegate signing, and countersignatures.
- Be able to enable blockchain table based history logging for regular tables using Flashback Archives.
- Gain practical skills for preventing unauthorized tampering and ensuring compliance with regulatory requirements.

Let’s dive in and start building secure, tamper-resistant database solutions!

* Estimated Workshop Time: 2 hour, 15 minutes 

You may now [proceed to the next lab](#next).

## Learn More

* For more information on Immutable Table and other Immutable Table commands, please see **[DBMS\_IMMUTABLE\_TABLE](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_immutable_table.html)** documentation and SQLcl help section accessed using **`help immutable_table`** in the SQLcl console.

* For more information on using certificates with blockchain tables, please see the **[DBMS\_USER\_CERTS](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_user_certs.html)** documentation and SQLcl help section accessed using **`help certificate`** in the SQLcl console.

* For more information on Blockchain Table and other Blockchain Table commands, please see the **[DBMS\_BLOCKCHAIN\_TABLE](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_blockchain_table.html)** documentation and SQLcl help section accessed using **`help blockchain_table`** in the SQLcl console.

* For more information on Blockchain Flashback Journals for regular tables, please see **[Protecting Flashback Archive Data](https://docs.oracle.com/en/database/oracle/oracle-database/23/adfns/flashback.html#GUID-6B04E5D6-4740-4CA6-9CC6-A3CD19E00FA6)** documentation.

* For more information about PKI Certificate SQLcl commands, please see **[SQLcl Certificates](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/25.1/sqcug/certificate.html)**

* For more information about Immutable table SQLcl commands, please see **[SQLcl Immutable Table](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/25.1/sqcug/immutable_table.html)**

* For more information about Blockchain table SQLcl commands, please see **[SQLcl Blockchain Table](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/25.1/sqcug/blockchain_table.html)**

* For more information on SQLcl, please see **[SQLcl Documentation](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/)**

## Acknowledgements

* **Contributors** - Amit Ketkar, Pavas Navaney, Vinay Pandhariwal 
* **Created By/Date** - Vinay Pandhariwal, April 2025
* **Last Updated By/Date** - Vinay Pandhariwal, April 2025
