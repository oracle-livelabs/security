# About This Hands-on Lab

*Estimated Workshop Time:* 55 minutes for core labs

## Solution Overview

Oracle Database Security Central provides a unified command center for database security across the fleet. It brings together:

- **User Assessment/User360** — identifies privileged and high-risk users, risky entitlements, direct and indirect access paths, and dormant accounts.
- **Sensitive Data Discovery/Data360** — discovers and classifies sensitive data.
- **Security Assessment/Configuration360** — identifies configuration risks, release gaps, and security drift.
- **Audit and Monitoring/Audit360** — collects database activity and provides reports, alerts, and investigation tools.
- **Policy Management** — configures Audit, Database Firewall, SQL Firewall, and Database Vault policies.
- **Security Advisor** — helps investigate risk, activity, and compliance posture using natural-language questions.

For more information, see [Oracle Database Security Central](https://www.oracle.com/security/database-security/database-security-central/).

## Workshop Environment

This workshop uses a preconfigured Oracle AI Database environment containing the following targets:

- **`employees_search`** — an internal HR application containing sensitive employee information. The application is accessed by an application service account and privileged database users.
- **`customer_orders`** — an order management application containing customer, order, billing, and shipping information.

## Core Story

Security Central identifies a compound risk: one or more database targets are running an older database release, host sensitive employee data, and are accessed by privileged users whose activity on sensitive data is not fully audited or controlled.

In this workshop, you will investigate the risk, discover the affected sensitive objects and user groups, identify the missing controls, and configure security policies to reduce the exposure.

You will then generate test activity and verify the results in Reports, Alerts, and Security Advisor.

## Objectives

By completing this workshop, you will learn how to:

1. Establish a security posture baseline.
2. Find database release, user, and sensitive-data risks.
3. Discover affected sensitive objects and privileged user groups.
4. Identify gaps in auditing and access controls.
5. Configure audit policies and Database Firewall.
6. Optionally extend protection with SQL Firewall and Database Vault.
7. Verify security controls using Reports, Alerts, and Security Advisor.

## Workshop Flow

| Approximate time | Lab | What you will do |
|---|---|---|
| 5 minutes | Access Security Central | Sign in and establish the initial security posture baseline. |
| 15 minutes | Assess and Discover the Risk | Find the risks, affected targets, sensitive objects, and privileged user groups. |
| 10 minutes | Audit, Monitor, and Alert on Privileged Activity | Identify the audit gap, configure audit policies, and verify activity coverage. |
| 15 minutes | Protect and Prevent Unauthorized Database Activity | Configure Database Firewall as the core control. SQL Firewall and Database Vault are available as optional extensions. |
| 10 minutes | Review Compliance Evidence and Confirm Workshop Outcomes | Verify blocked, logged, and alerted activity and summarize the security posture. |

## The Investigation Flow

The workshop follows this sequence:

**Find the risk → Discover the exposure → Identify the gap → Configure the control → Generate safe test activity → Verify the evidence**

By the end of the workshop, you will understand how Oracle Database Security Central connects user risk, sensitive data, security policies, database activity, and compliance evidence in one place.

## Acknowledgements

* **Author:** Nazia Zaidi, Database Security - Product Manager
* **Contributors:** Angeline Dhanarani, Database Security - Product Manager
* **Last Updated By/Date:** Nazia Zaidi, Database Security - Product Manager - October 2026
