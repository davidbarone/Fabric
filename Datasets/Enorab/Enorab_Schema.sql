/*********************************************************************
Enorab_schema.sql:	A script to generate a ficticious bank dataset.

Author:		David Barone
Created:	13/10/2024
Url:		https://github.com/davidbarone/Power-BI/tree/main/Datasets/Enorab 
Notes:		This script has been written for MSSQL (SQL Server)

Version History:

Version	Date		Author			Details
1.0		13/10/2024	David Barone	Script created
*********************************************************************/
USE Enorab
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetDates]    Script Date: 8/10/2022 3:59:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Staging tables
DROP TABLE IF EXISTS staging.InterestRate
DROP TABLE IF EXISTS staging.Person
DROP TABLE IF EXISTS staging.Address1
DROP TABLE IF EXISTS staging.Address2
DROP TABLE IF EXISTS staging.RegionWeighting

DROP SCHEMA IF EXISTS staging
GO
CREATE SCHEMA staging
GO

CREATE TABLE staging.InterestRate (
	RateId INT NOT NULL,
	Rate FLOAT NOT NULL,
	YearStart INT NOT NULL,
	MonthStart INT NOT NULL
)

CREATE TABLE staging.Person (
	[PersonId] INT, 
	[FirstName] varchar(50), 
	[Surname] varchar(50), 
	[Sex] varchar(1), 
	[DoB] date
)

CREATE TABLE staging.Address1 (
	[AddressLine1] VARCHAR(250), 
	[AddressLine2] VARCHAR(250), 
	[Town] VARCHAR(250), 
	[Region] VARCHAR(250), 
	[Postcode] INT,
	[Country] VARCHAR(50)
)

CREATE TABLE staging.Address2 (
	[AddressLine1] VARCHAR(250), 
	[AddressLine2] VARCHAR(250), 
	[Town] VARCHAR(250), 
	[Region] VARCHAR(250), 
	[Postcode] INT,
	[PostcodeRegion] INT,
	[Country] VARCHAR(50)
)

CREATE TABLE staging.RegionWeighting (
	Region VARCHAR(50),
	Weighting FLOAT,
	HasBank BIT
)

-- Main tables
DROP TABLE IF EXISTS Person
DROP TABLE IF EXISTS Address
DROP SEQUENCE IF EXISTS SeqBranch
DROP TABLE IF EXISTS Branch
DROP TABLE IF EXISTS DateTable
DROP TABLE IF EXISTS InterestRate

IF EXISTS (
	SELECT * FROM sysobjects WHERE id = object_id(N'fnGetDates')
	AND xtype IN (N'FN', N'IF', N'TF')
)
DROP FUNCTION fnGetDates

IF EXISTS (
	SELECT * FROM sysobjects WHERE id = object_id(N'DateToInt')
	AND xtype IN (N'FN', N'IF', N'TF')
)
DROP FUNCTION DateToInt

IF EXISTS (
	SELECT * FROM sysobjects WHERE id = object_id(N'DateTableView')
	AND xtype IN (N'V')
)
DROP VIEW DateTableView

GO

-- =============================================
-- Author:		David Barone
-- Create date: 20241015
-- Description:	Converts Date To Int
-- =============================================
CREATE FUNCTION DateToInt 
(
	@Date DATE
)
RETURNS INT
AS
BEGIN
	RETURN (YEAR(@Date) * 10000) + (MONTH(@Date) * 100) + DAY(@Date)
END;
GO	

