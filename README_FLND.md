# "Freelandia" Demonstration Setup
The following outlines the steps to instantiate a short demonstration showcasing the latest AI-related features of Oracle RDBMS 23ai. The scenario involves the secure querying, including via a conversational interface, of diplomatic communication between the postings of a fictional country ("Freelandia"). The demo uses AI Vector Search and a number of internal PL/SQL packages inside the database to build a RAG pipeline prior to calling out to an external LLM. Label Security is used to enforce access control (row-by-row) on the content that the end-user has access to. This content is provided as context (along with the end-users query) to the external LLM, in order to generate a (hopefully coherent) response.

Standard keyword search (of the same content - but similarly protected by Label Security) is also provided - via Oracle Text. Oracle Database Vault is set up to preclude DBA access to the content, as well as to prevent end-users connecting directly to the database. You will require a 23ai instance with access to the O/S. Note that a new PDB is instantiated as part of the setup.

A viewlet of the demonstration is available [here](https://oradocs.oracle.com/documents/fileview/D7D1774E977684DA23DD8C552F83555D5DF33A10B208/_SecureAIPlatform_Video2_VoiceoverOnly_8m_INTERNAL_ONLY.mkv). A schematic of the solution is shown [here](https://oradocs.oracle.com/documents/fileview/DA556EDBAB0D84D4064F32B6398CD236E7BF7142A822/_SolutionSchematic.pptx). 

These setup steps have been tested on the docker/free release of 23ai, but should work in any environment where you have access to the O/S.

Please send any questions to chris.pickett@oracle.com.

## Initial
- Copy and unzip the provided FLND.zip file to some directory ($DIRTOP) on the Oracle 23ai DB server.
- Ensure that the listener.ora file for your 23ai environment has a **static** entry for the CDB. As the setup process involves shutting down/starting up the CDB, this process will fail without a static entry for the CDB in your listener.ora file.
- Edit the parameters.sql file in the $DIRTOP/SQL directory. There is a section at the top where you **must** make changes to certain mandatory parameters, including the location of your Ollama server and the model you wish to use for LLM integration. Parameters in this file marked as optional do not require changing.

## Pluggable Database Creation
- Ensure your environment is setup as follows (ie create and run the following script as the oracle user):

    <span style="font-family:Courier">
        #!/bin/sh<br>
        export ORAENV_ASK=NO<br>
        export ORACLE_SID={SID of your CDB}<br>
        . /usr/local/bin/oraenv<br>
        export ORAENV_ASK=YES<br>
        export PATH=$PATH:$ORACLE_HOME/sqlcl/bin
    </span>  
<br>

- Navigate to $DIRTOP/SQL 

- Now execute the following:

    <span style="font-family:Courier">
        $ sql /nolog<br>
        > @create_pdb
    </span>
<br>

- Check the create_pdb.lst file - if all has gone well, the end should look like:

    <span style="font-family:Courier">
        SQL> SELECT * FROM DBA_DV_STATUS;

        NAME                   STATUS            
        ______________________ _________________ 
        DV_CONFIGURE_STATUS    TRUE              
        DV_ENABLE_STATUS       TRUE              
        DV_APP_PROTECTION      NOT CONFIGURED    

        SQL> SELECT * FROM DBA_OLS_STATUS;

        NAME                    STATUS    DESCRIPTION                        
        _______________________ _________ __________________________________ 
        OLS_CONFIGURE_STATUS    TRUE      Determines if OLS is configured    
        OLS_ENABLE_STATUS       TRUE      Determines if OLS is enabled       
    </span>

## Schema Creation
- From the same directory as above (i.e. $DIRTOP/SQL), execute the following:

    <span style="font-family:Courier">
        $ sql /nolog<br>
        > @create_all
    </span>
<br>

- Check the create_all.lst file for any errors. Some errors may be due to attempts to drop non-existent objects. These can be ignored.
- Use the testing.sql file in the $DIRTOP/SQL directory to test asking questions and receiving answers from the LLM.

## Python (Streamlit) Setup
- Coming

## TODO
- Text/AI:        Load all the attachments (specific to each cable) into attachment table
- Unified Index:  Unify Oracle Text and vector indices (requires 23.6)
- DBV:            DB Vault connect rules to create MAC-realm around tables, and CONNECT rules (disallow) for end-users not connecting through Python app
- AVDF:           Unified audit rules for SELECTs on chunk table and invocations of response function - capture user's NL query and (potentially) use vector search (somewhere?) to detect early IoC based on a user's "strange" question...
- Spatial:        Geo-coding of missions (postings), to allow spatially-based analysis of trends
- JSON:           Actual use of JSON/Relational duality (not currently possible due to validation-related error on ingestion) rather than current approach of loading JSON document into a JSON column followed by manual shredding into separate tables. This is why I have kept the approach of loading (synthetically-generated) JSON documents (in the $DIRTOP/JSON directory) when loading the data, as the intent is to move eventually to a duality-based approach.
- Access Ctrl:    Higher-level analysis/summary available to analysts *without* them having access to lower-level data (common use case in Justice & Public Safety domains)
- Low-code UIs:   APEX and VisualBuilder/JET, in addition to Python
- Autonomous:     Equivalent setup scripts for ADB