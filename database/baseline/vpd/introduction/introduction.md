# Introduction

## About this Workshop

This workshop introduces the functionality of Oracle Virtual Private Database (VPD). It gives the user an opportunity to learn how to configure this feature to implement row and column level security. Oracle VPD creates security policies to control database access at the row and column level.

*Estimated Workshop Time*: 45 minutes

### About VPD 

Oracle Virtual Private Database enforces security, to a fine level of granularity, directly on database tables, views, or synonyms. Because you attach security policies directly to these database objects, and the policies are automatically applied whenever a user accesses data, there is no way to bypass security.

When a user directly or indirectly accesses a table, view, or synonym that is protected with an Oracle Virtual Private Database policy, Oracle Database dynamically modifies the SQL statement of the user. This modification creates a WHERE condition (called a predicate) returned by a function implementing the security policy. Oracle Database modifies the statement dynamically, transparently to the user, using any condition that can be expressed in or returned by a function. You can apply Oracle Virtual Private Database policies to SELECT, INSERT, UPDATE, INDEX, and DELETE statements.

### Objectives
Understand the basics of Oracle Virtual Private Database (VPD), including limiting rows and columns returned in a user query.  This lab will demonstrate how to create a PL/SQL function and apply it to a table to restrict rows based on session user and client identifier, without affecting the Glassfish-based HR application.

The entire DB Security PMs Team wishes you an excellent workshop!

### Prerequisites

This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment

## Acknowledgements
- **Author** - Stephen Stuart & Noah Galloso, Solution Engineers, North America Specialist Hub
- **Contributors** - Richard C. Evans, Database Security Product Manager 
- **Last Updated By/Date** - Stephen Stuart & Noah Galloso, August 2023