----------------------------------------------------------
-- GetDates()
--
-- This TVF can be used to initialse a date dimension.
--
-- Includes calendar and fiscal (July-June) variants.
----------------------------------------------------------
CREATE FUNCTION [dbo].[fnGetDates] 
(   
    @StartDate DATETIME,
    @EndDate DATETIME
)
RETURNS @DateTable TABLE (
	
	-- Standard Calendar
	
	[DateKey] [int] NOT NULL,
	[CalendarDate] [date] NOT NULL,
	[CalendarDateName] [varchar](11) NOT NULL,
	[CalendarDayOfWeek] [int] NOT NULL,
	[CalendarDayOfIsoWeek] [int] NOT NULL,
	[CalendarDayOfYear] [int] NOT NULL,
	[CalendarWeekStart] [date] NOT NULL,
	[CalendarWeekEnd] [date] NOT NULL,
	[CalendarIsoWeekStart] [date] NOT NULL,
	[CalendarIsoWeekEnd] [date] NOT NULL,
	[CalendarDay] [int] NOT NULL,
	[CalendarDayName] [varchar](3) NOT NULL,
	[CalendarWeekOfMonth] [int] NOT NULL,
	[CalendarWeekOfYear] [int] NOT NULL,
	[CalendarIsoWeekOfYear] [int] NOT NULL,
	[CalendarMonth] [int] NOT NULL,
	[CalendarMonthName] [varchar](3) NOT NULL,
	[CalendarQuarter] [int] NOT NULL,
	[CalendarSemester] [int] NOT NULL,
	[CalendarYear] [int] NOT NULL,
	[CalendarYearMonth] [int] NOT NULL,
	[CalendarYearMonthName] [varchar](6) NOT NULL,

	-- Alternate / Fiscal Calendar (1-Jul TO 30-Jun)

	[AltCalendarWeekOfYear] [int] NOT NULL,
	[AltCalendarMonth] [int] NOT NULL,
	[AltCalendarQuarter] [int] NOT NULL,
	[AltCalenderSemester] [int] NOT NULL,
	[AltCalendarYear] [int] NOT NULL,
	[AltCalenderYearMonth] [int] NOT NULL
)
AS
BEGIN 

	/*
	DECLARE @StartDate DATETIME
	DECLARE @EndDate DATETIME
	SET @StartDate = '01-JAN-2000'
	SET @EndDate = '31-DEC-2039'
	*/
	SET @StartDate = CAST(CAST(@StartDate AS DATE) AS DATETIME)
	SET @EndDate = CAST(CAST(@EndDate AS DATE) AS DATETIME)

	;WITH cteDates AS
    ( 
     select 1 AS Number,
            @StartDate CalendarDate
     where  @StartDate <= @EndDate
     union all 
     select Number+1,
            CalendarDate + 1 
     from    cteDates    
     where   CalendarDate + 1 < = @EndDate
    ),

	-- ADD KEYS, AND CALENDAR-DAY-BASED ATTRIBUTES
	cteCalendar AS
	(
		SELECT
			(YEAR(D.CalendarDate) * 10000) + (MONTH(D.CalendarDate) * 100) + DAY(D.CalendarDate) AS DateKey,
			CAST(D.CalendarDate AS DATE) CalendarDate,
			CONVERT(VARCHAR(11), D.CalendarDate, 113) AS CalendarDateName,
			DATEPART(weekday, D.CalendarDate) AS CalendarDayOfWeek,
			CASE
				WHEN (DATEPART(weekday, D.CalendarDate)-1) % 7 = 0 then 7
				ELSE (DATEPART(weekday, D.CalendarDate)-1) % 7
			END AS CalendarDayOfIsoWeek,
			DATEPART(dy, D.CalendarDate) AS CalendarDayOfYear,
			CAST(D.CalendarDate- DATEPART(weekday, D.CalendarDate) + 1 AS DATE) AS CalendarWeekStart,
			CAST(D.CalendarDate - DATEPART(weekday, D.CalendarDate) + 7 AS DATE) AS CalendarWeekEnd,
			DATEADD(dd, 1, CAST(D.CalendarDate- DATEPART(weekday, D.CalendarDate) + 1 AS DATE)) AS CalendarIsoWeekStart,
			DATEADD(dd, 1, CAST(D.CalendarDate - DATEPART(weekday, D.CalendarDate) + 7 AS DATE)) AS CalendarIsoWeekEnd,

			DATEPART(day, D.CalendarDate) AS CalendarDay,

			CASE(DATEPART(weekday, D.CalendarDate))
			WHEN 1 THEN 'Sun'
			WHEN 2 THEN 'Mon'
			WHEN 3 THEN 'Tue'
			WHEN 4 THEN 'Wed'
			WHEN 5 THEN 'Thu'
			WHEN 6 THEN 'Fri'
			WHEN 7 THEN 'Sat'
			END AS CalendarDayName,

			1 + (DATEPART(DAY, D.CalendarDate)/7) AS CalendarWeekOfMonth,
			DATEPART(week, D.CalendarDate) AS CalendarWeekOfYear,
			DATEPART(ISO_WEEK, D.CalendarDate) AS CalendarIsoWeekOfYear,
			MONTH(D.CalendarDate) AS CalendarMonth,

			CASE DATEPART(m, D.CalendarDate)
			WHEN 1 THEN 'Jan'
			WHEN 2 THEN 'Feb'
			WHEN 3 THEN 'Mar'
			WHEN 4 THEN 'Apr'
			WHEN 5 THEN 'May'
			WHEN 6 THEN 'Jun'
			WHEN 7 THEN 'Jul'
			WHEN 8 THEN 'Aug'
			WHEN 9 THEN 'Sep'
			WHEN 10 THEN 'Oct'
			WHEN 11 THEN 'Nov'
			WHEN 12 THEN 'Dec'
			END AS CalendarMonthName,

			DATEPART(q, D.CalendarDate) AS CalendarQuarter,
			CASE WHEN MONTH(D.CalendarDate) <=6 THEN 1 ELSE 2 END AS CalendarSemester,
			YEAR(D.CalendarDate) AS CalendarYear,
			(YEAR(D.CalendarDate) * 100) + MONTH(D.CalendarDate) AS CalendarYearMonth,
			SUBSTRING('JanFebMarAprMayJunJulAugSepOctNovDec', ((MONTH(D.CalendarDate)-1)*3)+1,3) + '-' + RIGHT(CAST(YEAR(D.CalendarDate) AS VARCHAR(4)), 2) CalendarYearMonthName
		FROM    cteDates D
	)
	
	, cteFiscalCalendar
	AS
	(
		SELECT 
			*,
			1 + ((CalendarWeekOfYear + 25) % 52) AltCalendarWeekOfYear,
			1 + ((CalendarMonth+ 5) % 12) AltCalendarMonth,
			1 + ((CalendarQuarter + 1) % 4) AltCalendarQuarter,
			1 + (CalendarSemester + 0) % 2 AltCalendarSemester,
			CalendarYear + CASE WHEN CalendarMonth >6 THEN 1 ELSE 0 END AltCalendarYear,
			(100 * (CalendarYear + CASE WHEN CalendarMonth >6 THEN 1 ELSE 0 END)) + ((CalendarMonth - 6) % 12) AltCalendarYearMonth
		FROM
			cteCalendar
	)

    INSERT INTO @DateTable
	SELECT * FROM cteFiscalCalendar OPTION (MAXRECURSION 0) 
    RETURN;
