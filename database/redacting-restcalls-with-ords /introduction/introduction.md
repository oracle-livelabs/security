# Redacting REST calls with ORDS

## Introduction

Oracle Data Redaction is an Oracle Advanced Security component that allows database users to ensure the confidentiality and privacy of their critical data. 

Data redaction is the process of obscuring sensitive data in a document or database, usually by replacing it with a placeholder. The goal of data redaction is to protect the privacy of individuals and prevent the unauthorized disclosure of sensitive information. Data redaction is often used to protect personal information such as names, addresses, and social security numbers, as well as financial and medical information. It is also used to redact classified or confidential information in government documents and other official records.

In terms of using Oracle Redaction with REST calls through ORDS (Oracle REST Data Services), you can use the ORDS API to configure redaction policies for specific columns or tables in your database. These policies can then be applied to REST calls made through ORDS, ensuring that sensitive data is not returned in the response.

To implement redaction in ORDS, you would first need to enable the redaction feature in the database. Then, you can use the ORDS API to create redaction policies that specify which columns or tables should be redacted, as well as the specific redaction function to be used (e.g. replacing with a specific string or a random value). These policies can then be applied to REST calls by configuring ORDS to use the redaction policies for specific resources or resource templates.
This workshop demonstrates how we can use Oracle Data Redaction with Oracle Rest Data Services to redact Get calls allowing user's to ensure the privacy of sensitive data.

![Lab architecture](images/lab-architecture.png)


Estimated Time: 30 minutes

### Objectives

In this lab, you will complete the following tasks:

- Configure the Autonomous Database environment.
- Use Redaction to anonymize REST GET calls.
- Reset your environment.

### Prerequisites

This workshop assumes you have:
- An Oracle Cloud Infratructure tanancy account
- Familiarity with Database is desired
- Some understanding of cloud and database terms is helpful
- Familiarity with Oracle Cloud Infrastructure (OCI) is helpful
- Basic understanding of RESTFUL services is helpful

*Note: Throughout this workshop, if you ever find yourself struggling when it comes to finding your resources in Oracle Cloud, make sure both your compartment and region correspond to where you created the resource.*

## Want to learn more about Oracle Data Redaction?
- [Introduction to Oracle Data Redcation](https://docs.oracle.com/database/121/DVADM/dvintro.htm#DVADM001)
- [Oracle Data Redaction FAQs](https://www.oracle.com/technetwork/database/options/data-masking-subsetting/learnmore/faq-security-asdr-external-3215961.pdf)

# Acknowledgements

- **Authors** - Alpha Diallo & Ethan Shmargad, North America Specialists Hub
- **Creator** - Pedro Lopes, Dataabse Security Product Manager
- **Last Updated By/Date** - Alpha Diallo & Ethan Shmargad, January 2023