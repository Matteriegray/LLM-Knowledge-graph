from neo4j import GraphDatabase
from dotenv import load_dotenv
import os

load_dotenv()

uri = os.getenv("NEO4J_URI")
username = os.getenv("NEO4J_USER")
password = os.getenv("NEO4J_PASSWORD")

driver = GraphDatabase.driver(uri, auth=(username, password))

query = """
MATCH (a:Asset)
WHERE NOT (a)-[:REQUIRES_AUTH]->(:Authenticator)
RETURN a.name AS asset
"""

with driver.session() as session:
    result = session.run(query)

    print("\nAssets Missing Authentication:\n")

    for record in result:
        print("-", record["asset"])

driver.close()