// Test queries to validate the graph database model

// 1. Get all employees with their roles
MATCH (e:Employee)-[:HAS_ROLE]->(r:Role)
RETURN e.name AS employee_name, e.department AS department, r.name AS role_name
ORDER BY e.name;

// 2. Get all leaves taken by a specific employee
MATCH (e:Employee {name: "Subodh bhave"})-[:TAKE_LEAVE]->(l:Leave)
RETURN e.name AS employee_name, l.leave_type AS leave_type,
       l.leave_from AS from_date, l.leave_to AS to_date, l.status AS status;

// 3. Get all employees in Engineering department with their roles
MATCH (e:Employee)-[:HAS_ROLE]->(r:Role)
WHERE e.department = "Engineering"
RETURN e.name AS employee_name, r.name AS role_name, e.salary AS salary
ORDER BY e.salary DESC;

// 4. Get all approved leaves with employee details
MATCH (e:Employee)-[:TAKE_LEAVE]->(l:Leave)
WHERE l.status = "Approved"
RETURN e.name AS employee_name, l.leave_type AS leave_type,
       l.leave_from AS from_date, l.leave_to AS to_date;

// 5. Count leaves by type
MATCH (l:Leave)
RETURN l.leave_type AS leave_type, count(l) AS total_leaves
ORDER BY total_leaves DESC;

// 6. Get employees with pending leaves
MATCH (e:Employee)-[:TAKE_LEAVE]->(l:Leave)
WHERE l.status = "Pending"
RETURN e.name AS employee_name, e.department AS department,
       l.leave_type AS leave_type, l.leave_from AS from_date;

// 7. Get all roles in a specific department
MATCH (r:Role)
WHERE r.department = "Engineering"
RETURN r.name AS role_name, r.department AS department;

// 8. Get employee count by role
MATCH (e:Employee)-[:HAS_ROLE]->(r:Role)
RETURN r.name AS role_name, count(e) AS employee_count
ORDER BY employee_count DESC;

// 9. Get complete graph structure for a specific employee
MATCH path = (e:Employee {name: "Subodh bhave"})-[*1..2]-(connected)
RETURN path;

// 10. Get all employees with their roles and leaves
MATCH (e:Employee)-[:HAS_ROLE]->(r:Role)
OPTIONAL MATCH (e)-[:TAKE_LEAVE]->(l:Leave)
RETURN e.name AS employee_name, r.name AS role_name,
       collect({type: l.leave_type, from: l.leave_from, to: l.leave_to, status: l.status}) AS leaves;

// ============================================================
// PROJECT-RELATED QUERIES
// ============================================================

// 11. Get all employees working on a specific project
MATCH (e:Employee)-[:WORKS_ON]->(p:Project {project_id: "P1"})
RETURN e.name AS employee_name, e.department AS department,
       p.project_name AS project_name, p.project_status AS status;

// 12. Get all projects with employee count
MATCH (p:Project)
OPTIONAL MATCH (e:Employee)-[:WORKS_ON]->(p)
RETURN p.project_name AS project_name, p.project_status AS status,
       count(e) AS employee_count
ORDER BY employee_count DESC;

// 13. Get all active projects with their team members
MATCH (p:Project {project_status: "Active"})
OPTIONAL MATCH (e:Employee)-[:WORKS_ON]->(p)
RETURN p.project_name AS project,
       collect(e.name) AS team_members,
       count(e) AS team_size
ORDER BY team_size DESC;

// 14. Get employee with their complete profile (role, project, leaves)
MATCH (e:Employee)-[:HAS_ROLE]->(r:Role)
OPTIONAL MATCH (e)-[:WORKS_ON]->(p:Project)
OPTIONAL MATCH (e)-[:TAKE_LEAVE]->(l:Leave)
RETURN e.name AS employee,
       r.name AS role,
       p.project_name AS project,
       count(l) AS total_leaves
ORDER BY e.name;

