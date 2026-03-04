from neo4j import GraphDatabase
from dotenv import load_dotenv
import os

load_dotenv()

uri = os.getenv("NEO4J_URI")
username = os.getenv("NEO4J_USER")
password = os.getenv("NEO4J_PASSWORD")

driver = GraphDatabase.driver(uri, auth=(username, password))

query = """
MATCH (r:Role)-[:HAS_PERMISSION]->(p:Permission)
RETURN r.name AS role, p.operation AS permission
"""

with driver.session() as session:
    result = session.run(query)

    print("\nRole Permissions:\n")

    for record in result:
        print(record["role"], "->", record["permission"])

driver.close()