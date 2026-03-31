import os
from google import genai
from google.genai import types

class LlamaService:
    """
    LLM Service using Google Gemini API (new google.genai SDK).
    Implements the two core LLM calls described in Algorithm 1 of the paper:
      - identify_classes(): Zero-shot prompting to find relevant ontology classes (Line 5)
      - generate_response(): Final answer generation from augmented prompt (Line 15)
    """

    # Ontology classes from Figure 2 of the paper
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
                "Please add it to your .env file as: GEMINI_API_KEY=your_key_here\n"
                "Get a free key at: https://aistudio.google.com/app/apikey"
            )
        self.client = genai.Client(api_key=api_key)
        self.model = "gemini-3-flash-preview"

    # ------------------------------------------------------------------
    # Algorithm 1 - Line 5: Zero-shot class identification
    # ------------------------------------------------------------------
    def identify_classes(self, question: str) -> list:
        """
        Uses zero-shot prompting to identify which ontology classes from
        Figure 2 of the paper are most relevant to the user's question.
        Returns a list of class name strings (e.g. ["Zone", "Firewall"]).
        """
        classes_list = ", ".join(self.ONTOLOGY_CLASSES)

        prompt = f"""You are an ICS (Industrial Control System) security expert working with an ontology based on IEC 62443.

The ontology contains these classes:
{classes_list}

Given the following user question, identify which ontology classes are most relevant 
for retrieving information to answer it.

Return ONLY a comma-separated list of class names from the list above.
No explanations, no extra text, no punctuation — just the class names separated by commas.

User question: {question}

Relevant classes:"""

        response = self.client.models.generate_content(
            model=self.model,
            contents=prompt,
            config=types.GenerateContentConfig(
                temperature=0.0,
                max_output_tokens=150,
            )
        )

        raw_output = response.text.strip()

        # Parse and validate against known ontology classes
        identified = [
            cls.strip()
            for cls in raw_output.split(",")
            if cls.strip() in self.ONTOLOGY_CLASSES
        ]

        # Fallback: if nothing valid comes back, use safe defaults
        if not identified:
            print(f"[Warning] Could not identify classes from: '{raw_output}'. Using defaults.")
            identified = ["Zone", "Asset", "SystemSecurityRequirement"]

        print(f"[Debug] Identified classes: {identified}")
        return identified

    # ------------------------------------------------------------------
    # Algorithm 1 - Line 15: Final response generation
    # ------------------------------------------------------------------
    def generate_response(self, final_prompt: str) -> str:
        """
        Takes the fully augmented prompt (user question + graph sentences +
        IEC 62443 context) and generates a detailed security analysis response.
        This corresponds to Algorithm 1, Line 15 of the paper.
        """
        system_instruction = """You are a security-by-design assistant for Industrial Control Systems (ICS).

You have been given:
1. A user's security question
2. Sentences describing the system architecture retrieved from a knowledge graph
3. Relevant terms and definitions from the IEC 62443-3-3 security standard

Your job:
- Answer the question based ONLY on the provided architecture and standard context
- Be precise, technical, and structured in your response
- If you reference a specific asset, zone, firewall, or requirement — name it explicitly
- If the provided context is insufficient to fully answer, say so clearly
- Do NOT guess or hallucinate information that is not in the context"""

        response = self.client.models.generate_content(
            model=self.model,
            contents=final_prompt,
            config=types.GenerateContentConfig(
                system_instruction=system_instruction,
                temperature=0.2,
                max_output_tokens=1024,
            )
        )

        return response.text.strip()