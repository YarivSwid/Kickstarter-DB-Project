--Not Nested
SELECT        TOP 5 A.Country, Users = COUNT(DISTINCT U.[E-mail]), 
[Number of Pledges] = COUNT(P.[Pledge-ID]), [Total Pledges] = SUM(P.Amount)
FROM		Users AS U JOIN Addresses AS A ON U.[E-mail]=A.[User E-mail]
		JOIN Pledges AS P ON U.[E-mail]=P.[User E-mail]
WHERE		year(U.[Join-Date]) > 2017
GROUP BY	A.Country
HAVING		COUNT(P.[Pledge-ID]) > 5
ORDER BY	[Total Pledges] DESC

Select U.[E-mail],PledgeAmount = Sum(Pl.Amount),
	Rank = Case When Sum(Pl.Amount)<100 Then 'F'
	When  Sum(Pl.Amount)>=100 and Sum(Pl.Amount)<500 then 'D'
	When  Sum(Pl.Amount)>=500 and Sum(Pl.Amount)<1000  then 'C'
	When  Sum(Pl.Amount)>=1000 and Sum(Pl.Amount)<1500 then 'B'
	When  Sum(Pl.Amount)>=1500 and Sum(Pl.Amount)<2500 then 'A'
	When  Sum(Pl.Amount)>=2500 then 'S' end
From Users as U Join Pledges as Pl
On U.[E-mail] = Pl.[User E-mail] 
Where year(getDate()) - year(Pl.DT) <=2
Group By U.[E-mail]
Order By 2 Desc

--Nested
SELECT [Success Ratio] = 
	(
	SELECT Sum = COUNT(*)
	FROM	(
			SELECT	Pr.[Project-ID], Received = SUM(Pl.Amount) - Pr.[Funding-Goal]
			FROM	Projects as Pr LEFT JOIN Pledges as Pl ON Pr.[Project-ID] = Pl.[Project-ID]
			GROUP BY	Pr.[Project-ID], Pr.[Funding-Goal]
			HAVING		SUM(Pl.Amount) - Pr.[Funding-Goal] >= 0
			) as Q
	)
	/
	CAST(COUNT(DISTINCT [Project-ID]) as Float)
FROM Projects

Select [MvpCountry].[E-mail],Users.Country,AmountOfPledges = Sum(Pl.Amount) 
From	(
Select us.[E-mail],Us.name, Us.Country
From Users As Us 
Where	Us.Country IN
			(Select Distinct temp.Country
			From	Users As U join (Select top 10 Us.Country, AmountOfPledges = count(Distinct [Pledge-ID])
									From 	Pledges As Pl Join Users As Us On Pl.[User E-mail] = Us.[E-mail]
									Group By Us.Country
									Order By 2 desc) As temp 
					On temp.Country=U.country) 
			Group by us.[E-mail],Us.Name,Us.Country
			) As MvpCountry
		Join Users On Users.[E-mail] = MvpCountry.[E-mail] Join Pledges As Pl
		On pl.[User E-mail] = MvpCountry.[E-mail]
 Where year(getDate()) - year(Pl.DT) <= 2
 Group By [MvpCountry].[E-mail],Users.country
 Having Sum(Pl.Amount) > 1000
 Order By 3 DESC

 --Additions
UPDATE		Rewards
SET		[Minimum-Amount] = [Minimum-Amount]*0.9
WHERE		Rewards.[Project-ID] IN 
		(
			SELECT		P1.[Project-ID]
			FROM		Pledges AS P1 JOIN Projects as P2 ON P1.[Project-ID]=P2.[Project-ID]
			GROUP BY	P1.[Project-ID], P2.[Funding-Goal]
			HAVING	SUM(P1.Amount) BETWEEN P2.[Funding-Goal]*0.9 AND P2.[Funding-Goal]
		)

SELECT Name, [Minimum-Amount]
FROM REWARDS
WHERE [Project-ID] IN	(
						SELECT		P2.[Project-ID]
						FROM		Pledges AS P1 JOIN Projects as P2 ON P1.[Project-ID]=P2.[Project-ID]
						GROUP BY	P2.[Project-ID], P2.[Funding-Goal], P2.[Funding-Goal]
						HAVING	SUM(P1.Amount) BETWEEN P2.[Funding-Goal]*0.9 AND P2.[Funding-Goal]
						)



SELECT	[Project-ID], Title, [Start-Date]
FROM	PROJECTS
EXCEPT
SELECT	Pr.[Project-ID], Pr.Title, Pr.[Start-Date]
FROM	Projects as Pr JOIN Rewards as R ON Pr.[Project-ID] = R.[Project-ID]
	JOIN Pledges as Pl ON (R.Name = Pl.Name AND R.[Project-ID] = Pl.[Project-ID])
ORDER BY [Start-Date] ASC
