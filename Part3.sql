--Lookup Tables

create table Countries (
	Country varchar(40),
	
	constraint PK_Countries Primary key(Country)
)

Create table SortedBy(
	Criteria varchar(20)

	constraint PK_Criteria Primary key(Criteria)
)

INSERT INTO SortedBy (Criteria)
VALUES
	('Magic'),
	('Popularity'),
	('Newest'),
	('End Date'),
	('Most Funded'),
	('Most Backed'),
	('Near Me')

create table CCTypes
(
	CCType varchar(20)

	constraint PK_CCTypes Primary key(CCType)
)

INSERT INTO CCTypes (CCType)
VALUES
	('AMEX'),
	('Diners Club'),
	('Discover'),
	('JCB'),
	('Mastercard'),
	('UnionPay'),
	('Visa')

--Tables

create table Users(
	[E-mail]	varchar(30) Not Null,
	Name		varchar(20) Not Null,
	Password	varchar(20) Not Null,
	[Join-Date]	datetime Not Null,
	Country		varchar(40) Not Null,

	constraint PK_Users			Primary key([E-mail]),
	constraint FK_Users_Country	Foreign key(Country) references Countries(Country),
	constraint CK_U_Email		check([E-mail] like '%@%.%'),
	constraint CK_U_Name		check(Name not like '%[0-9]%'),
)

create table Websites(
	[User E-mail]	varchar(30) Not Null,
	Website			varchar(30) Not Null,
	
	constraint PK_Websites	Primary key([User E-mail],Website),
	constraint FK_W_Users	Foreign key([User E-mail])
		references Users([E-mail]),
	constraint CK_W_Website	check(Website like '%www.%.%')
)

create table Categories(
	[Sub-Category]	varchar(20) Not Null,
	Category		varchar(20) Not Null,
	
	constraint PK_Categories	Primary key([Sub-Category])
)

create table Projects(
	[Project-ID]		integer Not Null, 
	Title				varchar(100) Not Null,
	[Sub-Title]			varchar(100) Not Null,
	[Sub-Category]		varchar(20) Not Null,
	[Funding-Goal]		money Not Null,
	Duration			integer Not Null, 
	[Start-Date]		datetime Not Null,
	Country				varchar(40) Not Null,
	[Creator E-mail]	varchar(30) Not Null,
		
	constraint PK_Projects			Primary key([Project-ID]),
	constraint FK_P_Categories		Foreign key([Sub-Category]) 
		references Categories([Sub-Category]),
	constraint FK_P_Users			Foreign key([Creator E-mail]) 
		references Users([E-mail]),
	constraint FK_Projects_Country	Foreign key (Country)
		references Countries (Country),
	constraint CK_P_FG				check([Funding-Goal] > 0),
	constraint CK_P_Duration		check(Duration > 0)
)

create table Rewards(
	[Project-ID]					integer Not Null,
	Name							varchar(100) Not Null,
	[Minimum-Amount]				money Not Null,
	[Estimated Delivery - Month]	tinyint Not Null,
	[Estimated Delivery - Year]		smallint Not Null,

	constraint PK_Rewards			Primary key([Project-ID],Name),
	constraint FK_R_Projects		Foreign key([Project-ID]) 
		references Projects([Project-ID]),
	constraint CK_R_MA				check([Minimum-Amount]>=0),
	constraint CK_R_EY				check([Estimated Delivery - Year]> year(current_timestamp) or 
		([Estimated Delivery - Month] >= month(current_timestamp) and [Estimated Delivery - Year] = year(current_timestamp))),
	constraint CK_R_EM			check([Estimated Delivery - Month] between 1 and 12),
)

create table Addresses(
	[User E-mail]		varchar(30) Not Null,
	Number				integer Not Null,
	Zipcode				varchar(20) Not Null,
	[Country]			varchar(40) Not Null,
	City				varchar(20) Not Null,
	[Street - Name]		varchar(20) Not Null,
	[Street - Number]	integer Null,

	constraint PK_Addresses				Primary key([User E-mail],Number),
	constraint FK_A_Users				Foreign key([User E-mail]) 
		references Users([E-mail]),
	constraint FK_Addresses_Country		Foreign key (Country)
		references Countries (Country),
	constraint CK_A_N					check(Number > 0),
	constraint CK_A_SN					check([Street - Number] >= 0)
)

create table Follows(
	[E-mail - Follower]		varchar(30) Not Null,
	[E-mail - Followed]		varchar(30) Not Null,
	DT						datetime Not Null,

	constraint PK_F_U		Primary key([E-mail - Follower],[E-mail - Followed]),
	constraint FK_F_U1		Foreign key([E-mail - Follower]) 
		references Users([E-mail]),
	constraint FK_F_U2		Foreign key([E-mail - Followed]) 
		references Users([E-mail])
)

create table [In Favorites of](
	[Project-ID]				integer Not Null,
	[User E-mail]				varchar(30) Not Null,
	DT							datetime

	constraint PK_IFO			Primary key([Project-ID],[User E-mail]),
	constraint FK_IFO_Projects	Foreign key([Project-ID])
		references Projects([Project-ID]),
	constraint FK_IFO_Users		Foreign key([User E-mail])
		references Users([E-mail]),
)

