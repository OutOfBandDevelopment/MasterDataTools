DECLARE @schema NVARCHAR(255) = 'Vehicles',
		@table NVARCHAR(255) = 'Drivers',
		@addmissing BIT = 1,
		@cleanup BIT = 1,
		@output BIT = 1
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
), [ForeignKeysScripts] AS (
	SELECT
		[ParentSchemaName]
		,[ParentTableName]
		,'ALTER TABLE ' + [Parent] + ' DROP CONSTRAINT ' + [ForeignKey] AS [DropFK]
		,'ALTER TABLE ' + [Parent] + ' ADD CONSTRAINT '+[ForeignKey]+' FOREIGN KEY (' +[ParentColumns]+ ') REFERENCES ' + [Reference] + ' (' +[ReferenceColumns]+ ')' + [ForeignKey] AS [CreateFK]
	FROM [ForeignKeys]
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
), [IdentityTables] AS (
	SELECT 
		[Tables].[Schema]
		,[Tables].[Table]
		,'SET IDENTITY_INSERT ' + [Tables].[TableName] + ' ON ' AS [InsertIdentityOn]
		,'SET IDENTITY_INSERT ' + [Tables].[TableName] + ' ON ' AS [InsertIdentityOff]

	FROM [Columns]
	INNER JOIN [Tables]
		ON [Columns].[object_id] = [Tables].[TableId]
	WHERE
		[Columns].[is_identity] = 1
)
	SELECT 
		CAST(STRING_AGG([Before], CHAR(13) + CHAR(10)) WITHIN GROUP (ORDER BY [Schema],[Table],[Before]) AS XML) AS [Before]
		,CAST(STRING_AGG([After], CHAR(13) + CHAR(10)) WITHIN GROUP (ORDER BY [Schema],[Table],[Before]) AS XML) AS [After]
	FROM (
		SELECT
			[IdentityTables].[Schema]
			,[IdentityTables].[Table]
			,[IdentityTables].[InsertIdentityOn] AS [Before]
			,[IdentityTables].[InsertIdentityOff] AS [After]
		FROM [IdentityTables]
		UNION ALL
		SELECT
			[ForeignKeysScripts].[ParentSchemaName]
			,[ForeignKeysScripts].[ParentTableName]
			,[ForeignKeysScripts].[DropFk] AS [Before]
			,[ForeignKeysScripts].[CreateFK] AS [After]
		FROM [ForeignKeysScripts]
	) AS [Scripts]
	WHERE 	
		[Schema] = @Schema
		AND [Table] = @Table