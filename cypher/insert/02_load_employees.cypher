// Load Employee nodes from CSV and create HAS_ROLE relationships
// This should be run after roles are loaded

LOAD CSV WITH HEADERS FROM 'file:///employee.csv' AS row
MERGE (e:Employee {id: row.id})
SET e.name = row.name,
    e.department = row.department,
    e.salary = toInteger(row.salary)
WITH e, row
MATCH (r:Role {id: row.role})
MERGE (e)-[:HAS_ROLE]->(r);
