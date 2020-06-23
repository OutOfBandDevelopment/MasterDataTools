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


## Usage

### Export
	
The export tool will generate a JSON file per database table.  These files will be a current copy of the existing
database.

### Import

The import tool will use the provided json files and database to generate merge scripts. These scripts will do 
their best to merge the provided json data into the expected database schemas.  

#### Merge key override

One of the features of the merge tool is the abilty to override the primary keys for merge scripts.  This will 
also allow for an artifical match key on tables that do not have primary keys.  

To use this functionality you can add an extended property called `__MDT_MergeKey` to the fields you wish to use
as the merge key.  The value of thse keys will be used to control the order of the fields in the resulting script.
Note, the order of these fields has no really effect other than helping to resolve regenerations and source control 
merges.

##### Example

```SQL
EXEC sp_addextendedproperty   
	@name = N'__MDT_MergeKey', @value = '0',  
	@level0type = N'Schema', @level0name = 'dbo',  
	@level1type = N'Table', @level1name = '_ImportedData',   
	@level2type = N'Column',@level2name = 'Key1';  
	
EXEC sp_addextendedproperty   
	@name = N'__MDT_MergeKey', @value = '1',  
	@level0type = N'Schema', @level0name = 'dbo',  
	@level1type = N'Table', @level1name = '_ImportedData',   
	@level2type = N'Column',@level2name = 'Key2';  
	;  
	
EXEC sp_addextendedproperty   
	@name = N'__MDT_MergeKey', @value = '2',  
	@level0type = N'Schema', @level0name = 'dbo',  
	@level1type = N'Table', @level1name = '_ImportedData',   
	@level2type = N'Column',@level2name = 'Key2';
```