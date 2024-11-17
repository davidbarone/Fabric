/*********************************************************************
Module:		enorab.sql
Purpose:	Generates data for a ficticious bank dataset.
Depends:	Run enorab_schema.sql first.

Author:		David Barone
Created:	13/10/2024
Url:		https://github.com/davidbarone/Power-BI/tree/main/Datasets/Enorab 
Notes:		This script has been written for MSSQL (SQL Server).

Version History:

Version	Date		Author			Details
1.0		13/10/2024	David Barone	Script created
*********************************************************************/
USE enorab
GO

BEGIN TRANSACTION

BEGIN

	-- 1. Random variables
	BEGIN
		DECLARE @random1 FLOAT
		DECLARE @random2 FLOAT
		SELECT @random1 = RAND(1)	-- Fixed seed, so script is idempotent.
		SELECT @random2 = RAND(2)	-- Fixed seed, so script is idempotent.
	END

	-- 2. Configuration
	BEGIN
		DECLARE @reference_date DATE = '20241013'						-- Date used on any static datasets. All static dates to be adjusted relative to this date.
		DECLARE @today DATE = GETDATE()									-- Today's date
		DECLARE @new_branch_open_rate FLOAT = 4.0/100;					-- daily rate that a new branch opens
		DECLARE @marry_within_year_range INT = 5						-- only marry people within this many years age.
		DECLARE @account_create_rate FLOAT = 0.001						-- This is the daily rate of an individual creating a new investment account
		DECLARE @new_customer_rate FLOAT = 0.001						-- Rate at which a new customer opens first account at bank
		DECLARE @days_history INT = 10 * 365.25							-- number of days history to generate
		DECLARE @start_date DATE = DATEADD(DAY, -@days_history, @today)	-- start date
		DECLARE @life_table_m0 FLOAT = 0.0002							-- Life table linear model (male) coefficient order 0
		DECLARE @life_table_m1 FLOAT = 0.0								-- Life table linear model (male) coefficient order 1
		DECLARE @life_table_m2 FLOAT = 0.0								-- Life table linear model (male) coefficient order 2
		DECLARE @life_table_m3 FLOAT = 0.0								-- Life table linear model (male) coefficient order 2
		DECLARE @life_table_m4 FLOAT = -0.000000001						-- Life table linear model (male) coefficient order 2
		DECLARE @life_table_m5 FLOAT = 0.00000000005					-- Life table linear model (male) coefficient order 2
		DECLARE @life_table_f0 FLOAT = 0.0002							-- Life table linear model (female) coefficient order 0
		DECLARE @life_table_f1 FLOAT = 0.0								-- Life table linear model (female) coefficient order 1
		DECLARE @life_table_f2 FLOAT = 0.0								-- Life table linear model (female) coefficient order 2
		DECLARE @life_table_f3 FLOAT = 0.0								-- Life table linear model (female) coefficient order 2
		DECLARE @life_table_f4 FLOAT = -0.000000001						-- Life table linear model (female) coefficient order 2
		DECLARE @life_table_f5 FLOAT = 0.00000000004					-- Life table linear model (female) coefficient order 2
		DECLARE @birth_rate_per_1000_per_year FLOAT = 18				-- Birth rate per 1000 per year
		DECLARE @boy_birth_ratio FLOAT = 104.0/204						-- ratio of boys born
		DECLARE @population_epoch INT = 1000							-- used to generate population
		DECLARE @epoch_days INT = 100*365								-- days prior to the start date, to start generating a population

		-- validations
		IF @days_history < 100 OR @days_history > 10000
		BEGIN
			raiserror('Configuration error: days_history must be between 100 and 10000', 20, -1)
		END

		-- display configurations
		SELECT
			'start_date' CONFIGURATION,
			CAST(@start_date AS VARCHAR) VALUE,
			'Start date for the dataset. Enorab is designed with a 10-year data window.' DESCRIPTION
		UNION ALL
		SELECT
			'new_branch_open_rate',
			CAST(@new_branch_open_rate AS VARCHAR),
			'A rate (between 0 and 1) determinining the likelyhood of a branch opening on a given date.'
		UNION ALL
		SELECT
			'reference_date',
			CAST(@reference_date AS VARCHAR),
			'The date that all static dates in the script were generated. This script will automatically adjust these dates to be relative to today.'
		UNION ALL
		SELECT
			'today',
			CAST(@today AS VARCHAR),
			'Today''s date - the last date that data exists in this dataset is @Today - 1.'
		UNION ALL
		SELECT
			'marry_within_year_range',
			CAST(@marry_within_year_range AS VARCHAR),
			'Max difference in years alllowed for marrying people.'
		UNION ALL
		SELECT
			'account_create_rate',
			CAST(@account_create_rate AS VARCHAR),
			'Daily rate that a customer creates a new account.'
		UNION ALL
		SELECT
			'new_customer_rate',
			CAST(@new_customer_rate AS VARCHAR),
			'Daily rate that a new customer opens first account.'
		UNION ALL
		SELECT
			'days_history',
			CAST(@days_history AS VARCHAR),
			'Number of days of history to generate dataset for.'

	END

	------------------------------------------
	-- 3. Staging data
	------------------------------------------

	-- 3.1 staging.date_table
	BEGIN
		PRINT('Creating calendar for period 1900-2099...')
		TRUNCATE TABLE staging.date_table;
		INSERT INTO staging.date_table SELECT * FROM staging.fn_dates ('19000101', '20991231');
	END

	-- 3.2 staging.person table
	BEGIN
		PRINT('Creating pool of people...')
		DECLARE @person_json VARCHAR(MAX)
		SELECT @person_json = BulkColumn
		FROM OPENROWSET (BULK 'E:\david\github\Power-BI\datasets\enorab\json\person.json', SINGLE_CLOB) import
		
		TRUNCATE TABLE staging.person
		/*
		INSERT INTO staging.person SELECT *	FROM staging.fn_person(@person_json, @reference_date, @today)
		EXEC staging.sp_person_marry @marrying_rate, @marry_within_year_range
		*/
	END

	-- 3.3 staging.address table
	BEGIN
		PRINT('Creating pool of addresses...')
		DECLARE @address_json VARCHAR(MAX)
		SELECT @address_json = BulkColumn
		FROM OPENROWSET (BULK 'E:\david\github\Power-BI\datasets\enorab\json\address.json', SINGLE_CLOB) import

		TRUNCATE TABLE staging.address
		INSERT INTO staging.address SELECT * FROM staging.fn_address(@address_json)
	END

	-- 3.4 Interest rate table
	BEGIN
		PRINT('Generating interest rate history...')
		DECLARE @interest_rate_json VARCHAR(MAX)
		SELECT @interest_rate_json = BulkColumn
		FROM OPENROWSET (BULK 'E:\david\github\Power-BI\Datasets\Enorab\json\interest_rate.json', SINGLE_CLOB) import

		INSERT INTO staging.interest_rate SELECT * FROM staging.fn_interest_rate(@interest_rate_json, @start_date, @today)
	END

	-- 3.4 Life table
	BEGIN
		PRINT('Generating life table...')
		DECLARE @life_table_json VARCHAR(MAX)
		SELECT @life_table_json = BulkColumn
		FROM OPENROWSET (BULK 'E:\david\github\Power-BI\Datasets\Enorab\json\life_table.json', SINGLE_CLOB) import

		INSERT INTO staging.life_table SELECT * FROM staging.fn_life_table(@life_table_json)
	END

	-- 3.5 Generate population
	-- Generates a population using a number of models for
	-- births, deaths, marriages etc.
	BEGIN

		-- Generate population
		TRUNCATE TABLE staging.person
		INSERT INTO staging.person
		EXEC staging.sp_person_births_deaths_marriages
			@start_date,
			@today,
			@epoch_days,
			@population_epoch,
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
	END

	-------------------------------------
	-- 4. Reference data (static)
	-------------------------------------
	BEGIN
		TRUNCATE TABLE product_type;
		INSERT INTO product_type
		SELECT 1, 'Everyday Account', 'Everyday transactional / checking account', 0, 1, 1, 0, 1, 1 UNION ALL
		SELECT 2, 'Savings Account', 'Used to save money', 0, 1, 0, 0, 1, 0 UNION ALL
		SELECT 3, 'High Interest Savings Account', 'High interest savings account - higher rates, but restrictions on withdrawals', 0, 0, 0, 0, 1, 0 UNION ALL
		SELECT 4, 'Term Deposit', 'Lock money for term for higher rates', 0, 0, 0, 0, 0, 0 UNION ALL
		SELECT 5, 'Young Saver Account', 'Account for under-18s', 0, 1, 1, 0, 1, 0 UNION ALL
		SELECT 6, 'Business Account', 'Business bank account', 0, 1, 1, 1, 1, 1 UNION ALL 
		SELECT 7, 'Offset Account', 'Linked to a home loan account', 0, 1, 1, 0, 1, 1 UNION ALL

		-- Loans

		SELECT 10, 'Home Loan', 'Home loan account', 1, 0, 0, 0, 0, 0 UNION ALL
		SELECT 11, 'Business Loan', 'Business Loan', 1, 0, 0, 0, 0, 0 UNION ALL
		SELECT 12, 'Personal Loan', 'Personal Loan', 1, 0, 0, 0, 0, 0 UNION ALL

		-- Credit cards
		SELECT 20, 'Credit Card Account', 'Account linked to a credit card', 1, 1, 1, 1, 1, 1;

	END

	-------------------------------------
	-- 5. Main daily data generation
	-------------------------------------

	DECLARE @date DATE
	SELECT @random1 = RAND()
	SELECT @random2 = RAND()
	SET @date = @start_date

	WHILE @date < @today
	BEGIN
		DECLARE @msg VARCHAR(250)
		--SET @msg = 'Processing date: ' + CAST(@date AS VARCHAR)
		PRINT(@msg)
		
		-- 5.1 Create interest rate for day
		EXEC sp_calculate_interest_rate @date, @start_date

		-- 5.1 Create new branches
		EXEC sp_branch_open @date, @new_branch_open_rate, @random1, @random2 

		-- 5.2 New people being born in the population

		-- 5.3 People dying in the population
		--EXEC staging.sp_person_die @date

		-- 5.4 New customer opening new account (invester or borrower)

		-- 5.4 Existing customers opening a new account

		-- 5.5 Transactions on transactional accounts

		-- 5.6 Interest charged on loans

		-- 5.7 Interest charged on overdrawn accounts

		-- 5.8 Calculation of fees (e.g. unauthorised overdraft)

		-- 5.9 Calculation of bank interest

		-- 5.10 Calculation of term deposit interest

		-- 5.11 Rollover of term deposit

		-- 5.12 Rollover of loan product (fixed rate -> variable rate)
		
		-- 5.13 Existing customers closing an existing account

		-- 5.146 Existing customers leaving bank (closing all accounts)

		-- 5.xx End of Month
		-- Update parameters (e.g. invest/borrower bias)
		
		-- next date
		SET @date = DATEADD(d, 1, @Date)
	END
END

-- Final Data
SELECT * FROM branch
SELECT * FROM [address]

COMMIT
