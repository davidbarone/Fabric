/*********************************************************************
module:		enorab_schema.sql:
Purpose:	Generates schema for enorab - a ficticious bank dataset.
Author:		David Barone
Created:	13/10/2024
Url:		https://github.com/davidbarone/Power-BI/tree/main/Datasets/Enorab 
Notes:		This script has been written for MSSQL (SQL Server)

Version History:

Version	Date		Author			Details
1.0		13/10/2024	David Barone	Script created
*********************************************************************/
USE enorab
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetDates]    Script Date: 8/10/2022 3:59:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Drop objects
DROP FUNCTION IF EXISTS staging.fn_person_generate_life_table
DROP FUNCTION IF EXISTS staging.fn_person
DROP FUNCTION IF EXISTS staging.fn_address
DROP FUNCTION IF EXISTS staging.fn_interest_rate
DROP FUNCTION IF EXISTS staging.fn_life_table
DROP FUNCTION IF EXISTS staging.fn_date_to_int
DROP FUNCTION IF EXISTS staging.fn_dates
DROP PROCEDURE IF EXISTS staging.sp_person_marry
DROP PROCEDURE IF EXISTS sp_calculate_interest_rate

DROP SEQUENCE IF EXISTS seq_branch
DROP VIEW IF EXISTS staging.vw_region
DROP VIEW IF EXISTS vw_date_table

DROP TABLE IF EXISTS staging.date_table
DROP TABLE IF EXISTS staging.interest_rate
DROP TABLE IF EXISTS staging.life_table
DROP TABLE IF EXISTS staging.person
DROP TABLE IF EXISTS staging.address
DROP TABLE IF EXISTS interest_rate
DROP TABLE IF EXISTS person
DROP TABLE IF EXISTS [address]
DROP TABLE IF EXISTS branch
DROP TABLE IF EXISTS interest_rate

DROP PROCEDURE IF EXISTS staging.sp_person_die
DROP PROCEDURE IF EXISTS sp_branch_open

-- Drop schema
DROP SCHEMA IF EXISTS staging
GO

-- Create schema
CREATE SCHEMA staging
GO

---------------------------------------------
-- Tables
---------------------------------------------

CREATE TABLE staging.interest_rate (
	interest_rate_id INT NOT NULL,
	interest_rate FLOAT NOT NULL,
	year_start INT NOT NULL,
	month_start INT NOT NULL
)
GO

CREATE TABLE staging.life_table (
	age INT NOT NULL,
	male_rate FLOAT NOT NULL,
	female_rate FLOAT NOT NULL
)

CREATE TABLE dbo.interest_rate (
	calendar_date DATE NOT NULL,
	interest_rate FLOAT NOT NULL
)
GO

CREATE TABLE staging.person (
	person_id INT PRIMARY KEY, 
	first_name varchar(50), 
	surname varchar(50), 
	sex varchar(1), 
	date_of_birth date,
	date_of_birth_adjusted DATE,
	date_of_death date,
	marrying_type FLOAT,
	spouse_person_id INT
)
GO

CREATE TABLE staging.address (
	address_id INT PRIMARY KEY,
	address_line_1 VARCHAR(250), 
	address_line_2 VARCHAR(250), 
	town VARCHAR(250), 
	region VARCHAR(250), 
	postcode INT,
	postcode_region INT,
	country VARCHAR(50)
)
GO

CREATE TABLE address (
	address_id INT NOT NULL,
	address_line_1 VARCHAR(250),
	address_line_2 VARCHAR(250),
	town VARCHAR(50),
	region VARCHAR(50),
	postcode INT,
	country VARCHAR(50)
)
GO

CREATE TABLE branch (
	branch_id SMALLINT NOT NULL,
	branch_name VARCHAR(50) NOT NULL,
	branch_address_id INT NOT NULL,
	branch_open_date_id INT NOT NULL
)
GO

