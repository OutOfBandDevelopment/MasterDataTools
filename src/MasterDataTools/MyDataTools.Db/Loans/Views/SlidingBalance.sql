
CREATE VIEW [Loans].[SlidingBalance]
AS --
	SELECT 
		[TransactionID]
		,[CustomerID]
		,[Credit]
		,[Debit]
		,[Note]
		,[DateTime]
		,[Currency]
		,SUM(ISNULL([Credit],0) - ISNULL([Debit],0)) OVER (
			PARTITION BY [CustomerID], [Currency]
			ORDER BY [DateTime]
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) AS [Balance]
	FROM [Loans].[Transactions]