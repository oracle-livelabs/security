# Objective

Modify the existing supplied Flask application in this repository so it becomes the **canonical, professional starter application** for the AI World Deep Data Security hands-on lab.

Do the implementation work directly in the repository. Do not merely propose changes.

The application already has the right technical foundation. Preserve that foundation and improve the user experience, visual polish, code quality, and lab observability.

**Important: DO NOT add customer search yet.**

Customer search will be the student's **first Vibe coding exercise** during the lab.

The desired lab story is:

1. Student starts with a professionally built, known-good customer-sales application.
2. Marvin initially has intentionally excessive database authorization and can see all 22 customers and sensitive identifiers.
3. Oracle Deep Data Security is applied without changing the application.
4. Marvin now sees only 14 authorized customers and no sensitive identifiers.
5. Marvin is legitimately promoted to Sales Manager.
6. Marvin now sees 20 customers, still excluding Finance and Sensitive Identifier.
7. Only then does the student use Vibe to add new application features.
8. Those Vibe-generated features intentionally contain **no application-side business data authorization**.
9. Oracle Deep Data Security remains the independent security boundary.

The key teaching point is:

> The application can ask for data. Oracle Database decides which rows and columns the authenticated end user is authorized to receive.

---

# Existing Application

Inspect the existing repository before modifying it.

The supplied application currently includes:

```text
flask-app/
    app.py
    db.py
    config.py
    requirements.txt
    run.sh
    run_dev.sh
    setup_venv.sh
    configure_env.sh
    verify_app_server.sh
    templates/
        index.html
        query.html
    static/
        app.css
        app.js
```

The existing application already has several important properties that MUST be preserved:

* Flask
* Flask-Login
* Flask-WTF CSRF protection
* server-side handling of Marvin's database password
* direct Oracle Database authentication as MARVIN
* Python `oracledb`
* Oracle Thick mode / Instant Client
* Autonomous AI Database wallet/TNS configuration
* `deepsec_low`
* Gunicorn
* responsive custom CSS
* short-lived Oracle connections
* no application-side customer row authorization
* no application-side sensitive-column authorization

Do not replace this application with a new framework or redesign its architecture unnecessarily.

This should be a refinement of the existing application.

---

# Critical Security Architecture

The application intentionally authenticates directly to Oracle Database as the end user Marvin.

The database password Marvin enters at sign-in is used to establish Oracle Database sessions as:

```text
MARVIN
```

This lets Oracle Deep Data Security evaluate Marvin's database identity and active data roles directly.

The current architecture resembles:

```text
Browser
   |
   v
Flask application
   |
   | Marvin's supplied credentials
   v
Oracle Database session as MARVIN
   |
   v
Deep Data Security
   |
   +-- End-user identity
   +-- Active data roles
   +-- Authorized rows
   +-- Authorized columns
   |
   v
Result returned to Flask
```

Preserve this architecture.

---

# Do Not Add Application-Side Business Authorization

This is one of the most important requirements.

The Flask application must intentionally contain **no customer row or column business authorization logic**.

Do not add Python logic such as:

```python
if username == "MARVIN":
    ...
```

Do not add:

```python
if customer.sales_rep == current_user:
    ...
```

Do not add application role logic such as:

```python
if role == "sales_manager":
    ...
```

Do not add hard-coded knowledge of:

```text
MARVIN
SALES_TEAM
FINANCE
Apex Treasury
Crown Capital
```

for the purpose of determining access.

Do not add SQL authorization predicates such as:

```sql
WHERE sales_rep = 'MARVIN'
```

or:

```sql
WHERE sales_rep = :username
```

or:

```sql
WHERE sales_rep IN ('MARVIN', 'SALES_TEAM')
```

or:

```sql
WHERE sales_rep <> 'FINANCE'
```

Oracle Deep Data Security must remain responsible for determining which customer rows and columns are available.

---

# This Does NOT Mean "Make the Application Insecure"

The application should remain professionally implemented.

We are deliberately omitting **business data authorization from Flask**.

We are NOT deliberately introducing:

* SQL injection
* cross-site scripting
* credential exposure
* insecure cookies
* CSRF vulnerabilities
* unsafe session handling
* hard-coded passwords
* logging of passwords
* unsafe dynamic SQL
* unrelated application vulnerabilities

This distinction is important to the lab.

The message is:

> Application security still matters, but it should not be the only security boundary protecting the data.

---