CREATE TABLE staging.date_table(
	date_id INT NOT NULL,
	calendar_date DATE NOT NULL,
	calendar_date_name VARCHAR(11) NOT NULL,
	calendar_day_of_week SMALLINT NOT NULL,
	calendar_day_of_iso_week SMALLINT NOT NULL,
	calendar_day_of_year INT NOT NULL,
	calendar_week_start DATE NOT NULL,
	calendar_week_end DATE NOT NULL,
	calendar_iso_week_start DATE NOT NULL,
	calendar_iso_week_end DATE NOT NULL,
	calendar_day SMALLINT NOT NULL,
	calendar_day_name VARCHAR(3) NOT NULL,
	calendar_week_of_month SMALLINT NOT NULL,
	calendar_week_of_year SMALLINT NOT NULL,
	calendar_iso_week_of_year SMALLINT NOT NULL,
	calendar_month SMALLINT NOT NULL,
	calendar_month_name VARCHAR(3) NOT NULL,
	calendar_quarter SMALLINT NOT NULL,
	calendar_semester SMALLINT NOT NULL,
	calendar_year SMALLINT NOT NULL,
	calendar_year_month INT NOT NULL,
	calendar_year_month_name VARCHAR(6) NOT NULL,
	alt_calendar_week_of_year SMALLINT NOT NULL,
	alt_calendar_month SMALLINT NOT NULL,
	alt_calendar_quarter SMALLINT NOT NULL,
	alt_calender_semester SMALLINT NOT NULL,
	alt_calendar_year SMALLINT NOT NULL,
	alt_calender_year_month INT NOT NULL,
 CONSTRAINT [pk_date_table] PRIMARY KEY CLUSTERED 
(
	date_id ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uq_date_table_calendar_date] ON staging.date_table
(
	calendar_date ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

---------------------------------------------
-- Sequences
---------------------------------------------

CREATE SEQUENCE seq_branch
 AS [int]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 2147483647
 CACHE 
GO

---------------------------------------------
-- Functions
---------------------------------------------

-- =============================================
-- Author:		D.Barone
-- Create date: 20241117
-- Description:	Generates a life table.
-- =============================================
CREATE FUNCTION staging.fn_person_generate_life_table
(
	-- polynomial coefficients:
	@m0 FLOAT,
	@m1 FLOAT,
	@m2 FLOAT,
	@m3 FLOAT,
	@m4 FLOAT,
	@m5 FLOAT,
	@f0 FLOAT,
	@f1 FLOAT,
	@f2 FLOAT,
	@f3 FLOAT,
	@f4 FLOAT,
	@f5 FLOAT
)
RETURNS 
@output TABLE
(
	age INT,
	male_rate FLOAT,
	female_rate FLOAT
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set

	DECLARE @age INT
	SET @age = 0
	WHILE @age <= 130
	BEGIN
		INSERT INTO @output (age, male_rate, female_rate)
		SELECT
			@age,
			((@m5 * POWER(@age, 5)) + (@m4 * POWER(@age, 4)) + (@m3 * POWER(@age, 3)) +(@m2 * POWER(@age, 2)) + (@m1 * POWER(@age, 1)) + (@m0 * POWER(@age, 0))),
			((@f5 * POWER(@age, 5)) + (@f4 * POWER(@age, 4)) + (@f3 * POWER(@age, 3)) +(@f2 * POWER(@age, 2)) + (@f1 * POWER(@age, 1)) + (@f0 * POWER(@age, 0)))

		SET @age = @age + 1
	END

	RETURN 
END
GO

-- =============================================
-- Object:		staging.fn_date_to_int
-- Type:		FUNCTION
-- Author:		David Barone
-- Create date: 20241015
-- Description:	Converts Date To Int.
-- =============================================
CREATE FUNCTION staging.fn_date_to_int 
(
	@Date DATE
)
RETURNS INT
AS
BEGIN
	RETURN (YEAR(@Date) * 10000) + (MONTH(@Date) * 100) + DAY(@Date)
END;
GO	

-- =============================================
-- Object:		fn_dates
-- Type:		FUNCTION
-- Author:		David Barone
-- Create date: 20241015
-- Description:	Gets dates.
-- =============================================
CREATE FUNCTION staging.fn_dates 
(   
    @start_date DATETIME,
    @end_date DATETIME
)
RETURNS @date_table TABLE (
	date_id INT NOT NULL,
	calendar_date DATE NOT NULL,
	calendar_date_name VARCHAR(11) NOT NULL,
	calendar_day_of_week SMALLINT NOT NULL,
	calendar_day_of_iso_week SMALLINT NOT NULL,
	calendar_day_of_year INT NOT NULL,
	calendar_week_start DATE NOT NULL,
	calendar_week_end DATE NOT NULL,
	calendar_iso_week_start DATE NOT NULL,
	calendar_iso_week_end DATE NOT NULL,
	calendar_day SMALLINT NOT NULL,
	calendar_day_name VARCHAR(3) NOT NULL,
	calendar_week_of_month SMALLINT NOT NULL,
	calendar_week_of_year SMALLINT NOT NULL,
	calendar_iso_week_of_year SMALLINT NOT NULL,
	calendar_month SMALLINT NOT NULL,
	calendar_month_name VARCHAR(3) NOT NULL,
	calendar_quarter SMALLINT NOT NULL,
	calendar_semester SMALLINT NOT NULL,
	calendar_year SMALLINT NOT NULL,
	calendar_year_month INT NOT NULL,
	calendar_year_month_name VARCHAR(6) NOT NULL,
	alt_calendar_week_of_year SMALLINT NOT NULL,
	alt_calendar_month SMALLINT NOT NULL,
	alt_calendar_quarter SMALLINT NOT NULL,
	alt_calender_semester SMALLINT NOT NULL,
	alt_calendar_year SMALLINT NOT NULL,
	alt_calender_year_month INT NOT NULL
)
AS
BEGIN 

	SET @start_date = CAST(CAST(@start_date AS DATE) AS DATETIME)
	SET @end_date = CAST(CAST(@end_date AS DATE) AS DATETIME)

	;WITH cteDates AS
    (
		SELECT
			1 AS number,
			@start_date calendar_date
		WHERE
			@start_date <= @end_date
		UNION ALL
		SELECT
			number + 1,
			calendar_date + 1
		FROM
			cteDates
		WHERE
			calendar_date + 1 <= @end_date
    ),

	-- ADD KEYS, AND CALENDAR-DAY-BASED ATTRIBUTES
	cteCalendar AS
	(
		SELECT
			(YEAR(d.calendar_date) * 10000) + (MONTH(d.calendar_date) * 100) + DAY(d.calendar_date) AS date_id,
			CAST(d.calendar_date AS DATE) calendar_date,
			CONVERT(VARCHAR(11), d.calendar_date, 113) AS calendar_date_name,
			DATEPART(WEEKDAY, d.calendar_date) AS calendar_day_of_week,
			CASE
				WHEN (DATEPART(WEEKDAY, d.calendar_date)-1) % 7 = 0 then 7
				ELSE (DATEPART(WEEKDAY, d.calendar_date)-1) % 7
			END AS calendar_day_of_iso_week,
			DATEPART(DY, d.calendar_date) AS calendar_day_of_year,
			CAST(d.calendar_date- DATEPART(WEEKDAY, d.calendar_date) + 1 AS DATE) AS calendar_week_start,
			CAST(d.calendar_date - DATEPART(WEEKDAY, d.calendar_date) + 7 AS DATE) AS calendar_week_end,
			DATEADD(DD, 1, CAST(d.calendar_date- DATEPART(WEEKDAY, d.calendar_date) + 1 AS DATE)) AS calendar_iso_week_start,
			DATEADD(DD, 1, CAST(d.calendar_date - DATEPART(WEEKDAY, d.calendar_date) + 7 AS DATE)) AS calendar_iso_week_end,
			DATEPART(DAY, d.calendar_date) AS calendar_day,

			CASE(DATEPART(WEEKDAY, d.calendar_date))
			WHEN 1 THEN 'Sun'
			WHEN 2 THEN 'Mon'
			WHEN 3 THEN 'Tue'
			WHEN 4 THEN 'Wed'
			WHEN 5 THEN 'Thu'
			WHEN 6 THEN 'Fri'
			WHEN 7 THEN 'Sat'
			END AS calendar_day_name,

			1 + (DATEPART(DAY, d.calendar_date)/7) AS calendar_week_of_month,
			DATEPART(WEEK, d.calendar_date) AS calendar_week_of_year,
			DATEPART(ISO_WEEK, d.calendar_date) AS calendar_iso_week_of_year,
			MONTH(d.calendar_date) AS calendar_month,

			CASE DATEPART(M, d.calendar_date)
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
			END AS calendar_month_name,

			DATEPART(q, d.calendar_date) AS calendar_quarter,
			CASE WHEN MONTH(d.calendar_date) <=6 THEN 1 ELSE 2 END AS calendar_semester,
			YEAR(d.calendar_date) AS calendar_year,
			(YEAR(d.calendar_date) * 100) + MONTH(d.calendar_date) AS calendar_year_month,
			SUBSTRING('JanFebMarAprMayJunJulAugSepOctNovDec', ((MONTH(d.calendar_date)-1)*3)+1,3) + '-' + RIGHT(CAST(YEAR(d.calendar_date) AS VARCHAR(4)), 2) calendar_year_month_name
		FROM    cteDates D
	)
	
	, cteFiscalCalendar
	AS
	(
		SELECT 
			*,
			1 + ((calendar_week_of_year + 25) % 52) alt_calendar_week_of_year,
			1 + ((calendar_month+ 5) % 12) alt_calendar_month,
			1 + ((calendar_quarter + 1) % 4) alt_calendar_quarter,
			1 + (calendar_semester + 0) % 2 alt_calendar_semester,
			calendar_year + CASE WHEN calendar_month > 6 THEN 1 ELSE 0 END alt_calendar_year,
			(100 * (calendar_year + CASE WHEN calendar_month > 6 THEN 1 ELSE 0 END)) + ((calendar_month - 6) % 12) alt_calendar_year_month
		FROM
			cteCalendar
	)

    INSERT INTO @date_table
	SELECT * FROM cteFiscalCalendar OPTION (MAXRECURSION 0) 
    RETURN;
END
GO

-- =============================================
-- Object:		staging.fn_person
-- Type:		FUNCTION
-- Author:		David Barone
-- Create date: 20241015
-- Description:	Transforms person data from json.
-- =============================================
CREATE FUNCTION staging.fn_person
(
	@json NVARCHAR(MAX),
	@reference_date DATE,
	@today DATE
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT
		*,
		DATEADD(DAY, -DATEDIFF(DAY, date_of_birth, @reference_date), @today) date_of_birth_adjusted,
		CAST(NULL AS DATE) date_of_death,
		CAST(NULL AS FLOAT) marrying_propensity,
		CAST(NULL AS INT) spouse_person_id
	FROM OPENJSON(@json)
	WITH 
	(
		person_id INT, 
		first_name VARCHAR(50), 
		surname VARCHAR(50), 
		sex VARCHAR(1), 
		date_of_birth DATE
	)
)
GO

-- =============================================
-- Object:		staging.fn_address
-- Type:		FUNCTION
-- Author:		David Barone
-- Create date: 20241015
-- Description:	Transforms address data from json.
-- =============================================
CREATE FUNCTION staging.fn_address
(
	@json NVARCHAR(MAX)
)
RETURNS
	@results TABLE 
(
	address_id INT,
	address_line_1 VARCHAR(250), 
	address_line_2 VARCHAR(250), 
	town VARCHAR(250), 
	region VARCHAR(250), 
	postcode INT,
	postcode_region INT,
	country VARCHAR(50)
)
AS
BEGIN

	DECLARE @address TABLE (
		address_line_1 VARCHAR(250), 
		address_line_2 VARCHAR(250), 
		town VARCHAR(250), 
		region VARCHAR(250), 
		postcode INT,
		country VARCHAR(50)
	)

	INSERT INTO
		@Address (address_line_1, address_line_2, town, region, postcode, country)
	SELECT
		*
	FROM OPENJSON(@json)
	WITH 
	(
		address_line_1 VARCHAR(250), 
		address_line_2 VARCHAR(250), 
		town VARCHAR(250), 
		region VARCHAR(250), 
		postcode INT,
		country VARCHAR(50)
	)

	-- Turn blanks into NULLs
	UPDATE @Address SET address_line_2 = NULLIF(address_line_2, '')

	-- Dbarone.Net.Fake generates a lot of distinct regions. We'll group by 1st 2 digits of
	-- postcode, and use the 1st region for each group as a region. This will give us just
	-- under 100 regions.
	; WITH cteAddresses
	AS
	(
		SELECT
			ROW_NUMBER() OVER (ORDER BY postcode) AS address_id,
			*,
			CAST(postcode/1000 AS INT) postcode_region
		FROM
			@Address
	)
	, cteFirstAddressIdPerRegion
	AS
	(
		SELECT
			postcode_region,
			MIN(address_id) default_region_address_id
		FROM
			cteAddresses
		GROUP BY
			postcode_region
	)

	INSERT INTO @results
	SELECT
		a.address_id,
		a.address_line_1,
		a.address_line_2,
		a.town,
		a2.region,
		a.postcode,
		a.postcode_region,
		a.country
	FROM
		cteAddresses a
	INNER JOIN
		cteFirstAddressIdPerRegion ar
	ON
		a.postcode_region = ar.postcode_region
	INNER JOIN
		cteAddresses a2
	ON
		ar.default_region_address_id = a2.address_id

	RETURN 
END
GO

-- =============================================
-- Object:		staging.fn_interest_rate
-- Type:		FUNCTION
-- Author:		David Barone
-- Create date: 20241015
-- Description:	Transforms interest rate data from json.
-- Notes:		Repeats data for as long as history
--              requires.
-- =============================================
CREATE FUNCTION staging.fn_interest_rate
(
	@json VARCHAR(MAX),
	@start_date DATE,
	@today DATE
)
RETURNS
	@results TABLE 
(
	interest_rate_id INT,
	interest_rate FLOAT,
	year_start INT, 
	month_start INT
)
AS
BEGIN 

	-- Get initial copy of interest rates from json
	DECLARE @interest_rate TABLE (
		interest_rate_id INT,
		interest_rate FLOAT,
		year_start INT,
		month_start INT
	)

	INSERT INTO
		@interest_rate (interest_rate_id, interest_rate, year_start, month_start)
	SELECT
		*
	FROM OPENJSON(@json)
	WITH 
	(
		interest_rate_id INT,
		interest_rate FLOAT,
		year_start INT,
		month_start INT
	)

	-- Now we loop to fill up rates for entire history
	DECLARE @interest_rate_id INT = 0
	DECLARE @year_start INT = 0
	DECLARE @month_start INT = 0
	WHILE (1=1)
	BEGIN
		INSERT INTO
			@results (interest_rate_id, interest_rate, year_start, month_start)
		SELECT
			@interest_rate_id + interest_rate_id,
			interest_rate,
			CAST(((@year_start * 12) + @month_start + (year_start * 12) + month_start) / 12 AS INT) year_start,
			CAST(((@year_start * 12) + @month_start + (year_start * 12) + month_start) % 12 AS INT) month_start
		FROM
			@interest_rate

		-- get last record from output
		SELECT
			@interest_rate_id = a.interest_rate_id,
			@year_start = a.year_start,
			@month_start = a.month_start
		FROM
		(
			SELECT TOP(1) * FROM @results ORDER BY interest_rate_id DESC
		) a

		IF (DATEDIFF(YEAR, @start_date, @today) < @year_start)
		BEGIN
			-- break once we have enough rates history
			BREAK
		END

	END
	RETURN
END

GO

-- =============================================
-- Object:		staging.fn_life_table
-- Type:		FUNCTION
-- Author:		David Barone
-- Create date: 20241015
-- Description:	Transforms life table from json.
-- =============================================
CREATE FUNCTION staging.fn_life_table
(
	@json VARCHAR(MAX)
)
RETURNS
	@results TABLE 
(
	age INT,
	male_rate FLOAT,
	female_rate FLOAT
)
AS
BEGIN 

	INSERT INTO
		@results (age, male_rate, female_rate)
	SELECT
		*
	FROM OPENJSON(@json)
	WITH 
	(
		age INT,
		male_rate FLOAT,
		female_rate FLOAT
	)

	RETURN
END

GO

---------------------------------------------
-- Procedures
---------------------------------------------

-- =============================================
-- Object:		staging.sp_person_generate_population
-- Type:		PROCEDURE
-- Author:		David Barone
-- Create date: 20241026
-- Description:	Generates a population.
-- Notes:		Algorithm works as follows:
--
-- a) Define a start/end date for population
-- b) Define end population required (n)
-- c) define epoch = start date - 100 years
-- d) create population (n) at epoch date with age
-- 	  following linear distribution of ages between 0 and 100
-- e) play the following daily algorithm:
-- f) new births at rate of @birth_date_per_1000_per_year. Boy ratio is @boy_birth_ratio
-- g) deaths based on life polymonial function, based on age/sex
-- i) repeat daily process until end date
-- j) if population > n, then randomly remove people
-- =============================================
ALTER PROCEDURE [staging].[sp_person_generate_population]
	@start_date DATE,
	@end_date DATE,
	@required_population INT,

	@birth_rate_per_1000_per_year FLOAT,
	@boy_birth_ratio FLOAT,

	@life_table_m0 FLOAT,
	@life_table_m1 FLOAT,
	@life_table_m2 FLOAT,
	@life_table_m3 FLOAT,
	@life_table_m4 FLOAT,
	@life_table_m5 FLOAT,

	@life_table_f0 FLOAT,
	@life_table_f1 FLOAT,
	@life_table_f2 FLOAT,
	@life_table_f3 FLOAT,
	@life_table_f4 FLOAT,
	@life_table_f5 FLOAT

