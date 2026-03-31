import os
from neo4j import GraphDatabase
from nl_transformer import NLTransformer
from ranker import CentralityRanker
# Note: You will need to implement/stub these for the script to run
from vector_db import SecurityStandardDB 
from llm_service import LlamaService
from dotenv import load_dotenv
load_dotenv()

# ----------------------------
# Initialization
# ----------------------------
uri = os.getenv("NEO4J_URI", "bolt://localhost:7687")
user = os.getenv("NEO4J_USER", "neo4j")
password = os.getenv("NEO4J_PASSWORD", "plsbropls")
driver = GraphDatabase.driver(uri, auth=(user, password))

transformer = NLTransformer()
ranker = CentralityRanker()
standard_db = SecurityStandardDB() 
llm = LlamaService()

# ----------------------------
# Helper: Neighborhood Retrieval
# ----------------------------
def get_neighborhood_triples(driver, relevant_classes):
    """
    Algorithm 1, Steps 7-10: Identifies instances and retrieves 
    their adjacent instances (neighborhood) from the graph.
    """
    triples = []
    with driver.session() as session:
        for cls in relevant_classes:
            # Retrieves the node and its direct neighbors to provide context
            query = f"""
            MATCH (n:{cls})-[r]-(m) 
            RETURN n.name as subject, type(r) as predicate, m.name as object 
            LIMIT 25
            """
            result = session.run(query)
            triples.extend([record.data() for record in result])
    return triples

# ----------------------------
# Main Automated Pipeline
# ----------------------------
def run_automated_pipeline(question):
    """
    Orchestrates the Knowledge Graph-augmented LLM framework.
    """
    # STEP 1: Concept Retrieval (Algorithm 1, Line 5)
    # Uses Zero-shot prompting to identify relevant ontology classes
    relevant_classes = llm.identify_classes(question)

    # STEP 2: Information Retrieval & Neighborhoods (Algorithm 1, Lines 7-10)
    raw_triples = get_neighborhood_triples(driver, relevant_classes)

    if not raw_triples:
        return "No relevant architectural data found in the knowledge graph."

    # STEP 3: Information Encoding (Algorithm 1, Line 11)
    # Convert raw triples into a list of Natural Language sentences
    all_sentences = [
        transformer.transform_triple(t['subject'], t['predicate'], t['object']) 
        for t in raw_triples
    ]

    # STEP 4: Token Management / Centrality (Algorithm 1, Line 14)
    # Prioritizes 'central' nodes to fit within the LLM's 4,096 token limit
    final_sentences = ranker.filter_by_closeness(
        nl_sentences=all_sentences, 
        raw_triples=raw_triples, 
        max_tokens=3000
    )

    # STEP 5: Standard Compliance Context (Algorithm 1, Line 12)
    # Similarity search in Vector DB for IEC 62443-3-3 definitions
    compliance_context = standard_db.similarity_search(question)

    # STEP 6: Final Augmented Prompt (Algorithm 1, Line 13)
    # Constructs the self-contained prompt shown in Figure 9 of the paper
    final_prompt = f"""
    1- User Prompt: {question}
    
    2- Sentences (System Architecture):
    {final_sentences}
    
    3- Extra Context (IEC 62443-3-3 Standards):
    {compliance_context}
    
    Based on the architecture sentences and standard definitions provided above, 
    verify the security requirement or answer the user's question with technical detail.
    """
    
    # STEP 7: LLM Inference (Algorithm 1, Line 15)
    return llm.generate_response(final_prompt)

# ----------------------------
# Entry Point
# ----------------------------
def main():
    print("--- ICS Security-by-Design Automated Assistant ---")
    print("Type 'exit' to quit.")
    
    while True:
        question = input("\nEnter your security query: ").strip()
        if question.lower() == "exit":
            break
        
        if not question:
            continue

        try:
            print("\nProcessing and analyzing graph context...")
            response = run_automated_pipeline(question)
            print("\n[Analysis Results]:")
            print(response)
        except Exception as e:
            print(f"\nAn error occurred during processing: {e}")

if __name__ == "__main__":
    main()