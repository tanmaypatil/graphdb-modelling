# Do a domain modelling for graph database .

## Models 
Trying to model a use case where we are checking usefulness of graph db for finding co relations 
Models are as below 
  * employee 
  * role 
  * Leaves 
Each model has a unique key, called as id. 

# Relations 
  * employee has a role 
    (employee)-[:HAS_ROLE]->(role)
  * employee take leave(s)
    (employee)-[:TAKE_LEAVE]->(leave)

## Data 
Data has been kept in data folder.
Data is in csv format .
Each model will have its own csv.  

## Tech stack
* database - neo4j
* langauge - python 

## Database 
  host : http://localhost:7474
  user : neo4j
  password : password
  db name : leaves

## Cypher queries 
  ### storing queries
  All the queries to be stored in cypher folder.
  Further sub folders need to be used.
  * insert - Folder  would be store queries to load from csv and insert into db
  * queries - Folder would be store queries to test model

  ### General instructions 
  * use merge so that duplicate nodes are not created 
  
  