AS
BEGIN

	SET NOCOUNT ON

	DECLARE @epoch DATE = DATEADD(YEAR, -100, @start_date)

	DECLARE @people TABLE (
		person_id INT IDENTITY(1,1),
		sex CHAR(1),
		date_of_birth DATE,
		date_of_death DATE NULL
	)

	-- Set starting population at epoch.
	DECLARE @i INT = 0
	WHILE @i < @required_population
	BEGIN
		DECLARE @random FLOAT = RAND()
		DECLARE @days_alive INT
		SET @days_alive = @random * 100 * 365.25
		INSERT INTO @people (date_of_birth, sex) SELECT DATEADD(DAY, -@days_alive, @epoch), CASE WHEN @i % 2 = 0 THEN 'M' ELSE 'F' END
		SET @i = @i + 1
	END

	--SELECT * FROM @people

	-- Iterate through to end date
	DECLARE @current_date DATE = @epoch
	WHILE @current_date < @end_date
	BEGIN
		DECLARE @msg VARCHAR(250)
		--PRINT ('Iterating population for date: ' + CAST(@current_date AS VARCHAR))

		-- deaths
		; WITH cte1
		AS
		(
			SELECT
				p.person_id,
				date_of_birth,
				p.sex,
				p.date_of_death,
				CAST(DATEDIFF(YEAR, p.date_of_birth, @current_date) AS bigint) age
			FROM
				@people p
			WHERE
				date_of_death IS NULL
		)
		, cte2
		AS
		(
			SELECT
				c.*,

				-- Calculate survival rate
				CASE
					WHEN c.sex = 'M' THEN lt.male_rate / 365.25
					WHEN c.sex = 'F' THEN lt.female_rate / 365.25
				END survival_rate,
				(0.0 + ABS(CHECKSUM(NewId())) %  CAST(POWER(2.0, 31) -1 AS INT)) / CAST(POWER(2.0, 31) -1 AS INT) random_survive
			FROM
				cte1 c
			INNER JOIN
				staging.fn_person_generate_life_table (
					@life_table_m0,
					@life_table_m1,
					@life_table_m2,
					@life_table_m3,
					@life_table_m4,
					@life_table_m5,
					@life_table_f0,
					@life_table_f1,
					@life_table_f2,
					@life_table_f3,
					@life_table_f4,
					@life_table_f5
				) lt
			ON
				c.age = lt.age
			WHERE
				date_of_death IS NULL
		)

		UPDATE
			@people
		SET
			date_of_death = @current_date
		FROM
			@people p
		INNER JOIN
			cte2 c
		ON
			p.person_id = c.person_id
		WHERE
			random_survive <= survival_rate

		-- births
		; WITH cte1
		AS
		(
			SELECT
				p.person_id,
				@birth_rate_per_1000_per_year / 1000 / 365.25 birth_rate,
				(0.0 + ABS(CHECKSUM(NewId())) %  CAST(POWER(2.0, 31) -1 AS INT)) / CAST(POWER(2.0, 31) -1 AS INT) random
			FROM
				@people p
			WHERE
				date_of_death IS NULL
		)
		, cte2
		AS
		(
			SELECT
				*,
				CASE WHEN random <= birth_rate THEN 'YES' ELSE '' END OK
			FROM
				cte1
		)

		INSERT INTO
			@people (sex, date_of_birth)
		SELECT
			CASE
				WHEN (0.0 +
					ABS(
						CHECKSUM(NewId())
						) % CAST(POWER(2.0, 31) -1 AS INT)
					) / CAST(POWER(2.0, 31) -1 AS INT) <= @boy_birth_ratio
				THEN 'M'
				ELSE 'F'
			END,
			@current_date
		FROM
			cte2 c
		INNER JOIN
			@people p
		ON
			p.person_id = c.person_id
		WHERE
			c.random <= c.birth_rate

		SET @current_date = DATEADD(DD, 1, @current_date)
	END

	-- return population who were alive at any time between start
	-- date and end date
	SELECT *, DATEDIFF(YEAR, date_of_birth, date_of_death) FROM @people
	WHERE 
		(
		date_of_death IS NULL
		--OR date_of_death >= @start_date
		) AND
		date_of_birth < @end_date
	ORDER BY date_of_birth