# Preserve the Existing Customer Query

The existing `db.py` currently documents the correct design:

```python
"""Direct local-end-user database access. No application-side authorization."""
```

Preserve that intent.

The existing customer query is conceptually:

```sql
SELECT customer_name,
       region,
       revenue,
       credit_limit,
       sensitive_identifier
  FROM APPLAB.customers
 ORDER BY revenue DESC
```

There is deliberately no business authorization predicate in this query.

Do not add one.

The exact same basic query should continue to produce different results solely because Marvin's database authorization changes.

---

# Lab Data and Expected Results

The `APPLAB.CUSTOMERS` sample data contains:

* 14 `MARVIN` customers
* 6 `SALES_TEAM` customers
* 2 `FINANCE` customers

Total:

```text
22 customers
```

Important examples:

| Customer       | Sales representative | Purpose                                           |
| -------------- | -------------------- | ------------------------------------------------- |
| Frontier Goods | MARVIN               | Marvin should always retain access                |
| Acme East      | SALES_TEAM           | Appears after legitimate manager promotion        |
| Apex Treasury  | FINANCE              | Must disappear after Deep Data Security is active |
| Crown Capital  | FINANCE              | Must remain unavailable to employee or manager    |

---

# Authorization State 1 — Full Access

Initially Marvin has:

```text
HOL_DATAROLE_FULL_ACCESS
```

The full-access database data grant permits every row and column.

Expected application result:

```text
Rows returned: 22
Sensitive Identifier: visible
Apex Treasury: visible
Crown Capital: visible
```

The application is not creating this exposure.

The database authorization is intentionally too broad.

---

# Authorization State 2 — Sales Employee

After:

```sql
@../database/enable_employee_policy.sql
```

Marvin has:

```text
HOL_DATAROLE_SALES_EMPLOYEE
```

Expected result from the SAME APPLICATION:

```text
Rows returned: 14
Sensitive Identifier: Not authorized
Apex Treasury: unavailable
Crown Capital: unavailable
Acme East: unavailable
Frontier Goods: available
```

No Flask code should change.

---

# Authorization State 3 — Sales Manager

After:

```sql
@../database/promote_marvin_to_manager.sql
```

Marvin has:

```text
HOL_DATAROLE_SALES_EMPLOYEE
HOL_DATAROLE_SALES_MANAGER
```

Expected result:

```text
Rows returned: 20
Sensitive Identifier: Not authorized
Apex Treasury: unavailable
Crown Capital: unavailable
Acme East: available
Frontier Goods: available
```

Again, no Flask application change should be required.

The database authorization alone changes the result.

---

# Product/UI Direction

The existing application is technically good but currently presents itself primarily as a security demonstration.

Change the presentation so it looks first like a **professional customer-sales application**, while retaining enough lab observability to explain what Oracle is doing.

The student should initially think:

> This looks like a normal internal customer application.

Then during the lab they discover that Oracle is independently controlling the data returned to it.

---

# Recommended Primary Branding

Use a professional product identity such as:

```text
Oracle Customer Sales
```

or:

```text
Customer Sales
```

The exact wording can follow the existing visual design, but avoid making every heading say "Deep Data Security demonstration."

Deep Data Security should still be visible as the underlying security technology.

For example, secondary text could say:

```text
Protected by Oracle Database
```

or:

```text
Oracle Deep Data Security
```

Do not remove the security story completely.

The application should simply feel like a real customer application first.

---

# Sign-In Page

Improve the existing sign-in page so it looks like a polished business application.

The page should communicate:

```text
Oracle Customer Sales

Sign in

Database user
Marvin

Database password
[                         ]

[ Sign in ]
```

The application currently has a persona dropdown even though Marvin is the only available persona.

Because there is only one user, prefer simplifying the UI.

Instead of making the student choose Marvin from a one-item dropdown, display Marvin clearly as the database identity being used.

For example:

```text
Database user
Marvin — Sales
```

The application may keep the underlying `PERSONAS` implementation if that simplifies compatibility.

Do not redesign the backend simply to remove the select box.

The UI should make the experience obvious to a novice.

---

# Sign-In Explanation

Keep a concise explanation that the password is authenticated by Oracle Database.

For example:

```text
Your database password is verified directly by Oracle Database.
```

A secondary explanation may say:

```text
The password remains only in this application server's memory for the current session.
```

Do not overwhelm the sign-in page with architecture terminology.

