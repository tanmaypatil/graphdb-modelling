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
