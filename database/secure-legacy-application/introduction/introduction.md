# Securing a legacy application using Oracle Database Vault on Oracle Autonomous Database

## Introduction

In addition to its self-managing capabilities, Oracle Autonomous Database also integrates with Oracle Database Vault. Oracle Database Vault is a security-enhancement tool that provides an additional layer of security by restricting access to sensitive data and preventing unauthorized users from accessing or manipulating it. By combining the self-managing capabilities of Oracle Autonomous Database with the security features of Oracle Database Vault, organizations can benefit from both enhanced performance and improved security.

One of the key features of Oracle Autonomous Database is its ability to automatically tune itself for optimal performance. This is achieved through the use of machine learning algorithms that continually analyze database workloads and make adjustments to the database configuration in real-time. This allows Oracle Autonomous Database to deliver consistently high performance, even as workloads and data volumes change over time.

Overall, Oracle Autonomous Database and Oracle Database Vault are valuable tools for organizations looking to optimize their database performance and improve security. The combination of these two technologies allows organizations to take advantage of the self-managing capabilities of Oracle Autonomous Database, while also protecting sensitive data with the security features of Oracle Database Vault.

![Lab Architecture](images/intro-architecture.png)

Estimated Time: 90 minutes

### Objectives

In this lab, you will complete the following tasks:

- Connect to the Glassfish legacy HR application
- Configure the Autonomous Database Instance
- Load and verify the data in the Glassfish application
- Enable Database Vault and verify the HR application
- Identify the connections to the EMPLOYEESEARCH_PROD schema
- Explore the Glassfish HR application functions with Database Vault enabled

### Prerequisites

This workshop assumes you have:
- An Oracle Cloud Infratructure tanancy account
- Familiarity with Database is desired
- Some understanding of cloud and database terms is helpful
- Familiarity with Oracle Cloud Infrastructure (OCI) is helpful
- Some basic understanding of data protection and security is a plus
- Some familiarity with Linux/Bash commands is helpful

*Note: Throughout this workshop, if you ever find yourself struggling when it comes to finding your resources in Oracle Cloud, make sure both your compartment and region correspond to where you created the resource.*

## Want to learn more about Oracle Database Vault?
- [Oracle Database Vault Landing Page](https://www.oracle.com/security/database-security/database-vault/)
- [Introduction to Oracle Database Vault](https://docs.oracle.com/database/121/DVADM/dvintro.htm#DVADM001)
- [Additional Database Vault LiveLab](https://livelabs.oracle.com/pls/apex/r/dbpm/livelabs/view-workshop?wid=682&clear=RR,180&session=100352880546347)

## Acknowledgements

- **Author** - Ethan Shmargad, North America Specialists Hub
- **Creator** - Richard Evans, Senior Principle Product Manager
- **Last Updated By/Date** - Ethan Shmargad, September 2022
