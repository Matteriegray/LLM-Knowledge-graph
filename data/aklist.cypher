// ===============================
// 1. CONSTRAINTS (Keep all of them)
// ===============================
CREATE CONSTRAINT IF NOT EXISTS FOR (a:Asset) REQUIRE a.name IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (h:Human) REQUIRE h.name IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (r:Role) REQUIRE r.name IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (z:Zone) REQUIRE z.name IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (f:Firewall) REQUIRE f.name IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (p:Port) REQUIRE p.port IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (req:Requirement) REQUIRE req.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (v:Vulnerability) REQUIRE v.name IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (perm:Permission) REQUIRE perm.operation IS UNIQUE;

// ===============================
// 2. ZONES (Updated with Descriptions & SL)
// ===============================
MERGE (:Zone {name:"Control Network", securityLevel:3, description:"Contains time-critical control equipment like PLCs and Robots."});
MERGE (:Zone {name:"Supervisory Network", securityLevel:2, description:"Provides monitoring and control of the manufacturing process."});
MERGE (:Zone {name:"Safety Network", securityLevel:4, description:"High-integrity network for safety-instrumented systems."});
MERGE (:Zone {name:"DMZ", securityLevel:1, description:"Isolated layer separating internal networks from corporate access."});
MERGE (:Zone {name:"Corporate Network", securityLevel:1, description:"General business network with internet connectivity."});

// ===============================
// 3. ASSETS (Your Full List + Paper's Properties)
// ===============================
// We use a list to MERGE all your assets while adding the required 'securityCapability'
UNWIND [
  {n:"PLC Controller 1", cap:"None", desc:"Cell automation controller."},
  {n:"PLC Controller 2", cap:"Password Authentication", desc:"Cell automation controller."},
  {n:"Robot Arm 1", cap:"None", desc:"Assembly robotic arm."},
  {n:"Robot Arm 2", cap:"None", desc:"Assembly robotic arm."},
  {n:"Robot Arm 3", cap:"None", desc:"Assembly robotic arm."},
  {n:"Robot Arm 4", cap:"None", desc:"Assembly robotic arm."},
  {n:"SCADA Server", cap:"MFA", desc:"Supervisory control server."},
  {n:"Historian Server", cap:"Password Authentication", desc:"Data logging server."},
  {n:"Engineering Workstation", cap:"Password Authentication", desc:"System for PLC programming."},
  {n:"Safety Controller", cap:"Physical Key Switch", desc:"Logic solver for safety functions."},
  {n:"VPN Gateway", cap:"Encrypted Tunnel", desc:"Entry point for remote connections."},
  {n:"Jump Server", cap:"MFA", desc:"Secure transition host."}
] AS asset
MERGE (a:Asset {name: asset.n})
SET a.securityCapability = asset.cap, a.description = asset.desc;

// =  =

// ===============================
// 4. REQUIREMENTS (IEC 62443-3-3)
// This is what was missing for automation
// ===============================
MERGE (:Requirement {id:"SR1.1", title:"Identification and Authentication", securityLevel_T:3, rationale:"Ensures that only verified users can access control system functions.", description:"The system shall provide the capability to identify and authenticate all human users."});
MERGE (:Requirement {id:"SR3.2", title:"Network Segmentation", securityLevel_T:2, rationale:"Prevents unauthorized communication between functional zones.", description:"The system shall provide the capability to logically or physically segment the network."});
MERGE (:Requirement {id:"SR7.7", title:"Least Functionality", securityLevel_T:1, rationale:"Minimizes attack surface by disabling unused services and ports.", description:"The system shall provide the capability to restrict the use of unnecessary ports."});

// ===============================
// 5. RELATIONSHIPS (The Automation Logic)
// ===============================

// Asset -> Zone (Using your existing logic)
MATCH (z:Zone {name:"Control Network"}), (a:Asset) 
WHERE a.name IN ["PLC Controller 1", "PLC Controller 2", "Robot Arm 1", "Robot Arm 2", "Robot Arm 3", "Robot Arm 4", "Safety Controller"] 
MERGE (a)-[:IN_ZONE]->(z);

// Requirement -> Asset (The 'AffectedAsset' link for compliance)
MATCH (req:Requirement {id:"SR1.1"}), (a:Asset) 
WHERE a.name STARTS WITH "PLC" OR a.name STARTS WITH "Robot"
MERGE (req)-[:APPLIES_TO]->(a);

// Firewall -> Zone
MATCH (f:Firewall {name:"Plant Firewall"}), (z:Zone {name:"Control Network"}) 
MERGE (f)-[:PROTECTS]->(z);