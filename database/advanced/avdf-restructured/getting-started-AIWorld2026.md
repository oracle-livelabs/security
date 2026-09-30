# Access Security Central console
## Task 1: Access Security Central console
Before accessing Security Central, retrieve the initial credentials and URLs from the LiveLabs environment.
1. In the LiveLabs console, open **Lab Info** and expand **Terraform Outputs**.
   Copy or note the following values:
   - **AVS Passphrase** — the initial password for the `AVADMIN` and `AVAUDITOR` users.
   - **HOL Host 2** — the Security Central console URL.
   - **Remote Desktop** — the remote desktop URL, if you are using the provided desktop environment.
   ![LiveLabs Lab Info showing Terraform Outputs](images/lab-info-redacted.svg)
   > The values are generated for each reservation and may be different from the example shown.
2. In a browser, open the **HOL Host 2** link from the LiveLabs **Lab Info** panel.
3. Log in to the Security Central console as `AVADMIN` using the **AVS Passphrase**.
   ![Log in as AVADMIN](images/avdf-400.png)
4. Reset the `AVADMIN` password.
   - Set a new password.
   - Click **Submit**.
   - Save the new password for later use.
   ![Reset the AVADMIN password](images/avdf-401.png)
5. Log in to the Security Central console as `AVAUDITOR` using the original **AVS Passphrase** from the LiveLabs **Lab Info** panel.
   ![Log in as AVAUDITOR](images/avdf-300.png)
6. Reset the `AVAUDITOR` password.
   - Set a new password.
   - Click **Submit**.
   - Save the new password for later use.
   ![Reset the AVAUDITOR password](images/avdf-301.png)
## Task 2: Check access to the GlassFish application
Verify that the GlassFish application is available and connected to the expected Oracle AI Database PDB.
1. Open the GlassFish application in a browser:
   `http://dbsec-lab:8080/hr_prod_pdb1`
   If you are not using the remote desktop session, use the corresponding public application URL provided with your environment.
2. Log in using:
   - **Username:** `hradmin`
   - **Password:** `Oracle123`
3. Confirm that the application displays **Welcome HR Administrator**.
4. Open **Session Details**.
5. Verify the database connection details:
   - **DB_NAME:** `FREEPDB1`
   - **HOST:** `dbsec-lab`
You are now ready to continue to **Assess and Discover**.