END

GO

/****** Object:  Table [dbo].[DateTable]    Script Date: 8/10/2022 4:09:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DateTable](
	[DateKey] [int] NOT NULL,
	[CalendarDate] [date] NOT NULL,
	[CalendarDateName] [varchar](11) NOT NULL,
	[CalendarDayOfWeek] [int] NOT NULL,
	[CalendarDayOfIsoWeek] [int] NOT NULL,
	[CalendarDayOfYear] [int] NOT NULL,
	[CalendarWeekStart] [date] NOT NULL,
	[CalendarWeekEnd] [date] NOT NULL,
	[CalendarIsoWeekStart] [date] NOT NULL,
	[CalendarIsoWeekEnd] [date] NOT NULL,
	[CalendarDay] [int] NOT NULL,
	[CalendarDayName] [varchar](3) NOT NULL,
	[CalendarWeekOfMonth] [int] NOT NULL,
	[CalendarWeekOfYear] [int] NOT NULL,
	[CalendarIsoWeekOfYear] [int] NOT NULL,
	[CalendarMonth] [int] NOT NULL,
	[CalendarMonthName] [varchar](3) NOT NULL,
	[CalendarQuarter] [int] NOT NULL,
	[CalendarSemester] [int] NOT NULL,
	[CalendarYear] [int] NOT NULL,
	[CalendarYearMonth] [int] NOT NULL,
	[CalendarYearMonthName] [varchar](6) NOT NULL,
	[AltCalendarWeekOfYear] [int] NOT NULL,
	[AltCalendarMonth] [int] NOT NULL,
	[AltCalendarQuarter] [int] NOT NULL,
	[AltCalenderSemester] [int] NOT NULL,
	[AltCalendarYear] [int] NOT NULL,
	[AltCalenderYearMonth] [int] NOT NULL,
 CONSTRAINT [PK_DateTable] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [UQ_DateTable_CalendarDate]    Script Date: 8/10/2022 4:09:17 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_DateTable_CalendarDate] ON [dbo].[DateTable]
(
	[CalendarDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[DateTableView]    Script Date: 8/10/2022 4:09:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DateTableView]
AS
	SELECT
		*,

		-- AGO FIELDS ARE DYNAMIC BASED ON GETDATE()
		DATEDIFF(DD, CalendarDate, GETDATE()) CalendarDaysAgo,
		DATEDIFF(WW, CalendarDate, GETDATE()) CalendarWeeksAgo,
		DATEDIFF(MM, CalendarDate, GETDATE()) CalendarMonthsAgo,
		DATEDIFF(QQ, CalendarDate, GETDATE()) CalendarQuartersAgo,
		DATEDIFF(YY, CalendarDate, GETDATE()) CalendarYearsAgo
	FROM
		DateTable
GO

		
		-- The base interest rate in effect
		CREATE TABLE InterestRate (
			RateId INT NOT NULL,
			Rate FLOAT NOT NULL,
			YearStart INT NOT NULL,
			MonthStart INT NOT NULL
		);
GO

INSERT INTO InterestRate 
SELECT 1, 2.5, 0, 0
UNION ALL
SELECT 2, 2.25, 0, 3
UNION ALL
SELECT 3, 1.75, 0, 5
UNION ALL
SELECT 4, 1.50, 1, 2
UNION ALL
SELECT 5, 1.25, 1, 4
UNION ALL
SELECT 6, 1.00, 1, 7
UNION ALL
SELECT 7, 0.75, 4, 2
UNION ALL
SELECT 8, 0.50, 4, 5
UNION ALL
SELECT 9, 0.25, 6, 9
UNION ALL
SELECT 10, 0.50, 7, 10
UNION ALL
SELECT 11, 1.00, 7, 11
UNION ALL
SELECT 11, 1.50, 8, 2
UNION ALL
SELECT 11, 2.00, 8, 3
UNION ALL
SELECT 11, 2.25, 8, 4
UNION ALL
SELECT 11, 2.50, 8, 5
UNION ALL
SELECT 11, 2.75, 8, 6
UNION ALL
SELECT 11, 3.00, 8, 8
UNION ALL
SELECT 11, 3.25, 8, 10
UNION ALL
SELECT 11, 3.50, 9, 0
UNION ALL
SELECT 11, 3.75, 9, 2
UNION ALL
SELECT 11, 4.00, 9, 5
UNION ALL
SELECT 11, 4.25, 9, 9

GO

		CREATE TABLE Address (
			AddressId INT NOT NULL,
			AddressLine1 VARCHAR(250),
			AddressLine2 VARCHAR(250),
			Town VARCHAR(50),
			Region VARCHAR(50),
			Postcode INT,
			Country VARCHAR(50)
		)

		-- Branch
		CREATE TABLE Branch (
			BranchId SMALLINT NOT NULL,
			BranchName VARCHAR(50) NOT NULL,
			BranchAddressId INT NOT NULL,
			BranchOpenDateId INT NOT NULL
		)

		/****** Object:  Sequence [dbo].[SeqBranch]    Script Date: 16/10/2024 7:57:06 PM ******/
		CREATE SEQUENCE [dbo].[SeqBranch] 
		 AS [int]
		 START WITH 1
		 INCREMENT BY 1
		 MINVALUE 1
		 MAXVALUE 2147483647
		 CACHE 


