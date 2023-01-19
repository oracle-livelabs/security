# Oracle Access Governance Agent Installation and Configuration

## Introduction

OAG Agent will be installed and configured. 

*Estimated Lab Time*: 15 minutes

### Objectives

In this lab, you will:
 * Install and Configure **OAG Agent.**

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account


## Task 1: Install OAG Agent on the Compute Instance and Configure

1. Open a terminal session.  Move Agent ZIP file from the local file system to zip_oag inside OIG: /home/opc. 

    ```
    <copy>cd /home/opc/zip_oag</copy>
    <copy>ls</copy>
    ```
    ![Initialize the Kubernetes cluster and the pod network add-on](images/terminal-oag.png) 

     Verify the Agent zip is present inside zip_oag.

    
2. Setting the Environment variables using the below command:

    ```
    <copy>source oag_agent.env</copy>
    ```
    ![Initialize the Kubernetes cluster and the pod network add-on](images/env-setup.png) 
 

3. Install the agent

    ```
    <copy>sh agentManagement.sh --volume /home/opc/vol_oag —-agentpackage /home/opc/zip_oag/oig-oag.zip —-install</copy>
    ```
    ![Initialize the Kubernetes cluster and the pod network add-on](images/agent-install.png) 

4. Start the agent
     ```
    <copy>sh agentManagement.sh --volume /home/opc/vol_oag —-start</copy>
    ```
    ![Initialize the Kubernetes cluster and the pod network add-on](images/agent-start.png) 

5. Verify the agent

     ```
    <copy>sh agentManagement.sh --volume /home/opc/vol_oag --status</copy>
    ```
    ![Initialize the Kubernetes cluster and the pod network add-on](images/agent-status.png) 


You may now [proceed to the next lab](#next).

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Author** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 
* **Last Updated By/Date** - Anbu Anbarasu, Cloud Platform COE, January 2023