create table [Collaborated by](
	[Project-ID]				integer Not Null,
	[User E-mail]				varchar(30) Not Null,

	constraint PK_CB			Primary key([Project-ID],[User E-mail]),
	constraint FK_CB_Projects	Foreign key([Project-ID])
		references Projects([Project-ID]),
	constraint FK_CB_Users		Foreign key([User E-mail])
		references Users([E-mail])
)

create table Comments(
	[Project-ID]					integer Not Null,
	[Comment Number]				integer Not Null,
	DT								datetime Not Null,
	[Text]							varchar(280) Not Null,
	[Comment On Project-ID]			integer Null,
	[Commented On Comment Number]	integer Null,
	[Commentor]					varchar(30) Not Null,

	constraint PK_Comments			Primary key([Project-ID],[Comment Number]),
	constraint FK_C_Projects1		Foreign key([Project-ID]) 
		references Projects([Project-ID]),
	constraint FK_C_Projects2		Foreign key([Comment on Project-ID],[Commented On Comment Number]) 
		references Comments([Project-ID],[Comment Number]),
	constraint FK_C_Users			Foreign key([Commentor])
		references Users([E-mail]),
	constraint CK_C_CN				check([Commented On Comment Number] > 0)
)

create table Searches(
	[IP Address]			varchar(15) Not Null,
	DT						datetime Not Null,
	[Text]					varchar(280) Null	default '',
	[Sub-Category]			varchar(20) Null	default 'All Categories',
	Country					varchar(40) Null,
	[Sorted By]				varchar(20) Null	default 'Magic',
	[E-mail]				varchar(30) Null,

	constraint PK_Searches			Primary key ([IP Address],DT),
	constraint FK_S_Users			Foreign key ([E-mail]) 
		references Users([E-mail]),
	constraint FK_Searches_Country	Foreign key (Country)
		references Countries (Country),
	constraint FK_Searches_SortedBy	Foreign key ([Sorted By])
		references SortedBy(Criteria)
)

create table [Credit Cards](
	[CC-Number]				integer Not Null,
	[Type]					varchar(20) Not Null,
	[Owner]					varchar(20) Not Null,
	[Expiration-Month]		tinyint Not Null,
	[Expiration-Year]		smallint Not Null,
	CVV						varchar(3) Not Null,

	constraint PK_CC		Primary key([CC-Number]),
	constraint FK_CC_CCTypes	Foreign key([Type])
		references CCTypes(CCType),
	constraint CK_CC_CCN	check([CC-Number]>0),
	constraint CK_CC_CVV	check(CVV like '[0-9][0-9][0-9]'),
	constraint CK_CC_EY		check([Expiration-Year]> year(current_timestamp) or 
		([Expiration-Month] >= month(current_timestamp) and [Expiration-Year] = year(current_timestamp))),
	constraint CK_CC_EM	check([Expiration-Month] between 1 and 12),
)

create table Saves(
	[User E-mail]				varchar(30) Not Null,
	[CC-Number]					integer Not Null,

	constraint PK_Saves			Primary key([User E-mail],[CC-Number]),
	constraint FK_Saves_Users	Foreign key([User E-mail])
		references Users([E-mail]),
	constraint FK_Saves_CC		Foreign key([CC-Number])
		references [Credit Cards]([CC-Number]),
)

create table Retrieves(
	[Project-ID]			integer Not Null,
	[IP Address]			varchar(15) Not Null,
	DT						datetime Not Null,

	constraint PK_Retrieves				Primary key([Project-ID],[IP Address],DT),
	constraint FK_Retrieves_Projects	Foreign key([Project-ID])
		references Projects([Project-ID]),
	constraint FK_Retrieves_Searches	Foreign key([IP Address],DT)
		references Searches([IP Address],DT)
)

create table Pledges(
	[Pledge-ID]					integer Not Null,
	DT							datetime Not Null,
	Amount						money Not Null,
	[User E-mail]				varchar(30) Not Null,
	[CC-Number]					integer Not Null,
	[Project-ID]				integer Not Null,
	Name						varchar(100) Not Null,
	[Address of User E-mail]	varchar(30) Null,
	[Address Number]			integer Null

	constraint PK_Pledges			Primary key([Pledge-ID]),
	constraint FK_Pledges_Users		Foreign key([User E-mail])
		references Users([E-mail]),
	constraint FK_Pledges_CC		Foreign key([CC-Number])
		references [Credit Cards]([CC-Number]),
	constraint FK_Pledges_Rewards	Foreign key([Project-ID],Name)
		references Rewards([Project-ID],Name),
	constraint FK_Pledges_Add		Foreign key([Address of User E-mail],[Address Number])
		references Addresses([User E-mail],Number),
	constraint CK_Pledges_Amount	check(Amount >0) 
)

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
SET	Amount = 3000
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
	SELECT		TOP 3 U.[E-mail], U.Name, U.Country, Followers = COUNT(*)
	FROM		Users as U join Follows as F ON U.[E-mail] = F.[E-mail - Followed]
	WHERE		DATEDIFF(day, F.DT, GETDATE()) <= 30
	GROUP BY	U.[E-mail], U.Name, U.Country
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