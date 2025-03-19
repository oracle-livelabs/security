# Blockchain Tables: Enhance Data Integrity with Cryptographic Precision and Trust

## **Introduction**

**Blockchain Tables** in Oracle Database extend the concept of immutability with cryptographic security, enabling organizations to ensure both data integrity and authenticity. They are designed to meet the increasing demand for secure, tamper-resistant, and auditable data storage solutions. Building on the foundation of Immutable Tables, Blockchain Tables introduce advanced features such as **row-level signing**, **digest verification**, and **distributed trust mechanisms**, making them ideal for scenarios where transparency, auditability, and verifiable data authenticity are essential.

At their core, Blockchain Tables are **insert-only tables** that organize rows into cryptographically secure chains. Each inserted row is linked to the previous row using a cryptographic hash, creating an immutable chain of data that ensures any attempt to tamper with or delete rows can be detected. Unlike traditional database tables, Blockchain Tables prohibit updates to rows and restrict deletions based on configurable retention policies, making them a powerful tool for applications requiring a tamper-resistant ledger.

These tables address critical challenges faced by enterprises and governments in protecting data from unauthorized modifications, fraud, and cyber-attacks. They provide an unparalleled level of security by focusing on safeguarding data that records important actions, assets, entities, and documents. Unauthorized modification of such records can result in loss of assets, business disruption, and legal complications. Blockchain Tables not only ensure the immutability of data but also provide built-in mechanisms for verifying that data remains unaltered over time.

<details open>
<summary><mark>Key Characteristics of Blockchain Tables:</mark></summary>
- **Tamper-Resistant Design:** Each row is chained to the previous row using cryptographic hashes, ensuring data immutability.
- **Insert-Only Operations:** Rows can only be inserted; updates are not allowed.
- **Retention Policy:** Deletion of rows is restricted based on a defined retention period, ensuring a secure and auditable history.
- **Row-Level Signing (Optional):** Users can add digital signatures to rows for enhanced fraud protection, requiring a digital certificate to verify the signature.
- **Independent Verification:** Built-in tools allow users to verify that rows and chains have not been tampered with or deleted.
- **Integration with Existing Applications:** Blockchain Tables can be seamlessly used with regular database tables in queries and transactions.
</details>
</ br>
<details open>
<summary><mark>Practical Use Cases:</mark></summary>
1. **Fraud Prevention:**
   Blockchain Tables provide cryptographic evidence of data authenticity, helping detect and prevent tampering with critical records.
   
2. **Regulatory Compliance:**
   Meet stringent requirements for data transparency and traceability in industries such as finance, healthcare, and government.
   
3. **Tamper-Resistant Ledgers:**
   Maintain a secure and auditable history of transactions, assets, or events, ensuring the integrity of current and historical data.

4. **Trusted Applications Without Distributed Consensus:**
   Blockchain Tables can be used in blockchain applications where different database users trust Oracle Database to maintain a tamper-resistant blockchain. This eliminates the need for distributed consensus mechanisms, providing the security of a blockchain with much higher throughput and lower latency.
</details>
</br>
<details open>
<summary><mark>Why Blockchain Tables?</mark></summary>
Blockchain Tables address critical challenges faced by enterprises and governments, focusing on protecting data from criminals, hackers, and fraud. Unauthorized modification of records can result in loss of assets, business, and legal repercussions. Blockchain Tables provide an effective solution to ensure that important records are immutable and verifiable. These features make them essential for applications requiring tamper-resistant ledgers of current and historical transactions.
</details>

#### Enhanced Fraud Protection with Optional Signatures:
- A **user signature** can be added to a row to provide additional security.
- Signatures require a digital certificate, which the database uses to verify the authenticity of the signed row.

In this lab, we will use SQLcl to perform various operations on Blockchain Tables, leveraging its intuitive and user-friendly interface. The dedicated command for managing Blockchain Tables is `blockchain_table | bl` . SQLcl offers powerful features such as Completion Insight (TAB) for command suggestions, Command History to revisit previous commands, and an In-Line Editor for easy modifications, ensuring a smooth and efficient workflow. For additional guidance, you can access the help section directly in the SQLcl console by typing `help blockchain_table` or `help bl` . This provides a comprehensive overview of all commands and functionalities, making it easier to explore and manage Blockchain Tables throughout the lab.


* Estimated Time: 45 minutes

Watch the video below for a quick walk through of the lab.

[Blockchain Tables](videohub:1_w6ghvbpi:medium)

### Objectives

In this lab, you will:

- **Create a Blockchain Table** <br />
  Learn how to define and set up a Blockchain Table, including its structure and configuration.

- **Insert Rows into the Blockchain Table** <br />
  Understand how to add data to the Blockchain Table and ensure proper formatting for immutable storage.

- **Describe the Details of a Blockchain Table** <br />
  Retrieve and analyze metadata about the Blockchain Table, including its chain configuration, properties, and security features.

- **Verify Rows and Chains for Integrity and Authenticity** <br />
  Explore the built-in mechanisms to check row integrity and the authenticity of data in the Blockchain Table.

- **Sign Rows in a Blockchain Table** <br />
  Understand the process of digitally signing rows to add an additional layer of verification.

- **Generate Signed and Unsigned Distributable Digests** <br />
  Learn how to create distributable digests to share verifiable data snapshots from the Blockchain Table.


### Prerequisites

* A Free-Tier or LiveLabs Oracle Cloud account.
* Have successfully completed the previous labs.

## Task 1: Create a Blockchain Table

---

1. The `CREATE BLOCKCHAIN TABLE` statement requires additional attributes to ensure tamper-resistant functionality. These include the **`NO DROP`**, **`NO DELETE`**, and **`HASHING USING`** clauses, along with the **BLOCKCHAIN** keyword. Here’s what each clause does:

	- **`NO DROP` Clause**:
		- Prevents the table from being dropped until specific conditions are met.
		- **`NO DROP UNTIL number DAYS IDLE`**: The table cannot be dropped until there have been no new rows inserted for the specified number of days. 
		- If the table has no rows, it can still be dropped regardless of this setting.

	- **`NO DELETE` Clause**:
		- Defines how long rows in the table are protected from deletion.
		- **`NO DELETE`**: Retains rows indefinitely (cannot be deleted).
		- **`NO DELETE UNTIL number DAYS AFTER INSERT`**: Protects rows from deletion for a specified minimum of **16 days**.
		- Adding **`LOCKED`** ensures that this retention setting cannot be changed later using the `ALTER TABLE` command.

	- **`HASHING USING` Clause**:
		- Specifies the cryptographic hash algorithm for securing row data.
		- **`HASHING USING sha2_512`**: Uses the SHA2_512 algorithm to create tamper-resistant rows.
		
	- **`VERSION v1`**: Basic blockchain table functionality.
	- **`VERSION v2`**: Supports additional features like schema evolution, delegate signatures, and countersignatures (available in Oracle 23ai).

	Run the following command to create a Blockchain Table named **`bank_ledger_bt`**. This table maintains a tamper-resistant ledger of current and historical transactions using the **SHA2_512** hashing algorithm. Rows in this table cannot be deleted, and the table itself can only be dropped after **16 days** of inactivity.

	```
		<copy>
	CREATE BLOCKCHAIN TABLE bank_ledger_bt (
		account_number VARCHAR2(128) UNIQUE,
		deposit_date DATE,
		deposit_amount NUMBER
	)
	NO DROP UNTIL 16 DAYS IDLE
	NO DELETE LOCKED
	HASHING USING "SHA2_512" VERSION "v2";
	</copy>
	```
	> **Expected Output:**  
	> <pre>
	> Blockchain TABLE created.</pre>


