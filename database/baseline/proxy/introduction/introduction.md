# Introduction

## About this Workshop

This workshop introduces the functionality of Proxy Authentication. Proxy Authentication allows a user (the proxy user) to connect to the database on behalf of another user (the target user) and this workshop shows developers the proper usage, configuration and best practices with Proxy Authentication.

*Estimated Workshop Time*: 45 minutes

### About Proxy Authentication

Proxy authentication is the process of using a middle tier for user authentication. You can design a middle tier server to proxy clients in a secure fashion by using the following three forms of proxy authentication:

- The middle tier server authenticates itself with the database server and a client. In this case, an application user or another application, authenticates itself with the middle tier server. Client identities can be maintained all the way through to the database.

- The client, that is, a database user, is not authenticated by the middle tier server. The client's identity and database password are passed through the middle tier server to the database server for authentication.

- The client, that is, a global user, is authenticated by the middle tier server, and passes either a Distinguished name (DN) or a Certificate through the middle tier for retrieving the client's user name.

In all cases, an administrator must authorize the middle tier server to proxy a client, that is, to act on behalf of the client.



### Objectives
Allow a developer to access the application data without knowing the application schema password.  The developer created will inherit the privileges of the application schema.

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
