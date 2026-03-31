# ranker.py
import networkx as nx

class CentralityRanker:
    def __init__(self, tokenizer=None):
        # tokenizer could be a simple word counter or a real LLM tokenizer
        self.tokenizer = tokenizer or (lambda x: len(x.split()))

    def filter_by_closeness(self, nl_sentences, raw_triples, max_tokens=3000):
        """
        Ranks sentences based on the closeness centrality of the nodes they describe.
        """
        if not nl_sentences:
            return ""

        # 1. Build a temporary graph of the retrieved neighborhood
        G = nx.Graph()
        sentence_map = [] # To keep track of which sentence belongs to which node

        for i, triple in enumerate(raw_triples):
            s = triple.get("subject")
            o = triple.get("object")
            if s and o:
                G.add_edge(s, o)
                # Map the generated NL sentence back to these nodes
                sentence_map.append({
                    "sentence": nl_sentences[i],
                    "nodes": [s, o]
                })

        # 2. Calculate Closeness Centrality for all nodes in the neighborhood
        # High centrality means the node is "closer" to all other retrieved nodes
        centrality = nx.closeness_centrality(G)

        # 3. Score each sentence based on the average centrality of its participants
        for item in sentence_map:
            scores = [centrality.get(node, 0) for node in item["nodes"]]
            item["score"] = sum(scores) / len(scores) if scores else 0

        # 4. Sort sentences by score (descending)
        ranked_sentences = sorted(sentence_map, key=lambda x: x["score"], reverse=True)

        # 5. Pack sentences until the token limit is reached
        final_context = []
        current_tokens = 0
        
        for item in ranked_sentences:
            sentence = item["sentence"]
            token_count = self.tokenizer(sentence)
            
            if current_tokens + token_count <= max_tokens:
                final_context.append(sentence)
                current_tokens += token_count
            else:
                break # Token limit reached

        return "\n".join(final_context)