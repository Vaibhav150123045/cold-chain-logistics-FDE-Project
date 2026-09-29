import os
import urllib.parse
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

# Load environment variables from a .env file if present
load_dotenv()

db_host = os.getenv("SQL_SERVER_NAME", "localhost")
db_port = os.getenv("SQL_SERVER_PORT", "1433")
db_user = os.getenv("SQL_SERVER_USERNAME")
db_password = os.getenv("SQL_SERVER_PASSWORD")
db_name = os.getenv("SQL_SERVER_DATABASE", "free-sql-db-0184666")


def test_connection():
    print(
        f"Attempting to connect to Azure SQL Server at {db_host}:{db_port}...")

    # Construct connection string using your format
    connection_string = (
        f"DRIVER={{ODBC Driver 18 for SQL Server}};"
        f"SERVER=tcp:{db_host},{db_port};"
        f"DATABASE=free-sql-db-0184666;"
        f"UID={db_user};"
        f"PWD={db_password};"
        f"Encrypt=yes;"
        f"TrustServerCertificate=yes;"
        f"Connection Timeout=30;"
    )
    print(f"DEBUG -> DB_USER: '{db_user}'")
    print(
        f"DEBUG -> DB_PASSWORD loaded? {bool(db_password)} (Length: {len(db_password) if db_password else 0})")

    try:
        # URL-encode parameters for SQLAlchemy
        params = urllib.parse.quote_plus(connection_string)
        engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

        # Test the connection by executing a lightweight query
        with engine.connect() as connection:
            result = connection.execute(text("SELECT @@VERSION;"))
            version = result.scalar()

            print("\nSUCCESS: Connected to Azure SQL Database successfully!")
            print(f"Database Server Version: {version.splitlines()[0]}")

    except Exception as e:
        print("\nFAILURE: Could not connect to the database.")
        print(f"Error Details:\n{e}")


if __name__ == "__main__":
    test_connection()