END
GO

EXEC staging.sp_person_generate_population
	'20000101',
	'20241027',
	1000,
	@birth_rate_per_1000_per_year,
	@boy_birth_ratio,
	@life_table_m0,
	@life_table_m1,
	@life_table_m2,
	@life_table_m3,
	@life_table_m4,
	@life_table_m5,
	@life_table_f0,
	@life_table_f1,
	@life_table_f2,
	@life_table_f3,
	@life_table_f4,
	@life_table_f5
GO

-- =============================================
-- Object:		staging.sp_person_die
-- Type:		PROCEDURE
-- Author:		David Barone
-- Create date: 20241026
-- Description:	decease people using life table.
-- =============================================
CREATE PROCEDURE staging.sp_person_die
	@date DATE
AS
BEGIN
		SET NOCOUNT ON

		DECLARE @date_id INT
		SELECT @date_id = date_id FROM staging.date_table WHERE calendar_date = @date

		PRINT ('Begin death process...')
		DECLARE @random FLOAT-- = RAND(@date_id)

		-- Calculate whether person dies today
		DECLARE @current_person_id INT

		WHILE (1=1)
		BEGIN
			DECLARE @next_person_id INT = NULL
			SELECT @random = RAND()

			DECLARE @next_rate FLOAT
			SELECT TOP(1)
				@next_person_id = person_id,
				@next_rate = (CASE p.sex WHEN 'M' THEN lt.male_rate ELSE lt.female_rate END / 365.25) -- convert to daily rate
			FROM
				staging.person p
			INNER JOIN
				staging.life_table lt
			ON DATEDIFF(YEAR, p.date_of_birth_adjusted, @date) = lt.age
			WHERE
				date_of_death IS NULL AND
				person_id > COALESCE(@current_person_id, 0)
				
			ORDER BY
				person_id			
			
			IF @next_person_id IS NULL
			BEGIN
				BREAK
			END
	
			UPDATE staging.person
			SET date_of_death = @date
			WHERE
				person_id = @next_person_id AND
				@random < @next_rate

			SET @current_person_id = @next_person_id
		END
		PRINT ('End death process...')
