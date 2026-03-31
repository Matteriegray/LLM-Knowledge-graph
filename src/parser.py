# parser.py
import re

def parse_question(question):
    question = question.lower()
    
    # Extract asset
    asset_match = re.search(r'robot arm \d+', question)
    if asset_match:
        asset = asset_match.group(0)  # e.g., "robot arm 1"
    else:
        asset = None
    
    # Determine intent based on keywords
    if "control" in question or "access" in question or "maintain" in question:
        intent = "role_permission"
    else:
        intent = None
    
    if intent and asset:
        return {"intent": intent, "entities": [asset]}
    else:
        return None