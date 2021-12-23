--Report

Create View SubCatAndProject AS
	Select Cat.Category,Pr.[Sub-Category], AmountOfProjects = Count(Pr.[Project-ID]),StartYear = year(Pr.[Start-Date])
	From Projects AS Pr join Categories as Cat
	On Pr.[Sub-Category] = Cat.[Sub-Category]
	Group By Cat.Category,Pr.[Sub-Category],year(Pr.[Start-Date])

Create View AmountsOfPledgesAndProjects As
 Select Pr.[Project-ID],TotalAmountNeeded = Pr.[Funding-Goal], TotalAmountNow = Sum( Pl.Amount ), AmountRatio = Sum(Pl.Amount)/ (Pr.[Funding-Goal])
 ,YearStartDate = year( Pr.[Start-Date] ), pr.Country
 From Users as U join Projects as Pr 
 On U.[E-mail] = Pr.[Creator E-mail] Join Pledges as Pl On
 Pr.[Project-ID] = Pl.[Project-ID]
 Group By Pr.[Project-ID] ,Pr.[Funding-Goal],year( Pr.[Start-Date] ),Pr.Country

Create View UsersJoinDate AS 
		Select JoinYear = Year(U.[Join-Date]),JoinMonth = Month(U.[Join-Date]) ,NubmerOfUsers = Count(U.[Join-Date])
		From Users as U
		Group By Year(U.[Join-Date]),Month(U.[Join-Date])

Create View NewProjectsJoinDates AS 
		Select JoinYear = Year( Pr.[Start-Date] ),JoinMonth = Month( Pr.[Start-Date] ), HowManyProjects = Count( Pr.[Project-ID] )
		From Projects as Pr
		Group By Year( Pr.[Start-Date] ),Month( Pr.[Start-Date] )

Create View ProjectsEndDate AS 
		Select Pr.[Project-ID] ,Year =  Year(Pr.[Start-Date]+ Pr.Duration),Month =  Month(Pr.[Start-Date]+ Pr.Duration),EndDate = Pr.[Start-Date] + Pr.Duration
		From Projects as Pr

Create View MultiView AS
	Select Pr.[Project-ID],Cat.Category,Cat.[Sub-Category],[Project Country] = Pr.Country,[Pledge User Country] = U.Country,
		Pl.[Pledge-ID],PledgeDate = Pl.DT,ProjectStartDate = Pr.[Start-Date],ProjectEndDate = (Pr.[Start-Date]+Pr.Duration),Pl.Amount 
	From Projects As Pr Join Categories As Cat On Pr.[Sub-Category] = Cat.[Sub-Category] join Pledges As Pl
	On Pl.[Project-ID] = Pr.[Project-ID] join Users as U On Pl.[User E-mail] = U.[E-mail]
	Group By Pr.[Project-ID],Cat.Category,Cat.[Sub-Category],Pr.[Start-Date],Pr.Country,U.Country,Pl.[Pledge-ID],Pl.DT,Pr.[Start-Date],Pl.Amount,Pr.Duration 


--Dashboard
CREATE VIEW TotalPledgesPerProj AS
	SELECT	Pr.[Project-ID], Pr.[Sub-Category], Pr.Country, Pr.[Funding-Goal], Ending = DATEADD(dd, Pr.Duration, Pr.[Start-Date]), [Amount Received] = SUM(Pl.Amount)
	FROM	Projects as Pr LEFT JOIN Rewards as R ON Pr.[Project-ID] = R.[Project-ID]
			LEFT JOIN Pledges as Pl ON (R.Name = Pl.Name AND R.[Project-ID] = Pl.[Project-ID])
	GROUP BY	Pr.[Project-ID], Pr.[Sub-Category], Pr.Country, Pr.[Funding-Goal], Pr.[Start-Date], Pr.Duration

CREATE VIEW PledgesUsers AS
	SELECT P.[Pledge-ID], P.DT, P.Amount, U.Country
	FROM Pledges as P JOIN Users as U ON P.[User E-mail] = U.[E-mail]
	GROUP BY P.[Pledge-ID], P.DT, P.Amount, U.Country

CREATE VIEW CommentsByTime AS
	SELECT Date = CAST(DT as Date), Count = COUNT(*)
	FROM Comments
	GROUP BY CAST(DT as Date)

CREATE VIEW SearchesByTime AS
	SELECT Date = CAST(DT as Date), Count = COUNT(*)
	FROM Searches
	GROUP BY CAST(DT as Date)

CREATE VIEW MostFollowed AS
	SELECT		TOP 3 [E-mail], Name, Country, Followers = COUNT(*)
	FROM		FollowsUsers
	WHERE		DATEDIFF(day, DT, GETDATE()) <= 30
	GROUP BY	[E-mail], Name, Country
	ORDER BY	COUNT(*) DESC