// 15. Find employees working on same project
MATCH (e1:Employee)-[:WORKS_ON]->(p:Project)<-[:WORKS_ON]-(e2:Employee)
WHERE e1.name < e2.name  // Avoid duplicates
RETURN p.project_name AS project,
       e1.name AS employee1,
       e2.name AS employee2
ORDER BY project;

// 16. Get projects in Engineering department with team details
MATCH (e:Employee {department: "Engineering"})-[:WORKS_ON]->(p:Project)
MATCH (e)-[:HAS_ROLE]->(r:Role)
RETURN p.project_name AS project,
       collect({name: e.name, role: r.name, salary: e.salary}) AS team_members
ORDER BY p.project_name;

// 17. Find employees on same project who have taken leaves
MATCH (e:Employee)-[:WORKS_ON]->(p:Project)
MATCH (e)-[:TAKE_LEAVE]->(l:Leave)
RETURN p.project_name AS project,
       e.name AS employee,
       l.leave_type AS leave_type,
       l.leave_from AS from_date,
       l.leave_to AS to_date,
       l.status AS leave_status
ORDER BY p.project_name, l.leave_from;

// 18. Get project workload by department
MATCH (e:Employee)-[:WORKS_ON]->(p:Project)
RETURN e.department AS department,
       count(DISTINCT p) AS projects_count,
       count(e) AS employees_assigned
ORDER BY projects_count DESC;

// 19. Find all relationships for a specific employee (comprehensive view)
MATCH path = (e:Employee {name: "Subodh bhave"})-[r]-(connected)
RETURN type(r) AS relationship_type,
       labels(connected)[0] AS connected_to_type,
       CASE
         WHEN 'Role' IN labels(connected) THEN connected.name
         WHEN 'Project' IN labels(connected) THEN connected.project_name
         WHEN 'Leave' IN labels(connected) THEN connected.leave_type
       END AS details;

// 20. Get employees working on multiple projects (if any share projects)
MATCH (e:Employee)-[:WORKS_ON]->(p:Project)
WITH e, count(p) AS project_count
WHERE project_count > 1
RETURN e.name AS employee, project_count
ORDER BY project_count DESC;

// ============================================================
// SKILL-BASED QUERIES
// ============================================================

// 21. Get all employees with a specific skill
MATCH (e:Employee)-[r:HAS_SKILL]->(s:Skill {name: "Java"})
RETURN e.name AS employee,
       e.department AS department,
       r.proficiency_level AS proficiency,
       r.years_of_experience AS years_experience
ORDER BY r.proficiency_level DESC, r.years_of_experience DESC;

// 22. Get all skills for a specific employee
MATCH (e:Employee {name: "Rahul Sharma"})-[r:HAS_SKILL]->(s:Skill)
RETURN e.name AS employee,
       s.name AS skill,
       s.category AS category,
       r.proficiency_level AS proficiency,
       r.years_of_experience AS years_experience
ORDER BY s.category, s.name;

// 23. Find employees with similar skill sets (overlapping skills)
MATCH (e1:Employee)-[:HAS_SKILL]->(skill:Skill)<-[:HAS_SKILL]-(e2:Employee)
WHERE e1.name < e2.name  // Avoid duplicates
WITH e1, e2, collect(skill.name) AS shared_skills, count(skill) AS skill_overlap
WHERE skill_overlap >= 2  // At least 2 shared skills
RETURN e1.name AS employee1,
       e2.name AS employee2,
       skill_overlap AS number_of_shared_skills,
       shared_skills
ORDER BY skill_overlap DESC;

// 24. Get skill distribution by department
MATCH (e:Employee)-[:HAS_SKILL]->(s:Skill)
RETURN e.department AS department,
       s.category AS skill_category,
       count(DISTINCT s) AS unique_skills,
       count(*) AS total_skill_instances
ORDER BY department, skill_category;

// 25. Find experts (proficiency level = "Expert") in each skill
MATCH (e:Employee)-[r:HAS_SKILL {proficiency_level: "Expert"}]->(s:Skill)
RETURN s.name AS skill,
       s.category AS category,
       collect(e.name) AS experts,
       count(e) AS expert_count
