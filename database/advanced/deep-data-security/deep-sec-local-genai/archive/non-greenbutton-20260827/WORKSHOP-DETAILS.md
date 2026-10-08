# Workshop Details

## Short Description

See an intentionally excessive application and AI Insights result, then use Oracle Deep Data Security to enforce what a local end user can retrieve even when Vibe modifies the application.

## Long Description

In this 60-minute workshop, you create a customer-data demonstration on Oracle Autonomous AI Database 26ai. Marvin is a local Oracle Deep Data Security end user, not an OCI IAM user. Students first see a full-access result, including Credit Limit and Sensitive Identifier, then apply an employee data grant and rerun the unchanged Flask query and AI Insights questions. Oracle Deep Data Security determines the rows and columns returned to both experiences.

## Workshop Outline

1. Provision the lab, install the wallet, and create the full-access role.
2. Start the supplied customer application and observe Marvin's excessive access in Customer Accounts and AI Insights.
3. Apply the employee data grant and rerun the unchanged query and AI Insights questions.
4. Promote Marvin to manager and observe the legitimate increase in authorized rows.
5. Use Vibe to add features and attempt row and column bypasses.
6. Destroy the Resource Manager Stack.

## Prerequisites

- A non-production OCI compartment that permits the BYOL, 2-ECPU, 1-TB Autonomous AI Database defaults.
- An Oracle Linux 9 compute instance with JupyterLab and Python 3.
- The supplied custom image must be visible in Ashburn. Use the main Terraform ZIP when the Stack operator can create its GenAI dynamic group and policy; otherwise use the no-IAM ZIP only when existing tenancy authorization already covers the new compute instance.
- Privileged ADB credentials for the setup scripts and a protected wallet location on the compute host.
