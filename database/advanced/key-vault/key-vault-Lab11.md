# Bring Your Own Key

## Introduction
A person or process can possess their own keys (with better entropy) that they wish to manage with their other keys. These externally generated keys can be uploaded to and registered with Oracle Key Vault. At the time of use, the key administrator can share the key-ID (the name of a key) with the appropriate DBA. Both processes would be isolated from each other to maintain key secrecy.

Estimated Lab Time: 2 minutes

### Objectives
In this lab, you will learn how to create a correctly formatted file to upload an externally generated key into OKV. You will also learn how to see this key on the OKV management console and how to locate the key-ID that will be shared with the DBA.

### Prerequisites
This lab assumes you have completed lab 10.

## Task 1: Re...

A...

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*