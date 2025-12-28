# Do a domain modelling for graph database .

## Objective 
 Create a neo4j based graph modelling and experimenting with queries .
 Will be constantly updating models or adding models.
 would expect cypher queries for graph creation and graph queries updated .

## Models
Trying to model a use case where we are checking usefulness of graph db for finding co relations
Models are as below
  * employee
  * role
  * Leaves
  * projects
Each model has a unique key, called as id (or project_id for projects).

# Relations
  * employee has a role
    (employee)-[:HAS_ROLE]->(role)
  * employee take leave(s)
    (employee)-[:TAKE_LEAVE]->(leave)
  * employee works on project(s)
    (employee)-[:WORKS_ON]->(project)

## Data 
  Data has been kept in data folder.
  Each data file is in csv format .
  Each model will have its own csv. 
  Each file has to copied to neo4j import directory path.

## Tech stack
* database - neo4j
* langauge - python 

## Database
  Browser URL : http://localhost:7474
  Bolt URL : bolt://localhost:7687
  user : neo4j
  password : password
  db name : neo4j

## Cypher queries 
  ### storing queries
  All the queries to be stored in cypher folder.
  Further sub folders need to be used.
  * insert - Folder  would be store queries to load from csv and insert into db
  * queries - Folder would be store queries to test model

  ### General instructions 
  * use merge so that duplicate nodes are not created 
  
  
