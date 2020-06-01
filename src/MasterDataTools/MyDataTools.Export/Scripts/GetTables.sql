SELECT 
	[schemas].[name] AS [Schema],
    [tables].[name] AS [Table], 
	'SELECT * FROM [' + [schemas].[name] + '].[' + [tables].[name] + '] FOR JSON AUTO' AS [JsonScript],
	'SELECT * FROM [' + [schemas].[name] + '].[' + [tables].[name] + '] FOR XML AUTO' AS[XmlScript]
FROM[sys].[schemas]
INNER JOIN[sys].[tables]
ON[tables].[schema_id] = [schemas].[schema_id]
WHERE
[schemas].[name] != 'dbo'
ORDER BY
	[schemas].[name],
	[tables].[name] 