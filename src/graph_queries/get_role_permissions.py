# graph_queries/get_role_permissions.py
from neo4j import GraphDatabase

def run(driver):
    query = """
    MATCH (r:Role)-[:HAS_PERMISSION]->(p:Permission)-[:ACCESS_TO]->(a:Asset)
    RETURN r.name AS role, p.operation AS permission, a.name AS asset
    """
    
    with driver.session() as session:
        result = session.run(query)
        # Convert Neo4j records to a list of dicts
        return [record.data() for record in result]