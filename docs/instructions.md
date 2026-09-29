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

- Created pinecone and deepseek account and paste the API keys to consume thoses services.