---

# Customer Accounts Page

Rename/reframe the current "Authorized Query" screen into a normal customer account screen.

Suggested structure:

```text
Oracle Customer Sales

Customer Accounts

Review the customer accounts available to your current database identity.

[ Customer Report ]
```

After loading:

```text
20 Customer Accounts
```

followed by the customer table.

Suggested columns:

```text
Customer
Region
Revenue
Credit Limit
Sensitive Identifier
```

Keep the current data fields.

---

# Do NOT Add Search Yet

This is critical.

The professional starter application must NOT contain:

* customer search
* customer filtering UI
* customer-name filter route
* search API
* search SQL
* customer detail-by-ID page
* CSV export
* admin explorer

Those features are deliberately reserved for the Vibe portion of the lab.

The Customer Accounts page should visually have enough room that a search field can naturally be added later, but do not implement one.

The first visible Vibe modification needs to feel meaningful.

---

# Customer Table

Make the customer table polished and easy to read.

Preserve:

* customer name
* region
* revenue
* credit limit
* sensitive identifier

Use appropriate numeric formatting.

Continue displaying an unavailable value as:

```text
Not authorized
```

where that is the behavior produced by Oracle/the existing application mechanism.

Do NOT create Flask logic that decides Marvin is not authorized for a column.

Preserve the current database-driven behavior.

---

# Database Security Context

The existing application displays useful information about the active Oracle session.

Keep this feature and make it visually intentional.

Create a clearly labeled area such as:

```text
Database Security Context

End User
MARVIN

Active Data Roles
HOL_DATAROLE_SALES_EMPLOYEE
HOL_DATAROLE_SALES_MANAGER

Rows Returned by Oracle
20
```

This is important to the lab.

The instructor should be able to point at this area and say:

> Oracle sees Marvin and knows which data roles are active.

The context information should come from the existing Oracle queries:

```sql
select ora_end_user_context.username from dual
```

and:

```sql
select role_name
from v$end_user_data_role
order by role_name
```

Do not fake this information in Flask.

---

# SQL Observability

Keep the ability to show the SQL the application sends to Oracle.

However, de-emphasize it so the application still looks like a normal business application.

Instead of a large permanent section labeled:

```text
Fixed SQL
```

consider a collapsible section such as:

```text
Lab Details
    View SQL sent to Oracle
```

Using native HTML `<details>` / `<summary>` is acceptable and avoids unnecessary JavaScript.

When expanded, show the customer SQL.

This is an important instructor proof point:

> There is no `sales_rep = 'MARVIN'` predicate in the application's SQL.

Do not hide the SQL permanently.

---

# Loading State

Add professional loading behavior.

When the user selects:

```text
Customer Report
```

the application should:

* disable the button temporarily
* display an understandable loading state such as `Loading customer accounts…`
* avoid allowing repeated accidental submissions
* restore the button when the request completes
* handle errors cleanly

Cloud/database latency at a conference should not make the application appear broken.

---

# Empty State

Create a polished reusable empty state.

Before the first query, something like:

```text
Load customer accounts to view available records.
```

For a zero-row result, something like:

```text
No customers were returned.
```

or:

```text
No customer records matched this request.
```

Do NOT say:

```text
Access denied
```

or:

```text
You are not authorized for this customer
```

unless Oracle explicitly returned such an error.

This distinction matters later when Vibe adds search.

From Flask's perspective, Oracle may simply return zero rows.

---

# Error Handling

Maintain clear, novice-friendly error messages.

Do not expose:

* passwords
* wallet secrets
* connection strings containing credentials
* stack traces to the browser
* unnecessary internal details

Server-side logs may retain useful technical errors, but never log Marvin's password.

---

# Important JavaScript Security Cleanup

The existing `static/app.js` currently builds customer rows and security-context content using `innerHTML` with values returned by the database.

Replace that pattern for dynamic database values.

Use DOM APIs and `textContent` so customer/database values are treated as text rather than executable HTML.

For example, create:

```javascript
const td = document.createElement("td");
td.textContent = row.customer_name;
```

rather than interpolating database values directly into `innerHTML`.

Do the same for:

* customer values
* database end-user value
* active data-role value
* other dynamic server-returned strings

Static markup that contains no untrusted values may still use normal HTML templates.

The starter app should not contain unrelated XSS-style weaknesses.

Again:

> We are deliberately omitting business data authorization, not basic secure coding practices.