END
GO

-- =============================================
-- Object:		staging.sp_person_marry
-- Type:		PROCEDURE
-- Author:		David Barone
-- Create date: 20241015
-- Description:	marries people.
-- =============================================
CREATE PROCEDURE staging.sp_person_marry
	@marrying_type_rate FLOAT,
	@marry_within_year_range INT
AS
BEGIN
		SET NOCOUNT ON

		PRINT ('Begin marriage process...')

		DECLARE @Random FLOAT = RAND(1)

		-- Calculate marrying type for each person (0..1)
		WHILE (1=1)
		BEGIN
			DECLARE @next_person_id INT
			SELECT @next_person_id = MIN(person_id) FROM staging.person WHERE marrying_type IS NULL
			IF @next_person_id IS NULL
			BEGIN
				BREAK
			END

			SET @random = RAND()

			UPDATE staging.person
			SET marrying_type = @Random
			WHERE person_id = @next_person_id
		END

		-- Marry people based on following rules:
		-- - Person must be marrying type (i.e. above the @marrying_type_rate)
		-- - Must find another person with same surname, within @marry_within_year_range of age
		-- - Must be > 18 years old
		-- - one M, one F
		WHILE (1=1)
		BEGIN
			DECLARE @spouse_male_person_id INT = NULL
			DECLARE @spouse_female_person_id INT = NULL

			SELECT
				@spouse_male_person_id = a.spouse_male_person_id,
				@spouse_female_person_id = a.spouse_female_person_id
			FROM
			(
				SELECT TOP 1
					males.person_id spouse_male_person_id,
					females.person_id spouse_female_person_id
				FROM
					(SELECT * FROM staging.person WHERE Sex = 'M' AND marrying_type > @marrying_type_rate AND spouse_person_id IS NULL) males
				INNER JOIN
					(SELECT * FROM staging.person WHERE Sex = 'F' AND marrying_type > @marrying_type_rate AND spouse_person_id IS NULL) females
				ON
					males.surname = females.surname
					AND DATEDIFF(YEAR, males.date_of_birth_adjusted, females.date_of_birth_adjusted) BETWEEN -@marry_within_year_range AND @marry_within_year_range
			) A

			IF @spouse_male_person_id IS NULL OR @spouse_female_person_id IS NULL
			BEGIN
				BREAK
			END

			UPDATE staging.person SET spouse_person_id = @spouse_female_person_id WHERE person_id = @spouse_male_person_id 
			UPDATE staging.person SET spouse_person_id = @spouse_male_person_id WHERE person_id = @spouse_female_person_id
		END

		PRINT ('End marriage process...')

