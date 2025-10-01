# Increased Key Control for Less Secure Environments

## Introduction
In certain scenarios, it may be necessary to share data with environments that operate under lower security controls. However, it is critical that the TDE master encryption keys aren't exposed with this environment, downloaded or cached with the secure persistent cache. For this purpose, the Oracle Key Vault can manage keys that are non-extractable.

Estimated Lab Time: 2 minutes

### Objectives
In this lab, you will rekey a key with OKV as the external store but tag the key with the attribute 'Non-Extractable'. You will then simulate a connectivity failure, and then attempt to create a new tablespace (which will fail), to observe how the keys weren't exposed/available to the riskier environment.

### Prerequisites
This lab assumes you have completed lab 8.

## Task 1: Re...

A...

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*