ORDER BY expert_count DESC, s.name;

// 26. Find skill gaps in a specific project (skills not present in the team)
// First get all skills in the project
MATCH (e:Employee)-[:WORKS_ON]->(p:Project {project_id: "P1"})
MATCH (e)-[:HAS_SKILL]->(s:Skill)
WITH p, collect(DISTINCT s.id) AS project_skills
// Then find skills not in the project
MATCH (all_skills:Skill)
WHERE NOT all_skills.id IN project_skills
RETURN p.project_name AS project_name,
       all_skills.name AS missing_skill,
       all_skills.category AS category,
       all_skills.description AS description
ORDER BY all_skills.category, all_skills.name;

// 27. Find potential mentors (employees with Expert level who can mentor others with lower proficiency)
MATCH (expert:Employee)-[r1:HAS_SKILL]->(s:Skill)<-[r2:HAS_SKILL]-(learner:Employee)
WHERE r1.proficiency_level = "Expert"
  AND r2.proficiency_level IN ["Beginner", "Intermediate"]
  AND expert.id <> learner.id
RETURN s.name AS skill,
       expert.name AS mentor,
       learner.name AS mentee,
       r2.proficiency_level AS mentee_current_level
ORDER BY s.name, expert.name;

// 28. Get complete skill profile by category for all employees
MATCH (e:Employee)-[r:HAS_SKILL]->(s:Skill)
RETURN e.name AS employee,
       s.category AS skill_category,
       collect({
           skill: s.name,
           proficiency: r.proficiency_level,
           experience: r.years_of_experience
       }) AS skills,
       count(s) AS skills_in_category
ORDER BY e.name, s.category;

// 29. Find employees with complementary skills on the same project
MATCH (e1:Employee)-[:WORKS_ON]->(p:Project)<-[:WORKS_ON]-(e2:Employee)
WHERE e1.name < e2.name
MATCH (e1)-[:HAS_SKILL]->(s1:Skill)
MATCH (e2)-[:HAS_SKILL]->(s2:Skill)
WHERE s1.id <> s2.id  // Different skills
WITH p, e1, e2, collect(DISTINCT s1.name) AS e1_skills, collect(DISTINCT s2.name) AS e2_skills
RETURN p.project_name AS project,
       e1.name AS employee1,
       e2.name AS employee2,
       e1_skills,
       e2_skills
ORDER BY p.project_name;

// 30. Find skill diversity in projects (unique skills and categories per project)
MATCH (e:Employee)-[:WORKS_ON]->(p:Project)
MATCH (e)-[:HAS_SKILL]->(s:Skill)
RETURN p.project_name AS project,
       count(DISTINCT s) AS unique_skills,
       count(DISTINCT s.category) AS skill_categories,
       collect(DISTINCT s.category) AS categories_covered
ORDER BY unique_skills DESC;

// 31. Get employees with skills in multiple categories (versatile employees)
MATCH (e:Employee)-[:HAS_SKILL]->(s:Skill)
WITH e, collect(DISTINCT s.category) AS categories, count(DISTINCT s.category) AS category_count
WHERE category_count >= 2
RETURN e.name AS employee,
       e.department AS department,
       category_count AS number_of_categories,
       categories
ORDER BY category_count DESC, e.name;

// 32. Find all Programming Language skills and who has them
MATCH (e:Employee)-[r:HAS_SKILL]->(s:Skill {category: "Programming Language"})
RETURN s.name AS programming_language,
       collect({
           employee: e.name,
           proficiency: r.proficiency_level,
           years: r.years_of_experience
       }) AS developers
ORDER BY s.name;

// 33. Multi-hop query: Find skills of colleagues on the same project
MATCH (e:Employee {name: "Subodh bhave"})-[:WORKS_ON]->(p:Project)<-[:WORKS_ON]-(colleague:Employee)
WHERE e.id <> colleague.id
MATCH (colleague)-[r:HAS_SKILL]->(s:Skill)
RETURN colleague.name AS colleague,
       p.project_name AS shared_project,
       collect({
           skill: s.name,
           proficiency: r.proficiency_level
       }) AS colleague_skills
