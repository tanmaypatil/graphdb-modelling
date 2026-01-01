// Load Employee-Skill Relationships from CSV
// This should be run after loading employees (02) and skills (05)
// Ensure employee_skills.csv is in the Neo4j import directory

LOAD CSV WITH HEADERS FROM 'file:///employee_skills.csv' AS row
MATCH (e:Employee {id: row.employee_id})
MATCH (s:Skill {id: row.skill_id})
MERGE (e)-[r:HAS_SKILL]->(s)
SET r.proficiency_level = row.proficiency_level,
    r.years_of_experience = toInteger(row.years_of_experience);

// Verify relationships created
MATCH (e:Employee)-[r:HAS_SKILL]->(s:Skill)
RETURN count(r) as total_employee_skills;

// Show employees with their skills
MATCH (e:Employee)-[r:HAS_SKILL]->(s:Skill)
RETURN e.name,
       collect(s.name + ' (' + r.proficiency_level + ')') as skills,
       count(s) as skill_count
ORDER BY e.name;

// Show skill distribution by proficiency level
MATCH (e:Employee)-[r:HAS_SKILL]->(s:Skill)
RETURN r.proficiency_level, count(*) as count
ORDER BY count DESC;