---

# Preserve Credential Handling

The existing `app.py` deliberately stores Marvin's supplied password only in server-process memory.

It currently uses an opaque browser login ID and an in-memory `_logins` structure.

Preserve that design for this lab unless there is a concrete bug that requires correction.

The password must NOT be:

* stored in a browser cookie
* returned to the browser
* written to `.env`
* written to disk
* logged
* placed into source code

Do not introduce a shared application database password.

---

# Gunicorn Worker Requirement

The current application stores login credentials in process memory.

Therefore the existing one-worker Gunicorn configuration is important:

```bash
--workers "${GUNICORN_WORKERS:-1}"
```

Do not change the default to multiple workers.

Add a concise developer comment or documentation note explaining why the workshop intentionally defaults to one Gunicorn worker:

> The lab keeps the database password only in process memory. Multiple independent Gunicorn workers would not share that credential store.

Do not introduce Redis or another external session store merely to make the application multi-worker.

This is a disposable one-student workshop application.

---

# Oracle Connection Requirements

Preserve the existing Oracle connection behavior.

The application must continue to:

* use Python `oracledb`
* use Oracle Thick mode
* initialize Oracle Instant Client
* use the installed wallet/TNS configuration
* connect through `deepsec_low`
* authenticate as Marvin
* use Marvin's entered password
* close database connections after requests
* preserve `TNS_ADMIN` / wallet compatibility
* work with the existing setup and run scripts

Do not change to Thin mode.

Do not replace direct local-end-user authentication with a shared application user.

---

# Preserve Existing Operational Scripts

Do not break:

```text
setup_venv.sh
configure_env.sh
install_wallet.sh
verify_app_server.sh
run.sh
run_dev.sh
healthcheck.sh
stop.sh
```

The existing lab instructions depend on these scripts.

Keep the application listening on:

```text
7777
```

unless the existing environment overrides it.

---

# Visual Quality

Make the UI look polished enough to plausibly represent a professional internal Oracle sales application.

Priorities:

* clean typography
* consistent spacing
* visually clear page hierarchy
* professional card/table design
* responsive layout
* accessible labels
* useful focus states
* readable table on laptop screens
* sensible mobile behavior
* consistent buttons
* good empty/loading/error states

Reuse and improve the existing `static/app.css`.

Do not add a heavy frontend framework.

Do not turn this into a SPA.

Avoid unnecessary dependencies.

The simplicity of the source is useful because Vibe will modify it later.

---

# Lab-Friendly Language

Reduce unnecessary terminology on the main application screens.

A novice should not need to understand:

* TNS_ADMIN
* Oracle Instant Client
* Thick mode
* Flask
* Gunicorn
* data grant syntax

to operate the UI.

Those details belong in the lab instructions or developer documentation.

The primary UI should use understandable language such as:

```text
Customer Accounts
Database User
Active Data Roles
Rows Returned
Customer Report
Sensitive Identifier
Not authorized
```

---

# Keep Deep Data Security Visible

Although this should look like a customer application first, retain a subtle security identity.

Good examples:

```text
Protected by Oracle Database
```

```text
Oracle Deep Data Security
```

or a footer such as:

```text
Oracle Customer Sales · Protected by Oracle Deep Data Security
```

Do not plaster "security demonstration" across every screen.

---

# Future Vibe Exercise — Customer Search

DO NOT implement this feature now.

The student's first Vibe command will be approximately:

```text
vibe "Add a customer search box that lets Marvin search all customers by name."
```

The starter application should be simple and well organized enough that Vibe can implement this naturally.

The intended future search behavior is described below so you can keep the architecture compatible with it.

---

# Future Search Security Model

When Vibe later adds search, the new feature should contain **no application-side customer authorization logic**.

Conceptually, the future SQL should resemble:

```sql
SELECT customer_name,
       region,
       revenue,
       credit_limit,
       sensitive_identifier
  FROM APPLAB.customers
 WHERE UPPER(customer_name) LIKE UPPER(:search_term)
 ORDER BY revenue DESC
```

It should use bind variables.

It must not later need to add:

```sql
AND sales_rep = 'MARVIN'
```

or:

```sql
AND sales_rep IN ('MARVIN', 'SALES_TEAM')
```

The search term should be the only application filter.

Oracle Deep Data Security should reduce the searchable data set automatically.

Do not pre-build this query now.

Just keep the existing DB layer straightforward so Vibe can add it later.

