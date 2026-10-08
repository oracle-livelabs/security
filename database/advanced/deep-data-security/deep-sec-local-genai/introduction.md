# Introduction to Oracle Deep Data Security Lab

## Introduction

In this workshop, you secure an AI-powered app at the database layer with Oracle Deep Data Security on Oracle Autonomous AI Database 26ai.

Starting from a working Customer Sales App, you create two local end users, Marvin and Emma, and build employee and manager data roles. You define row- and column-level access with data grants, extend it to the Order History table with a cross-table data grant, and add manager access with an end user context.

After each step, you verify the results with SQL queries and with natural-language questions in Customer Insights. OCI Generative AI sees only the rows and columns the database authorizes for the signed-in user. No rephrasing or prompt trick can widen that access.

### Objectives

- Create local Deep Data Security end users, data roles, and data grants.
- Verify database-enforced row and column authorization in the Customer Sales App.
- Extend authorization to Order History through a cross-table data grant.
- Add manager access through an end user context.
- Query Order History through an Apache Iceberg external table without copying its data into Oracle.
- Use OCI Generative AI to test different questions against the authorized customer data.
- Confirm that GenAI queries cannot override or bypass database authorizations.

## Architecture

![Deep Data Security and OCI Generative AI workshop architecture](images/architecture-infographic.png)

The Customer Sales App and Customer Insights run as a Python Flask application. The browser interface uses HTML, CSS, and JavaScript, while the Python backend connects to ADB and OCI Generative AI. 

Oracle Deep Data Security controls which customer rows and columns the signed-in user can access. 
Customer Insights sends only those authorized results to OCI Generative AI, which answers questions about them without independently retrieving additional database data.

Order History is stored in Object Storage and queried from ADB through an external table. The source data remains in Object Storage.


You may now proceed to the next lab.

## Acknowledgements

- **Author** - Richard Evans
- **Last Updated** - October 2026
