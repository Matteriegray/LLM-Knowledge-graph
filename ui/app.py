import os
import sys
from pathlib import Path
from flask import Flask, render_template, request, jsonify
from dotenv import load_dotenv

# Ensure the project root and src directory are importable.
ROOT_DIR = Path(__file__).resolve().parents[1]
SRC_DIR = ROOT_DIR / "src"
sys.path.insert(0, str(SRC_DIR))

# Load environment variables from the root .env file.
load_dotenv(ROOT_DIR / ".env")

from main import run_automated_pipeline
from llm_service import LlamaService
from nl_transformer import NLTransformer
from ranker import CentralityRanker
from vector_db import SecurityStandardDB
from neo4j import GraphDatabase

app = Flask(__name__, static_folder="static", template_folder="templates")

startup_error = None
services = {}


def initialize_services():
    global services
    try:
        uri = os.getenv("NEO4J_URI", "bolt://localhost:7687")
        user = os.getenv("NEO4J_USER", "neo4j")
        password = os.getenv("NEO4J_PASSWORD", "plsbropls")

        driver = GraphDatabase.driver(uri, auth=(user, password))
        transformer = NLTransformer()
        ranker = CentralityRanker()
        standard_db = SecurityStandardDB()
        llm = LlamaService()

        services = {
            "driver": driver,
            "transformer": transformer,
            "ranker": ranker,
            "standard_db": standard_db,
            "llm": llm,
        }
    except Exception as exc:
        raise RuntimeError(
            "Failed to initialize backend services. "
            "Check your environment variables and Neo4j / Gemini configuration."
        ) from exc


try:
    initialize_services()
except Exception as exc:
    startup_error = str(exc)


@app.route("/")
def index():
    return render_template("index.html", startup_error=startup_error)


@app.route("/chat", methods=["POST"])
def chat():
    if startup_error:
        return jsonify({"error": startup_error}), 500

    payload = request.get_json(silent=True)
    if not payload or not payload.get("question"):
        return jsonify({"error": "Please provide a valid question."}), 400

    question = payload["question"].strip()
    if not question:
        return jsonify({"error": "Question cannot be empty."}), 400

    try:
        response = run_automated_pipeline(
            services["driver"],
            services["transformer"],
            services["ranker"],
            services["standard_db"],
            services["llm"],
            question,
        )
        return jsonify({"response": response})

    except Exception as exc:
        return jsonify({"error": str(exc)}), 500


@app.route("/health")
def health():
    return jsonify({"status": "ok", "ready": startup_error is None})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
