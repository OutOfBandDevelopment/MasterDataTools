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
)
	SELECT
		[ParentSchemaName]
		,[ParentTableName]
		,'ALTER TABLE ' + [Parent] + ' DROP CONSTRAINT ' + [ForeignKey] AS [DropFK]
		,'ALTER TABLE ' + [Parent] + ' ADD CONSTRAINT '+[ForeignKey]+' FOREIGN KEY (' +[ParentColumns]+ ') REFERENCES ' + [Reference] + ' (' +[ReferenceColumns]+ ')' + [ForeignKey] AS [CreateFK]
	FROM[ForeignKeys]
		ORDER BY
			[Parent]
			,[Reference]

