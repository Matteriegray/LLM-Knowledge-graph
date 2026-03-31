import os
from neo4j import GraphDatabase
from nl_transformer import NLTransformer
from ranker import CentralityRanker
from vector_db import SecurityStandardDB
from llm_service import LlamaService
from dotenv import load_dotenv

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
    relevant_classes = llm.identify_classes(question)
    raw_triples = get_neighborhood_triples(driver, relevant_classes)

    if not raw_triples:
        return "No relevant architectural data found in the knowledge graph."

    all_sentences = [
        transformer.transform_triple(t['subject'], t['predicate'], t['object'])
        for t in raw_triples
    ]

    final_sentences = ranker.filter_by_closeness(
        nl_sentences=all_sentences,
        raw_triples=raw_triples,
        max_tokens=3000
    )

    compliance_context = standard_db.similarity_search(question)

    final_prompt = f"""
    1- User Prompt: {question}

    2- Sentences (System Architecture):
    {final_sentences}

    3- Extra Context (IEC 62443-3-3 Standards):
    {compliance_context}

    Based on the architecture sentences and standard definitions provided above,
    verify the security requirement or answer the user's question with technical detail.
    """

    return llm.generate_response(final_prompt)


# ----------------------------
# Entry Point
# ----------------------------

def main():
    print("--- ICS Security-by-Design Automated Assistant ---")
    print("Type 'exit' to quit.")

    uri = os.getenv("NEO4J_URI", "bolt://localhost:7687")
    user = os.getenv("NEO4J_USER", "neo4j")
    password = os.getenv("NEO4J_PASSWORD", "plsbropls")

    try:
        driver = GraphDatabase.driver(uri, auth=(user, password))
        transformer = NLTransformer()
        ranker = CentralityRanker()
        standard_db = SecurityStandardDB()
        llm = LlamaService()
    except Exception as e:
        print(f"\nInitialization error: {e}")
        print("Please verify your environment variables and installed dependencies.")
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
                response = run_automated_pipeline(driver, transformer, ranker, standard_db, llm, question)
                print("\n[Analysis Results]:")
                print(response)
            except Exception as e:
                print(f"\nAn error occurred during processing: {e}")
    finally:
        driver.close()


if __name__ == "__main__":
    main()
