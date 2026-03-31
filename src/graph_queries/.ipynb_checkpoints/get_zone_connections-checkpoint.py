from neo4j import GraphDatabase
from dotenv import load_dotenv
import os

load_dotenv()

uri = os.getenv("NEO4J_URI")
username = os.getenv("NEO4J_USER")
password = os.getenv("NEO4J_PASSWORD")

driver = GraphDatabase.driver(uri, auth=(username, password))

query = """
MATCH (z1:Zone)-[:CONNECTS_TO]->(z2:Zone)
RETURN z1.name AS from_zone, z2.name AS to_zone
"""

with driver.session() as session:
    result = session.run(query)

    print("\nZone Connections:\n")

    for record in result:
        print(record["from_zone"], "->", record["to_zone"])

driver.close()