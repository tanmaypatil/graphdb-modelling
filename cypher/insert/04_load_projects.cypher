// Load Project nodes from CSV
// This should be run before creating WORKS_ON relationships

LOAD CSV WITH HEADERS FROM 'file:///projects.csv' AS row
MERGE (p:Project {project_id: row.project_id})
SET p.project_name = row.project_name,
    p.project_description = row.project_description,
    p.project_status = row.project_status;
