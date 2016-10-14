﻿
CREATE FUNCTION [dbo].[fn_split_strings]
(
	@List VARCHAR(8000),
	@Delimiter VARCHAR(255)
)
-- Courtesy of Jeff Moden.
RETURNS TABLE
WITH SCHEMABINDING AS
RETURN
  WITH E1(N)		AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
						 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
						 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
		E2(N)		AS (SELECT 1 FROM E1 a, E1 b),
		E4(N)		AS (SELECT 1 FROM E2 a, E2 b),
		E42(N)		AS (SELECT 1 FROM E4 a, E2 b),
		cteTally(N) AS (SELECT TOP (ISNULL(DATALENGTH(@List),0)) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E4),
		cteStart(N1) AS (SELECT 1 UNION ALL
						 SELECT t.N+len(@Delimiter) FROM cteTally t WHERE SUBSTRING(@List,t.N,len(@Delimiter)) = @Delimiter),
		cteLen(N1,L1) AS(SELECT s.N1, ISNULL(NULLIF(CHARINDEX(@Delimiter,@List,s.N1),0)-s.N1,8000) FROM cteStart s)
	SELECT ItemNumber = ROW_NUMBER() OVER(ORDER BY l.N1), --item number is disabled
		Item		= SUBSTRING(@List, l.N1, l.L1)
	FROM cteLen l