ORDER BY colleague.name;

// 34. Find employees who could be assigned to a project based on required skills
// Example: Find employees with Java AND Spring Boot skills
MATCH (e:Employee)-[:HAS_SKILL]->(s1:Skill {name: "Java"})
MATCH (e)-[:HAS_SKILL]->(s2:Skill {name: "Spring Boot"})
RETURN e.name AS employee,
       e.department AS department,
       collect(DISTINCT {
           role: [(e)-[:HAS_ROLE]->(r:Role) | r.name][0],
           projects: [(e)-[:WORKS_ON]->(p:Project) | p.project_name]
       })[0] AS current_assignment
ORDER BY e.name;

// 35. Get average years of experience by skill category
MATCH (e:Employee)-[r:HAS_SKILL]->(s:Skill)
RETURN s.category AS skill_category,
       round(avg(r.years_of_experience) * 100) / 100 AS avg_years_experience,
       count(*) AS total_instances
ORDER BY avg_years_experience DESC;

// 36. Find skill coverage by proficiency level
MATCH (e:Employee)-[r:HAS_SKILL]->(s:Skill)
RETURN r.proficiency_level AS proficiency,
       count(DISTINCT e) AS employees,
       count(DISTINCT s) AS unique_skills,
       count(*) AS total_skill_instances
ORDER BY
    CASE r.proficiency_level
        WHEN "Expert" THEN 1
        WHEN "Advanced" THEN 2
        WHEN "Intermediate" THEN 3
        WHEN "Beginner" THEN 4
    END;

// 37. Complex pattern: Find knowledge transfer risks
// (employees on same project with unique Expert skills who have approved leaves)
MATCH (e:Employee)-[:WORKS_ON]->(p:Project)
MATCH (e)-[r:HAS_SKILL {proficiency_level: "Expert"}]->(s:Skill)
MATCH (e)-[:TAKE_LEAVE]->(l:Leave {status: "Approved"})
// Check if skill is unique to this employee on the project
WHERE NOT EXISTS {
    MATCH (other:Employee)-[:WORKS_ON]->(p)
    MATCH (other)-[:HAS_SKILL]->(s)
    WHERE other.id <> e.id
}
RETURN p.project_name AS project,
       e.name AS employee_on_leave,
       s.name AS unique_expert_skill,
       l.leave_from AS leave_start,
       l.leave_to AS leave_end
ORDER BY p.project_name, l.leave_from;

// 38. Find the most common skill combinations (skills that appear together)
MATCH (e:Employee)-[:HAS_SKILL]->(s1:Skill)
MATCH (e)-[:HAS_SKILL]->(s2:Skill)
WHERE s1.name < s2.name  // Avoid duplicates and self-combinations
WITH s1.name AS skill1, s2.name AS skill2, count(e) AS employees_with_both
WHERE employees_with_both >= 2
RETURN skill1, skill2, employees_with_both
ORDER BY employees_with_both DESC;

// 39. Get skill upgrade opportunities (employees with Intermediate skills where experts exist)
MATCH (learner:Employee)-[r1:HAS_SKILL {proficiency_level: "Intermediate"}]->(s:Skill)
MATCH (expert:Employee)-[r2:HAS_SKILL {proficiency_level: "Expert"}]->(s)
WHERE learner.id <> expert.id
RETURN learner.name AS employee,
       s.name AS skill,
       r1.years_of_experience AS current_experience,
       collect(expert.name) AS available_experts
ORDER BY learner.name, s.name;

// 40. Complete employee skill matrix (pivot view)
MATCH (e:Employee)
OPTIONAL MATCH (e)-[r:HAS_SKILL]->(s:Skill)
RETURN e.name AS employee,
       e.department AS department,
       collect({
           skill: s.name,
           category: s.category,
           proficiency: r.proficiency_level,
           experience: r.years_of_experience
       }) AS all_skills,
       count(s) AS total_skills
ORDER BY total_skills DESC, e.name;
