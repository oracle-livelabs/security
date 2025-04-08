# Advanced Digest Generation and Verification in Blockchain Tables

## **Introduction**

While Blockchain Tables provide cryptographic chaining to ensure tamper-resistant data, real-world enterprise systems often require additional ways to validate and share the authenticity of table contents over time. This is where Blockchain Table digests come into play.

A digest is a compact, cryptographically signed or unsigned summary of selected rows or of the entire Blockchain Table. Digests can be securely stored, exported, or distributed to third parties, enabling periodic integrity checks or legal proof of unchanged historical data. Oracle provides built-in support for both full-table digests and filtered-row digests, along with flexible options for unsigned and signed digest generation. These allow organizations to implement fine-grained, auditable verification pipelines.

You can generate:
- Unsigned digests: Lightweight hashes for internal or local verification.
- Signed digests: Authenticated by the table owner's private key, suitable for regulatory, legal, or external sharing scenarios.

This lab explores how to generate both types of digests, validate them, and understand their applications. You’ll also learn important guidelines, such as matching signed/unsigned digests during verification, and maintaining consistency when working with filtered-row digests.

> Oracle 23ai introduces the ability to generate filtered digests using row selectors. These allow you to verify digest integrity over a subset of rows rather than the entire table — ideal for cases like regional audits, department-level records, or sensitive data slices.
> 
> We will continue working with the **bank\_ledger\_bt** table created in Lab 3, building upon it to explore advanced signing and verification features.


In this lab, we will use SQLcl to perform various operations on Blockchain Tables, leveraging its intuitive and user-friendly interface. The dedicated command for managing Blockchain Tables is `blockchain_table | bl` . SQLcl offers powerful features such as Completion Insight (TAB) for command suggestions, Command History to revisit previous commands, and an In-Line Editor for easy modifications, ensuring a smooth and efficient workflow. For additional guidance, you can access the help section directly in the SQLcl console by typing `help blockchain_table` or `help bl` . This provides a comprehensive overview of all commands and functionalities, making it easier to explore and manage Blockchain Tables throughout the lab.

* Estimated Time: 15 minutes

Watch the video below for a quick walk through of the lab.

[Advanced Digest Generation and Verification in Blockchain Tables](videohub:1_vc1xrzr9:medium)

### Objectives

In this lab, you will:

- **Generate a Full-Table Digest** <br />
  Learn how to compute a cryptographic digest across all rows in a Blockchain Table using SQLcl commands.

- **Generate a Signed Digest** <br />
  Create a digitally signed digest using the table owner's private key for secure distribution and validation.

- **Generate Digests for Filtered Rows** <br />
  Use -selector and -selector_file options introduced in Oracle 23ai to target specific row subsets.

- **Verify Blockchain Table State Using Digests** <br />
  Use the verify_table command to confirm data integrity against previously stored digest files.

- **Understand Digest Matching Rules** <br />
  Learn key verification rules:
  - Only signed digests can verify signed digests, and unsigned for unsigned.
  - A filtered digest must match its filtering criteria at verification time.
  - Digest types (full-table vs. filtered) cannot be interchanged during verification.


### Prerequisites

* A Free-Tier or LiveLabs Oracle Cloud account.
* Have successfully completed the previous labs.

## Task 1: Distribution of digest for the entire Blockchain Table

---

The commands `get_digest` and `get_signed_digest` provide robust mechanisms for verifying data integrity and authenticity in Blockchain Tables. The signed digest ensures an additional layer of trust by using cryptographic signing.

<details open>
<summary><mark>Generating Unsigned Digest for the entire Blockchain Table</mark></summary>

The **`blockchain_table get_digest`** command generates a cryptographic hash (digest) for the entire Blockchain Table. This digest enables validation of data integrity and authenticity over a specified range of rows.

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
![Generate digest for entire table](./images/lab5-task1-1.png " ")
> **Expected Output:**  
> <pre>
> Command executed successfully. </pre>

</details>
</br>

<details>
<summary><mark>Generating a Signed Digest for the entire Blockchain Table</mark></summary>

The **`blockchain_table get_signed_digest`** command generates and signs a cryptographic hash (digest) for the entire Blockchain Table. The signed digest is created using the table owner's private key stored in the database wallet, ensuring both integrity and authenticity.

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

</details>
</br>


## Task 2: Distribution of Digest for Filtered Rows in the Blockchain Table

---

Continuing from the previous task where we generated digests for the **entire table**, Oracle Database 23ai introduces powerful options to generate **filtered row digests**. These are useful when you want to validate specific subsets of rows rather than the whole table.

From version **23ai** onward, the following options are available for the `get_digest` and `get_signed_digest` SQLcl commands:

- **`-selector`** – Supply a text-based filter condition (excluding the `WHERE` keyword) to select a subset of rows.
- **`-selector_file`** – Provide a file that contains the filter condition used for row selection.

These filters help you generate cryptographic digests for only a specific portion of the Blockchain Table, enabling **targeted verification** based on business logic or operational needs.


<details open>
<summary><mark>Generating Unsigned Digest for Filtered Rows in the Blockchain Table</mark></summary>

The **`blockchain_table get_digest`** command generates a cryptographic hash (digest) for a **subset of rows** in a Blockchain Table using filtering criteria. This feature allows users to validate integrity for **specific rows** instead of the entire table, introduced in Oracle Database 23ai.

