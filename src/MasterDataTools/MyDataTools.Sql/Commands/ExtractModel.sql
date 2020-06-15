WITH [Tables] AS(
	SELECT
		'[' + [schemas].[name] + '].[' + [tables].[name] + ']'  AS[TableName]
		, [tables].[object_id] AS[TableId]
		, [schemas].[name] AS[Schema]
		, [tables].[name] AS [Table]
	FROM [sys].[schemas]
	INNER JOIN [sys].[tables]
		ON [tables].[schema_id] = [schemas].[schema_id]
), [ForeignKeys]
AS(
	SELECT
		[Parent].[Schema] AS[ParentSchemaName],
		[Parent].[Table] AS[ParentTableName],
		'[' + [foreign_keys].[name] + ']' AS[ForeignKey],
		[Parent].[TableName] AS[Parent],
		(
			SELECT STRING_AGG(CAST('[' + [columns].[name] + ']' AS NVARCHAR(MAX)), ',') WITHIN GROUP(ORDER BY [foreign_key_columns].[constraint_column_id])
			FROM [sys].[foreign_key_columns]
			INNER JOIN[sys].[columns]
				ON[foreign_key_columns].[parent_object_id] = [columns].[object_id]
					AND[foreign_key_columns].[parent_column_id] = [columns].[column_id]
			WHERE
				[foreign_key_columns].[constraint_object_id] = [foreign_keys].[object_id]
			) AS[ParentColumns],
		[Reference].[TableName] AS[Reference],
		(
			SELECT STRING_AGG(CAST('[' + [columns].[name] + ']' AS NVARCHAR(MAX)), ',') WITHIN GROUP(ORDER BY [foreign_key_columns].[constraint_column_id])
			FROM[sys].[foreign_key_columns]
			INNER JOIN[sys].[columns]
				ON[foreign_key_columns].[referenced_object_id] = [columns].[object_id]
					AND[foreign_key_columns].[referenced_column_id] = [columns].[column_id]
			WHERE
				[foreign_key_columns].[constraint_object_id] = [foreign_keys].[object_id]
		) AS[ReferenceColumns]
	FROM[sys].[foreign_keys]
	INNER JOIN[Tables] AS[Parent]
	   ON[Parent].[TableId] = [foreign_keys].[parent_object_id]
	INNER JOIN[Tables] AS[Reference]
	   ON[Reference].[TableId] = [foreign_keys].[referenced_object_id]
), [Columns] AS (
	SELECT 
		 [columns].[object_id]
		 ,[columns].[name] AS [ColumnName]
		 ,[columns].[column_id] AS [ColumnOrder]
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
), [IdentityTables] AS (
	SELECT 
		[Tables].[Schema]
		,[Tables].[Table]
	FROM [Columns]
	INNER JOIN [Tables]
		ON [Columns].[object_id] = [Tables].[TableId]
	WHERE
		[Columns].[is_identity] = 1
)
	SELECT 
		[Tables].[TableName]

		,(SELECT 
			[Columns].[ColumnName]
			 ,[Columns].[Type]
			 ,[Columns].[TypeDefinition]
			 ,[Columns].[is_nullable]
			 ,[Columns].[is_rowguidcol]
			 ,[Columns].[is_computed]
			 ,[Columns].[is_identity]

			,(SELECT 
					[extended_properties].[name]
					,[extended_properties].[value]
				FROM [sys].[extended_properties]
				WHERE	
					[extended_properties].[minor_id] = [Columns].[ColumnOrder]
					AND [extended_properties].[major_id] = [Tables].[TableId]
				FOR JSON AUTO) AS [ExtendedProperties]

			FROM [Columns]
			WHERE
				[Columns].[object_id] = [Tables].[TableId]
			ORDER BY
				[Columns].[ColumnOrder]
			FOR JSON AUTO) AS [Columns]

		,(SELECT 
			[ForeignKeys].[ForeignKey]
			,[ForeignKeys].[ParentColumns] AS [LocalColumns]
			,[ForeignKeys].[Reference] AS [ReferenceTable]
			,[ForeignKeys].[ReferenceColumns]
			FROM [ForeignKeys]
			WHERE
				[ForeignKeys].[ParentSchemaName] = [Tables].[Schema]
				AND [ForeignKeys].[ParentTableName] = [Tables].[Table]
			FOR JSON AUTO) AS [ForeignKeys]

		,(SELECT 
				[extended_properties].[name]
				,[extended_properties].[value]
			FROM [sys].[extended_properties]
			WHERE	
				[extended_properties].[minor_id] = 0
				AND [extended_properties].[major_id] = [Tables].[TableId]
			FOR JSON AUTO) AS [ExtendedProperties]

	FROM [Tables]
	ORDER BY
		[Tables].[Schema]
		,[Tables].[Table]
	FOR JSON AUTO