/*
By default the "merge key" will be the primary key.  you can override this by adding extended properties to related columns
This will also work for cases that do not have a primary key at all.
*/
EXEC sp_addextendedproperty   
	@name = N'__MDT_MergeKey', @value = '0',  
	@level0type = N'Schema', @level0name = 'dbo',  
	@level1type = N'Table', @level1name = '_ImportedData',   
	@level2type = N'Column',@level2name = 'SessionID';  
	
EXEC sp_addextendedproperty   
	@name = N'__MDT_MergeKey', @value = '1',  
	@level0type = N'Schema', @level0name = 'dbo',  
	@level1type = N'Table', @level1name = '_ImportedData',   
	@level2type = N'Column',@level2name = 'HostID';  
	;  
	
EXEC sp_addextendedproperty   
	@name = N'__MDT_MergeKey', @value = '2',  
	@level0type = N'Schema', @level0name = 'dbo',  
	@level1type = N'Table', @level1name = '_ImportedData',   
	@level2type = N'Column',@level2name = 'AttID';  ;  
	
EXEC sp_addextendedproperty   
	@name = N'__MDT_MergeKey', @value = '3',  
	@level0type = N'Schema', @level0name = 'dbo',  
	@level1type = N'Table', @level1name = '_ImportedData',   
	@level2type = N'Column',@level2name = 'ServerDateTime';  ;  
	
EXEC sp_addextendedproperty   
	@name = N'__MDT_MergeKey', @value = '4',  
	@level0type = N'Schema', @level0name = 'dbo',  
	@level1type = N'Table', @level1name = '_ImportedData',   
	@level2type = N'Column',@level2name = 'LogTriggerType';  
	
EXEC sp_addextendedproperty   
	@name = N'__MDT_MergeKey', @value = '5',  
	@level0type = N'Schema', @level0name = 'dbo',  
	@level1type = N'Table', @level1name = '_ImportedData',   
	@level2type = N'Column',@level2name = 'LogTriggerAction';  