---

# Future Search Acceptance Story

The important future search demonstration is:

## Before Deep Data Security

Search:

```text
Apex Treasury
```

Expected:

```text
1 matching customer
```

because the full-access database grant permits the Finance row.

---

## Employee Policy

After:

```sql
@../database/enable_employee_policy.sql
```

Search:

```text
Apex Treasury
```

Expected:

```text
0 matching customers
```

No Flask authorization change occurs.

---

## Manager Policy

After:

```sql
@../database/promote_marvin_to_manager.sql
```

Search:

```text
Apex Treasury
```

Expected:

```text
0 matching customers
```

because the manager data grant adds `SALES_TEAM`, not `FINANCE`.

---

# Future Search Examples

The future search feature should eventually demonstrate:

### Frontier Goods

```text
Baseline: found
Employee: found
Manager: found
```

### Acme East

```text
Baseline: found
Employee: not found
Manager: found
```

### Apex Treasury

```text
Baseline: found
Employee: not found
Manager: not found
```

No Flask role logic should be required for any of this.

---

# Future Vibe Experiments

After search, the lab may ask Vibe to add progressively riskier features such as:

```text
vibe "Add a customer details page that loads a customer by customer ID."
```

Later:

```text
vibe "Add an Export All Customers button that exports every customer field to CSV."
```

Later:

```text
vibe "Make sure Marvin can see the Sensitive Identifiers!"
```

Potentially:

```text
vibe "Add an admin page that tries to display every customer and every customer field."
```

The existing application should remain straightforward enough for Vibe to modify.

Do NOT build these features now.

Do NOT add application safeguards specifically intended to prevent Vibe from modifying the source.

The security boundary being demonstrated is Oracle Database, not source-code protection.

---

# Why These Future Features Matter

The lab is demonstrating realistic developer mistakes or security-naive feature development.

For example, a future customer-details route might naturally do:

```sql
SELECT ...
FROM APPLAB.customers
WHERE customer_id = :customer_id
```

without also doing:

```sql
AND sales_rep = :current_user
```

That kind of missing application authorization check could expose data in an architecture that depends entirely on Flask authorization.

With Deep Data Security active, Oracle should independently constrain the data set.

The professional starter application must make this lesson possible.

---

# Optional Developer Documentation

Add or update a concise developer-facing README section explaining:

## Application Security Model

State clearly that:

> This workshop application intentionally contains no application-side customer row or sensitive-column authorization. The Flask application authenticates directly to Oracle Database as the end user. Oracle Deep Data Security determines which rows and columns that database identity can retrieve.

Also explain:

> This does not mean the application intentionally ignores normal secure-development practices. SQL injection prevention, CSRF protection, safe output rendering, credential handling, and session security remain important.

Document the one-worker Gunicorn reason as described above.

Do not expose these implementation details prominently in the student-facing application UI.

---

# Do Not Change the Database Policy Model

Unless you find a real bug required to make the existing application operate, do not modify the Deep Data Security scripts as part of this task.

In particular, preserve the expected sequence:

```text
HOL_DATAROLE_FULL_ACCESS
        |
        v
HOL_DATAROLE_SALES_EMPLOYEE
        |
        v
HOL_DATAROLE_SALES_EMPLOYEE + HOL_DATAROLE_SALES_MANAGER
```

The application polish should not require policy changes.

---

# Testing

Perform reasonable local/static tests that do not require credentials you do not have.

At minimum check:

* Python syntax/imports
* JavaScript syntax if practical
* templates
* startup configuration
* no accidental search implementation
* no new application authorization filters
* no password logging
* no hard-coded database passwords
* no SQL string interpolation involving user input
* dynamic database values no longer rendered through unsafe `innerHTML`
* existing scripts remain executable/valid
* no new heavy dependencies
* application still defaults to one Gunicorn worker

If a live database/wallet is available in the environment, also perform the integration checks below.

If it is not available, clearly state which checks require the live lab environment.

---

# Manual Lab Acceptance Tests

## Full Access

Sign in as Marvin.

Load Customer Accounts.

Expected:

```text
Rows Returned: 22
Apex Treasury: visible
Crown Capital: visible
Sensitive Identifier: visible
Active Data Role: HOL_DATAROLE_FULL_ACCESS
```

---

## Employee

Apply:

```sql
@../database/enable_employee_policy.sql
```

Sign out and sign back in as Marvin.