2. After creating the table, run the following **SQLcl command** to describe the table's clauses and confirm its creation. Note that the description will display only the visible columns of the table:
	```
	<copy>
	blockchain_table desc -tab bank_ledger_bt
	</copy>
   ```
   ![Create the table](./images/lab4-task1-1.png " ")

> **Expected Output:**  
	> <pre>
	> Blockchain table 'bank_ledger_bt'  
	> ---------------------------------~
	>   
	> COLUMN_NAME     NULL?   DATA_TYPE  
	> --------------  -----   ---------  
	> ACCOUNT_NUMBER          VARCHAR2  
	> DEPOSIT_DATE            DATE  
	> DEPOSIT_AMOUNT          NUMBER  
	>   
	> Other Attributes:  
	> ------------------~
	> ROW RETENTION (DAYS)              : 365000  
	> ROW RETENTION LOCKED              : YES  
	> TABLE INACTIVITY RETENTION (DAYS) : 16  
	> HASHING ALGORITHM                 : SHA2_512  
	> TABLE VERSION                     : V2</pre>


## Task 2: Insert Rows into the Blockchain Table

---

1. Copy and paste the below code snippet in the worksheet and run them to insert records into the `bank_ledger` blockchain table.

	```
	<copy>
	INSERT INTO bank_ledger_bt VALUES ('991',to_date(sysdate,'dd-mm-yyyy'),100);
	INSERT INTO bank_ledger_bt VALUES ('992',to_date(sysdate,'dd-mm-yyyy'),200);
	INSERT INTO bank_ledger_bt VALUES ('993',to_date(sysdate,'dd-mm-yyyy'),500);
	INSERT INTO bank_ledger_bt VALUES ('994',to_date(sysdate,'dd-mm-yyyy'),-200);
	INSERT INTO bank_ledger_bt VALUES ('995',to_date(sysdate,'dd-mm-yyyy'),100);
	INSERT INTO bank_ledger_bt VALUES ('996',to_date(sysdate,'dd-mm-yyyy'),200);
	INSERT INTO bank_ledger_bt VALUES ('997',to_date(sysdate,'dd-mm-yyyy'),500);
	INSERT INTO bank_ledger_bt VALUES ('998',to_date(sysdate,'dd-mm-yyyy'),-200);
	INSERT INTO bank_ledger_bt VALUES ('999',to_date(sysdate,'dd-mm-yyyy'),-200);
	INSERT INTO bank_ledger_bt VALUES ('1000',to_date(sysdate,'dd-mm-yyyy'),-200);
	commit;
	</copy>
	```

	![insert rows in BT table](./images/lab4-task2-1.png " ")

2. Query the `bank_ledger` blockchain table to show the records.

	```
	<copy>
	select * from bank_ledger_bt;
	</copy>
	```

	![query bank_ledger table](./images/lab4-task2-2.png " ")

## Task 3: View Blockchain Tables and Its Internal Columns

---

1. Run the command to view the table details.

	```
	<copy>
	select * from user_blockchain_tables WHERE table_name = 'BANK_LEDGER_BT';
	</copy>
	```

	![view blockchain table details](./images/lab4-task3-1.png " ")

2. Use the `USER_TAB_COLS` view to display all internal column names used to store internal information like the users number, the users signature.

	```
	<copy>
	SELECT table_name, internal_column_id "Col ID", SUBSTR(column_name,1,30) "Column Name", SUBSTR(data_type,1,30) "Data Type", data_length "Data Length"
	FROM user_tab_cols 
	WHERE TABLE_NAME = 'BANK_LEDGER_BT'
	ORDER BY internal_column_id;
	</copy>
	```

	![query user_tab_cols view to view hidden columns](./images/lab4-task3-2.png " ")

	The additional columns ending with $ are Oracle managed to maintain the chained sequence, cryptographic hash values, and support user signing. You can include these columns in your queries by referencing them explicitly.

3. Query the `bank_ledger_bt` blockchain table to display all the values in the blockchain table including values of internal columns.

	```
	<copy>
	select account_number, deposit_date, deposit_amount, ORABCTAB_INST_ID$,
	ORABCTAB_CHAIN_ID$, ORABCTAB_SEQ_NUM$,
	ORABCTAB_CREATION_TIME$, ORABCTAB_USER_NUMBER$,
	ORABCTAB_HASH$, ORABCTAB_SIGNATURE$, ORABCTAB_SIGNATURE_ALG$,
	ORABCTAB_SIGNATURE_CERT$ from bank_ledger_bt;
	</copy>
	```

	![query bank_ledger_bt table](./images/lab4-task3-3.png " ")

## Task 4: Manage Rows in a Blockchain Table

---

When you try to manage the rows using update, delete, truncate you get the error `operation not allowed on the blockchain table`.

1. Update a record in the `bank_ledger_bt` blockchain table by setting deposit\_amount=0.

	```
	<copy>
	update bank_ledger_bt set deposit_amount=0 where account_number=999;
	</copy>
	```

	![update a record in bank_ledger_bt table](./images/lab4-task4-1.png " ")
	> **Expected Output:**  
	> <pre>
	> Error starting at line : 1 in command -  
	> update bank_ledger_bt set deposit_amount=0 where account_number=999  
	> Error at Command Line : 1 Column : 8  
	> Error report -  
	> SQL Error: ORA-05715: operation not allowed on the blockchain or immutable table  
	>   
	> https://docs.oracle.com/error-help/db/ora-05715/05715.0000 - "operation not allowed on the blockchain or immutable table"  
	> *Cause:    An attempt was made to perform update, delete, alter, truncate,  
	>            insert as select, rename, or move operation on a blockchain  
	>            or immutable table.  
	> *Action:   No action required.  
	>   
	> More Details :  
	> https://docs.oracle.com/error-help/db/ora-05715/</pre>


2. Delete a record in the `bank_ledger_bt` blockchain table.

	```
	<copy>
	delete from bank_ledger_bt where account_number=999;
	</copy>
	```

	![delete a record](./images/lab4-task4-2.png " ")
	> **Expected Output:**  
	> <pre>
	> Error starting at line : 1 in command -  
	> delete from bank_ledger_bt where account_number=999  
	> Error at Command Line : 1 Column : 13  
	> Error report -  
	> SQL Error: ORA-05715: operation not allowed on the blockchain or immutable table  
	>   
	> https://docs.oracle.com/error-help/db/ora-05715/05715.0000 - "operation not allowed on the blockchain or immutable table"  
	> *Cause:    An attempt was made to perform update, delete, alter, truncate,  
	>            insert as select, rename, or move operation on a blockchain  
	>            or immutable table.  
	> *Action:   No action required.  
	>   
	> More Details :  
	> https://docs.oracle.com/error-help/db/ora-05715/  
	> </pre>


