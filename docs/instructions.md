# Ingesting data

- Download the dataset from 'data/source/data.txt'
- Create a Azure SQL database (capture the connection strings and details)

To run MSSQL server as a docker container in local: 
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=your_password" -p 1433:1433 --name cold-storage-logistics-mysql -d mcr.microsoft.com/mssql/server:2022-latest

- install 