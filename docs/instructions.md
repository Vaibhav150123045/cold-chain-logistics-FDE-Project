# Phase 1
# Ingesting data

- Download the dataset from 'data/source/data.txt'
- Create a Azure SQL database (capture the connection strings and details)

To run MSSQL server as a docker container in local: 
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=your_password" -p 1433:1433 --name cold-storage-logistics-mysql -d mcr.microsoft.com/mssql/server:2022-latest

- install libraries using pip install requirements.txt

- python scripts/ingest_legacy_data.py

- Install MSSQL extension and connect to your database over there
- Keep your connection string ready 
Data Source=cold-storage-logistics-mysql.database.windows.net,1433;Initial Catalog=free-sql-db-0184666;Pooling=False;Connect Timeout=30;Encrypt=True;Trust Server Certificate=True;Application Name=vscode-mssql;Connect Retry Count=1;Connect Retry Interval=10;Command Timeout=30

- The client SOPs (standard operating procedures) are provided in data/policy/Cold_Chain_Incident_SOP_v2.md

- Initial brainstorming or design discussion is present in docs/Design & Requirements

- Creation of HLD & LLD

- Create pinecone and deepseek account and paste the API keys to consume thoses services.
- Paste these API keys in .env
- Run the scripts/ingest_sop_pinecone.py file


# Phase 2

# Phase 2

## Data Security

- Click on file : scripts\setup_security_and_view.sql
- VS-code will show you Start button directly on top else run like we were running the commands previously.
- Once done, create a new connection now with Agent-Profile
```
* Profile Name: agent-fde-ro
* Connection Group: Leave it on <Default>
* Input type: Select Parameters (Do not click "Load from Connection String", "Browse Azure", or "Browse Fabric")
* Server name*: localhost
* Port: 1433
* Trust server certificate: 🟩 Check this box / Turn it ON
* Authentication type*: SQL Login
* User name*: USR_FDE_RO
* Password*: AgentPassword2026!
* Save Password: 🟩 Check this box / Turn it ON
* Database name: Type master (or click "Select a database" and select master)
* Encrypt: Change this from Mandatory to Optional (or False)
```

Connect and test below commands :
```
-- TEST 1: This SHOULD work perfectly (Access to clean view)
SELECT TOP 5 * FROM FDE_VIEWS.VW_ACTIVE_FLEET;

-- TEST 2: This SHOULD fail instantly (Access to raw legacy table is DENIED)
SELECT TOP 5 * FROM dbo.TBL_SC_FLEET_HIST_RAW;