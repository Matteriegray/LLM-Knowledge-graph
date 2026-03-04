from neo4j import GraphDatabase
from dotenv import load_dotenv
import os

load_dotenv()

uri = os.getenv("NEO4J_URI")
username = os.getenv("NEO4J_USER")
password = os.getenv("NEO4J_PASSWORD")

driver = GraphDatabase.driver(uri, auth=(username, password))

query = """
MATCH (r:Requirement)-[:APPLIES_TO]->(a:Asset)
RETURN r.name AS requirement, a.name AS asset
"""

with driver.session() as session:
    result = session.run(query)

    print("\nSecurity Requirements Affecting Assets:\n")

    for record in result:
        print(record["requirement"], "->", record["asset"])

driver.close()