// ===============================
// CONSTRAINTS
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
// ZONES
// ===============================

MERGE (:Zone {name:"Control Network", securityLevel:3});
MERGE (:Zone {name:"Supervisory Network", securityLevel:2});
MERGE (:Zone {name:"Safety Network", securityLevel:4});
MERGE (:Zone {name:"DMZ", securityLevel:1});
MERGE (:Zone {name:"Corporate Network", securityLevel:1});


// ===============================
// FIREWALLS
// ===============================

MERGE (:Firewall {name:"Plant Firewall"});
MERGE (:Firewall {name:"DMZ Firewall"});
MERGE (:Firewall {name:"Remote Access Firewall"});


// ===============================
// ASSETS
// ===============================

MERGE (:Asset {name:"PLC Controller 1", authenticationEnabled:false});
MERGE (:Asset {name:"PLC Controller 2", authenticationEnabled:true});
MERGE (:Asset {name:"Robot Arm 1"});
MERGE (:Asset {name:"Robot Arm 2"});
MERGE (:Asset {name:"Robot Arm 3"});
MERGE (:Asset {name:"Robot Arm 4"});
MERGE (:Asset {name:"SCADA Server"});
MERGE (:Asset {name:"Historian Server"});
MERGE (:Asset {name:"Engineering Workstation"});
MERGE (:Asset {name:"Teach Pendant"});
MERGE (:Asset {name:"Safety Controller"});
MERGE (:Asset {name:"HMI Panel"});
MERGE (:Asset {name:"VPN Gateway"});
MERGE (:Asset {name:"Jump Server"});
MERGE (:Asset {name:"Quality Inspection Camera"});
MERGE (:Asset {name:"Packaging Robot"});
MERGE (:Asset {name:"Assembly Robot"});
MERGE (:Asset {name:"Industrial Sensor Hub"});


// ===============================
// HUMANS
// ===============================

MERGE (:Human {name:"Operator Jack"});
MERGE (:Human {name:"Operator Lina"});
MERGE (:Human {name:"Maintenance Ravi"});
MERGE (:Human {name:"Maintenance Bob"});
MERGE (:Human {name:"Engineer Alice"});
MERGE (:Human {name:"Engineer Chen"});
MERGE (:Human {name:"Administrator Sam"});
MERGE (:Human {name:"Security Analyst Maya"});
MERGE (:Human {name:"Operator David"});
MERGE (:Human {name:"Maintenance Sara"});
MERGE (:Human {name:"Engineer Victor"});
MERGE (:Human {name:"Engineer Maria"});


// ===============================
// ROLES
// ===============================

MERGE (:Role {name:"Operator"});
MERGE (:Role {name:"Maintainer"});
MERGE (:Role {name:"Engineer"});
MERGE (:Role {name:"Administrator"});
MERGE (:Role {name:"SecurityAnalyst"});


// ===============================
// PERMISSIONS
// ===============================

MERGE (:Permission {operation:"Control"});
MERGE (:Permission {operation:"Monitor"});
MERGE (:Permission {operation:"Configure"});
MERGE (:Permission {operation:"Maintain"});
MERGE (:Permission {operation:"UpdateFirmware"});
MERGE (:Permission {operation:"RemoteAccess"});
MERGE (:Permission {operation:"ReadLogs"});


// ===============================
// VULNERABILITIES
// ===============================

MERGE (:Vulnerability {name:"Missing Authentication"});
MERGE (:Vulnerability {name:"Weak Access Control"});
MERGE (:Vulnerability {name:"Open Insecure Port"});
MERGE (:Vulnerability {name:"Outdated Firmware"});
MERGE (:Vulnerability {name:"Excessive Privileges"});


// ===============================
// REQUIREMENTS (IEC 62443-3-3)
// ===============================

MERGE (:Requirement {id:"SR1.1", title:"Identification and Authentication"});
MERGE (:Requirement {id:"SR1.2", title:"Software Process Authentication"});
MERGE (:Requirement {id:"SR1.3", title:"Account Management"});
MERGE (:Requirement {id:"SR2.1", title:"Authorization Enforcement"});
MERGE (:Requirement {id:"SR2.2", title:"User Privilege Management"});
MERGE (:Requirement {id:"SR3.1", title:"Communication Integrity"});
MERGE (:Requirement {id:"SR3.2", title:"Network Segmentation"});
MERGE (:Requirement {id:"SR4.1", title:"Information Confidentiality"});
MERGE (:Requirement {id:"SR7.1", title:"Least Privilege"});
MERGE (:Requirement {id:"SR7.7", title:"Least Functionality"});

// ===============================
// PORTS
// ===============================

MERGE (:Port {port:502, protocol:"Modbus"});
MERGE (:Port {port:4840, protocol:"OPC-UA"});
MERGE (:Port {port:21, protocol:"FTP"});
MERGE (:Port {port:23, protocol:"Telnet"});


// ===============================
// RELATIONSHIPS
// ===============================

