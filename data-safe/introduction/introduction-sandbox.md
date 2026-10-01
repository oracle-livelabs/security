# Introduction

Protecting a database requires more than applying individual security controls. Security teams need to understand whether databases are securely configured, who has access to them, where sensitive data resides, how that data is protected, what activity is occurring, and whether applications are behaving as expected.

In this workshop, you take on the role of a database security administrator responsible for protecting a database and the sensitive information it contains.

Rather than exploring Oracle Data Safe as a collection of individual features, you will follow a connected security scenario. You will begin by assessing the security posture of your database and its users. You will then identify and protect sensitive data, monitor security-relevant database activity, and control the SQL statements that an application user is allowed to execute.

Along the way, you will answer questions such as:
- Is my database securely configured, and has its security posture changed?
- Which database users present the greatest potential risk, and have their privileges changed?
- Where is sensitive data stored, and what information could be exposed if an account were compromised?
- How can I provide useful data for non-production purposes without unnecessarily exposing sensitive information?
- What security-relevant activity is occurring in the database?
- Can I prevent an application account from executing SQL outside its expected workload?

By working through these questions as part of a single scenario, you will experience a practical database security workflow:

Assess → Discover → Protect → Monitor → Control  

Estimated Workshop Time: 2 hours

## About Oracle Data Safe

Oracle Data Safe is a unified database security service that helps you understand and reduce risk to data in Oracle databases.

Data Safe provides capabilities to assess database configurations and users, discover and protect sensitive data, monitor database activity, and control SQL activity. These capabilities can be used together to help security and database teams identify risk, protect sensitive information, detect suspicious behavior, and strengthen database security controls.

Watch a preview of "*Introduction to Oracle Data Safe*" (May 2025) [Video hosted on Oracle Video Hub](videohub:1_qzygqqzb)

## Objectives

In this workshop, you will:

- **Assess the database security posture** by identifying configuration risks, establishing an approved baseline, and detecting security drift with Security Assessment.
- **Evaluate database users and privileges** by identifying potentially high-risk users and detecting changes to users and entitlements with User Assessment.
- **Discover sensitive data** by identifying where sensitive information resides and creating a sensitive data model with Data Discovery.
- **Protect sensitive data for non-production use** by applying masking techniques that replace sensitive values while preserving useful characteristics of the data.
- **Monitor database activity** by configuring auditing and alerts, generating security-relevant activity, and investigating the resulting alerts and audit events.
- **Control application SQL behavior** by learning an application's expected SQL workload, creating an allow-list, enforcing a SQL Firewall policy, and investigating blocked SQL statements.

By the end of the workshop, you will understand how these Oracle Data Safe capabilities can work together to help identify, reduce, and monitor database security risk.

You may now **proceed to the next lab**.

## Learn More

The following links provide more information about Oracle Data Safe:

- [Oracle Data Safe website](https://www.oracle.com/security/database-security/data-safe/)
- [Oracle Data Safe documentation](https://docs.oracle.com/iaas/data-safe/index.html)


## Acknowledgements

- **Author** - Jody Glover, Lead Principal User Assistance Developer, Database Development
- **Contributor** - Bettina Schäumer, Lead Principal Product Manager, Oracle Database Security
- **Last Updated By/Date** - Bettina Schäumer, August 20, 2026
