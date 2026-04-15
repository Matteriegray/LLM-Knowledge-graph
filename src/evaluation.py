# evaluation.py

from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import re

# Load once (important for performance)
model = SentenceTransformer('all-MiniLM-L6-v2')


# --------------------------------------------------
# 🧠 1. Semantic Similarity
# --------------------------------------------------
def semantic_similarity(expected: str, generated: str) -> float:
    """
    Measures meaning similarity between expected and generated text
    Returns value in percentage (0–100)
    """
    try:
        emb1 = model.encode([expected])
        emb2 = model.encode([generated])

        score = cosine_similarity(emb1, emb2)[0][0]
        return round(score * 100, 2)

    except Exception as e:
        print(f"[Semantic Error]: {e}")
        return 0.0


# --------------------------------------------------
# 📏 2. Factual Consistency (Token Overlap)
# --------------------------------------------------
def factual_consistency(expected: str, generated: str) -> float:
    """
    Measures overlap of important words (simple factual proxy)
    """
    try:
        # Clean text
        expected_tokens = set(clean_text(expected))
        generated_tokens = set(clean_text(generated))

        if len(expected_tokens) == 0:
            return 0.0

        overlap = len(expected_tokens & generated_tokens)
        score = overlap / len(expected_tokens)

        return round(score * 100, 2)

    except Exception as e:
        print(f"[Factual Error]: {e}")
        return 0.0


# --------------------------------------------------
# 🧹 Helper: Text Cleaning
# --------------------------------------------------
def clean_text(text: str):
    """
    Normalize text into tokens
    """
    text = text.lower()
    text = re.sub(r'[^a-z0-9\s]', '', text)  # remove punctuation
    tokens = text.split()

    return tokens


# --------------------------------------------------
# 🛡️ 3. Vulnerability Detection (Optional but 🔥)
# --------------------------------------------------
def vulnerability_detection(expected_vulnerabilities: list, generated: str) -> float:
    """
    Checks if expected vulnerabilities appear in generated output
    """
    try:
        if not expected_vulnerabilities:
            return 0.0

        generated_lower = generated.lower()
        detected = 0

        for vuln in expected_vulnerabilities:
            if vuln.lower() in generated_lower:
                detected += 1

        score = detected / len(expected_vulnerabilities)

        return round(score * 100, 2)

    except Exception as e:
        print(f"[Vulnerability Error]: {e}")
        return 0.0


# --------------------------------------------------
# ⏱️ 4. Latency Helper (Optional)
# --------------------------------------------------
def compute_latency(start_time, end_time) -> float:
    """
    Returns response time in seconds
    """
    return round(end_time - start_time, 2)