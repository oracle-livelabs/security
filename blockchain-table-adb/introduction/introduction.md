# Introduction to the LiveLab: Immutable and Blockchain Tables

## About this Workshop

Data integrity and security are critical in today's digital era, where organizations handle vast amounts of sensitive information. While traditional security mechanisms like passwords, privileges, and encryption focus on keeping unauthorized users out, they often fail to address scenarios where authorized insiders or sophisticated attackers compromise data integrity. To bridge this gap, Oracle introduces **Immutable Tables** and **Blockchain Tables**, two powerful features designed to enhance in-database data security.

This LiveLab is designed to provide participants with hands-on experience in leveraging these technologies to ensure data remains tamper-proof and cryptographically secure within the database. Through structured exercises and SQLcl commands, participants will explore the unique functionalities of Immutable and Blockchain Tables.

#### Flow of the LiveLab:
1. **Immutable Tables: Basic Data Immutability**
   - Understand the core concept of immutability and how Immutable Tables ensure that data cannot be modified or deleted after insertion.
   - Learn the parameters required to create Immutable Tables, their management commands, and failure scenarios (e.g., trying to delete rows).

2. **Blockchain Tables: Advanced Cryptographic Security**
   - Build on the principles of immutability with additional functionalities like row signing and verification.
   - Understand the prerequisites for Blockchain Tables, such as creating wallets and managing certificates.
   - Learn advanced commands, such as countersignatures, digest generation, and row-level cryptographic verification.
   - Use cases: scenarios requiring end-to-end data integrity, transparency, and resistance to impersonation or falsification.

In this LiveLab, we will be using **SQLcl commands** [](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/24.3/sqcug/blockchain_table.html) to perform various operations on Immutable and Blockchain Tables, offering a seamless and interactive way to work with these advanced database features. While the same functionality can be achieved through **PL/SQL packages** such as `DBMS_IMMUTABLE_TABLE` and `DBMS_BLOCKCHAIN_TABLE` (as detailed in the [documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_blockchain_table.html)), SQLcl simplifies the process by providing user-friendly commands tailored for these operations. This approach makes it more convenient for users to create tables, manage certificates, verify data integrity, and perform other tasks without delving into complex PL/SQL scripts. By leveraging SQLcl, participants can focus on understanding the core concepts and functionalities of Immutable and Blockchain Tables while efficiently executing commands.

By the end of this LiveLab, participants will not only understand the technical nuances of Immutable and Blockchain Tables but also appreciate their real-world applications in mitigating data tampering risks and ensuring regulatory compliance. Let’s dive in and start building secure, tamper-proof database solutions!

Estimated Workshop Time: XX hour, xx minutes 

<if type="odbw">if you would like to watch us do the workshop, click [here](). </if>

### Prerequisites

This workshop assumes you have:

<TODO>

### Learn More

<TODO>

## Acknowledgements

* **Author** - Amit Ketkar, Database Product Manager
* **Contributors** - Pavas Navaney, Senior Member of Technical Staff <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Vinay Pandhariwal, Member of Technical Staff
* **Last Updated By/Date** - Vinay Pandhariwal, Member of Technical Staff