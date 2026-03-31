# executor.py
from neo4j import GraphDatabase

class GraphExecutor:
    def __init__(self, driver):
        self.driver = driver

    def run_query(self, query, parameters=None):
        """
        Executes a Cypher query and returns results in a standardized 
        Triple format (Subject, Predicate, Object).
        [cite: 171-174]
        """
        with self.driver.session() as session:
            result = session.run(query, parameters or {})
            
            # Standardizing output for the NLTransformer
            triples = []
            for record in result:
                # This format supports the 'n', 'rel', 'm' structure 
                # used in neighborhood retrieval 
                triples.append({
                    "subject": record.get("n", {}).get("name") or record.get("subject"),
                    "predicate": record.get("rel") or record.get("predicate"),
                    "object": record.get("m", {}).get("name") or record.get("object")
                })
            return triples

    def get_neighborhood(self, concept_name):
        """
        Implements Step 8-9 of Algorithm 1: Identify and retrieve 
        adjacent instances in the ontology.
        
        """
        # Cypher query to find a node and all its direct relationships
        query = """
        MATCH (n {name: $name})-[r]-(m)
        RETURN n.name AS subject, type(r) AS predicate, m.name AS object
        """
        return self.run_query(query, {"name": concept_name})