Load Customer Accounts.

Expected:

```text
Rows Returned: 14
Frontier Goods: visible
Acme East: unavailable
Apex Treasury: unavailable
Crown Capital: unavailable
Sensitive Identifier: Not authorized
Active Data Role: HOL_DATAROLE_SALES_EMPLOYEE
```

No Flask source-code change should occur.

---

## Manager

Apply:

```sql
@../database/promote_marvin_to_manager.sql
```

Sign out and sign back in.

Expected:

```text
Rows Returned: 20
Frontier Goods: visible
Acme East: visible
Apex Treasury: unavailable
Crown Capital: unavailable
Sensitive Identifier: Not authorized
```

Active roles should show the employee and manager data roles.

Again, no Flask source-code change should occur.

---

# Important Teaching Proof

After your modifications, a code review should make this obvious:

```text
Flask knows:
- Marvin authenticated successfully
- Oracle returned these rows
- Oracle reported these active data roles

Flask does NOT know:
- which sales representatives Marvin is allowed to access
- whether Finance customers are allowed
- whether SALES_TEAM customers are allowed
- whether a particular customer belongs to Marvin's authorization scope
```

Oracle Database owns those business-data authorization decisions.

---

# Packaging

This repository contains:

```text
package.sh
```

which packages:

```text
flask-app/
database/
```

into:

```text
dist/deep-data-security-flask-app.zip
```

and generates its SHA-256 file.

After all modifications and tests succeed, run the existing packaging script so the distribution ZIP reflects the updated professional starter application.

Do not package:

* `.env`
* wallet files
* credentials
* virtual environments
* generated secrets

Preserve the existing packaging safety checks.

Report the resulting package path and SHA-256.

---

# Keep the Scope Tight

Prefer small, understandable modifications to the existing code.

Do not:

* rewrite the application from scratch
* introduce React/Vue/etc.
* introduce a database ORM
* introduce Redis
* introduce a new authentication system
* change the database identity architecture
* implement search
* implement customer details
* implement CSV export
* implement application-side business authorization
* add unnecessary dependencies

This app needs to be both professional and easy for a coding agent to understand during a hands-on lab.

---

# Final Acceptance Criteria

The task is complete when all of the following are true:

* The existing Flask application remains the foundation.
* The application looks like a professional customer-sales application.
* The main business page is centered around Customer Accounts rather than "running an authorized query."
* Deep Data Security remains visible but secondary to the business UI.
* Marvin still authenticates directly to Oracle Database.
* Marvin's password remains server-side and in memory only.
* Thick-mode `oracledb` behavior is preserved.
* Wallet/TNS behavior is preserved.
* `deepsec_low` compatibility is preserved.
* Gunicorn defaults to one worker.
* No Flask customer row authorization exists.
* No Flask sensitive-column authorization exists.
* The customer SQL contains no business authorization predicate.
* Baseline should still produce 22 rows.
* Employee policy should still produce 3 rows.
* Manager policy should still produce 9 rows.
* Database end-user and active data roles remain visible.
* Rows Returned by Oracle remains visible.
* SQL sent to Oracle remains available through a less intrusive Lab Details area.
* Customer-table rendering no longer interpolates database values through unsafe `innerHTML`.
* Loading behavior is polished.
* Empty-result behavior is polished.
* Error handling remains safe.
* Sign-in UX is simplified for the single Marvin persona where practical.
* Search is NOT implemented.
* The code remains easy for Vibe to modify later.
* Existing setup/run/verification scripts continue to work.
* The distribution ZIP is rebuilt successfully.

---

# Final Response to Me

After making the changes, give me a concise implementation report containing:

1. **Files modified**
2. **What changed in each file**
3. **What you deliberately did NOT change**
4. **Exact customer SQL currently issued by the starter application**
5. **Confirmation that no Flask-side customer authorization exists**
6. **Confirmation that search has NOT been implemented**
7. **How dynamic database values are now rendered safely**
8. **How loading, empty, and error states work**
9. **How the Database Security Context is displayed**
10. **Why Gunicorn remains at one worker**
11. **Static/local tests you ran and their results**
12. **Any live database tests you were able to run**
13. **Tests that still require the actual lab ADB/wallet**
14. **Final package location and SHA-256**
15. **Any assumptions or issues I should know about**

Do not stop after giving me a plan. Inspect the existing code, make the changes, test them, package the result, and then provide the implementation report.
