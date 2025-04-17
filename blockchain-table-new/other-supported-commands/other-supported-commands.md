# Other Supported Commands

## **Introduction**

In the previous labs, we've explored various commands related to blockchain tables, immutable tables, and certificates. Beyond these, Oracle SQLcl offers additional commands that address specific use cases, enhancing our ability to manage and secure data effectively. In this lab, we'll delve into some of these supplementary commands to broaden our understanding and proficiency.

* Estimated Time: 10 minutes

### Objectives

- To familiarize ourselves with advanced SQLcl commands pertaining to blockchain tables, immutable tables, and certificates, enabling us to handle specialized scenarios and enhance data integrity and security.

### Prerequisites

* A Free-Tier or LiveLabs Oracle Cloud account.
* Have successfully completed the previous labs.


## Task 1: Other Immutable Table Commands
<details>
<summary><mark>Adding Interval Partitioning to Immutable Tables</mark></summary>

The **`immutable_table add_interval_partitioning`** command adds interval partitioning to an existing, non-partitioned Immutable Table. This feature automatically creates partitions for new data at regular intervals based on the specified settings, streamlining data management. It is supported for **V1** and **V2 Immutable Tables** starting from database version **23ai**.

#### Usage:
<pre>
immutable_table add_interval_partitioning {OPTIONS}
</pre>

<details>
<summary>**Options:**</summary>
- **`-table_name|-tab <table_name>` (Required):** Specifies the name of the Immutable Table. The table name can be preceded by its schema name. For case-sensitive schema or table names, enclose the full name in double quotes, and individual parts in double, double quotes.
- **`-interval_number|-intnum <interval_number>` (Required):** Defines the interval for partition creation. For example, setting `1` creates a partition every 1 unit of the specified frequency.
- **`-interval_frequency|-intfreq <interval_frequency>` (Required):** Specifies the time unit for the interval. Acceptable values are:
    - `YEAR`
    - `MONTH`
    - `DAY`
    - `HOUR`
    - `MINUTE`
- **`-first_high_timestamp|-firsthigh <first_high_timestamp>` (Required):** A timestamp specifying the upper boundary of the first partition. This timestamp determines the starting point for partition creation.
</details>
</br>

#### Key Notes:
1. This command is equivalent to the **`DBMS_IMMUTABLE_TABLE.ADD_INTERVAL_PARTITIONING`** PL/SQL procedure for programmatic operations.
2. It is only applicable to non-partitioned Immutable Tables.
3. Adding interval partitioning automates partition management, reducing manual overhead for handling large datasets.

By using the **`add_interval_partitioning`** command, you can seamlessly manage time-based data in Immutable Tables, ensuring efficient and scalable performance.
</details>
</br>


## Task 2: Other Certificate commands

<details>
<summary><mark>Adding a Copy of a Certificate to the Database</mark></summary>

The **`certificate add_copy`** command is used to copy an X.509 certificate from one pluggable database to another while retaining its original Global Unique Identifier (GUID). This ensures consistency in signature verification for Blockchain Tables across replicated or migrated environments.

#### Usage:
<pre>
certificate add_copy {OPTIONS}
</pre>

<details>
<summary>**Options:**</summary>
- **`-cert_file|-cf <cert_file>` (Required):** Specifies the X.509 certificate file to be copied into the database. This file is used for signature verification.
- **`-cert_guid|-cg <cert_guid>` (Required):** Specifies the GUID of the certificate being copied. The original GUID is preserved for consistency across databases.
- **`-username|-uname <username>` (Optional):** Specifies the database user under whose schema the certificate will be added. If omitted, the certificate is added to the current user's schema.
</details>
</br>

#### Key Notes:
1. This command is equivalent to the **`DBMS_USER_CERTS.ADD_COPY`** PL/SQL procedure.
2. The certificate GUID is preserved to maintain compatibility for verifying signatures in replicated Blockchain Tables.

By using the **`add_copy`** command, you can ensure seamless integration of certificates across pluggable databases, enabling consistent and secure signature verification in distributed environments.
</details>
</br>


## Task 3: Other Blockchain Table Commands

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
- **`-rowcount <rowcount>` (Optional) (Out Parameter):** Specifies the number of rows deleted.
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
- **`-row_data_file <row_data_file>` (Optional) (Out Parameter):** Specifies the file to save the generated row data bytes.
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
- **`-row_data_file <row_data_file>` (Optional) (Out Parameter):** Specifies the file to save the generated row data bytes.
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
- **`-rowcount <rowcount>` (Optional) (Out Parameter):** Outputs the number of successfully verified rows.
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

## Learn more

* For more information on Immutable Table and other Immutable Table commands, please see **[DBMS\_IMMUTABLE\_TABLE](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_immutable_table.html)** documentation and SQLcl help section accessed using **`help immutable_table`** in the SQLcl console.

* For more information on using certificates with blockchain tables, please see the **[DBMS\_USER\_CERTS](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_user_certs.html)** documentation and SQLcl help section accessed using **`help certificate`** in the SQLcl console.

* For more information on Blockchain Table and other Blockchain Table commands, please see the **[DBMS\_BLOCKCHAIN\_TABLE](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_blockchain_table.html)** documentation and SQLcl help section accessed using **`help blockchain_table`** in the SQLcl console.

* For more information about PKI Certificate SQLcl commands, please see **[SQLcl Certificates](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/25.1/sqcug/certificate.html)**

* For more information about Immutable table SQLcl commands, please see **[SQLcl Immutable Table](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/25.1/sqcug/immutable_table.html)**

* For more information about Blockchain table SQLcl commands, please see **[SQLcl Blockchain Table](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/25.1/sqcug/blockchain_table.html)**

## Acknowledgements

* **Contributors** - Amit Ketkar, Pavas Navaney, Vinay Pandhariwal 
* **Created By/Date** - Vinay Pandhariwal, April 2025
* **Last Updated By/Date** - Vinay Pandhariwal, April 2025