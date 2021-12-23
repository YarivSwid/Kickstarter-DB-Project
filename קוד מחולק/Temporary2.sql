--View
CREATE VIEW V_CensoredCC AS
	SELECT	[Censored Number] = [CC-Number] % 10000, [Type], [Expiration-Month], [Expiration-Year], CVV
	FROM [Credit Cards]

--Function 1
Create Function InvestmentAmount ( @ProjectID int )  
Returns int
as Begin
		Declare @OutPut_TotalAmount int
			
			Select 	@OutPut_TotalAmount = Sum(Pl.Amount) 
			From		Projects as Pr Join Pledges as Pl
					On Pr.[Project-ID] = Pl.[Project-ID]
			Where 		Pr.[Project-ID] = @ProjectID 
			Group by 	Pr.[Project-ID]

		Return @OutPut_TotalAmount
End

Select Amount = dbo.InvestmentAmount([Project-ID])
FROM Projects
WHERE [Project-ID]=5

--Function 2
CREATE FUNCTION PledgesByCC(@CCN integer)
RETURNS TABLE
AS	RETURN
	SELECT P.[Pledge-ID], P.DT, P.Amount, P.[Address of User E-mail], P.[Address Number]
	FROM Pledges as P JOIN [Credit Cards] as C ON P.[CC-Number] = C.[CC-Number]
	WHERE P.[CC-Number] = @CCN

SELECT	U.[E-mail], U.Name, A.Country, A.City, A.[Street - Name], A.[Street - Number], A.Zipcode
FROM	dbo.PledgesByCC(13110654) as P JOIN Addresses as A
	ON (P.[Address of User E-mail] = A.[User E-mail] AND P.[Address Number] = A.Number)
	JOIN Users as U ON A.[User E-mail] = U.[E-mail]

ALTER TABLE Projects
ADD [Amount Received] float Null

--Trigger
ALTER TABLE Projects
ADD [Amount Received] float Null

CREATE TRIGGER UpdateAmountReceived
	ON Pledges
	FOR INSERT, DELETE, UPDATE
	AS
		UPDATE Projects
		SET [Amount Received] =	(
						SELECT SUM(Pl.Amount)
						FROM	Projects as Pr JOIN Pledges as Pl ON Pr.[Project-ID] = Pl.[Project-ID]
						WHERE	Pr.[Project-ID] = Projects.[Project-ID]
						)
		WHERE [Project-ID] IN	(
						SELECT DISTINCT [Project-ID] FROM INSERTED
						UNION
						SELECT DISTINCT [Project-ID] FROM DELETED
						)

SELECT [Amount Received]
FROM Projects
WHERE	[Project-ID]=110

UPDATE Pledges
SET	Amount = 2000
WHERE [Pledge-ID]=1

SELECT [Amount Received]
FROM Projects
WHERE	[Project-ID]=110

--Stored Procedure
CREATE PROCEDURE sp_AddDuration @Days int, @ProjectID int
AS BEGIN
	UPDATE Projects
	SET	Duration = Duration + @Days
	WHERE [Project-ID]=@ProjectID
END

SELECT	[Project-ID], Duration
FROM	Projects
WHERE	[Project-ID]=1

EXECUTE sp_AddDuration 5,1
