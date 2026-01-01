// Load Skills from CSV
// This should be run after loading roles (01) and before loading employee skills (06)
// Ensure skills.csv is in the Neo4j import directory

LOAD CSV WITH HEADERS FROM 'file:///skills.csv' AS row
MERGE (s:Skill {id: row.id})
SET s.name = row.name,
    s.category = row.category,
    s.description = row.description;

// Verify skills loaded
MATCH (s:Skill)
RETURN count(s) as total_skills;

// Show sample skills by category
MATCH (s:Skill)
RETURN s.category, collect(s.name) as skills
ORDER BY s.category;