// Asset → Zone
MATCH (z:Zone {name:"Control Network"})
MATCH (a:Asset)
WHERE a.name IN [
  "PLC Controller 1",
  "PLC Controller 2",
  "Robot Arm 1",
  "Robot Arm 2",
  "Robot Arm 3",
  "Robot Arm 4",
  "Packaging Robot",
  "Assembly Robot",
  "Safety Controller"
]
MERGE (a)-[:IN_ZONE]->(z);
MATCH (z:Zone {name:"Supervisory Network"})
MATCH (a:Asset)
WHERE a.name IN [
  "SCADA Server",
  "Historian Server",
  "HMI Panel",
  "Engineering Workstation",
  "Quality Inspection Camera",
  "Industrial Sensor Hub"
]
MERGE (a)-[:IN_ZONE]->(z);
MATCH (z:Zone {name:"DMZ"})
MATCH (a:Asset)
WHERE a.name IN [
  "VPN Gateway",
  "Jump Server"
]
MERGE (a)-[:IN_ZONE]->(z);
MATCH (a:Asset {name:"Safety Controller"})
MATCH (z:Zone {name:"Safety Network"})
MERGE (a)-[:IN_ZONE]->(z);

// Human → Role
MATCH (h:Human),(r:Role {name:"Operator"})
WHERE h.name STARTS WITH "Operator"
MERGE (h)-[:HAS_ROLE]->(r);

MATCH (h:Human),(r:Role {name:"Maintainer"})
WHERE h.name STARTS WITH "Maintenance"
MERGE (h)-[:HAS_ROLE]->(r);

MATCH (h:Human),(r:Role {name:"Engineer"})
WHERE h.name STARTS WITH "Engineer"
MERGE (h)-[:HAS_ROLE]->(r);

MATCH (h:Human),(r:Role {name:"Administrator"})
WHERE h.name STARTS WITH "Administrator"
MERGE (h)-[:HAS_ROLE]->(r);

MATCH (h:Human),(r:Role {name:"SecurityAnalyst"})
WHERE h.name STARTS WITH "Security Analyst"
MERGE (h)-[:HAS_ROLE]->(r);

// Role → Permission
MATCH (r:Role {name:"Operator"})
MATCH (p:Permission)
WHERE p.operation IN ["Control","Monitor"]
MERGE (r)-[:HAS_PERMISSION]->(p);
MATCH (r:Role {name:"Maintainer"})
MATCH (p:Permission)
WHERE p.operation IN ["Maintain","UpdateFirmware","Monitor"]
MERGE (r)-[:HAS_PERMISSION]->(p);
MATCH (r:Role {name:"Engineer"})
MATCH (p:Permission)
WHERE p.operation IN ["Configure","UpdateFirmware","Monitor"]
MERGE (r)-[:HAS_PERMISSION]->(p);
MATCH (r:Role {name:"Administrator"})
MATCH (p:Permission)
WHERE p.operation IN ["RemoteAccess","Configure","Monitor"]
MERGE (r)-[:HAS_PERMISSION]->(p);
MATCH (r:Role {name:"SecurityAnalyst"})
MATCH (p:Permission)
WHERE p.operation IN ["ReadLogs","Monitor"]
MERGE (r)-[:HAS_PERMISSION]->(p);

//Permission → ACCESS_TO
MATCH (p:Permission {operation:"Control"})
MATCH (a:Asset)
WHERE a.name STARTS WITH "Robot Arm"
MERGE (p)-[:ACCESS_TO]->(a);
MATCH (p:Permission {operation:"Maintain"})
MATCH (a:Asset)
WHERE a.name STARTS WITH "PLC"
   OR a.name STARTS WITH "Robot Arm"
MERGE (p)-[:ACCESS_TO]->(a);
MATCH (p:Permission {operation:"Configure"})
MATCH (a:Asset)
WHERE a.name IN ["Engineering Workstation","PLC Controller 1","PLC Controller 2"]
MERGE (p)-[:ACCESS_TO]->(a);
MATCH (p:Permission {operation:"RemoteAccess"})
MATCH (a:Asset)
WHERE a.name IN ["VPN Gateway","Jump Server"]
MERGE (p)-[:ACCESS_TO]->(a);
MATCH (p:Permission {operation:"Monitor"})
MATCH (a:Asset)
WHERE a.name IN ["SCADA Server","HMI Panel"]
MERGE (p)-[:ACCESS_TO]->(a);
MATCH (p:Permission {operation:"UpdateFirmware"})
MATCH (a:Asset)
WHERE a.name STARTS WITH "PLC"
   OR a.name STARTS WITH "Robot Arm"
MERGE (p)-[:ACCESS_TO]->(a);
MATCH (p:Permission {operation:"ReadLogs"})
MATCH (a:Asset)
WHERE a.name IN ["Historian Server","SCADA Server"]
MERGE (p)-[:ACCESS_TO]->(a);

