# LLM + Knowledge Graph Based ICS Security Analysis System

## Overview

This project is an intelligent system designed to analyze the security of Industrial Control Systems (ICS) using a combination of Knowledge Graphs and Large Language Models (LLMs).

The system allows users to ask security-related questions in natural language and returns structured responses including vulnerabilities, risks, and recommended actions based on system architecture and standards.

---

## How the System Works

The system follows a multi-stage pipeline:

User Query  
↓  
Class Identification (LLM)  
↓  
Knowledge Graph Retrieval  
↓  
Context Construction  
↓  
LLM Reasoning (Gemini API)  
↓  
Technical Output  
↓  
Human-Friendly Report  

Additionally, performance metrics such as semantic similarity, factual consistency, and response latency are computed internally for evaluation.

---

## Project Structure

project/
│
├── .env                  # Environment variables (not committed)
├── .env.example          # Sample environment configuration
├── .gitignore
├── requirements.txt
│
└── src/
    ├── main.py           # Entry point
    ├── llm_service.py    # LLM interaction layer
    ├── evaluation.py     # Metrics computation
    ├── metrics_store.py  # Stores evaluation data
    ├── plot_metrics.py   # Visualization

---

## Setup Instructions

### 1. Clone the Repository

git clone <your-repo-url>  
cd <your-repo-name>  

---

### 2. Create Virtual Environment

python -m venv venv  

Activate the environment:

Windows:  
venv\Scripts\activate  

Mac/Linux:  
source venv/bin/activate  

---

### 3. Install Dependencies

pip install -r requirements.txt  

---

### 4. Configure Environment Variables

Copy the example file:

cp .env.example .env  

Edit the `.env` file and add your Gemini API key:

GEMINI_API_KEY=your_api_key_here  

---

## Running the Application

Run the system using:

python -m src.main  

---

## Execution Flow

1. The system accepts a natural language query  
2. It identifies relevant ontology classes  
3. Retrieves related data from the knowledge graph  
4. Uses Gemini LLM to generate a structured response  
5. Converts output into a human-friendly report  

---

## Backend Metrics

During execution, the system computes:

- Semantic Similarity  
- Factual Consistency  
- Response Latency  

These are printed in the terminal:

[METRICS - INTERNAL]  
Semantic Similarity: 81.45%  
Factual Consistency: 74.20%  
Latency: 1.23s  

These metrics are not exposed to the user interface.

---

## Visualizing Metrics

After running a few queries, you can plot performance:

from plot_metrics import plot_metrics  
plot_metrics()  

This generates a graph showing:
- Semantic similarity trend  
- Factual consistency trend  
- Latency  

---

## Troubleshooting

Module not found errors:  
pip install -r requirements.txt  

API Key not found:  
Ensure `.env` contains:  
GEMINI_API_KEY=your_key  

No graph displayed:  
- Run multiple queries first  
- Then call plot_metrics()  

---

## Notes

- Metrics are approximate and do not rely on a labeled dataset  
- Latency values may appear smaller compared to other metrics due to scale differences  
- First execution may take longer due to model download (Sentence Transformers)  

---

## Summary

This system demonstrates how combining structured knowledge with LLM reasoning can automate security analysis, reduce manual effort, and provide interpretable insights for complex ICS environments.