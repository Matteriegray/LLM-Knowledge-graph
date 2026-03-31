class NLTransformer:
    def __init__(self):
        # Standardized templates from Table 2 of the research paper 
        self.templates = {
            # Class & Hierarchy Templates
            "type": "{subject} is an instance of {object} class.",
            "subClassOf": "{subject} is a subclass of {object}.",
            "disjointWith": "{subject} and {object} have no instance in common.",
            
            # Object Properties (Relationships) 
            "isInZone": "The asset named {subject} is in the zone named {object}.",
            "hasRole": "Human {subject} has a role named {object}.",
            "hasPermission": "The role {subject} has the permission {object}.",
            "accessTo": "The permission {subject} gives the user access to perform operations on {object}.",
            "usesPort": "The interface/asset named {subject} uses a port named {object}.",
            "hasRule": "The firewall named {subject} has a rule named {object}.",
            "isPartOf": "The asset named {subject} is part of an asset named {object}.",
            
            # Data Properties & Constraints 
            "SecurityLevel_T": "The zone named {subject} has a target security level of {object}.",
            "PortStatus": "The port named {subject} has a status of {object}.",
            "ID": "The entity named {subject} has an ID/Name of {object}.",
            "operation": "The permission {subject} allows the following operations: {object}."
        }

    def transform_triple(self, subject, predicate, obj):
        """
        Transforms a single (S, P, O) triple into a natural language sentence.
        [cite: 356-359]
        """
        template = self.templates.get(predicate)
        if template:
            return template.format(subject=subject, object=obj)
        
        # Fallback for undefined predicates to maintain information flow
        return f"The {subject} has a {predicate} relationship with {obj}."

    def generate_context_block(self, raw_triples):
        """
        Processes raw Neo4j results into a self-contained context block.
        [cite: 411, 457]
        """
        sentences = []
        for record in raw_triples:
            # Logic to handle different dictionary structures from your queries
            # Extracting Subject, Predicate (Rel), and Object
            s = record.get('n', {}).get('name') or record.get('subject')
            p = record.get('rel') or record.get('predicate')
            o = record.get('m', {}).get('name') or record.get('object')
            
            if s and p and o:
                sentences.append(self.transform_triple(s, p, o))
        
        # Deduplicate to save tokens [cite: 335-336]
        unique_sentences = list(dict.fromkeys(sentences))
        return "\n".join(unique_sentences)