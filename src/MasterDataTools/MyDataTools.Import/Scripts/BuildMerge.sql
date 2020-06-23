DECLARE @Schema NVARCHAR(255) = 'Vehicles',
		@Table NVARCHAR(255) = 'Drivers',
		@AddMissing BIT = 1,
		@Cleanup BIT = 1,
		@Output BIT = 1
		;

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

	FROM [sys].[columns]
	INNER JOIN [sys].[types]
		ON [columns].[user_type_id] = [types].[user_type_id]
			AND [columns].[system_type_id] = [types].[system_type_id]
), [PrimaryKeys] As (
	SELECT 
		[indexes].[object_id]
		,[indexes].[name] AS [IndexName]
		,[columns].[name] AS [ColumnName]
		,[columns].[column_id]
		,[index_columns].[index_column_id] AS [IndexColumnOrder]
	FROM [sys].[indexes]
	INNER JOIN [sys].[index_columns]
		ON [indexes].[object_id] = [index_columns].[object_id]
			AND [indexes].[index_id] = [index_columns].[index_id]
	INNER JOIN [sys].[columns]
		ON [columns].[object_id] = [index_columns].[object_id]
			AND [columns].[column_id] = [index_columns].[column_id]
	WHERE
		[indexes].[is_primary_key] = 1
), [MergeKeyOverride] AS (	
	SELECT 
		[extended_properties].[major_id] AS [object_id]
		,[extended_properties].[name] AS [IndexName]
		,[columns].[name] AS [ColumnName]
		,[columns].[column_id]
		,DENSE_RANK() OVER (
			PARTITION BY [extended_properties].[major_id]
			ORDER BY [extended_properties].[value] 
			) AS [IndexColumnOrder]
	FROM [sys].[extended_properties]
	INNER JOIN [sys].[columns]
		ON [columns].[object_id] = [extended_properties].[major_id]
			AND [columns].[column_id] = [extended_properties].[minor_id]
	WHERE
		[extended_properties].[class] = 1 /*OBJECT_OR_COLUMN*/
		AND [extended_properties].[name] = '__MDT_MergeKey'
), [MergeKeys] AS (
	SELECT *
	FROM [PrimaryKeys]
	WHERE 
		NOT EXISTS(
			SELECT *
			FROM [MergeKeyOverride]
			WHERE 
				[MergeKeyOverride].[object_id] = [PrimaryKeys].[object_id]
		)
	UNION ALL
	SELECT *
	FROM [MergeKeyOverride]
), [MergeFields] AS (
	SELECT 
		[object_id]
		,[IndexName]
		,STRING_AGG(CAST(
			CHAR(9) + 'target.['+[ColumnName]+'] = source.['+[ColumnName]+']'
				AS NVARCHAR(MAX)), ' AND ' + CHAR(13) + CHAR(10)) 
			WITHIN GROUP (ORDER BY [IndexColumnOrder]) AS [MergeOn]
	FROM [MergeKeys]
	GROUP BY 
		[object_id]
		,[IndexName]
), [SourceFields] AS (
	SELECT 
		[Columns].[object_id]
		,STRING_AGG(CAST(
			CHAR(9) + CHAR(9) + '[' + [Columns].[ColumnName] + '] ' + [Columns].[TypeDefinition] + ' ''$.' + [Columns].[ColumnName] + ''''
				AS NVARCHAR(MAX)),',' + CHAR(13) + CHAR(10))
			WITHIN GROUP (ORDER BY [Columns].[ColumnOrder]) AS [SourceFields]
	FROM [Columns]
	GROUP BY 
		[Columns].[object_id]
), [UpdatableColumns] AS (
	SELECT 
		[columns].[object_id]
		,[columns].[name] AS [ColumnName]
		,[columns].[column_id] AS [ColumnOrder]
	FROM [sys].[columns]
	WHERE NOT EXISTS (
		SELECT 
			*
		FROM [MergeKeys]
		WHERE		
			[columns].[object_id] = [MergeKeys].[object_id]
			AND [columns].[column_id] = [MergeKeys].[column_id]
		)
		AND [columns].[is_identity] = 0 /* Can't update identity columns so don't worry about them. */
), [MergeUpdateFields] AS (
	SELECT 
		[NPK].[object_id]
		,STRING_AGG(CAST(
			CHAR(9) + 'target.[' + [NPK].[ColumnName] + '] != source.[' + [NPK].[ColumnName] + ']'
				AS NVARCHAR(MAX)),' OR ' + CHAR(13) + CHAR(10))
			WITHIN GROUP (ORDER BY [NPK].[ColumnOrder]) AS [NotMatchedFields]
		,STRING_AGG(CAST(
			CHAR(9) + CHAR(9) + '[' + [NPK].[ColumnName] + '] = source.[' + [NPK].[ColumnName] + ']'
				AS NVARCHAR(MAX)),',' + CHAR(13) + CHAR(10))
			WITHIN GROUP (ORDER BY [NPK].[ColumnOrder]) AS [UpdateSetFields]
		--,*
	FROM [UpdatableColumns] AS [NPK]
	GROUP BY 
		[NPK].[object_id]
), [InsertFields] AS (
	SELECT 
		[columns].[object_id]
		,STRING_AGG(CAST(
			CHAR(9) + CHAR(9) + '[' + [columns].[name] + ']'
				AS NVARCHAR(MAX)),',' + CHAR(13) + CHAR(10))
			WITHIN GROUP (ORDER BY [columns].[column_id]) AS [AllFields]
		,STRING_AGG(CAST(
			CHAR(9) + CHAR(9) + 'source.[' + [columns].[name] + ']'
				AS NVARCHAR(MAX)),',' + CHAR(13) + CHAR(10))
			WITHIN GROUP (ORDER BY [columns].[column_id]) AS [AllSourceFields]
	FROM [sys].[columns]
	GROUP BY
		[columns].[object_id]
), [MergeModel] AS (
	SELECT
		[Tables].[TableName]
		,[Tables].[TableId]
		,[Tables].[Schema]
		,[Tables].[Table]
		,[SourceFields].[SourceFields]
		,[MergeFields].[MergeOn]
		,[MergeUpdateFields].[NotMatchedFields]
		,[MergeUpdateFields].[UpdateSetFields]
		,[InsertFields].[AllFields]
		,[InsertFields].[AllSourceFields]
	FROM [Tables]
	LEFT OUTER JOIN [SourceFields]
		ON [SourceFields].[object_id] = [Tables].[TableId]
	LEFT OUTER JOIN [MergeFields]
		ON [MergeFields].[object_id] = [Tables].[TableId]
	LEFT OUTER JOIN [MergeUpdateFields]
		ON [MergeUpdateFields].[object_id] = [Tables].[TableId]		
	LEFT OUTER JOIN [InsertFields]
		ON [InsertFields].[object_id] = [Tables].[TableId]		
)
	SELECT CAST(
		'MERGE ' + [MergeModel].[TableName] + ' AS target' + CHAR(13) + CHAR(10) + 
		'USING (' + CHAR(13) + CHAR(10) +
		CHAR(9) + 'SELECT *' + CHAR(13) + CHAR(10) +
		CHAR(9) + 'FROM OPENJSON(@json)' + CHAR(13) + CHAR(10) +
		CHAR(9) + 'WITH (' + CHAR(13) + CHAR(10) +
		[MergeModel].[SourceFields] + CHAR(13) + CHAR(10) +
		CHAR(9) + ')' + CHAR(13) + CHAR(10) +
		') AS source  ON ' + CHAR(13) + CHAR(10) +
		[MergeModel].[MergeOn] + CHAR(13) + CHAR(10) +

		ISNULL(
			'WHEN MATCHED AND (' + CHAR(13) + CHAR(10) + 
			[MergeModel].[NotMatchedFields] + CHAR(13) + CHAR(10) + 
			CHAR(9) + ') THEN UPDATE SET' + CHAR(13) + CHAR(10) +  
			[MergeModel].[UpdateSetFields]
			,'') + CHAR(13) + CHAR(10) +
			
		ISNULL(CASE @AddMissing WHEN 1 THEN
			'WHEN NOT MATCHED BY TARGET' + CHAR(13) + CHAR(10) + 
			CHAR(9) + 'THEN INSERT (' + CHAR(13) + CHAR(10) + 
			[MergeModel].[AllFields] + CHAR(13) + CHAR(10) + 
			CHAR(9) + ') VALUES (' + CHAR(13) + CHAR(10) +  
			[MergeModel].[AllSourceFields] + CHAR(13) + CHAR(10) + 
			CHAR(9) + ')'
		END,'') + CHAR(13) + CHAR(10) +	
		
		ISNULL(CASE @Cleanup WHEN 1 THEN
			'WHEN NOT MATCHED BY SOURCE' + CHAR(13) + CHAR(10) + 
			CHAR(9) + 'THEN DELETE'
		END,'') + CHAR(13) + CHAR(10) +
		
		ISNULL(CASE @Output WHEN 1 THEN
			'OUTPUT ' + CHAR(13) + CHAR(10) + 
			CHAR(9) + '$action,' + CHAR(13) + CHAR(10) + 
			CHAR(9) + 'inserted.*,' + CHAR(13) + CHAR(10) + 
			CHAR(9) + 'deleted.*' + CHAR(13) + CHAR(10)
		END,'') + CHAR(13) + CHAR(10) +

		';'
		AS XML)
		
	FROM [MergeModel]
	WHERE
		[MergeModel].[Schema] = @Schema
		AND [MergeModel].[Table] = @Table