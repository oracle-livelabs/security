# Introduction

## About this Workshop

Oracle Identity Management enables organizations to effectively manage the end-to-end lifecycle of user identities across all enterprise resources, both within and beyond the firewall and into the cloud. The Oracle Identity Management platform delivers scalable solutions for identity governance, access management and directory services. This modern platform helps organizations strengthen security, simplify compliance and capture business opportunities around mobile and social access.

Oracle has included DevOps delivery model by leveraging Containers for Docker and Kubernetes to modernize the lifecycle management of Oracle Identity and Access Management products. This approach will simplify the deployment and maintenance of Oracle Identity and Access Management products across various deployments on physical, private cloud or public clouds.

Kubernetes is a system for running and coordinating containerized applications across clusters. It manages the life cycle of containerized applications and services, thereby providing predictability, scalability, and high availability.

Oracle provides an open source WebLogic Server Kubernetes Operator, which has several key features to assist with deployment and managemenet of various Fusion Middleware products including Oracle Identity Governance (OIG) and Oracle Access Management (OAM).
Oracle Unified Directory deployment on Kubernetes leverages deployment scripts provided by Oracle for creating Oracle Unified Directory containers using samples or Helm charts provided..

With the help of Kubernetes operator and out of the box deployment scripts, you can :-

1. Create OIG/OAM/OUD instances in a Kubernetes persistent volume. This persistent volume can reside in an NFS file system or other Kubernetes volume types
2. Start servers based on declarative startup parameters and desired states
3. Expose the OIG/OAM/OUD Services for external access
4. Scale OIG/OAM/OUD by starting and stopping servers on demand
5. Publish operator and WebLogic Server logs into Elasticsearch and interact with them in Kibana
6. Monitor the OIG instance using Prometheus and Grafana

*Estimated Time:* 90 minutes


### Objectives

In this workshop, you will learn how to:
* Setup a single-node local kubernetes cluster
* Deploy OIG in the kubernetes environment
* Deploy OAM in the kubernetes environment
* Create an OUD instance in the kubernetes environment

### Prerequisites
This lab assumes you have:
* A Free Tier, Paid or LiveLabs Oracle Cloud account

*Note: If you have a **Free Trial** account, when your Free Trial expires your account will be converted to an **Always Free** account. You will not be able to conduct Free Tier workshops unless the Always Free environment is available. **[Click here for the Free Tier FAQ page.](https://www.oracle.com/cloud/free/faq.html)***

## Learn More

* [OIG in a Kubenetes Environment](https://oracle.github.io/fmw-kubernetes/oig/)
* [OAM in a Kubenetes Environment](https://oracle.github.io/fmw-kubernetes/oam/)
* [OUD in a Kubenetes Environment](https://oracle.github.io/fmw-kubernetes/oud/)

## Acknowledgements
* **Author** - Keerti R, Anuj Tripathi, NATD Solution Engineering
* **Contributors** -  Keerti R, Anuj Tripathi
* **Last Updated By/Date** - Keerti R, NATD Solution Engineering, January 2022
