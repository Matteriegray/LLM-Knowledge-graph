import os
from neo4j import GraphDatabase
from nl_transformer import NLTransformer
from ranker import CentralityRanker
from vector_db import SecurityStandardDB
from llm_service import LlamaService
from dotenv import load_dotenv
from plot_metrics import plot_metrics

# Load environment variables at the very beginning
load_dotenv()

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
            query = f"""
            MATCH (n:{cls})-[r]-(m)
            RETURN n.name as subject, type(r) as predicate, m.name as object
            LIMIT 50
            """
            result = session.run(query)
            triples.extend([record.data() for record in result])
    return triples


# ----------------------------
# Main Automated Pipeline
# ----------------------------

def run_automated_pipeline(driver, transformer, ranker, standard_db, llm, question):
    """
    Orchestrates the Knowledge Graph-augmented LLM framework.
    """
    # STEP 1: Concept Retrieval (Algorithm 1, Line 5)
    relevant_classes = llm.identify_classes(question)
    
    # STEP 2: Neighborhood Retrieval (Algorithm 1, Lines 7-10)
    raw_triples = get_neighborhood_triples(driver, relevant_classes)

    if not raw_triples:
        return "No relevant architectural data found in the knowledge graph."

    # STEP 3: Information Encoding (Algorithm 1, Line 11)
    all_sentences = [
        transformer.transform_triple(t['subject'], t['predicate'], t['object'])
        for t in raw_triples
    ]

    # STEP 4: Token Management / Centrality (Algorithm 1, Line 14)
    final_sentences = ranker.filter_by_closeness(
        nl_sentences=all_sentences,
        raw_triples=raw_triples,
        max_tokens=3000
    )

    # STEP 5: Standard Compliance Context (Algorithm 1, Line 12)
    compliance_context = standard_db.similarity_search(question)

    # STEP 6: Final Augmented Prompt Construction (Algorithm 1, Line 13)
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
    # Get the raw technical analysis first
    technical_analysis = llm.generate_response(final_prompt)
    
    # STEP 8: NLP Narrative Layer (Humanizer)
    # Refine the technical data into a user-friendly report
    print("[Info] Refining technical analysis into a user-friendly report...")
    friendly_report = llm.humanize_output(question, technical_analysis)
    
    return friendly_report


# ----------------------------
# Entry Point
# ----------------------------

def main():
    print("--- ICS Security-by-Design Automated Assistant ---")
    print("Type 'exit' to quit.")

    # Fetch configuration from environment
    uri = os.getenv("NEO4J_URI", "bolt://localhost:7687")
    user = os.getenv("NEO4J_USER", "neo4j")
    password = os.getenv("NEO4J_PASSWORD", "plsbropls")

    # Initialize core services once
    try:
        driver = GraphDatabase.driver(uri, auth=(user, password))
        transformer = NLTransformer()
        ranker = CentralityRanker()
        standard_db = SecurityStandardDB()
        llm = LlamaService()
        print("[Info] All services initialized successfully.\n")
    except Exception as e:
        print(f"\nInitialization error: {e}")
        print("Please verify your environment variables (.env) and installed dependencies.")
        return

    try:
        while True:
            question = input("\nEnter your security query: ").strip()
            if question.lower() == "exit":
                break

            if not question:
                continue

            try:
                print("\nProcessing and analyzing graph context...")
                # Run the pipeline and get the humanized output
                response = run_automated_pipeline(driver, transformer, ranker, standard_db, llm, question)
                
                print("\n" + "="*50)
                print("[Analysis Results]")
                print("="*50)
                print(response)
                print("="*50)
                
            except Exception as e:
                print(f"\nAn error occurred during processing: {e}")
    finally:
        # Ensure driver is closed properly on exit
        driver.close()
        print("\n[Info] Database connection closed. Have a nice day!")


if __name__ == "__main__":
    main()
    plot_metrics()