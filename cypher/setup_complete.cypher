// ============================================================
// Complete setup script for Leaves Management System
// Run this in Neo4j Browser (http://localhost:7474)
// Make sure CSV files are in the import directory first
// ============================================================

// STEP 1: Clear existing data (OPTIONAL - uncomment if needed)
// WARNING: This will delete ALL data in the current database
// MATCH (n) DETACH DELETE n;

// ============================================================
// STEP 2: Load Roles
// ============================================================
LOAD CSV WITH HEADERS FROM 'file:///role.csv' AS row
MERGE (r:Role {id: row.id})
SET r.name = row.name,
    r.department = row.department;

// ============================================================
// STEP 3: Load Employees and create HAS_ROLE relationships
// ============================================================
LOAD CSV WITH HEADERS FROM 'file:///employee.csv' AS row
MERGE (e:Employee {id: row.id})
SET e.name = row.name,
    e.department = row.department,
    e.salary = toInteger(row.salary)
WITH e, row
MATCH (r:Role {id: row.role})
MERGE (e)-[:HAS_ROLE]->(r);

// ============================================================
// STEP 4: Load Leaves and create TAKE_LEAVE relationships
// ============================================================
LOAD CSV WITH HEADERS FROM 'file:///Leaves.csv' AS row
MERGE (l:Leave {id: row.id})
SET l.leave_type = row.leave_type,
    l.leave_from = date(row.leave_from),
    l.leave_to = date(row.leave_to),
    l.status = row.status
WITH l, row
MATCH (e:Employee {id: row.employee_id})
MERGE (e)-[:TAKE_LEAVE]->(l);

// ============================================================
// STEP 5: Verify the data loaded correctly
// ============================================================

// Count all nodes
MATCH (n) RETURN labels(n)[0] AS NodeType, count(n) AS Count;

// Count all relationships
MATCH ()-[r]->() RETURN type(r) AS RelationshipType, count(r) AS Count;

// View sample data
MATCH (e:Employee)-[:HAS_ROLE]->(r:Role)
RETURN e.name AS Employee, r.name AS Role, e.department AS Department
LIMIT 5;
