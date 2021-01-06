SELECT 
	schemas.name
	,schemas.schema_id

	,(SELECT 
		objects.name
		,objects.type
		,objects.type_desc
		--,objects.schema_id
		,objects.object_id
		--,objects.parent_object_id

		,(SELECT 
			columns.name
			,columns.system_type_id 
			,columns.user_type_id
			,columns.column_id
			,columns.is_computed
			,columns.is_nullable
			,columns.is_identity
			,columns.is_rowguidcol
			,columns.max_length
			,columns.precision
			,columns.scale
			,columns.xml_collection_id
			FROM sys.columns
			WHERE 
				columns.object_id = objects.object_id
			ORDER BY
				columns.name
			FOR XML AUTO, TYPE
				)
		
		,(SELECT 
			iObjects.name AS [@name]
			,iObjects.type AS [@typee]
			,iObjects.type_desc AS [@type_desc]
			--,iObjects.schema_id AS [@schema_id]
			,iObjects.object_id AS [@object_id]
			--,iObjects.parent_object_id AS [@parent_object_id]
			
			,(SELECT 
				columns.name
				,columns.system_type_id 
				,columns.user_type_id
				,columns.column_id
				,columns.is_computed
				,columns.is_nullable
				,columns.is_identity
				,columns.is_rowguidcol
				,columns.max_length
				,columns.precision
				,columns.scale
				,columns.xml_collection_id

				,index_columns.is_descending_key
				,index_columns.is_included_column
				FROM sys.index_columns 
				INNER JOIN sys.columns
					ON columns.object_id = iObjects.parent_object_id
						AND index_columns.column_id = columns.column_id
				WHERE 
					index_columns.object_id = iObjects.parent_object_id
				ORDER BY
					index_columns.key_ordinal
				FOR XML AUTO, TYPE
					)
			FROM sys.objects iObjects
			WHERE 
				iObjects.parent_object_id = objects.object_id
			ORDER BY
				iObjects.name
			FOR XML PATH('sys.objects'), TYPE
				)
		FROM sys.objects 
		WHERE 
			objects.schema_id = schemas.schema_id
			AND objects.parent_object_id = 0
		ORDER BY
			objects.name
		FOR XML AUTO, TYPE
			)
	,(SELECT *
		FROM sys.extended_properties
		)
FROM sys.schemas
WHERE 
	schemas.name NOT IN ('sys')

ORDER BY
	schemas.name

FOR XML AUTO, ROOT('db')

