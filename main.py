# main.py
from neo4j import GraphDatabase

# ----------------------------
# Neo4j connection
# ----------------------------
uri = "bolt://localhost:7687"
user = "neo4j"
password = "plsbropls"  # <-- replace with your Neo4j password
driver = GraphDatabase.driver(uri, auth=(user, password))

# ----------------------------
# Question to Cypher translator
# ----------------------------
def parse_question_to_query(question):
    """
    Parses questions like:
    - Who can control Robot Arm 1?
    - Who can monitor SCADA Server?
    - Who can update firmware on PLC Controller 1?
    Returns a Cypher query string or None.
    """
    question = question.lower()
    
    # List of known operations (must match Permission nodes)
    operations_map = {
        "control": "Control",
        "monitor": "Monitor",
        "configure": "Configure",
        "maintain": "Maintain",
        "update firmware": "UpdateFirmware",
        "remote access": "RemoteAccess",
        "read logs": "ReadLogs"
    }
    
    for key, op in operations_map.items():
        if key in question:
            # Extract asset name from question
            asset_name = question.split(key)[-1].strip(" ?")
            # Capitalize each word to match Neo4j data
            asset_name = " ".join([w.capitalize() for w in asset_name.split()])
            
            # Build Cypher query
            query = f"""
            MATCH (h:Human)-[:HAS_ROLE]->(r:Role)-[:HAS_PERMISSION]->(p:Permission)-[:ACCESS_TO]->(a:Asset)
            WHERE a.name = "{asset_name}" AND p.operation = "{op}"
            RETURN h.name AS Human, r.name AS Role
            """
            return query
    return None

# ----------------------------
# Main loop
# ----------------------------
def main():
    print("Ask your question (or type 'exit' to quit):")
    
    while True:
        question = input("> ").strip()
        if question.lower() == "exit":
            break
        
        cypher_query = parse_question_to_query(question)
        if not cypher_query:
            print("Sorry, I couldn't understand your question.")
            continue
        
        try:
            with driver.session() as session:
                result = session.run(cypher_query)
                humans = [f"{record['Human']} ({record['Role']})" for record in result]
            
            if humans:
                print("Answer:")
                for h in humans:
                    print(f"- {h}")
            else:
                print("No humans found for this permission and asset.")
        except Exception as e:
            print("Error querying database:", e)

if __name__ == "__main__":
    main()