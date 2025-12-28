// Load Leave nodes from CSV and create TAKE_LEAVE relationships
// This should be run after employees are loaded

LOAD CSV WITH HEADERS FROM 'file:///Leaves.csv' AS row
MERGE (l:Leave {id: row.id})
SET l.leave_type = row.leave_type,
    l.leave_from = date(row.leave_from),
    l.leave_to = date(row.leave_to),
    l.status = row.status
WITH l, row
MATCH (e:Employee {id: row.employee_id})
MERGE (e)-[:TAKE_LEAVE]->(l);
