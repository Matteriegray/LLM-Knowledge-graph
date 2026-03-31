// ===============================
// 1. CONSTRAINTS
// ===============================
CREATE CONSTRAINT IF NOT EXISTS FOR (a:Asset) REQUIRE a.name IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (z:Zone) REQUIRE z.name IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (r:Requirement) REQUIRE r.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (h:Human) REQUIRE h.name IS UNIQUE;

// ===============================
// 2. ZONES (10 Nodes)
// ===============================
UNWIND [
  {n:"Control_Zone_A", sl:3, d:"Primary production cell A."},
  {n:"Control_Zone_B", sl:3, d:"Primary production cell B."},
  {n:"Supervisory_Network", sl:2, d:"Process monitoring layer."},
  {n:"Safety_Zone", sl:4, d:"Critical safety instrumented systems."},
  {n:"DMZ_External", sl:1, d:"External facing demilitarized zone."},
  {n:"DMZ_Internal", sl:1, d:"Internal isolation layer."},
  {n:"Corporate_HQ", sl:1, d:"General office network."},
  {n:"Field_Sensors_East", sl:2, d:"Remote sensor cluster east."},
  {n:"Field_Sensors_West", sl:2, d:"Remote sensor cluster west."},
  {n:"Testing_Lab", sl:1, d:"Sandboxed environment for updates."}
] AS z MERGE (:Zone {name: z.n, securityLevel: z.sl, description: z.d});

// ===============================
// 3. ASSETS (40 Nodes)
// ===============================
UNWIND range(1, 10) AS i
MERGE (:Asset {name: "PLC_Unit_" + i, type: "Embedded Device", securityCapability: "Password", description: "Logic controller " + i});
UNWIND range(1, 10) AS i
MERGE (:Asset {name: "Robot_Arm_" + i, type: "Machine", securityCapability: "None", description: "Industrial robot " + i});
UNWIND range(1, 5) AS i
MERGE (:Asset {name: "HMI_Panel_" + i, type: "Host Device", securityCapability: "MFA", description: "Human machine interface " + i});
UNWIND range(1, 5) AS i
MERGE (:Asset {name: "Historian_" + i, type: "Server", securityCapability: "MFA", description: "Data logging server " + i});
UNWIND range(1, 10) AS i
MERGE (:Asset {name: "Sensor_Node_" + i, type: "Sensor", securityCapability: "None", description: "Environmental sensor " + i});

// ===============================
// 4. SECURITY REQUIREMENTS (20 Nodes)
// ===============================
UNWIND range(1, 20) AS i
MERGE (:Requirement {
    id: "SR_" + i, 
    title: "Security Requirement " + i, 
    securityLevel_T: (i % 4) + 1,
    rationale: "Rationale for SR " + i + " based on IEC 62443.",
    description: "Technical specification for SR " + i
});

// ===============================
// 5. HUMANS & ROLES (10 Nodes)
// ===============================
UNWIND ["Admin_A", "Admin_B", "Op_1", "Op_2", "Eng_1"] AS name
MERGE (:Human {name: name, description: "Staff member " + name});
UNWIND ["Administrator", "Operator", "Engineer", "Maintainer", "Auditor"] AS role
MERGE (:Role {name: role, description: "Professional role for " + role});

// ===============================
// 6. RELATIONSHIPS (~150 Interconnections)
// ===============================

// Asset to Zone (40 relationships)
MATCH (a:Asset), (z:Zone)
WHERE (a.name STARTS WITH "PLC" AND z.name = "Control_Zone_A")
   OR (a.name STARTS WITH "Robot" AND z.name = "Control_Zone_B")
   OR (a.name STARTS WITH "Sensor" AND z.name STARTS WITH "Field")
   OR (a.name STARTS WITH "HMI" AND z.name = "Supervisory_Network")
MERGE (a)-[:IN_ZONE]->(z);

// Zone to Zone / Conduits (20 relationships)
MATCH (z1:Zone {name:"Control_Zone_A"}), (z2:Zone {name:"Supervisory_Network"}) MERGE (z1)-[:CONNECTS_TO]->(z2);
MATCH (z1:Zone {name:"Control_Zone_B"}), (z2:Zone {name:"Supervisory_Network"}) MERGE (z1)-[:CONNECTS_TO]->(z2);
MATCH (z1:Zone {name:"Supervisory_Network"}), (z2:Zone {name:"DMZ_Internal"}) MERGE (z1)-[:CONNECTS_TO]->(z2);
MATCH (z1:Zone {name:"DMZ_Internal"}), (z2:Zone {name:"DMZ_External"}) MERGE (z1)-[:CONNECTS_TO]->(z2);

// Requirements to Assets (50 relationships)
MATCH (r:Requirement), (a:Asset)
WHERE (r.id IN ["SR_1", "SR_5"] AND a.type = "Embedded Device")
   OR (r.id IN ["SR_2", "SR_7"] AND a.type = "Machine")
   OR (r.id IN ["SR_10", "SR_15"] AND a.type = "Server")
MERGE (r)-[:APPLIES_TO]->(a);

// Human to Role to Permission (40 relationships)
MATCH (h:Human), (r:Role)
WHERE (h.name STARTS WITH "Admin" AND r.name = "Administrator")
   OR (h.name STARTS WITH "Op" AND r.name = "Operator")
   OR (h.name STARTS WITH "Eng" AND r.name = "Engineer")
MERGE (h)-[:HAS_ROLE]->(r);

MERGE (p1:Permission {operation: "Read", description: "View only access."});
MERGE (p2:Permission {operation: "Write", description: "Modification access."});
MERGE (p3:Permission {operation: "Execute", description: "Command access."});

MATCH (r:Role), (p:Permission)
WHERE (r.name = "Administrator") OR (r.name = "Operator" AND p.operation = "Read")
MERGE (r)-[:HAS_PERMISSION]->(p);