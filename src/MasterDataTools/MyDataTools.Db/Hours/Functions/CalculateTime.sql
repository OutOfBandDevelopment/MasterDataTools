
CREATE FUNCTION [Hours].[CalculateTime]
(
	@StartTime TIME,
	@StartBreak TIME,
	@EndBreak TIME,
	@EndTime TIME
)
RETURNS FLOAT --WITH SCHEMABINDING
AS
BEGIN
	DECLARE @result FLOAT;

	SET @result = (
			CONVERT([float], DATEDIFF(MINUTE, @StartTime,ISNULL(@EndTime,'0:00'))) -
			CONVERT([float], DATEDIFF(MINUTE, ISNULL(@StartBreak,'0:00'),ISNULL(@EndBreak,'0:00')))
		) / 60.0
		;

	RETURN @result;

END