//Firewall → PROTECTS
MATCH (f:Firewall {name:"Plant Firewall"})
MATCH (z:Zone {name:"Control Network"})
MERGE (f)-[:PROTECTS]->(z);
MATCH (f:Firewall {name:"DMZ Firewall"})
MATCH (z:Zone {name:"DMZ"})
MERGE (f)-[:PROTECTS]->(z);
MATCH (f:Firewall {name:"Remote Access Firewall"})
MATCH (z:Zone {name:"Corporate Network"})
MERGE (f)-[:PROTECTS]->(z);

//Firewall → FILTERS (network port filtering)
MATCH (f:Firewall {name:"Plant Firewall"})
MATCH (p:Port)
WHERE p.port IN [502, 4840]
MERGE (f)-[:FILTERS]->(p);
MATCH (f:Firewall {name:"DMZ Firewall"})
MATCH (p:Port)
WHERE p.port IN [21, 23]
MERGE (f)-[:FILTERS]->(p);

//Asset → HAS_VULNERABILITY
MATCH (a:Asset {name:"PLC Controller 1"})
MATCH (v:Vulnerability {name:"Missing Authentication"})
MERGE (a)-[:HAS_VULNERABILITY]->(v);
MATCH (a:Asset {name:"Robot Arm 1"})
MATCH (v:Vulnerability {name:"Weak Access Control"})
MERGE (a)-[:HAS_VULNERABILITY]->(v);
MATCH (a:Asset {name:"VPN Gateway"})
MATCH (v:Vulnerability {name:"Open Insecure Port"})
MERGE (a)-[:HAS_VULNERABILITY]->(v);
MATCH (a:Asset {name:"Robot Arm 3"})
MATCH (v:Vulnerability {name:"Outdated Firmware"})
MERGE (a)-[:HAS_VULNERABILITY]->(v);
MATCH (a:Asset {name:"Engineering Workstation"})
MATCH (v:Vulnerability {name:"Excessive Privileges"})
MERGE (a)-[:HAS_VULNERABILITY]->(v);

//Requirement → APPLIES_TO
MATCH (r:Requirement)
WHERE r.id IN ["SR1.1","SR1.2","SR1.3"]
MATCH (a:Asset)
WHERE a.name IN [
  "PLC Controller 1",
  "PLC Controller 2",
  "Engineering Workstation",
  "VPN Gateway",
  "Jump Server"
]
MERGE (r)-[:APPLIES_TO]->(a);
MATCH (r:Requirement)
WHERE r.id IN ["SR2.1","SR2.2"]
MATCH (a:Asset)
WHERE a.name IN [
  "Engineering Workstation",
  "SCADA Server",
  "PLC Controller 1",
  "PLC Controller 2"
]
MERGE (r)-[:APPLIES_TO]->(a);
MATCH (r:Requirement)
WHERE r.id IN ["SR3.1","SR3.2"]
MATCH (a:Asset)
WHERE a.name IN [
  "SCADA Server",
  "VPN Gateway",
  "HMI Panel",
  "Industrial Sensor Hub"
]
MERGE (r)-[:APPLIES_TO]->(a);
MATCH (r:Requirement {id:"SR4.1"})
MATCH (a:Asset)
WHERE a.name IN [
  "Historian Server",
  "SCADA Server"
]
MERGE (r)-[:APPLIES_TO]->(a);
MATCH (r:Requirement)
WHERE r.id IN ["SR7.1","SR7.7"]
MATCH (a:Asset)
WHERE a.name IN [
  "PLC Controller 1",
  "PLC Controller 2",
  "Engineering Workstation",
  "Robot Arm 1",
  "Robot Arm 2"
]
MERGE (r)-[:APPLIES_TO]->(a);

//Zone → CONNECTS_TO → Zone
MATCH (a:Zone {name:"Corporate Network"})
MATCH (b:Zone {name:"DMZ"})
MERGE (a)-[:CONNECTS_TO]->(b)
MERGE (b)-[:CONNECTS_TO]->(a);
MATCH (a:Zone {name:"DMZ"})
MATCH (b:Zone {name:"Supervisory Network"})
MERGE (a)-[:CONNECTS_TO]->(b)
MERGE (b)-[:CONNECTS_TO]->(a);
MATCH (a:Zone {name:"Supervisory Network"})
MATCH (b:Zone {name:"Control Network"})
MERGE (a)-[:CONNECTS_TO]->(b)
MERGE (b)-[:CONNECTS_TO]->(a);
MATCH (a:Zone {name:"Control Network"})
MATCH (b:Zone {name:"Safety Network"})
MERGE (a)-[:CONNECTS_TO]->(b)
MERGE (b)-[:CONNECTS_TO]->(a);

//Asset → USES_PORT → Port
MATCH (a:Asset)
WHERE a.name STARTS WITH "PLC"
MATCH (p:Port {port:502})
MERGE (a)-[:USES_PORT]->(p);
MATCH (a:Asset)
WHERE a.name STARTS WITH "PLC"
MATCH (p:Port {port:502})
MERGE (a)-[:USES_PORT]->(p);
MATCH (a:Asset {name:"VPN Gateway"})
MATCH (p:Port)
WHERE p.port IN [21,23]
MERGE (a)-[:USES_PORT]->(p);
