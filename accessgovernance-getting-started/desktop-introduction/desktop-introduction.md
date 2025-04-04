# Introduction

## About this Workshop

Oracle Access Governance is a cloud native identity governance and administration (IGA) service that provides customers with a simple, easy-to-understand view of what resources individuals can access, whether they should have that access, and how they’re using their access entitlements. 

Businesses are challenged every day to enforce appropriate, just-in-time user access rights to manage control of their information and address regulatory compliance requirements regarding least-privilege access. By providing immediate and prescriptive guidance about the types of access users should have, Oracle Access Governance makes it easier for administrators to provision new users and deprovision departing users quickly. In addition, machine learning intelligence in Oracle Access Governance can monitor all types of access to identify anomalous behavior patterns and automate remediation actions as required. 

Oracle Access Governance supports continuous compliance with proper access management and constantly evaluates and reports risks, allowing organizations to avoid big, manual, periodic reviews and significantly reducing the cost and effort of audit responses. Events and access at risk are reviewed regularly, and reviews are informed by built-in intelligence. Oracle Access Governance continuously adds support for orchestrated systems, providing strong insights into access controls across new applications that may span cloud and on-premises environments.

 The graphic below shows the high-level functional architecture of Oracle Access Governance.

 ![View List of Campaigns](images/diagram.jpg)

Oracle Access Governance is a comprehensive governance solution that supports various provisioning methods, including access requests and approvals, role-based access control (RBAC), attribute-based access control (ABAC), and policy-based access control (PBAC). The service features a conversation-style user experience, offering deep visibility into access permissions across the entire enterprise. It facilitates dynamic, periodic, and automated event-based micro certifications, such as an access review triggered by a job code or manager change. Additionally, it enables near real-time access reviews, providing detailed recommendations with options for reviewers to accept or review an entitlement based on the identified level of risk.

Oracle Access Governance can also run with Oracle Identity Governance in a hybrid deployment model. Organizations that opt for a hybrid model can take advantage of advanced capabilities available from cloud native services while retaining parts of their on-premises identity and access management suite to address compliance or data residency requirements.

This workshop walks you through the steps to get an overview of Oracle Access Governance with use cases including access controls implementation, user access reviews, and enterprise-wide visibility for systems managed using Access Governance. In this workshop, a fictitious corporation is using Oracle Access Governance to manage and govern the application access of its employees and contractors. This lab shows how the database is connected to AG as a target system and implement access control by creating identity collections, approval workflows, roles, access bundles, and centralized policies. It also shows how to perform access review campaigns, and associated review tasks.
Please note that this workshop uses Oracle Identity Governance (OIG) to provide the test data to demonstrate some of the key capabilities of Oracle Access Governance but it is not a requirement to have OIG to implement Oracle Access Governance based IGA solution.


*Estimated Workshop Time:* 3 Hours

### Objectives

In this workshop, you will learn how to:

- Setup and configure Oracle Access Governance service instance
- Install and configure Oracle Access Governance agents for the Oracle Identity Governance and the Oracle Database
- Perform data load and activate users in Access Governance
- Define Access Control components including Identity Collections, Access Bundles, Policies, and Approval Workflows
- Review “Who Has Access To What” using enterprise-wide browser
- Create Access Review Campaign and perform access reviews for the target database system

### Prerequisites

This lab assumes you have:

- Familiarity with OCI


## Learn More

- [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
- [Oracle Access Governance Documentation](https://docs.oracle.com/en/cloud/paas/access-governance/index.html)
- [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
- [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)
- [Oracle Access Governance Announcement Blog](https://blogs.oracle.com/cloudsecurity/post/intelligent-cloud-delivered-access-governance-with-prescriptive-analytics)

## Acknowledgements

- **Authors** - Anuj Tripathi, Anbu Anbarasu
- **Last Updated By/Date** - Anuj Tripathi, October 2023
