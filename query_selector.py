# query_selector.py
def select_query(intent, entities):
    if intent != "role_permission" or not entities:
        return None

    asset = entities[0]
    query = f"""
    MATCH (r:Role)-[p:CAN]->(a:Asset)
    WHERE toLower(a.name) = '{asset.lower()}'
    RETURN r.name AS role, p.name AS permission, a.name AS asset
    """
    return {"type": intent, "query": query}