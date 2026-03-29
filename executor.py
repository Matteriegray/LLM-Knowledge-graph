# executor.py
def run_query(driver, query_info):
    if not query_info:
        return None
    
    query = query_info["query"]
    with driver.session() as session:
        result = session.run(query)
        return [record.data() for record in result]