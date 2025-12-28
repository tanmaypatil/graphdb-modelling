// ============================================================
// Clear Database - Delete all nodes and relationships
// ============================================================
// WARNING: This will permanently delete ALL data in the database
// Use this when you want to start from scratch
// ============================================================

// Delete all nodes and their relationships
MATCH (n) DETACH DELETE n;

// Verify database is empty
MATCH (n) RETURN count(n) AS remaining_nodes;

// ============================================================
// After clearing, you can reload data by running:
// cypher/setup_complete.cypher
// ============================================================