3. Truncating the table `bank_ledger_bt`.

	```
	<copy>
	truncate table bank_ledger_bt;
	</copy>
	```

	![truncate bank_ledger_bt table](./images/lab4-task4-3.png " ")
	> **Expected Output:**  
	> <pre>
	> Error starting at line : 1 in command -  
	> truncate table bank_ledger_bt  
	> Error report -  
	> ORA-05715: operation not allowed on the blockchain or immutable table  
	>   
	> https://docs.oracle.com/error-help/db/ora-05715/05715.0000 - "operation not allowed on the blockchain or immutable table"  
	> *Cause:    An attempt was made to perform update, delete, alter, truncate,  
	>            insert as select, rename, or move operation on a blockchain  
	>            or immutable table.  
	> *Action:   No action required.</pre>



## Task 5: Manage Blockchain Tables

---

Managing Blockchain Tables involves ensuring their tamper-resistant and immutable properties are preserved while leveraging advanced features, especially in **V2 Blockchain Tables**. Below are examples of operations you can perform on Blockchain Tables, applicable to both **V1** and **V2** tables, with special features highlighted for V2.

### 1. **Create another blockchain Table without LOCKED keyword**
```
	<copy>
	CREATE BLOCKCHAIN TABLE bank_ledger_bt_2(
	account_number VARCHAR2(128),
	deposit_date DATE,
	deposit_amount NUMBER
	)
	NO DROP UNTIL 16 DAYS IDLE
	NO DELETE UNTIL 16 DAYS AFTER INSERT
	HASHING USING "SHA2_512" VERSION "v2";
	</copy>
```
![create bank_ledger_bt_@ table](./images/lab4-task5-1.png " ")
> **Expected Output:**  
> <pre>
> Blockchain TABLE created.</pre>


### 2. **Alter a Blockchain Table**

The **`ALTER TABLE`** command allows modifications to the `NO DROP` and `NO DELETE` clauses, but:
- Retention periods **cannot** be reduced.
- In V2 tables, schema evolution features like adding or dropping columns are supported.

	#### Example: Modify Retention Period
	Increase the retention period for `bank_ledger_bt_2` rows to 20 days after insertion:
		```
		<copy>
		ALTER TABLE bank_ledger_bt_2 NO DELETE UNTIL 20 DAYS AFTER INSERT;
		</copy>
		```
	![modify retention period](./images/lab4-task5-2.png " ")
	> **Expected Output:**  
	> <pre>
	> Table BANK_LEDGER_BT_2 altered.</pre>


	#### Example: Failed Reduction Example : Attempting to reduce the retention period will result in:
	```
	<copy>
	ALTER TABLE bank_ledger_bt_2 NO DELETE UNTIL 17 DAYS AFTER INSERT;
	</copy>
	```
	
	![failed reduction of retention time](./images/lab4-task5-3.png " ")
	> **Expected Output:**  
	> <pre>
	> Error starting at line : 1 in command -  
	> ALTER TABLE bank_ledger_bt_2 NO DELETE UNTIL 17 DAYS AFTER INSERT  
	> Error report -  
	> ORA-05732: retention value cannot be lowered  
	>   
	> https://docs.oracle.com/error-help/db/ora-05732/05732.0000 - "retention value cannot be lowered"  
	> *Cause:    An attempt was made to alter a blockchain or immutable table to a  
	>            lower retention value.  
	> *Action:   Specify a higher retention value. </pre>
		
	#### Example: Add Columns (V2 Tables Only)
	Add a new column to a V2 Blockchain Table:
			```
			<copy>
			ALTER TABLE bank_ledger_bt_2 ADD (additional_info VARCHAR2(100));
			</copy>
			```
	![Add column to blockchain table](./images/lab4-task5-4.png " ")
	> **Expected Output:**  
	> <pre>
	> Table BANK_LEDGER_BT_2 altered. </pre>

	#### Example: Drop Columns (V2 Tables Only)
	Drop a column in a V2 Blockchain Table:
		```
			<copy>
			ALTER TABLE bank_ledger_bt_2 DROP COLUMN additional_info;
			</copy>
		```
	![Drop column in blockchain table](./images/lab4-task5-5.png " ")
	> **Expected Output:**  
	> <pre>
	> Table BANK_LEDGER_BT_2 altered. </pre>

### 3. **Drop a Blockchain Table**

A Blockchain Table can only be dropped if:
- **No rows exist** in the table.
- The table complies with the `NO DROP` clause.
		The table `bank_ledger_bt_2` is dropped as it does not contain any rows.
		```
		<copy>
		DROP TABLE bank_ledger_bt_2;
		</copy>
		```
	> **Expected Output:**  
		> <pre>
		> Table BANK_LEDGER_BT_2 dropped. </pre>


- If rows exist or the `NO DROP` retention period is active, the command will fail.
		The table `bank_ledger_bt` does not get deleted as it contains multiple rows.
		```
		<copy>
		DROP TABLE bank_ledger_bt;
		</copy>
		```
	> **Expected Output:**  
		> <pre>
		> Error starting at line : 1 in command -  
		> DROP TABLE bank_ledger_bt  
		> Error report -  
		> ORA-05723: dropping BANK_LEDGER_BT, which is a non-empty blockchain or immutable table, is not allowed  
		>   
		> https://docs.oracle.com/error-help/db/ora-05723/05723.0000 - "dropping %s, which is a non-empty blockchain or immutable table, is not allowed"  
		> *Cause:    A blockchain or immutable table was created with a NO DROP clause,  
		>            or its idle period has not yet elapsed.  
		> *Action:   Do not attempt to drop this blockchain or immutable table, wait  
		>            until its idle period has elapsed, or wait until all its rows are  
		>            expired and deleted. </pre>

	![no drop clause in create blockchain table](./images/lab4-task5-7.png " ")

### 4. **Difference between a V1 Blockchain Table and V2 Blockchain Table with Advanced Features**

#### Example: Basic V1 Blockchain Table
<pre>
CREATE BLOCKCHAIN TABLE bank_ledger_bt_v1 (
   account_number VARCHAR2(128),
   deposit_date DATE,
   deposit_amount NUMBER
)
NO DROP UNTIL 16 DAYS IDLE
NO DELETE UNTIL 16 DAYS AFTER INSERT
HASHING USING "SHA2_512" VERSION "v1";
</pre>

#### Example: Advanced V2 Blockchain Table
Create a V2 Blockchain Table with user-defined chains and row versioning:
<pre>
CREATE BLOCKCHAIN TABLE bank_ledger_bt_v2 (
   id NUMBER,
   account_number VARCHAR2(128),
   deposit_date DATE,
   deposit_amount NUMBER
)
NO DROP UNTIL 0 DAYS IDLE
NO DELETE UNTIL 16 DAYS AFTER INSERT
HASHING USING "SHA2_512"
WITH ROW VERSION AND USER CHAIN bank_chain (bank)
VERSION "v2";
</pre>

V2 Blockchain Table comes with advance feature like ROW VERSION and USER_CHAIN


### 5. **Advanced Features for V2 Blockchain Tables**

#### **Row Versions**
Blockchain tables do not permit updates to existing rows. Instead, multiple versions of a row can be inserted, representing different stages of the same record. Row versions ensure accurate sequencing of related row inserts for a specified set of columns. Oracle automatically creates a view named **`<Table_Name>_LAST$`** to display only the latest row version for each unique set of values.