END
GO

-- =============================================
-- Object:		staging.sp_branch_open
-- Type:		PROCEDURE
-- Author:		David Barone
-- Create date: 20241015
-- Description:	Randomly opens a branch. Max
--              1 branch per region.
-- =============================================
CREATE PROCEDURE sp_branch_open
	@processing_date DATE,
	@new_branch_open_rate FLOAT,
	@random_branch_open FLOAT,
	@random_branch_weighting FLOAT
AS
BEGIN

	DECLARE @new_bank_region VARCHAR(50)

	SELECT
		@new_bank_region =
		(
			SELECT
				TOP(1) region
			FROM
				staging.vw_region r
			WHERE
				NOT EXISTS
				(
					SELECT
						NULL
					FROM
						branch b
					INNER JOIN
						[address] a
					ON
						b.Branch_Address_Id = a.Address_Id
						AND a.region = r.region
				)
				AND @random_branch_open > 1 - @new_branch_open_rate
				AND @random_branch_open <= r.weighting
		)
	
	IF @new_bank_region IS NOT NULL
	BEGIN
		-- Create new Branch Address
		DECLARE @bank_address_Id INT
		SELECT @bank_address_id = MIN(@bank_address_Id)
		FROM
			staging.address
		WHERE
			1=1
			AND address_line_2 IS NULL	-- For branches, don't select an address that is a flat with 2 address lines
			AND region = @new_bank_region

		-- Possible for a region to only have single address, and it to be a flat only address - if so we don't bother creating the branch.
		IF @bank_address_id IS NOT NULL
		BEGIN
			INSERT INTO Address (
				address_id,
				address_line_1,
				address_line_2,
				town,
				region,
				postcode,
				country)
			SELECT
				address_id,
				address_line_1,
				address_line_2,
				town,
				region,
				postcode,
				country	
			FROM
				staging.address
			WHERE address_id = @bank_address_Id

			-- Create new branch
			DECLARE @branch_id INT
			SELECT @branch_id = NEXT VALUE FOR seq_branch

			INSERT INTO branch (
				branch_id,
				branch_name,
				branch_open_date_id,
				branch_address_id)
			SELECT
				@branch_id,
				@new_bank_region,
				dbo.DateToInt(@processing_date),
				@bank_address_Id
		END
	END

