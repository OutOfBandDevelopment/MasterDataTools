
CREATE PROCEDURE [Accounting].[GetInvoiceXML]
	@InvoiceID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		[InvoiceID] AS [@id]
		,[Notes] AS [@notes]
		,[InvoiceDate] AS [@date-invoice]
		,[DueDate] AS [@date-due]
		,[TermsAndConditions] AS [@terms-conditions]
		,[InvoiceNumber] AS [@invoice-number]
		
		,CAST((
			SELECT 
				[Customers].[CustomerID] AS [@id]
				,[Customers].[CompanyName] AS [@name-company]
				,[Customers].[FirstName] AS [@name-first]
				,[Customers].[LastName] AS [@name-last]
				,[Customers].[Address1] AS [@address1]
				,[Customers].[Address2] AS [@address2]
				,[Customers].[City] AS [@city]
				,[Customers].[State] AS [@state]
				,[Customers].[PostalCode] AS [@postal]
				,[Customers].[Country] AS [@country]
				,[Customers].[AccountingEmail] AS [@email-accounting]
				,[Customers].[ContractEmail] AS [@email]
				,[Customers].[Phone] AS [@phone]
				,[Customers].[Notes] AS [@note]
			FROM [Common].[Customers]
			WHERE 
				[Customers].[CustomerID] = [Invoices].[CustomerID]
			FOR XML PATH('customer')
				) AS XML)
			
		,CAST((
			SELECT 
				[Terms].[TermID] AS [@id]
				,[Terms].[Name] AS [@name]
				,[Terms].[Details] AS [@details]
			FROM [Accounting].[Terms]
			WHERE 
				[Terms].[TermID] = [Invoices].[TermsID]
			FOR XML PATH('terms')
				) AS XML)
			
		,CAST((
			SELECT 
				[LineItems].[LineItemID] AS [@id]
				,[LineItems].[Description] AS [@description]
				,CAST([LineItems].[Quantity] AS numeric) AS [@quantity]
				,CAST([LineItems].[UnitPrice] AS numeric) AS [@unit-price]
				,CAST([LineItems].[TaxRate] AS numeric) AS [@tax-rate]

				,CAST([LineItems].[ExtendedAmount] AS numeric) AS [@extended-amount]
				,CAST([LineItems].[TaxAmount] AS numeric) AS [@tax-amount]
				,CAST([LineItems].[TotalAmount] AS numeric) AS [@line-total]
				--,[LineItems].[ProjectID]
			FROM [Accounting].[LineItems]
			WHERE 
				[LineItems].[InvoiceID] = [Invoices].[InvoiceID]
			FOR XML PATH('line-item')
				) AS XML)			
	
		,CAST((
			SELECT 
				CAST(SUM([LineItems].[ExtendedAmount]) AS numeric) AS [@extended-amount]
				,CAST(SUM([LineItems].[TaxAmount]) AS numeric) AS [@tax-amount]
				,CAST(SUM([LineItems].[TotalAmount]) AS numeric) AS [@line-total]
			FROM [Accounting].[LineItems]
			WHERE 
				[LineItems].[InvoiceID] = [Invoices].[InvoiceID]
			FOR XML PATH('line-item-total')
			) AS XML)
			
		,CAST((
			SELECT 
				[TimeLogs].[TimeLogID] AS [@id]
				,[TimeLogs].[Date] AS [@date]
				,CAST([TimeLogs].[Hours] AS numeric) AS [@hours]
				,[Projects].[Name] AS [@project]
				,CAST([Projects].[HourlyRate] AS numeric) AS [@project-rate]
				,CAST([Projects].[HourlyRate] * [TimeLogs].[Hours]AS numeric) AS [@cost]
			FROM [Hours].[TimeLogs]
			LEFT OUTER JOIN [Accounting].[Projects]
				ON [Projects].[ProjectID] = [TimeLogs].[ProjectID]
			WHERE 
				[TimeLogs].[InvoiceID] = [Invoices].[InvoiceID]
			FOR XML PATH('tracked-time')
				) AS XML)
			
		,CAST((
			SELECT 
				CAST(SUM([TimeLogs].[Hours]) AS numeric) AS [@hours]
				,CAST(SUM([Projects].[HourlyRate] * [TimeLogs].[Hours]) AS numeric) AS [@cost]
			FROM [Hours].[TimeLogs]
			LEFT OUTER JOIN [Accounting].[Projects]
				ON [Projects].[ProjectID] = [TimeLogs].[ProjectID]
			WHERE 
				[TimeLogs].[InvoiceID] = [Invoices].[InvoiceID]
			FOR XML PATH('tracked-time-total')
			) AS XML)

	FROM [Accounting].[Invoices]
	WHERE
		[Invoices].[InvoiceID] = @InvoiceID
	FOR XML PATH('invoice') --, ROOT('invoices')
END