To create a blockchain table with row versions, use the **`WITH ROW VERSION`** clause.

##### Example: Create a Blockchain Table with Row Versions
<pre>
CREATE BLOCKCHAIN TABLE bank_ledger_version (
   bank VARCHAR2(128),
   account_no NUMBER,
   deposit_date DATE,
   deposit_amount NUMBER
)
  NO DROP UNTIL 31 DAYS IDLE
  NO DELETE LOCKED
  HASHING USING "SHA2_512"
  WITH ROW VERSION bank_version (bank, account_no)
  VERSION "v2";
</pre>

**Restrictions for Row Versions:**
- At most **three columns** can be specified.
- Supported column types: **NUMBER, CHAR, VARCHAR2, RAW**.
- The primary key columns must not be identical to the set of row version columns.
- The <row_version_name> must be supplied when creating the table.
- Row versions cannot be used with version 1 blockchain tables.

---

#### **User Chains**
In addition to row versions, V2 blockchain tables support **user-defined chains**, which group rows with the same values in up to three specified columns. These chains help logically partition data and are verified separately from system chains.
To create user chains in blockchain tables, use the following syntax:

- **`WITH USER CHAIN <chain_name> (col1 [, col2 [, col3]])`**: Creates a user-defined chain based on the specified columns.

- **`WITH ROW VERSION AND USER CHAIN <chain_name> (col1 [, col2 [, col3]])`**: Combines row versioning with user chains, ensuring row sequencing within the user chain.

The cryptographic hash for a user chain is stored in the hidden column **`ORABCTAB_USER_CHAIN_HASH$`**, and rows are ordered by **`ORABCTAB_ROW_VERSION$`**.

##### Example: Create a Blockchain Table with User Chains
<pre>
CREATE BLOCKCHAIN TABLE bank_ledger (
   bank VARCHAR2(128),
   account_no NUMBER,
   deposit_date DATE,
   deposit_amount NUMBER
)
  NO DROP UNTIL 31 DAYS IDLE
  NO DELETE LOCKED
  HASHING USING "SHA2_512"
  WITH ROW_VERSION AND USER CHAIN bank_accounts (bank, account_no)
  VERSION "v2";
</pre>

**Restrictions for User Chains:**
- At most **three columns** can be specified.
- Supported column types: **NUMBER, CHAR, VARCHAR2, RAW**.
- The user chain columns must not be identical to the primary key columns.
- User chains are not supported in version 1 blockchain tables.


## Task 6: Verifying Rows in Blockchain Tables

---

This functionality verifies the integrity of rows in Blockchain Tables by checking the hash values and by default validating the row signatures. This command ensures that no rows have been tampered with or modified, preserving the table’s immutability. 

<details open>
<summary><mark>SQLcl based verification</mark></summary>

The command used here is **`blockchain_table verify_rows`**. This is equivalent to the **`DBMS_BLOCKCHAIN_TABLE.VERIFY_ROWS`** PL/SQL procedure.

Usage:
	<pre>
	blockchain\_table verify\_rows {OPTIONS}
	</pre>

<details open>
<summary>**Options:**</summary>
- **`-table_name|-tab <table_name>` (Required):** Specifies the name of the Blockchain Table to verify.
- **`-low_timestamp|-low <low_timestamp>` (Optional):** Defines the lower bound of the time range for verifying rows. Default is `NULL`.
- **`-high_timestamp|-high <high_timestamp>` (Optional):** Defines the upper bound of the time range for verifying rows. Default is `NULL`.
- **`-instance_id|-inst <instance_id>` (Optional):** Restricts verification to rows inserted on the specified instance.
- **`-chain_id|-ch <chain_id>` (Optional):** Restricts verification to rows on the specified chain (default is all chains).
- **`-rowcount <rowcount>` (Optional):** Outputs the number of rows verified.
- **`-skip_user_signature|-skipuser` (Optional):** Skips validation of user signatures if present. 
- **`-skip_delegate_signature|-skipdlg` (Optional):** Skips validation of delegate signatures if present.
- **`-skip_countersignature|-skipctr` (Optional):** Skips validation of countersignatures if present.
</details>
</br>

#### Example:
To verify all rows in a table:
```
	<copy>
	blockchain_table verify_rows -tab bank_ledger_bt;
	</copy>
```

![verify rows in blockchain table](./images/lab4-task6-1.png " ")
> **Expected Output:**  
> <pre>
> Command executed successfully.  
> Verified 10 rows from '"DEMOUSER".bank_ledger_bt' table.</pre>


#### Example with Timestamp Range:
To verify rows created between two timestamps:
```
	<copy>
	blockchain_table verify_rows -tab bank_ledger_bt -low '16-JAN-25 01.00.01 AM UTC' -high '17-JAN-25 11.21.30 AM UTC'
	</copy>
```
>NOTE: Timestamps need to be specified as per NLS settings.

![verify_rows with timestamp](./images/lab4-task6-2.png " ")
> **Expected Output:**  
> <pre>
> Command executed successfully.  
> Verified 0 rows from '"DEMOUSER".bank_ledger_bt' table. </pre>

#### Example with Signature Skipping:
To verify rows but skip validating user signatures:
```
	<copy>
	blockchain_table verify_rows -tab bank_ledger_bt -skip_user_signature -skip_delegate_signature -skip_countersignature
	</copy>
```
![verify rows with skipping signature flag](./images/lab4-task6-3.png " ")
> **Expected Output:**  
> <pre>
> Command executed successfully.  
> Verified 10 rows from '"DEMOUSER".bank_ledger_bt' table.</pre>

</details>

<details>
<summary><mark>Independent Verification of Blockchain Table Data (Additional Information, Not Needed for the Lab)</mark></summary>

Oracle Blockchain Tables allow for **independent verification** of their data, ensuring tamper-resistant integrity even outside the Oracle Database environment. Oracle provides sample **Java source code** and **configuration files** to facilitate this independent verification process. These samples also demonstrate how to publish Oracle cryptographic hashes to platforms like **Hyperledger Fabric**, enabling cross-platform compatibility.

#### Key Features of Independent Verification:
- **Verify Oracle Blockchain Table Data:** Validate the integrity of blockchain table rows outside the Oracle Database using cryptographic hash checks.
- **Publish to Hyperledger Fabric:** Use the provided examples to distribute Oracle crypto-hashes on blockchain platforms such as Hyperledger Fabric.
- **Extend Functionality:** Customize the sample programs to integrate Oracle cryptographic solutions with other blockchain ecosystems.

#### Resources:
The resources, including source code and configuration samples, are available on GitHub. Access the full documentation and examples at the following link:

[Oracle Blockchain Table Samples – Independent Verification](https://github.com/oracle-samples/blockchain-table-samples/blob/main/README.md)

#### Getting Started:
1. Clone or download the repository from GitHub.
2. Follow the instructions in the **README.md** file to configure and run the Java verification program.
3. Customize the code to fit your organization's specific requirements for independent verification or blockchain integration.
</details>
</br>

## Task 7: Signing Rows in Blockchain Tables

---

The **`blockchain_table sign_row`** command enables users to provide a digital signature for a previously inserted row in a Blockchain Table. This signature ensures the authenticity and integrity of the row data. The command corresponds to the **`DBMS_BLOCKCHAIN_TABLE.SIGN_ROW`** PL/SQL procedure.

#### Usage:
<pre>
blockchain_table sign_row {OPTIONS}
</pre>

<details open>
<summary>**Options:**</summary>
- **`-table_name|-tab <table_name>` (Required):** Specifies the name of the Blockchain Table containing the row to be signed.
- **`-instance_id|-inst <instance_id>` (Optional):** Restricts the operation to rows inserted on the specified database instance.
- **`-chain_id|-ch <chain_id>` (Optional):** Specifies the chain to which the row belongs. By default, there are 32 chains per database instance, numbered from 0 to 31.
- **`-sequence_id|-seq <sequence_id>` (Optional):** Specifies the position of the row within the chain.
- **`-row_hash <row_hash>` (Optional):** Specifies the expected value of the row's hash before signing. Default is `NULL`.
- **`-keycol1_name|-kc1name <key_column>` (Optional):** Specifies the name of the first key column for identifying the row.
- **`-keycol1_value|-kc1val <key_value>` (Optional):** Specifies the value of the first key column.
- **`-keycol2_name|-kc2name <key_column>` (Optional):** Specifies the name of the second key column (for composite keys).
- **`-keycol2_value|-kc2val <key_value>` (Optional):** Specifies the value of the second key column.
- **`-keycol3_name|-kc3name <key_column>` (Optional):** Specifies the name of the third key column (for composite keys).
- **`-keycol3_value|-kc3val <key_value>` (Optional):** Specifies the value of the third key column.
- **`-signature|-sig <signature>` (Optional):** Outputs the hexadecimal representation of the digital signature.
- **`-signature_file|-sigfile <signature_file>` (Optional):** Specifies the file name to store the binary representation of the digital signature.
- **`-cert_guid|-cg <cert_guid>` (Required):** Specifies the Global Unique Identifier (GUID) of the certificate used for signing.
- **`-algorithm|-algo <algorithm>` (Required):** Specifies the algorithm used for generating the digital signature. Acceptable values:
	- `RSA_SHA2_256`
	- `RSA_SHA2_384`
	- `RSA_SHA2_512`
- **`-wallet_path|-wallet <wallet_path>` (Optional):** Specifies the local wallet path containing the private key for signing.
- **`-wallet_password|-walletpw <wallet_password>` (Optional):** Provides the password for accessing the wallet interactively if not supplied directly.
- **`-wallet_private_key_alias|-walletpvtkeyalias <alias>` (Optional):** Identifies the private key in the wallet for signature generation. If not provided, the system retrieves the private key using the `cert_guid`.
- **`-wallet_private_key_password|-walletpvtkeypw <password>` (Optional):** Provides the password to access the private key stored in the wallet.
- **`-data_format|-df <data_format>` (Optional):** Specifies the version of the data layout for the hash in the row. Default is `1`.
- **`-type <type>` (Optional):** Specifies the type of signature. Acceptable values:
	- `USER`: Default value, used for user-generated signatures.
	- `DELEGATE`: Indicates the signature is delegated.
- **`-pdb_guid <pdb_guid>` (Optional):** Specifies the GUID of the Pluggable Database (PDB) where the Blockchain Table is located. Required for V2 tables in a multi-tenant environment.
</details>

> NOTE: The certificates and Wallet used below are the one's generated in Lab 3.

#### Before signing lets declare some variables and add certificates for ease of use.
```
<copy>
variable   inst_id        VARCHAR2;
variable   chain_id       VARCHAR2;
variable   seq_id         VARCHAR2;
variable   row_hash       VARCHAR2;
variable   guid           VARCHAR2;

certificate add -cert_file demouser_cert.crt -cert_guid ::guid

</copy>
```
![add certificate](./images/lab4-task7-1.png " ")
> **Expected Output:**  
> <pre>
> Command executed successfully.  
> CERTIFICATE_GUID : &lt;RANDOM_GUID&gt; </pre>


#### Example: Sign a Row Using Key Column Parameters and private key stored in a wallet 
To sign a specific row in the `bank_ledger_bt` table using key columns. The command accesses the wallet to retrieve the private key and generate a signature. If the wallet_password is not provided, you will be prompted to enter the password:
```
<copy>

bl sign_row -tab bank_ledger_bt  -kc1name "account_number" -kc1val "994" -cert_guid ":guid" -algo "RSA_SHA2_512" -type "USER" -wallet_path . -wallet_password Welcome_123# -wallet_private_key_password Welcome_123#

commit;
</copy>
```

![sign row using key columns](./images/lab4-task7-5.png " ")
> **Expected Output:**  
> <pre>
> Command executed successfully.  
> Successfully signed row identified by key columns account_number = '994' in table '"DEMOUSER".bank_ledger_bt'. </pre>


#### Example: Sign a Row Using Key Column Parameters and a private key stored in a file
To sign a specific row in the `bank_ledger_bt` table using key columns. The code internally uses OpenSSL installed on user's local system (here cloudshell) to generate signature:
```
<copy>

bl sign_row -tab bank_ledger_bt  -kc1name "account_number" -kc1val "993" -prvtkey demouser_privatekey.pem -cert_guid ":guid" -algo "RSA_SHA2_512" -type "USER"

commit;

</copy>
```
![sign row using key columns and private key](./images/lab4-task7-4.png " ")
> **Expected Output:**  
> <pre>
> Command executed successfully.  
> Successfully signed row identified by key columns account_number = '993' in table '"DEMOUSER".bank_ledger_bt'. </pre>


#### Example: Sign a Row Using Positional Parameters and a private key stored in a file
To sign a specific row in the `bank_ledger_bt` table using positional parameters i.e. instance id, chain id and sequence id. The code internally uses OpenSSL installed on user's local system (here cloudshell) to generate signature:
```
<copy>

begin
     select ORABCTAB_INST_ID$, ORABCTAB_CHAIN_ID$, ORABCTAB_SEQ_NUM$, ORABCTAB_HASH$  into :inst_id, :chain_id, :seq_id, :row_hash from bank_ledger_bt where account_number = '992';
end;
/

bl sign_row -tab bank_ledger_bt -inst ":inst_id" -ch ":chain_id" -seq ":seq_id"  -prvtkey demouser_privatekey.pem -cert_guid ":guid" -row_hash ":row_hash" -algo "RSA_SHA2_512" -type "USER"

commit;
</copy>
```

![sign row using positional parameters](./images/lab4-task7-3.png " ")
> **Expected Output:**  
> <pre>
> Command executed successfully.  
> Successfully signed row at instance id '<INST_ID>', chain id '<CHAIN_ID>' and sequence id '<SEQUENCE_ID>' in table '"DEMOUSER".bank_ledger_bt'. </pre>


#### Example: Sign a Row Using Positional Parameters and OpenSSL
To sign a specific row in the `bank_ledger_bt` table using positional parameters i.e. instance id, chain id and sequence id:
```
<copy>

begin
     select ORABCTAB_INST_ID$, ORABCTAB_CHAIN_ID$, ORABCTAB_SEQ_NUM$, ORABCTAB_HASH$  into :inst_id, :chain_id, :seq_id, :row_hash from bank_ledger_bt where account_number = '991';
end;
/

blockchain_table get_bytes_for_row_signature -tab bank_ledger_bt -inst ":inst_id" -ch ":chain_id" -seq ":seq_id" -row_data_file row1.dat -type "USER"

!openssl dgst -sha512 -sign demouser_privatekey.pem -out row1_sign.dat row1.dat

bl sign_row -tab bank_ledger_bt -inst ":inst_id" -ch ":chain_id" -seq ":seq_id" -row_hash ":row_hash" -signature_file row1_sign.dat -cert_guid ":guid" -algo "RSA_SHA2_512"

commit;
</copy>
```

![sign row using positional prameters and openssl](./images/lab4-task7-2.png " ")
> **Expected Output:**  
> <pre>
> Command executed successfully.  
> Successfully signed row at instance id '<INST_ID>', chain id '<CHAIN_ID>' and sequence id '<SEQUENCE_ID>' in table '"DEMOUSER".bank_ledger_bt'. </pre>


Using the `sign_row` command ensures the authenticity of Blockchain Table data by attaching cryptographic signatures to rows, identified either by chain/sequence or key columns. The inclusion of **`type`** and **`pdb_guid`** options adds flexibility for advanced use cases in multi-tenant environments and delegated signing.


<details open>
<summary>**Delegate Signing**</summary>

Delegate signing in Blockchain Tables allows a delegate to sign rows on behalf of the primary user, using a delegate certificate. This is particularly useful in scenarios where the primary user wants to enable other trusted entities to sign rows without sharing their private key. To perform delegate signing, the delegate certificate must be added to the database, and the **`type`** option must be set to **`DELEGATE`** in the **`sign_row`** command. This ensures that the signature is explicitly marked as a delegate's signature, preserving auditability and trust. Delegate signing provides flexibility while maintaining security, as the primary user's credentials remain secure.
</details>

<details open>
<summary>**Countersignature**</summary>

A countersignature in Blockchain Tables is an additional layer of security that involves the table owner signing the content of a previously signed row. This ensures the row's integrity and authenticity from both the user's and the owner's perspectives. The **`countersign_row`** command generates the countersignature by using the table owner's private key stored in the database wallet. This feature is particularly valuable in scenarios requiring end-to-end verification of critical data, as it enables independent validation of both the user's and the owner's signatures. Countersignatures enhance the overall trust and auditability of Blockchain Table rows, making them highly secure and reliable for sensitive applications.


#### Usage:
<pre>
blockchain_table countersign_row {OPTIONS}
</pre>

<details open>
<summary>Options:</summary>
- **`-table_name|-tab <table_name>` (Required):** Specifies the name of the Blockchain Table containing the row to be countersigned.
- **`-instance_id|-inst <instance_id>` (Optional):** Restricts the operation to rows inserted on the specified database instance.
- **`-chain_id|-ch <chain_id>` (Optional):** Specifies the chain to which the row belongs.
- **`-sequence_id|-seq <sequence_id>` (Optional):** Specifies the position of the row within the chain.
- **`-keycol1_name|-kc1name <key_column>` (Optional):** Specifies the name of the first key column for identifying the row.
- **`-keycol1_value|-kc1val <key_value>` (Optional):** Specifies the value of the first key column.
- **`-keycol2_name|-kc2name <key_column>` (Optional):** Specifies the name of the second key column (for composite keys).
- **`-keycol2_value|-kc2val <key_value>` (Optional):** Specifies the value of the second key column.
- **`-keycol3_name|-kc3name <key_column>` (Optional):** Specifies the name of the third key column (for composite keys).
- **`-keycol3_value|-kc3val <key_value>` (Optional):** Specifies the value of the third key column.
- **`-countersignature|-csig <countersignature>` (Optional):** Outputs the hexadecimal representation of the countersignature.
- **`-bytes_file <bytes_file>` (Optional):** Specifies the file name to store the countersignature bytes.
- **`-countersign_cert_guid|-cscg <cert_guid>` (Optional):** Specifies the certificate GUID used for verifying the countersignature.
- **`-countersignature_algorithm|-countersignalgo <algorithm>` (Optional):** Specifies the algorithm used for generating the countersignature. Acceptable values:
	- `RSA_SHA2_256`
	- `RSA_SHA2_384`
	- `RSA_SHA2_512`
- **`-content_version <content_version>` (Optional):** Specifies the version of the data layout for the countersignature. Default is `V2_DIGEST`.
</details>
</details>
</br>


## Task 8: Distribution and Verification of Blockchain digest

---

The commands `get_digest` and `get_signed_digest` provide robust mechanisms for verifying data integrity and authenticity in Blockchain Tables. The signed digest ensures an additional layer of trust by using cryptographic signing.

<details open>
<summary><mark>Generating Unsigned Digest for Blockchain Tables</mark></summary>

The **`blockchain_table get_digest`** command generates a cryptographic hash (digest) for specified rows or the entire Blockchain Table. This digest enables validation of data integrity and authenticity over a specified range of rows.


#### Usage:
<pre>
blockchain_table get_digest {OPTIONS}
</pre>

<details open>
<summary>Options:</summary>
- **`-table_name|-tab <table_name>` (Required):** Specifies the name of the Blockchain Table.
- **`-selector <selector>` (Optional):** A WHERE clause without the `WHERE` keyword to filter rows for the digest.
- **`-selector_file <selector_file>` (Optional):** Specifies a file containing the row selection criteria.
- **`-bytes_file <bytes_file>` (Optional):** Specifies the file name to store the generated digest bytes.
- **`-digest <digest>` (Optional):** Outputs the hexadecimal representation of the digest.
- **`-digest_file <digest_file>` (Optional):** Specifies the file name to store the binary digest.
- **`-row_data_file <row_data_file>` (Optional):** Specifies the file to save the generated row data bytes.
- **`-row_indexes_file <row_indexes_file>` (Optional):** Specifies the file to save the row index details in JSON format.
- **`-algorithm|-algo <algorithm>` (Optional):** Specifies the hash algorithm. Acceptable values:
	- `SHA2_256`
	- `SHA2_384`
	- `SHA2_512`
	- Default is `SHA2_256`
</details>


#### Example: Generate Digest for Entire Table
```
<copy>
bl get_digest -tab bank_ledger_bt -bytes_file demouser_bytes1.txt -digest_file demouser_digest1.txt -algorithm "SHA2_384"
</copy>
```
![Generate digest for entire table](./images/lab4-task8-1.png " ")
> **Expected Output:**  
> <pre>
> Command executed successfully. </pre>


#### Example: Generate Digest for Specific Rows
```
<copy>
bl get_digest -tab bank_ledger_bt -selector "account_number=999" -bytes_file demouser_bytes2.txt -digest_file demouser_digest2.txt -row_data_file demouser_rowdatafile2.txt -row_indexes_file demouser_rowindex2.txt -algorithm "SHA2_384"
</copy>
```
![generate digest for specific rows](./images/lab4-task8-2.png " ")
> **Expected Output:**  
> <pre>
> Command executed successfully. </pre>

</details>
</br>

<details>
<summary><mark>Generating a Signed Digest for Blockchain Tables</mark></summary>

The **`blockchain_table get_signed_digest`** command generates and signs a cryptographic hash (digest) for specified rows or the entire Blockchain Table. The signed digest is created using the table owner's private key stored in the database wallet, ensuring both integrity and authenticity.


#### Usage:
<pre>
blockchain_table get_signed_digest {OPTIONS}
</pre>

<details open>
<summary>**Options:**</summary>
- **`-table_name|-tab <table_name>` (Required):** Specifies the name of the Blockchain Table.
- **`-selector <selector>` (Optional):** A WHERE clause without the `WHERE` keyword to filter rows for the signed digest.
- **`-selector_file <selector_file>` (Optional):** Specifies a file containing the row selection criteria.
- **`-bytes_file <bytes_file>` (Optional):** Specifies the file name to store the digest bytes before signing.
- **`-digest <digest>` (Optional):** Outputs the hexadecimal representation of the signed digest.
- **`-digest_file <digest_file>` (Optional):** Specifies the file name to store the signed binary digest.
- **`-row_data_file <row_data_file>` (Optional):** Specifies the file to save the generated row data bytes.
- **`-row_indexes_file <row_indexes_file>` (Optional):** Specifies the file to save the row index details in JSON format.
- **`-cert_guid|-cg <cert_guid>` (Required):** Specifies the certificate GUID used for signing.
- **`-algorithm|-algo <algorithm>` (Optional):** Specifies the signing algorithm. Acceptable values:
	- `RSA_SHA2_256`
	- `RSA_SHA2_384`
	- `RSA_SHA2_512`
	- Default is `RSA_SHA2_256`
</details>

#### Example: Generate Signed Digest for Entire Table
```
<copy>
variable cert_guid VARCHAR2;

bl get_signed_digest -tab bank_ledger_bt -bytes_file demouser_signed_bytes2.txt -digest_file demouser_signed_digest2.txt -row_data_file demouser_signed_rowdatafile2.txt -cg ":cert_guid" -algorithm "RSA_SHA2_384"

print cert_guid
</copy>
```

#### Example: Generate Signed Digest for Specific Rows
```
<copy>
variable cert_guid VARCHAR2;

bl get_signed_digest -tab bank_ledger_bt -selector "account_number=999" -bytes_file demouser_signed_bytes2.txt -digest_file demouser_signed_digest2.txt -row_data_file demouser_signed_rowdatafile2.txt -row_indexes_file demouser_signed_rowindexfile2.txt -cg ":cert_guid" -algorithm "RSA_SHA2_384"

print cert_guid
</copy>
```

</details>
</br>

<details open>
<summary><mark>Verifying an Entire Blockchain Table</mark></summary>

The **`blockchain_table verify_table`** command checks the integrity of all rows in a Blockchain Table between a specified range of digests. This includes verifying signatures, user chains, and system chains for rows created within the range defined by the provided digest files. This command is equivalent to the **`DBMS_BLOCKCHAIN_TABLE.VERIFY_TABLE_BLOCKCHAIN`** PL/SQL procedure.


#### Usage:
<pre>
blockchain_table verify_table {OPTIONS}
</pre>

<details>
<summary>**Options:**</summary>
- **`-begin_bytes_file <begin_bytes_file>` (Required):** Specifies the file containing the starting digest. This digest must be generated using commands like `get_signed_digest` or `get_digest`.
- **`-end_bytes_file <end_bytes_file>` (Required):** Specifies the file containing the ending digest. This digest must also be generated using `get_signed_digest` or `get_digest`.
- **`-rowcount <rowcount>` (Optional):** Outputs the number of successfully verified rows.
- **`-skip_user_signature|-skipuser` (Optional):** Skips validation of user signatures if present. Default is `FALSE`.
- **`-skip_delegate_signature|-skipdlg` (Optional):** Skips validation of delegate signatures if present. Default is `FALSE`.
- **`-skip_countersignature|-skipctr` (Optional):** Skips validation of countersignatures if present. Default is `FALSE`.
</details>
</br>

#### Example: Verify the Entire Table
Lets first create another digest files using `get_digest` command:
```
<copy>
bl get_digest -tab bank_ledger_bt -bytes_file demouser_bytes3.txt -digest_file demouser_digest3.txt -algorithm "SHA2_384"
</copy>
```
> **Expected Output:**  
> <pre>
> Command executed successfully. </pre>

To verify the `bank_ledger_bt` table using starting and ending digests:
```
<copy>
bl verify_table -end_bytes_file demouser_bytes3.txt -begin_bytes_file demouser_bytes1.txt
</copy>
```
![verify table](./images/lab4-task8-5.png " ")
> **Expected Output:**  
> <pre>
> Command executed successfully.  
> Verified 10 rows. </pre>

</details>

You may now [proceed to the next lab](#next).

## Other Blockchain Table Commands

<details>
<summary><mark>Adding Interval Partitioning to Blockchain Tables</mark></summary>

The **`blockchain_table add_interval_partitioning`** command adds interval partitioning to an existing, non-partitioned Blockchain Table (V1 or V2). Interval partitioning automatically creates partitions based on a specified time interval, enhancing the manageability and performance of large Blockchain Tables.


#### Usage:
<pre>
blockchain_table add_interval_partitioning {OPTIONS}
</pre>

<details>
<summary>**Options:**</summary>
- **`-table_name|-tab <table_name>` (Required):** Specifies the name of the Blockchain Table to which interval partitioning will be added. Use double quotes for case-sensitive table names.
- **`-interval_number|-intnum <interval_number>` (Required):** Sets the interval value (e.g., 1, 2, 3) for partition creation.
- **`-interval_frequency|-intfreq <interval_frequency>` (Required):** Specifies the frequency for the interval. Supported values:
	- `YEAR`
	- `MONTH`
	- `DAY`
	- `HOUR`
	- `MINUTE`
- **`-first_high_timestamp|-firsthigh <first_high_timestamp>` (Required):** Specifies the upper boundary of the first partition. This timestamp determines when the initial interval ends.
</details>
</details>
</br>

<details>
<summary><mark>Deleting Expired Rows in Blockchain Tables</mark></summary>

The **`blockchain_table delete_expired_rows`** command deletes expired rows from a Blockchain Table. Expired rows are those that have surpassed the retention period defined during table creation.

#### Usage:
<pre>
blockchain_table delete_expired_rows {OPTIONS}
</pre>

<details>
<summary>**Options:**</summary>
- **`-table_name|-tab <table_name>` (Required):** Specifies the name of the Blockchain Table from which expired rows will be deleted. Use double quotes for case-sensitive table names.
- **`-before_timestamp|-before <before_timestamp>` (Optional):** Deletes rows with timestamps less than the specified value, formatted as per `NLS_SESSION_PARAMETERS`. Behavior:
	- If NULL: Deletes all expired rows in the table.
	- If older than the calculated timestamp: Deletes expired rows with timestamps less than the specified value.
	- If younger than the calculated timestamp: Deletes rows based on the retention policy.
	- Default: `NULL`.
- **`-rowcount <rowcount>` (Optional):** Specifies the number of rows deleted.
</details>
</details>
</br>


<details>
<summary><mark>Retrieving Bytes for Row Hash in Blockchain Tables</mark></summary>

The **`blockchain_table get_bytes_for_row_hash`** command retrieves the bytes of a specific row in a Blockchain Table. The output includes metadata-value pairs and column-data-value pairs in column position order, followed by the hash for the previous row in the chain. This is essential for inspecting row-specific cryptographic details.

#### Usage:
<pre>
blockchain_table get_bytes_for_row_hash {OPTIONS}
</pre>

<details>
<summary>**Options:**</summary>
- **`-table_name|-tab <table_name>` (Required):** Specifies the name of the Blockchain Table. Use double quotes for case-sensitive table names.
- **`-instance_id|-inst <instance_id>` (Optional):** Restricts the operation to rows inserted on the specified instance.
- **`-chain_id|-ch <chain_id>` (Optional):** Specifies the chain to which the row belongs. By default, Blockchain Tables have 32 chains per database instance numbered from 0 to 31.
- **`-sequence_id|-seq <sequence_id>` (Optional):** Specifies the position of the row within the chain.
- **`-data_format|-df <data_format>` (Optional, Default: `1`):** Specifies the version of the data layout for the hash. Currently, only `1` is supported.
- **`-row_data_file <row_data_file>` (Optional):** Specifies the file to save the generated row data bytes.
- **`-user_chain|-uchain <user_chain>` (Optional):** For V2 Blockchain Tables, specifies the user chain when the bytes for the cryptographic hash on the user chain are desired. Specify `NULL` for system chains.
- **`-keycol1_name|-kc1name <keycol1_name>` (Optional):** Specifies the name of the first key column.
- **`-keycol1_value|-kc1val <keycol1_value>` (Optional):** Specifies the value of the first key column.
- **`-keycol2_name|-kc2name <keycol2_name>` (Optional):** Specifies the name of the second key column (for composite keys).
- **`-keycol2_value|-kc2val <keycol2_value>` (Optional):** Specifies the value of the second key column.
- **`-keycol3_name|-kc3name <keycol3_name>` (Optional):** Specifies the name of the third key column (for composite keys).
- **`-keycol3_value|-kc3val <keycol3_value>` (Optional):** Specifies the value of the third key column.
- **`-pdb_guid <pdb_guid>` (Optional):** For V2 Blockchain Tables, specifies the GUID of the Pluggable Database (PDB) that inserted the row. Must be `NULL` for V1 Blockchain Tables.
</details>

</details>
</br>

<details>
<summary><mark>Retrieving Bytes for Row Signature in Blockchain Tables</mark></summary>

The **`blockchain_table get_bytes_for_row_signature`** command retrieves the bytes used to compute a user signature, a delegate signature, or a countersignature. The bytes returned represent the cryptographic input for the specified type of signature, enabling external validation or troubleshooting.

#### Usage:
<pre>
blockchain_table get_bytes_for_row_signature {OPTIONS}
</pre>

<details>
<summary>**Options:**</summary>
- **`-table_name|-tab <table_name>` (Required):** Specifies the name of the Blockchain Table. Use double quotes for case-sensitive table names.
- **`-instance_id|-inst <instance_id>` (Optional):** Restricts the operation to rows inserted on the specified database instance.
- **`-chain_id|-ch <chain_id>` (Optional):** Specifies the chain to which the row belongs. By default, Blockchain Tables have 32 chains per database instance numbered from 0 to 31.
- **`-sequence_id|-seq <sequence_id>` (Optional):** Specifies the position of the row within the chain.
- **`-data_format|-df <data_format>` (Optional, Default: `1`):** Specifies the version of the data layout for the hash in the row. Currently, only `1` is supported.
- **`-row_data_file <row_data_file>` (Optional):** Specifies the file to save the generated row data bytes.
- **`-keycol1_name|-kc1name <keycol1_name>` (Optional):** Specifies the name of the first key column.
- **`-keycol1_value|-kc1val <keycol1_value>` (Optional):** Specifies the value of the first key column.
- **`-keycol2_name|-kc2name <keycol2_name>` (Optional):** Specifies the name of the second key column (for composite keys).
- **`-keycol2_value|-kc2val <keycol2_value>` (Optional):** Specifies the value of the second key column.
- **`-keycol3_name|-kc3name <keycol3_name>` (Optional):** Specifies the name of the third key column (for composite keys).
- **`-keycol3_value|-kc3val <keycol3_value>` (Optional):** Specifies the value of the third key column.
- **`-pdb_guid <pdb_guid>` (Optional):** For V2 Blockchain Tables, specifies the GUID of the Pluggable Database (PDB) that inserted the row. Must be `NULL` for V1 Blockchain Tables.
- **`-type <type>` (Optional, Default: `USER`):** Specifies the type of signature bytes to retrieve. Acceptable values:
	- `USER`
	- `DELEGATE`
	- `COUNTERSIGNATURE`
</details>
</details>
</br>


<details>
<summary><mark>Verifying User Chains in Blockchain Tables</mark></summary>

The **`blockchain_table verify_user_chains`** command verifies rows associated with one or more user-defined chains in a Blockchain Table. This feature is applicable when the user chains feature is enabled during the creation of a Blockchain Table. The command ensures the integrity and authenticity of user chain data by validating hash chains and optional signatures.


#### Usage:
<pre>
blockchain_table verify_user_chains {OPTIONS}
</pre>

<details>
<summary>**Options:**</summary>
- **`-table_name|-tab <table_name>` (Required):** Specifies the name of the Blockchain Table. The name can include a schema prefix for clarity. Use double quotes for case-sensitive names.
- **`-user_chain|-uchain <user_chain>` (Required):** Specifies the name of the user-defined chain to verify.
- **`-rowcount <rowcount>` (Optional):** Outputs the number of successfully verified rows.
- **`-keycol1_value|-kc1val <key_value>` (Optional):** Specifies the value of the first key column for identifying the user chain.
- **`-keycol2_value|-kc2val <key_value>` (Optional):** Specifies the value of the second key column (for composite keys).
- **`-keycol3_value|-kc3val <key_value>` (Optional):** Specifies the value of the third key column (for composite keys).
- **`-low_timestamp|-low <low_timestamp>` (Optional):** Restricts the operation to rows created after the specified timestamp. Default is `NULL`.
- **`-high_timestamp|-high <high_timestamp>` (Optional):** Restricts the operation to rows created before the specified timestamp. Default is `NULL`.
- **`-skip_user_signature|-skipuser` (Optional):** Skips validation of user signatures if present. Default is `FALSE`.
- **`-skip_delegate_signature|-skipdlg` (Optional):** Skips validation of delegate signatures if present. Default is `FALSE`.
- **`-skip_countersignature|-skipctr` (Optional):** Skips validation of countersignatures if present. Default is `FALSE`.
- **`-pdb_guid <pdb_guid>` (Optional):** For V2 Blockchain Tables, specifies the GUID of the Pluggable Database (PDB) that inserted the row. Must be `NULL` for V1 tables.
</details>
</details>
</br>

You may now [proceed to the next lab](#next).

## Learn more

* For more information on managing certificates, including adding, dropping, and other related procedures, please see the [DBMS\_BLOCKCHAIN\_TABLE](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_blockchain_table.html) documentation and SQLcl help section accessed using **`help blockchain_table`** in the SQLcl console.

## Acknowledgements

* **Contributors** - Amit Ketkar, Pavas Navaney, Vinay Pandhariwal 
* **Created By/Date** - Vinay Pandhariwal, March 2025
* **Last Updated By/Date** - Vinay Pandhariwal, March 2025
