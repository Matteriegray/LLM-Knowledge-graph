":begin
CREATE CONSTRAINT asset_name FOR (node:Asset) REQUIRE (node.name) IS UNIQUE;
CREATE CONSTRAINT human_name FOR (node:Human) REQUIRE (node.name) IS UNIQUE;
CREATE CONSTRAINT role_name FOR (node:Role) REQUIRE (node.name) IS UNIQUE;
CREATE CONSTRAINT zone_name FOR (node:Zone) REQUIRE (node.name) IS UNIQUE;
CREATE CONSTRAINT UNIQUE_IMPORT_NAME FOR (node:`UNIQUE IMPORT LABEL`) REQUIRE (node.`UNIQUE IMPORT ID`) IS UNIQUE;
:commit
CALL db.awaitIndexes(300);
:begin
UNWIND [{name:"PLC Controller", properties:{type:"EmbeddedDevice"}}, {name:"PLC Controller 1", properties:{authenticationEnabled:false}}, {name:"PLC Controller 2", properties:{authenticationEnabled:true}}, {name:"Robot Arm 1", properties:{}}, {name:"Robot Arm 2", properties:{}}, {name:"SCADA Server", properties:{}}, {name:"Historian Server", properties:{}}, {name:"Engineering Workstation", properties:{}}, {name:"Teach Pendant", properties:{}}, {name:"Safety Controller", properties:{}}, {name:"HMI Panel", properties:{}}, {name:"VPN Gateway", properties:{}}, {name:"Jump Server", properties:{}}, {name:"Robot Arm 3", properties:{}}, {name:"Robot Arm 4", properties:{}}, {name:"Quality Inspection Camera", properties:{}}, {name:"Packaging Robot", properties:{}}, {name:"Assembly Robot", properties:{}}, {name:"Industrial Sensor Hub", properties:{}}] AS row
CREATE (n:Asset{name: row.name}) SET n += row.properties;
UNWIND [{_id:52, properties:{id:"SR1.1", title:"Identification and Authentication"}}, {_id:53, properties:{id:"SR1.2", title:"Software Process Authentication"}}, {_id:54, properties:{id:"SR2.1", title:"Authorization Enforcement"}}, {_id:55, properties:{id:"SR3.1", title:"Communication Integrity"}}, {_id:56, properties:{id:"SR7.1", title:"Least Privilege"}}, {_id:57, properties:{id:"SR7.7", title:"Least Functionality"}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Requirement;
UNWIND [{_id:48, properties:{protocol:"Modbus", port:502}}, {_id:49, properties:{protocol:"OPC-UA", port:4840}}, {_id:50, properties:{protocol:"HTTPS", port:443}}, {_id:51, properties:{protocol:"SSH", port:22}}, {_id:158, properties:{protocol:"EtherNet/IP", port:44818}}, {_id:159, properties:{protocol:"Profinet", port:34962}}, {_id:160, properties:{protocol:"FTP", port:21}}, {_id:161, properties:{protocol:"Telnet", port:23}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Port;
UNWIND [{name:"Jack", properties:{}}, {name:"Operator Jack", properties:{}}, {name:"Operator Lina", properties:{}}, {name:"Maintenance Ravi", properties:{}}, {name:"Maintenance Bob", properties:{}}, {name:"Engineer Alice", properties:{}}, {name:"Engineer Chen", properties:{}}, {name:"Administrator Sam", properties:{}}, {name:"Security Analyst Maya", properties:{}}, {name:"Operator David", properties:{}}, {name:"Maintenance Sara", properties:{}}, {name:"Engineer Victor", properties:{}}, {name:"Engineer Maria", properties:{}}] AS row
CREATE (n:Human{name: row.name}) SET n += row.properties;
UNWIND [{name:"Operator", properties:{}}, {name:"Maintainer", properties:{}}, {name:"Engineer", properties:{}}, {name:"Administrator", properties:{}}, {name:"SecurityAnalyst", properties:{}}] AS row
CREATE (n:Role{name: row.name}) SET n += row.properties;
UNWIND [{_id:153, properties:{name:"Missing Authentication"}}, {_id:154, properties:{name:"Weak Access Control"}}, {_id:155, properties:{name:"Open Insecure Port"}}, {_id:156, properties:{name:"Outdated Firmware"}}, {_id:157, properties:{name:"Excessive Privileges"}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Vulnerability;
UNWIND [{_id:6, properties:{operation:"Control"}}, {_id:7, properties:{operation:"Monitor"}}, {_id:38, properties:{operation:"Control"}}, {_id:39, properties:{operation:"Monitor"}}, {_id:40, properties:{operation:"Configure"}}, {_id:41, properties:{operation:"Maintain"}}, {_id:42, properties:{operation:"UpdateFirmware"}}, {_id:43, properties:{operation:"RemoteAccess"}}, {_id:44, properties:{operation:"ReadLogs"}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Permission;
UNWIND [{_id:45, properties:{name:"Plant Firewall"}}, {_id:46, properties:{name:"DMZ Firewall"}}, {_id:47, properties:{name:"Remote Access Firewall"}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Firewall;
UNWIND [{_id:58, properties:{}}, {_id:59, properties:{}}, {_id:60, properties:{}}, {_id:61, properties:{}}, {_id:62, properties:{}}, {_id:63, properties:{}}, {_id:64, properties:{}}, {_id:65, properties:{}}, {_id:66, properties:{}}, {_id:67, properties:{}}, {_id:68, properties:{}}, {_id:69, properties:{}}, {_id:70, properties:{}}, {_id:71, properties:{}}, {_id:72, properties:{}}, {_id:73, properties:{}}, {_id:74, properties:{}}, {_id:75, properties:{}}, {_id:76, properties:{}}, {_id:77, properties:{}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties;
UNWIND [{_id:78, properties:{}}, {_id:79, properties:{}}, {_id:80, properties:{}}, {_id:81, properties:{}}, {_id:82, properties:{}}, {_id:83, properties:{}}, {_id:84, properties:{}}, {_id:85, properties:{}}, {_id:86, properties:{}}, {_id:87, properties:{}}, {_id:88, properties:{}}, {_id:89, properties:{}}, {_id:90, properties:{}}, {_id:91, properties:{}}, {_id:92, properties:{}}, {_id:93, properties:{}}, {_id:94, properties:{}}, {_id:95, properties:{}}, {_id:96, properties:{}}, {_id:97, properties:{}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties;
UNWIND [{_id:98, properties:{}}, {_id:99, properties:{}}, {_id:100, properties:{}}, {_id:101, properties:{}}, {_id:102, properties:{}}, {_id:103, properties:{}}, {_id:104, properties:{}}, {_id:105, properties:{}}, {_id:106, properties:{}}, {_id:107, properties:{}}, {_id:108, properties:{}}, {_id:109, properties:{}}, {_id:110, properties:{}}, {_id:111, properties:{}}, {_id:112, properties:{}}, {_id:113, properties:{}}, {_id:114, properties:{}}, {_id:115, properties:{}}, {_id:116, properties:{}}, {_id:117, properties:{}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties;
UNWIND [{_id:118, properties:{}}, {_id:119, properties:{}}, {_id:120, properties:{}}, {_id:121, properties:{}}, {_id:122, properties:{}}, {_id:123, properties:{}}, {_id:124, properties:{}}, {_id:125, properties:{}}, {_id:126, properties:{}}, {_id:127, properties:{}}, {_id:128, properties:{}}, {_id:129, properties:{}}, {_id:130, properties:{}}, {_id:131, properties:{}}, {_id:132, properties:{}}, {_id:133, properties:{}}, {_id:134, properties:{}}, {_id:135, properties:{}}, {_id:136, properties:{}}, {_id:137, properties:{}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties;
UNWIND [{_id:138, properties:{}}, {_id:139, properties:{}}, {_id:140, properties:{}}, {_id:141, properties:{}}, {_id:142, properties:{}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties;
UNWIND [{name:"Control Network", properties:{securityLevel:3}}, {name:"Supervisory Network", properties:{securityLevel:2}}, {name:"Safety Network", properties:{securityLevel:4}}, {name:"DMZ", properties:{securityLevel:1}}, {name:"Corporate Network", properties:{securityLevel:1}}] AS row
CREATE (n:Zone{name: row.name}) SET n += row.properties;
:commit
:begin
UNWIND [{start: {_id:6}, end: {name:"PLC Controller"}, properties:{}}, {start: {_id:41}, end: {name:"Robot Arm 1"}, properties:{}}, {start: {_id:41}, end: {name:"Robot Arm 2"}, properties:{}}, {start: {_id:42}, end: {name:"Engineering Workstation"}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:Asset{name: row.end.name})
CREATE (start)-[r:ACCESS_TO]->(end) SET r += row.properties;
UNWIND [{start: {_id:58}, end: {_id:59}, properties:{}}, {start: {_id:60}, end: {_id:59}, properties:{}}, {start: {_id:61}, end: {_id:59}, properties:{}}, {start: {_id:62}, end: {_id:59}, properties:{}}, {start: {_id:63}, end: {_id:64}, properties:{}}, {start: {_id:65}, end: {_id:64}, properties:{}}, {start: {_id:66}, end: {_id:64}, properties:{}}, {start: {_id:67}, end: {_id:59}, properties:{}}, {start: {_id:68}, end: {_id:69}, properties:{}}, {start: {_id:70}, end: {_id:64}, properties:{}}, {start: {_id:71}, end: {_id:72}, properties:{}}, {start: {_id:73}, end: {_id:72}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:IN_ZONE]->(end) SET r += row.properties;
UNWIND [{start: {_id:74}, end: {_id:75}, properties:{}}, {start: {_id:76}, end: {_id:75}, properties:{}}, {start: {_id:77}, end: {_id:78}, properties:{}}, {start: {_id:79}, end: {_id:78}, properties:{}}, {start: {_id:80}, end: {_id:81}, properties:{}}, {start: {_id:82}, end: {_id:81}, properties:{}}, {start: {_id:83}, end: {_id:84}, properties:{}}, {start: {_id:85}, end: {_id:86}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:HAS_ROLE]->(end) SET r += row.properties;
UNWIND [{start: {_id:117}, end: {_id:118}, properties:{}}, {start: {_id:119}, end: {_id:120}, properties:{}}, {start: {_id:121}, end: {_id:122}, properties:{}}, {start: {_id:123}, end: {_id:124}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:USES_PORT]->(end) SET r += row.properties;
UNWIND [{start: {_id:87}, end: {_id:88}, properties:{}}, {start: {_id:87}, end: {_id:89}, properties:{}}, {start: {_id:90}, end: {_id:91}, properties:{}}, {start: {_id:92}, end: {_id:93}, properties:{}}, {start: {_id:94}, end: {_id:95}, properties:{}}, {start: {_id:96}, end: {_id:97}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:HAS_PERMISSION]->(end) SET r += row.properties;
UNWIND [{start: {_id:131}, end: {_id:132}, properties:{}}, {start: {_id:133}, end: {_id:134}, properties:{}}, {start: {_id:135}, end: {_id:136}, properties:{}}, {start: {_id:137}, end: {_id:138}, properties:{}}, {start: {_id:139}, end: {_id:140}, properties:{}}, {start: {_id:141}, end: {_id:142}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:APPLIES_TO]->(end) SET r += row.properties;
UNWIND [{start: {name:"Robot Arm 3"}, end: {name:"Control Network"}, properties:{}}, {start: {name:"Robot Arm 4"}, end: {name:"Control Network"}, properties:{}}, {start: {name:"Quality Inspection Camera"}, end: {name:"Supervisory Network"}, properties:{}}, {start: {name:"Quality Inspection Camera"}, end: {name:"Supervisory Network"}, properties:{}}, {start: {name:"Packaging Robot"}, end: {name:"Control Network"}, properties:{}}, {start: {name:"Assembly Robot"}, end: {name:"Control Network"}, properties:{}}, {start: {name:"Industrial Sensor Hub"}, end: {name:"Supervisory Network"}, properties:{}}, {start: {name:"Industrial Sensor Hub"}, end: {name:"Supervisory Network"}, properties:{}}] AS row
MATCH (start:Asset{name: row.start.name})
MATCH (end:Zone{name: row.end.name})
CREATE (start)-[r:IN_ZONE]->(end) SET r += row.properties;
UNWIND [{start: {name:"Control Network"}, end: {name:"Supervisory Network"}, properties:{}}, {start: {name:"Control Network"}, end: {name:"Supervisory Network"}, properties:{}}, {start: {name:"Control Network"}, end: {name:"Safety Network"}, properties:{}}, {start: {name:"Control Network"}, end: {name:"Safety Network"}, properties:{}}, {start: {name:"Supervisory Network"}, end: {name:"Control Network"}, properties:{}}, {start: {name:"Supervisory Network"}, end: {name:"Control Network"}, properties:{}}, {start: {name:"Supervisory Network"}, end: {name:"DMZ"}, properties:{}}, {start: {name:"Supervisory Network"}, end: {name:"DMZ"}, properties:{}}, {start: {name:"Safety Network"}, end: {name:"Control Network"}, properties:{}}, {start: {name:"Safety Network"}, end: {name:"Control Network"}, properties:{}}, {start: {name:"DMZ"}, end: {name:"Supervisory Network"}, properties:{}}, {start: {name:"DMZ"}, end: {name:"Supervisory Network"}, properties:{}}, {start: {name:"DMZ"}, end: {name:"Corporate Network"}, properties:{}}, {start: {name:"DMZ"}, end: {name:"Corporate Network"}, properties:{}}, {start: {name:"Corporate Network"}, end: {name:"DMZ"}, properties:{}}, {start: {name:"Corporate Network"}, end: {name:"DMZ"}, properties:{}}] AS row
MATCH (start:Zone{name: row.start.name})
MATCH (end:Zone{name: row.end.name})
CREATE (start)-[r:CONNECTS_TO]->(end) SET r += row.properties;
UNWIND [{start: {name:"Operator David"}, end: {name:"Operator"}, properties:{}}, {start: {name:"Maintenance Sara"}, end: {name:"Maintainer"}, properties:{}}, {start: {name:"Maintenance Sara"}, end: {name:"Maintainer"}, properties:{}}, {start: {name:"Engineer Victor"}, end: {name:"Engineer"}, properties:{}}, {start: {name:"Engineer Victor"}, end: {name:"Engineer"}, properties:{}}, {start: {name:"Engineer Maria"}, end: {name:"Engineer"}, properties:{}}, {start: {name:"Engineer Maria"}, end: {name:"Engineer"}, properties:{}}] AS row
MATCH (start:Human{name: row.start.name})
MATCH (end:Role{name: row.end.name})
CREATE (start)-[r:HAS_ROLE]->(end) SET r += row.properties;
UNWIND [{start: {_id:98}, end: {_id:99}, properties:{}}, {start: {_id:98}, end: {_id:100}, properties:{}}, {start: {_id:101}, end: {_id:102}, properties:{}}, {start: {_id:103}, end: {_id:104}, properties:{}}, {start: {_id:105}, end: {_id:99}, properties:{}}, {start: {_id:106}, end: {_id:104}, properties:{}}, {start: {_id:107}, end: {_id:108}, properties:{}}, {start: {_id:109}, end: {_id:110}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:ACCESS_TO]->(end) SET r += row.properties;
UNWIND [{start: {name:"PLC Controller 1"}, end: {_id:153}, properties:{}}, {start: {name:"Robot Arm 1"}, end: {_id:154}, properties:{}}, {start: {name:"VPN Gateway"}, end: {_id:155}, properties:{}}] AS row
MATCH (start:Asset{name: row.start.name})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:HAS_VULNERABILITY]->(end) SET r += row.properties;
UNWIND [{start: {_id:125}, end: {_id:126}, properties:{}}, {start: {_id:127}, end: {_id:128}, properties:{}}, {start: {_id:129}, end: {_id:130}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:FILTERS]->(end) SET r += row.properties;
UNWIND [{start: {_id:111}, end: {_id:112}, properties:{}}, {start: {_id:113}, end: {_id:114}, properties:{}}, {start: {_id:115}, end: {_id:116}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:PROTECTS]->(end) SET r += row.properties;
UNWIND [{start: {name:"PLC Controller 1"}, end: {_id:158}, properties:{}}, {start: {name:"PLC Controller 1"}, end: {_id:158}, properties:{}}, {start: {name:"SCADA Server"}, end: {_id:160}, properties:{}}, {start: {name:"Engineering Workstation"}, end: {_id:161}, properties:{}}, {start: {name:"Engineering Workstation"}, end: {_id:161}, properties:{}}] AS row
MATCH (start:Asset{name: row.start.name})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:USES_PORT]->(end) SET r += row.properties;
UNWIND [{start: {name:"Maintainer"}, end: {_id:42}, properties:{}}, {start: {name:"Maintainer"}, end: {_id:42}, properties:{}}, {start: {name:"Maintainer"}, end: {_id:42}, properties:{}}, {start: {name:"Maintainer"}, end: {_id:42}, properties:{}}, {start: {name:"Engineer"}, end: {_id:41}, properties:{}}, {start: {name:"Engineer"}, end: {_id:41}, properties:{}}, {start: {name:"Engineer"}, end: {_id:41}, properties:{}}, {start: {name:"Engineer"}, end: {_id:41}, properties:{}}, {start: {name:"Engineer"}, end: {_id:42}, properties:{}}, {start: {name:"Engineer"}, end: {_id:42}, properties:{}}, {start: {name:"Engineer"}, end: {_id:42}, properties:{}}, {start: {name:"Engineer"}, end: {_id:42}, properties:{}}] AS row
MATCH (start:Role{name: row.start.name})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:HAS_PERMISSION]->(end) SET r += row.properties;
:commit
:begin
MATCH (n:`UNIQUE IMPORT LABEL`)  WITH n LIMIT 20000 REMOVE n:`UNIQUE IMPORT LABEL` REMOVE n.`UNIQUE IMPORT ID`;
:commit
:begin
DROP CONSTRAINT UNIQUE_IMPORT_NAME;
:commit
"
