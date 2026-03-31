from neo4j import GraphDatabase
from dotenv import load_dotenv
import os

# load environment variables
load_dotenv()

# read Neo4j credentials
uri = os.getenv("NEO4J_URI")
username = os.getenv("NEO4J_USER")
password = os.getenv("NEO4J_PASSWORD")

# connect to Neo4j
driver = GraphDatabase.driver(uri, auth=(username, password))

# zone we want to check
zone_name = "Control Network"

# cypher query
query = """
MATCH (a:Asset)-[:IN_ZONE]->(z:Zone {name:$zone})
RETURN a.name AS asset
"""

# run query
with driver.session() as session:
    result = session.run(query, zone=zone_name)

    print(f"\nAssets in zone: {zone_name}\n")

    for record in result:
        print("-", record["asset"])

driver.close()