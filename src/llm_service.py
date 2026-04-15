import os
from google import genai
from google.genai import types
import time
from metrics_store import metrics_data
from evaluation import semantic_similarity, factual_consistency

class LlamaService:
    """
    LLM Service using Google Gemini API (new google.genai SDK).
    Implements the core LLM calls described in Algorithm 1 of the paper:
      - identify_classes(): Zero-shot class identification (Line 5)
      - generate_response(): Final technical response generation (Line 15)
      - humanize_output(): NLP Narrative Layer for user-friendly reporting.
    """

    ONTOLOGY_CLASSES = [
        "Zone", "Conduit", "Asset", "Hardware", "Software", "Human",
        "EmbeddedDevice", "HostDevice", "NetworkDevice", "SoftwareApplication",
        "Sensor", "Actuator", "Machine", "Firewall", "Information",
        "Port", "CommunicationChannel", "Session", "Authenticator",
        "Account", "Role", "Permission", "ExternalEntity",
        "SystemSecurityRequirement", "RequirementEnhancement", "Rationale",
        "AffectedAsset"
    ]

    def __init__(self):
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise ValueError(
                "GEMINI_API_KEY not found. "
                "Please add it to your .env file as: GEMINI_API_KEY=your_key_here"
            )
        self.client = genai.Client(api_key=api_key)
        self.model = "gemini-3-flash-preview"

    def identify_classes(self, question: str) -> list:
        """Algorithm 1 - Line 5: Zero-shot class identification"""
        classes_list = ", ".join(self.ONTOLOGY_CLASSES)
        prompt = f"""You are an ICS security expert. Identify relevant ontology classes: {classes_list}
Return ONLY a comma-separated list.
User question: {question}"""

        response = self.client.models.generate_content(
            model=self.model,
            contents=prompt,
            config=types.GenerateContentConfig(temperature=0.0, 
                                               max_output_tokens=150)
        )
        
        raw_output = response.text.strip()
        identified = [cls.strip() for cls in raw_output.split(",") if cls.strip() in self.ONTOLOGY_CLASSES]
        return identified if identified else ["Zone", "Asset", "SystemSecurityRequirement"]

    def generate_response(self, final_prompt: str) -> str:
        """Algorithm 1 - Line 15: Final technical response generation + metrics"""

        system_instruction = """You are a security-by-design assistant for ICS.
    Answer based ONLY on the provided architecture and standard context.
    Be precise, technical, and structured. Do NOT hallucinate."""

        # ⏱ Start time
        start_time = time.time()

        response = self.client.models.generate_content(
            model=self.model,
            contents=final_prompt,
            config=types.GenerateContentConfig(
                system_instruction=system_instruction,
                temperature=0.2,
                max_output_tokens=1024,
            )
        )

        # ⏱ End time
        end_time = time.time()
        latency = end_time - start_time

        output_text = response.text.strip()

        # 🧠 Metrics Calculation (safe + silent)
        try:
            expected = final_prompt  # fallback baseline

            sem_score = semantic_similarity(expected, output_text)
            fact_score = factual_consistency(expected, output_text)

            # 📦 Store globally
            metrics_data["queries"].append(len(metrics_data["queries"]) + 1)
            metrics_data["semantic"].append(sem_score)
            metrics_data["factual"].append(fact_score)
            metrics_data["latency"].append(latency)

            # 🖥️ Backend logging ONLY
            print("\nMETRICS")
            print(f"Semantic Similarity: {sem_score:.2f}%")
            print(f"Factual Consistency: {fact_score:.2f}%")
            print(f"Latency: {latency:.2f}s")

        except Exception as e:
            print(f"[Metrics Error]: {e}")

        return output_text

    # ------------------------------------------------------------------
    # NEW: NLP Narrative Layer
    # ------------------------------------------------------------------
    def humanize_output(self, question: str, technical_data: str) -> str:
        """
        Converts detailed technical security analysis into a 
        user-friendly executive summary for non-technical stakeholders.
        """
        humanizer_prompt = f"""
        You are a friendly IT Security Consultant. 
        Transform the technical analysis below into a 'Human-Friendly' report.

        Instructions:
        1. Start with a 'Summary' (The Bottom Line).
        2. Use clear headings like 'What We Found' and 'Recommended Actions'.
        3. Explain technical issues (like "Missing Authentication") in plain English.
        4. Keep the specific names of assets (e.g. PLC_Controller_1).
        5. Avoid database terms like "triples", "nodes", or "relationships".

        Original Question: {question}
        Technical Data: {technical_data}

        Friendly Report:"""

        response = self.client.models.generate_content(
            model=self.model,
            contents=humanizer_prompt,
            config=types.GenerateContentConfig(temperature=0.3)
        )
        return response.text.strip()