CREATE VIEW Userlist AS
SELECT		DISTINCT [User email] = U.[E-mail], U.Country, U.[Join-Date], [Sum pledges] = SUM(P.Amount), 
			Pledged =  
			(
				CASE WHEN SUM(P.Amount) IS NULL THEN 'No'
				ELSE 'Yes'
				END
			)

CREATE VIEW FavoriteProjects AS
	SELECT		TOP 3 P.[Project-ID], P.Title, P.[Sub-Category], P.[Funding-Goal], P.Country, Total = COUNT(*)
	FROM		[In Favorites of] as F JOIN Projects as P ON F.[Project-ID] = P.[Project-ID]
	WHERE		DATEDIFF(day, F.DT, GETDATE()) <= 30
	GROUP BY	P.[Project-ID], P.Title, P.[Sub-Category], P.[Funding-Goal], P.Country
	ORDER BY	COUNT(*) DESC

CREATE VIEW PledgesCategories AS
	SELECT	Pl.[Pledge-ID], Pl.DT, Pl.Amount, Pr.[Project-ID], Pr.Country, C.[Sub-Category], C.Category
	FROM	Pledges as Pl JOIN Projects as Pr ON Pl.[Project-ID] = Pr.[Project-ID]
			JOIN Categories as C ON Pr.[Sub-Category] = C.[Sub-Category]

--Window Functions
Select	[General Rank] = RN.[Rows By Pl Amount],RN.Category,Pr.[Sub-Category],
		[Category Rank] = Rank() Over(Partition by RN.Category Order By Sum( RN.SumOfPledges ) DESC),RN.SumOfPledges
From(
	Select Cat.Category,Cat.[Sub-Category],SumOfPledges = Sum( pl.Amount ), [Rows By Pl Amount] = Row_Number() Over( Order By Sum( pl.Amount ) DESC )
	From Projects as Pr Join Pledges as Pl
		On pr.[Project-ID] = pl.[Project-ID] Join Categories as Cat 
		On Cat.[Sub-Category] = Pr.[Sub-Category]
	Where Pr.[Start-Date] >= 2020
	Group By Cat.Category,Cat.[Sub-Category]
		) As RN Join Projects As Pr 
	On Pr.[Sub-Category]= RN.[Sub-Category] 
Group By [Rows By Pl Amount],RN.Category,Pr.[Sub-Category],RN.SumOfPledges
Order By 1

Select CCr.Country,CCR.City,CCR.[Pledge Amount], [Package Number] = Ntile(15) Over(Order By CCR.[Pledge Amount] DESC)
From (
	Select U.Country,ad.City,[Pledge Amount] = Sum(Pl.Amount),[Rank] = Dense_Rank() Over(Partition by U.Country Order by Sum(Pl.Amount)) 
	From Projects as Pr Join Pledges as Pl
	On pr.[Project-ID] = pl.[Project-ID] Join Categories as Cat 
	On Cat.[Sub-Category] = Pr.[Sub-Category] Join Users as U On
	U.[E-mail] = Pl.[User E-mail] Join Addresses as Ad 
	On Ad.[User E-mail] = Pl.[User E-mail]
	Where year(Pr.[Start-Date]) = 2020
	Group By U.Country,Ad.City
	) as CCR
Where CCR.[Rank] = 1
Group By CCR.Country,City,CCR.[Pledge Amount]

--Mixed Advanced Techniques
CREATE FUNCTION PledgesForReward(@PID int, @N varchar(100))
	RETURNS Integer
	AS	BEGIN
		DECLARE @Pledges Integer
			SELECT	@Pledges = COUNT(DISTINCT P.[Pledge-ID])
			FROM REWARDS as R LEFT JOIN Pledges as P ON (R.[Project-ID] = P.[Project-ID] AND R.Name = P.Name)
			WHERE P.[Project-ID] = @PID AND R.Name = @N
			GROUP BY R.[Project-ID], R.Name
		RETURN @Pledges
		END

ALTER TABLE Projects
ADD MinReward Real

CREATE TRIGGER	UpdateMinReward
	ON Rewards
	FOR INSERT, UPDATE, DELETE
	AS
		UPDATE Projects
		SET MinReward = (SELECT MIN([Minimum-Amount])
						FROM Rewards
						WHERE Projects.[Project-ID] = Rewards.[Project-ID]
						)
		WHERE [Project-ID] IN	(SELECT DISTINCT [Project-ID]
								FROM INSERTED
								UNION
								SELECT DISTINCT [Project-ID]
								FROM DELETED
								)

CREATE PROCEDURE SP_UpdateMinAmount @UpdateBy Real, @PID int
	AS
	UPDATE	Rewards
	SET [Minimum-Amount] = [Minimum-Amount] * @UpdateBy
	WHERE	Rewards.[Project-ID] = @PID
			AND (dbo.PledgesForReward(Rewards.[Project-ID], Rewards.Name)) IS NULL

SELECT *
FROM Projects
WHERE [Project-ID] = 73

SELECT *
FROM Rewards
WHERE [Project-ID] = 73

EXECUTE SP_UpdateMinAmount 1.1, 73
