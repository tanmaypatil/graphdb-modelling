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
