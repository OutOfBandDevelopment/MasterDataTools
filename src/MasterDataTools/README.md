# Master Data Tools

## Intent

The intent of this project is to build a tool that makes master data management easy.  Planned schema management
will be done using SQL Server projects.  

Data management should be targeted to use SQLCMD scripts that can be 
used as post deployments scripts for noted projects.  Configurable options would be managed though SQL Extended 
properties for persistence. Required SQL scripts will be external standalone scripts that do not require 
modification to existing databases or schema.  Inital external persitence would be done with JSON files but could 
optionally support other formats such as XML or YML (Advantage of XML and JSON is they can be execute directly 
within sql and note require exteral tooling.)

