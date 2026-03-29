# graph_queries/get_control_by_asset.py
from neo4j import GraphDatabase
import os

uri = os.getenv("NEO4J_URI", "bolt://localhost:7687")
username = os.getenv("NEO4J_USER", "neo4j")
password = os.getenv("NEO4J_PASSWORD", "password")

driver = GraphDatabase.driver(uri, auth=(username, password))

def run(entities):
    asset_name = entities.get("asset")
    if not asset_name:
        print("No asset provided.")
        return

    query = f"""
    MATCH (r:Role)-[:HAS_PERMISSION]->(p:Permission)-[:ACCESS_TO]->(a:Asset)
    WHERE p.operation = "Control" AND a.name = "{asset_name}"
    RETURN r.name AS role
    """

    with driver.session() as session:
        result = session.run(query)
        roles = [record["role"] for record in result]

    if roles:
        print(f"Roles that can control {asset_name}: {', '.join(roles)}")
    else:
        print(f"No roles have Control permission on {asset_name}")