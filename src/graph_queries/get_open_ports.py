from neo4j import GraphDatabase
from dotenv import load_dotenv
import os

load_dotenv()

uri = os.getenv("NEO4J_URI")
username = os.getenv("NEO4J_USER")
password = os.getenv("NEO4J_PASSWORD")

driver = GraphDatabase.driver(uri, auth=(username, password))

query = """
MATCH (a:Asset)-[:USES_PORT]->(p:Port)
RETURN a.name AS asset, p.number AS port, p.protocol AS protocol
"""

with driver.session() as session:
    result = session.run(query)

    print("\nAssets and Open Ports:\n")

    for record in result:
        print(record["asset"], "-> Port", record["port"], record["protocol"])

driver.close()