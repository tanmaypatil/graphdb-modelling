// Load Role nodes from CSV
// This should be run first as employees reference roles

LOAD CSV WITH HEADERS FROM 'file:///role.csv' AS row
MERGE (r:Role {id: row.id})
SET r.name = row.name,
    r.department = row.department;
