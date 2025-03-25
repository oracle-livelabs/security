# Prevent and Detect Fraud with Immutable and Blockchain Tables on Oracle Autonomous Database

## About this Workshop

Data integrity and security are critical in today's digital era, where organizations handle vast amounts of sensitive information. While traditional security mechanisms like passwords, privileges, and encryption focus on keeping unauthorized users out, they often fail to address scenarios where authorized insiders or sophisticated attackers compromise data integrity. To bridge this gap, Oracle introduces **Immutable Tables** and **Blockchain Tables**, two powerful features designed to enhance in-database data security.

This LiveLab is designed to provide participants with hands-on experience in leveraging these technologies to ensure data remains tamper-resistant and cryptographically secure within the database. Through structured exercises and SQLcl commands, participants will explore the unique functionalities of Immutable and Blockchain Tables.

#### Flow of the LiveLab:
1. **Immutable Tables: Basic Data Immutability**
   - Understand the core concept of immutability and how Immutable Tables ensure that data cannot be modified or deleted after insertion.
   - Learn the parameters required to create Immutable Tables, their management commands, and failure scenarios (e.g., trying to delete rows).

2. **Blockchain Tables: Advanced Cryptographic Security**
   - Build on the principles of immutability with additional functionalities like row signing and verification.
   - Understand the prerequisites for Blockchain Tables, such as creating wallets and managing certificates.
   - Learn advanced commands, such as countersignatures, digest generation, and row-level cryptographic verification.
   - Use cases: scenarios requiring end-to-end data integrity, transparency, and resistance to impersonation or falsification.

In this LiveLab, we will be using [**SQLcl commands**](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/24.4/sqcug/blockchain_table.html) to perform various operations on Immutable and Blockchain Tables, offering a seamless and interactive way to work with these advanced database features. While the same functionality can be achieved through **PL/SQL packages** such as `DBMS_IMMUTABLE_TABLE` and `DBMS_BLOCKCHAIN_TABLE` (as detailed in the [documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_blockchain_table.html)), SQLcl simplifies the process by providing user-friendly commands tailored for these operations. This approach makes it more convenient for users to create tables, manage certificates, verify data integrity, and perform other tasks without delving into complex PL/SQL scripts. By leveraging SQLcl, participants can focus on understanding the core concepts and functionalities of Immutable and Blockchain Tables while efficiently executing commands.

By the end of this LiveLab, participants will not only understand the technical nuances of Immutable and Blockchain Tables but also appreciate their real-world applications in mitigating data tampering risks and ensuring regulatory compliance. Let’s dive in and start building secure, tamper-resistant database solutions!

* Estimated Workshop Time: 1 hour, 50 minutes 

You may now [proceed to the next lab](#next).

## Learn More

* For more information on Immutable Table and other Immutable Table commands, please see [DBMS\_IMMUTABLE\_TABLE](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_immutable_table.html) documentation and SQLcl help section accessed using **`help immutable_table`** in the SQLcl console.

* For more information on Blockchain Table and other Blockchain Table commands, please see [DBMS\_BLOCKCHAIN\_TABLE](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_blockchain_table.html) documentation and SQLcl help section accessed using **`help blockchain_table`** in the SQLcl console.

* For more information about Immutable table and Blockchain table SQLcl commands, please see **[SQLcl Command Reference](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/24.4/sqcug/blockchain_table.html#GUID-1430B902-25D7-4C72-926D-3EEF9C035661)**

* For more information on SQLcl, please see **[SQLcl Documentation](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/)**

## Acknowledgements

* **Contributors** - Amit Ketkar, Pavas Navaney, Vinay Pandhariwal 
* **Created By/Date** - Vinay Pandhariwal, March 2025
* **Last Updated By/Date** - Vinay Pandhariwal, March 2025