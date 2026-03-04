from neo4j import GraphDatabase
from dotenv import load_dotenv
import os

load_dotenv()

uri = os.getenv("NEO4J_URI")
username = os.getenv("NEO4J_USER")
password = os.getenv("NEO4J_PASSWORD")

driver = GraphDatabase.driver(uri, auth=(username, password))

query = """
MATCH (h:Human)-[:HAS_ROLE]->(r:Role)-[:HAS_PERMISSION]->(p:Permission)
RETURN h.name AS human, r.name AS role, p.operation AS permission
"""

with driver.session() as session:
    result = session.run(query)

    print("\nHuman Access Permissions:\n")

    for record in result:
        print(record["human"], "->", record["permission"])

driver.close()