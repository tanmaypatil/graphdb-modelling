// Load Employee nodes from CSV and create HAS_ROLE and WORKS_ON relationships
// This should be run after roles and projects are loaded

LOAD CSV WITH HEADERS FROM 'file:///employee.csv' AS row
MERGE (e:Employee {id: row.id})
SET e.name = row.name,
    e.department = row.department,
    e.salary = toInteger(row.salary)
WITH e, row
MATCH (r:Role {id: row.role})
MERGE (e)-[:HAS_ROLE]->(r)
WITH e, row
MATCH (p:Project {project_id: row.project_id})
MERGE (e)-[:WORKS_ON]->(p);
