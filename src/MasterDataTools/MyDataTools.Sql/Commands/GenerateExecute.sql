DECLARE @json NVARCHAR(MAX) = N'
[
  {
    "DriverID": 1,
    "Name": "Matt",
    "UserID": "BE274DBB-B4FE-4FF9-AF1A-E87D6B994074"
  },
  {
    "DriverID": 2,
    "Name": "Buddy",
    "UserID": "BE274DBB-BEEF-4FF9-DEAD-E87D6B994074"
  }
]
';
  --{
  --  "DriverID": 3,
  --  "Name": "Q",
  --  "UserID": "BE274DBB-DEAD-DEAD-DEAD-E87D6B994074"
  --}

BEGIN TRAN

SET IDENTITY_INSERT [Vehicles].[Drivers] ON 

MERGE  [Vehicles].[Drivers] AS target
USING (
	SELECT *
	FROM OPENJSON(@json)
	WITH (
		[DriverID] int '$.DriverID',
		[Name] nvarchar(512) '$.Name',
		[UserID] uniqueidentifier '$.UserID'
	)
) AS source
ON target.[DriverID] = source.[DriverId]
WHEN MATCHED AND target.[Name] != source.[Name]
	THEN UPDATE SET
		[Name] = source.[Name]
WHEN NOT MATCHED BY TARGET
	THEN INSERT (
		[DriverID],
		[Name],
		[UserID]
	) VALUES (
		source.[DriverID],
		source.[Name],
		source.[UserID]
	)
WHEN NOT MATCHED BY SOURCE
	THEN DELETE

OUTPUT 
	$action,
	inserted.*,
	deleted.*
	;
		
SET IDENTITY_INSERT [Vehicles].[Drivers] OFF 

--COMMIT
ROLLBACK