END
GO

-- =============================================
-- Object:		sp_calculate_interest_rate
-- Type:		PROCEDURE
-- Author:		David Barone
-- Create date: 20241015
-- Description:	Writes a daily interest rate.
-- =============================================
CREATE PROCEDURE sp_calculate_interest_rate
	@processing_date DATE,
	@start_date DATE
AS
BEGIN

	DECLARE @interest_rate FLOAT

	-- months from start date:
	DECLARE @months INT = DATEDIFF(MONTH, @start_date, @processing_date)
	
	;WITH cteRates
	AS
	(
		SELECT
			*,
			(ir.year_start * 12) + ir.month_start total_month
		FROM
			staging.interest_rate ir
	)

	, cteAddNext
	AS
	(
		SELECT
			*,
			LEAD(total_month, 1) OVER (ORDER BY interest_rate_id) next_total_month
		FROM
			cteRates
	)

	SELECT
		@interest_rate = interest_rate
	FROM
		cteAddNext ir
	WHERE
		ir.total_month <= @months AND
		ir.next_total_month > @months

	INSERT INTO
		interest_rate (calendar_date, interest_rate)
	SELECT
		@processing_date, @interest_rate

END
GO

---------------------------------------------
-- Views
---------------------------------------------

-- =============================================
-- Object:		vw_date_table
-- Type:		VIEW
-- Author:		David Barone
-- Create date: 20241015
-- Description:	Dynamically generated date table.
-- =============================================
CREATE VIEW vw_date_table
AS
	SELECT
		*,

		-- AGO FIELDS ARE DYNAMIC BASED ON GETDATE()
		DATEDIFF(DD, calendar_date, GETDATE()) calendar_days_ago,
		DATEDIFF(WW, calendar_date, GETDATE()) calendar_weeks_ago,
		DATEDIFF(MM, calendar_date, GETDATE()) calendar_months_ago,
		DATEDIFF(QQ, calendar_date, GETDATE()) calendar_quarters_ago,
		DATEDIFF(YY, calendar_date, GETDATE()) calendar_years_ago
	FROM
		staging.date_table
GO

-- =============================================
-- Object:		vw_region
-- Type:		VIEW
-- Author:		David Barone
-- Create date: 20241015
-- Description:	view of regions.
-- =============================================
CREATE VIEW staging.vw_region
AS
	WITH cteRegions
	AS
	(
		SELECT
			region,
			COUNT(1) weighting
		FROM
			staging.address
		GROUP BY
			region
	)
	, cteRegionBranches
	AS
	(
		SELECT
			a.region,
			COUNT(b.branch_id) branch_count
		FROM
			branch b
		INNER JOIN
			[address] a
		ON
			b.branch_address_id = a.address_id
		GROUP BY
			a.region
	)
	, cteMaxWeighting
	AS
	(
		SELECT MAX(weighting) max_weighting FROM cteRegions
	)

	SELECT
		r.region,
		CAST(weighting AS FLOAT) / mw.max_weighting weighting	-- convert to number in range (0..1),
	FROM
		cteRegions r
	CROSS JOIN
		cteMaxWeighting mw
	LEFT OUTER JOIN
		cteRegionBranches rb
	ON
		r.region = rb.region
GO
