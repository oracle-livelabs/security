# Encrypt Data in-motion with TLS

## Introduction

Oracle Data Redaction is an Advanced Security feature that allows you to mask sensitive data in real-time, protecting it from unauthorized disclosure. This feature is included with your Autonomous Database subscription and is particularly useful for read-only scenarios such as displaying sensitive information in reports or sending it to other applications via GET APIs.

The DMBS_REDACT PL/SQL package is used to manage redaction policies and configure the specific columns and redaction formats.

In this workshop, you will learn how to use Oracle Data Redaction with Oracle Rest Data Services (ORDS) to redact  data in a GET response, ensuring the privacy of sensitive data. The process includes REST enabling the table you want to make available through ORDS, creating redaction policies for specific columns and tables, and specifying the redaction function to be used. You'll be able to contrast the response that contains data in clear vs the one that has sensitive data redacted.

![Lab architecture](images/lab-architecture.png)


Estimated Workshop Time: 27 minutes

### Objectives

In this lab, you will complete the following tasks:

- Create Database wallet and self signed certificate.
- Configure Database listener to support TLS encryption.
- Test TLS and non-TLS connectivity.
- Configure the Oracle Instant Client on Linux 8. 

### Prerequisites

This workshop assumes that you have:
- Familiarity with Database is desirable, but not required
- Some understanding of cloud and database terms is helpful
- Familiarity with Oracle Cloud Infrastructure (OCI) is helpful
- Some basic understanding of DB security is a plus

*Note: Throughout this workshop, if you ever find yourself struggling when it comes to finding your resources in Oracle Cloud, make sure both your compartment and region correspond to where you created the resource.*

## Want to learn more about Oracle Data Security?
- [Introduction to Oracle Data Redaction](https://docs.oracle.com/en/database/oracle/oracle-database/21/asoag/introduction-to-oracle-data-redaction.html#GUID-82EA9712-387C-4D3A-BB72-F64A707C67CA)
- [Oracle Data Redaction FAQs](https://www.oracle.com/technetwork/database/options/data-masking-subsetting/learnmore/faq-security-asdr-external-3215961.pdf)

## Acknowledgements

- **Authors** - Stephen Stuart & Alpha Diallo, Solution Engineers,North America Specialist Hub
- **Creator** - Richard C. Evans, Database Security Product Manager
- **Last Updated By/Date** - Stephen Stuart & Alpha Diallo, March 2023