You can apply filters using:
- **`-selector`**: Directly specify the filter condition as a WHERE clause (without the `WHERE` keyword).
- **`-selector_file`**: Provide a file containing the row selection condition.

> **Note:** A filtered row digest can only be used with the **same selector** for verification. Mismatched filter conditions will lead to verification failure.

#### Usage:
<pre>
blockchain_table get_digest {OPTIONS}
</pre>

<details open>
<summary>Options:</summary>
- **`-table_name|-tab <table_name>` (Required):** Name of the Blockchain Table.
- **`-selector <selector>` (Optional):** Filtering clause for row selection.
- **`-selector_file <selector_file>` (Optional):** File containing the selector condition.
- **`-bytes_file <bytes_file>` (Optional):** File to store raw digest bytes.
- **`-digest <digest>` (Optional):** Hexadecimal digest output.
- **`-digest_file <digest_file>` (Optional):** File to store binary digest.
- **`-row_data_file <row_data_file>` (Optional):** File to store row data used for digest.
- **`-row_indexes_file <row_indexes_file>` (Optional):** File to store row index details in JSON.
- **`-algorithm|-algo <algorithm>` (Optional):** Hash algorithm to use. Options:
    - `SHA2_256` (default)
    - `SHA2_384`
    - `SHA2_512`
</details>


#### Example: Generate Digest for Specific Rows
```
<copy>
bl get_digest -tab bank_ledger_bt -selector "account_number=999" -bytes_file demouser_bytes2.txt -digest_file demouser_digest2.txt -row_data_file demouser_rowdatafile2.txt -row_indexes_file demouser_rowindex2.txt -algorithm "SHA2_384"
</copy>
```
![generate digest for specific rows](./images/lab5-task2-1.png " ")
> **Expected Output:**  
> <pre>
> Command executed successfully. </pre>

</details>
</br>

<details>
<summary><mark>Generating a Signed Digest for Filtered Rows in the Blockchain Table</mark></summary>

The **`blockchain_table get_signed_digest`** command generates and signs a cryptographic hash (digest) for specified rows of the Blockchain Table. The signed digest is created using the table owner's private key stored in the database wallet, ensuring both integrity and authenticity.

You can apply filters using:
- **`-selector`**: Directly specify the filter condition as a WHERE clause (without the `WHERE` keyword).
- **`-selector_file`**: Provide a file containing the row selection condition.

> Note: Signed digests must be verified using other signed digests, and only when the same filtering criteria is applied. Mixing signed and unsigned digests, or inconsistent filters, will lead to verification failure.

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

## Task 3: Verification of Blockchain Table digest

---

The **`blockchain_table verify_table`** command checks the integrity of all rows in a Blockchain Table between a specified range of digests. This includes verifying signatures, user chains, and system chains for rows created within the range defined by the provided digest files. This command is equivalent to the **`DBMS_BLOCKCHAIN_TABLE.VERIFY_TABLE_BLOCKCHAIN`** PL/SQL procedure.

> **Important Notes:**
> - You must use the **same type of digest** for both the `start_digest_file` and `end_digest_file`:
>     - Full table digests must be verified against **other full table digests**.
>     - Filtered row digests must be verified against **other filtered row digests**.
>     - Interchanging digest types (e.g., full with filtered) will result in **verification failure**.
>
> - When using **filtered row digests**, ensure that **both digest files were generated using the same row filter**. Using different filters will lead to **verification failure**.
>
> - Signed digests can only be verified against **other signed digests**, and **unsigned digests** can only be verified against other **unsigned digests**. Mixing signed and unsigned digests during verification is not supported and will result in failure.

#### Usage:
<pre>
blockchain_table verify_table {OPTIONS}
</pre>

<details open>
<summary>**Options:**</summary>
- **`-begin_bytes_file <begin_bytes_file>` (Required):** Specifies the file containing the starting digest. This digest must be generated using commands like `get_signed_digest` or `get_digest`.
- **`-end_bytes_file <end_bytes_file>` (Required):** Specifies the file containing the ending digest. This digest must also be generated using `get_signed_digest` or `get_digest`.
- **`-rowcount <rowcount>` (Optional):** Outputs the number of successfully verified rows.
- **`-skip_user_signature|-skipuser` (Optional):** Skips validation of user signatures if present. Default is `FALSE`.
- **`-skip_delegate_signature|-skipdlg` (Optional):** Skips validation of delegate signatures if present. Default is `FALSE`.
- **`-skip_countersignature|-skipctr` (Optional):** Skips validation of countersignatures if present. Default is `FALSE`.
</details>
</br>

#### Example: Verify unsigned digest for the entire Blockchain Table
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
![verify table](./images/lab5-task3-1.png " ")
> **Expected Output:**  
> <pre>
> Command executed successfully.  
> Verified 10 rows. </pre>

You may now [proceed to the next lab](#next).

## Learn more

* For more information on managing certificates, including adding, dropping, and other related procedures, please see the [DBMS\_BLOCKCHAIN\_TABLE](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_blockchain_table.html) documentation and SQLcl help section accessed using **`help blockchain_table`** in the SQLcl console.

## Acknowledgements

* **Contributors** - Amit Ketkar, Pavas Navaney, Vinay Pandhariwal 
* **Created By/Date** - Vinay Pandhariwal, April 2025
* **Last Updated By/Date** - Vinay Pandhariwal, April 2025
