
WITH [Tables] AS(
	SELECT
		'[' + [schemas].[name] + '].[' + [tables].[name] + ']'  AS[TableName]
		, [tables].[object_id] AS[TableId]
		, [schemas].[name] AS[Schema]
		, [tables].[name] AS [Table]
	FROM [sys].[schemas]
	INNER JOIN [sys].[tables]
		ON [tables].[schema_id] = [schemas].[schema_id]
), [Columns] AS (
	SELECT 
		 [columns].[object_id]
		 ,[columns].[name] AS [ColumnName]
		 ,[columns].[column_id] AS [ColumnOrder]
		 --,'JSON_VALUE(@json, ''$[0].'+ [columns].[name] +''') AS ['+[columns].[name]+']' AS 
		 ,[types].[name] AS [Type]
		 ,[types].[name] + ISNULL('(' + CASE [types].[name] 
			WHEN 'binary' THEN CAST([columns].[max_length] AS NVARCHAR)
			WHEN 'char' THEN CAST([columns].[max_length] AS NVARCHAR)
			WHEN 'nchar' THEN CAST([columns].[max_length] AS NVARCHAR)
		
			WHEN 'time' THEN CAST([columns].[scale] AS NVARCHAR)
			WHEN 'datetime2' THEN CAST([columns].[scale] AS NVARCHAR)
			WHEN 'datetimeoffset' THEN CAST([columns].[scale] AS NVARCHAR)
		
			WHEN 'decimal' THEN CAST([columns].[precision] AS NVARCHAR) + ', ' + CAST([columns].[scale] AS NVARCHAR)
			WHEN 'numeric' THEN CAST([columns].[precision] AS NVARCHAR) + ', ' + CAST([columns].[scale] AS NVARCHAR)
		
			WHEN 'varbinary' THEN CASE [columns].[max_length]  WHEN -1 THEN 'MAX' ELSE CAST([columns].[max_length] AS NVARCHAR) END
			WHEN 'varchar' THEN CASE [columns].[max_length]  WHEN -1 THEN 'MAX' ELSE CAST([columns].[max_length] AS NVARCHAR) END
			WHEN 'nvarchar' THEN CASE [columns].[max_length]  WHEN -1 THEN 'MAX' ELSE CAST([columns].[max_length] AS NVARCHAR) END
		 END + ')','') AS [TypeDefinition]
		 ,[columns].[is_nullable]
		 ,[columns].[is_rowguidcol]
		 ,[columns].[is_computed]
		 ,[columns].[is_identity]
	FROM [sys].[columns]
	INNER JOIN [sys].[types]
		ON [columns].[user_type_id] = [types].[user_type_id]
			AND [columns].[system_type_id] = [types].[system_type_id]
)

	SELECT 
		[Tables].*
		,'SET IDENTITY_INSERT ' + [Tables].[TableName] + ' ON ' AS [InsertIdentityOn]
		,'SET IDENTITY_INSERT ' + [Tables].[TableName] + ' ON ' AS [InsertIdentityOff]

	FROM [Columns]
	INNER JOIN [Tables]
		ON [Columns].[object_id] = [Tables].[TableId]
	WHERE
		[Columns].[is_identity] = 1
	ORDER BY
		[Tables].[Schema]
		,[Tables].[Table]