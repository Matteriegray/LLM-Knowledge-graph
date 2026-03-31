import os
import numpy as np
from google import genai
 
class SecurityStandardDB:
    """
    Vector database for IEC 62443-3-3 security requirements.
    Uses Gemini embeddings to find the most relevant standard definitions
    for a given user query. Corresponds to Algorithm 1, Line 12 of the paper.
    """
 
    def __init__(self):
        # gemini-embedding-001 is the correct available embedding model
        self.embedding_model = "gemini-embedding-001"
 
        # IEC 62443-3-3 requirements — the compliance context from the paper
        self.requirements = [
            {
                "id": "SR 1.1",
                "text": "Human user identification and authentication: All human users must be uniquely identified and authenticated on all interfaces of the control system."
            },
            {
                "id": "SR 1.2",
                "text": "Software process and device identification and authentication: All software processes and devices must be identified and authenticated before establishing a connection."
            },
            {
                "id": "SR 1.3",
                "text": "Account management: The system shall provide the capability to manage accounts including creating, activating, modifying, disabling, and removing accounts."
            },
            {
                "id": "SR 2.1",
                "text": "Authorization enforcement: The system shall enforce authorizations assigned to all human users to control use of the system."
            },
            {
                "id": "SR 3.2",
                "text": "Malicious code protection: The system shall provide protection mechanisms and detection capabilities to protect against malicious code."
            },
            {
                "id": "SR 3.3",
                "text": "Security functionality verification: The system shall provide the capability to support verification of the intended operation of security functions."
            },
            {
                "id": "SR 5.1",
                "text": "Network segmentation: The system shall provide the capability to segment the control system into zones and conduits based on criticality."
            },
            {
                "id": "SR 5.2",
                "text": "Zone boundary protection: The system shall provide the capability to monitor and control all communications at zone boundaries to enforce the compartmentalization of zones."
            },
            {
                "id": "SR 5.3",
                "text": "General purpose person-to-person communication restrictions: The system shall provide the capability to restrict general purpose person-to-person communications."
            },
            {
                "id": "SR 7.6",
                "text": "Network and security configuration settings: The system shall provide the capability to report current security settings and any changes to those settings."
            },
            {
                "id": "SR 7.7",
                "text": "Least functionality: The system shall provide the capability to specifically restrict the use of unnecessary functions, ports, protocols, and services."
            },
        ]
 
        self.api_key = os.getenv("GEMINI_API_KEY")
        self.corpus_embeddings = None
        self.embedding_ready = False
 
        if self.api_key:
            try:
                self.client = genai.Client(api_key=self.api_key)
                print("[Info] Building IEC 62443-3-3 embeddings...")
                self.corpus_embeddings = [
                    self.client.models.embed_content(
                        model=self.embedding_model,
                        contents=req["text"]
                    ).embeddings[0].values
                    for req in self.requirements
                ]
                self.embedding_ready = True
                print("[Info] Embeddings ready.")
            except Exception as e:
                print(f"[Warning] Could not build embeddings: {e}")
                print("[Info] Falling back to keyword search.")
                self.embedding_ready = False
        else:
            print("[Info] GEMINI_API_KEY not set. Using keyword search for IEC 62443 context.")
 
    def similarity_search(self, question: str, top_k: int = 2) -> str:
        """
        Finds the most relevant IEC 62443-3-3 requirements for the given question.
        Uses embedding similarity if available, otherwise falls back to keyword matching.
        Returns a formatted string of matching requirements.
        """
        if self.embedding_ready:
            try:
                query_embedding = self.client.models.embed_content(
                    model=self.embedding_model,
                    contents=question
                ).embeddings[0].values
 
                # Cosine similarity scores
                scores = [
                    np.dot(query_embedding, corpus_emb) /
                    (np.linalg.norm(query_embedding) * np.linalg.norm(corpus_emb))
                    for corpus_emb in self.corpus_embeddings
                ]
 
                # Get top_k matches
                top_indices = sorted(range(len(scores)), key=lambda i: scores[i], reverse=True)[:top_k]
                results = [
                    f"[{self.requirements[i]['id']}] {self.requirements[i]['text']}"
                    for i in top_indices
                ]
                return "\n".join(results)
 
            except Exception as e:
                print(f"[Warning] Embedding search failed: {e}. Falling back to keyword matching.")
 
        return self._keyword_search(question)
 
    def _keyword_search(self, question: str) -> str:
        """
        Simple keyword fallback when embeddings are unavailable.
        """
        query = question.lower()
        scored = [
            (req, sum(query.count(token) for token in req["text"].lower().split()))
            for req in self.requirements
        ]
        scored.sort(key=lambda x: x[1], reverse=True)
        best = scored[0][0]
        return f"[{best['id']}] {best['text']}"