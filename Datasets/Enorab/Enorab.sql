/*********************************************************************
Enorab.sql:	A script to generate a ficticious bank dataset.

Author:		David Barone
Created:	13/10/2024
Url:		https://github.com/davidbarone/Power-BI/tree/main/Datasets/Enorab 
Notes:		This script has been written for MSSQL (SQL Server).
			Please run enorab_schema.sql first to create base objects.

Version History:

Version	Date		Author			Details
1.0		13/10/2024	David Barone	Script created
*********************************************************************/
USE Enorab

BEGIN TRANSACTION

BEGIN

	-- 1.0 Random variables
	BEGIN
		DECLARE @Random1 FLOAT
		DECLARE @Random2 FLOAT
		SELECT @Random1 = RAND(1)	-- Fixed seed, so script is idempotent.
		SELECT @Random2 = RAND(2)	-- Fixed seed, so script is idempotent.
	END

	-- 2.0 Configuration
	BEGIN
		-- branch opening rate per region weighting unit
		DECLARE @NewBranchOpeningRate FLOAT = 4.0/100;

		-- @MarryingTypeRate
		-- Each person gets a random propensity to marry (0..1)
		-- people can marry under following scenarios
		-- 1. Person's MarryingType value > @MarryingTypeThreshold, then:
		-- 2. Randomly marry person of opposite sex with (a) same surname and (b) age within 10 years and (c) both ages > 18
		-- Don't track when married - assumed fully married / not married for the lifespan of our dataset.
		DECLARE @MarryingTypeRate FLOAT = 0.2				-- people
		DECLARE @MarryWithinYearRange INT = 5				-- only marry people within this many years age.

		-- Reference Dates
		DECLARE @ReferenceDate DATE = '20241013'	-- This is date that script was created. All static dates to be adjusted relative to this date.
		DECLARE @Today DATE = GETDATE()
		DECLARE @StartDate DATE = DATEADD(YEAR, -10, GETDATE())
		DECLARE @CreateAccountRate FLOAT = 0.001	-- This is the daily rate of an individual creating a new investment account
		
		SELECT '@StartDate' CONFIGURATION, CAST(@StartDate AS VARCHAR) VALUE, 'Start date for the dataset. Enorab is designed with a 10-year data window.' DESCRIPTION
		UNION ALL
		SELECT '@NewBranchOpeningRate', CAST(@NewBranchOpeningRate AS VARCHAR), 'A rate (between 0 and 1) determinining the likelyhood of a branch opening on a given date.'
		UNION ALL
		SELECT '@ReferenceDate', CAST(@ReferenceDate AS VARCHAR), 'The date that all static dates in the script were generated. This script will automatically adjust these dates to be relative to today.'
		UNION ALL
		SELECT '@Today', CAST(@Today AS VARCHAR), 'Today''s date - the last date that data exists in this dataset is @Today - 1.'
		UNION ALL
		SELECT '@MarryingTypeThreshold', CAST(@MarryingTypeRate AS VARCHAR), 'Rate for marrying people. Value of 1 denotes all people can marry.'
		
	END

	-- 3.0 Populate date dimension
	BEGIN
		TRUNCATE TABLE DateTable;
		INSERT INTO DateTable SELECT * FROM fnGetDates(@StartDate, @Today);
	END

	-- 4. staging.person table
	BEGIN
		-- 4.0 Load Json Data

		-- These datasets obtained using Dbarone.Net.Fake
		-- Url: https://github.com/davidbarone/Dbarone.Net.Fake
		DECLARE @personJson VARCHAR(MAX)
		SELECT @personJson=BulkColumn
		FROM OPENROWSET (BULK 'E:\david\github\Power-BI\Datasets\Enorab\person.json', SINGLE_CLOB) import
		
		INSERT INTO staging.Person SELECT *	FROM staging.fnPerson(@personJson, @referenceDate, @today)

		EXEC staging.spPersonMarry @MarryingTypeRate, @marryWithinYearRange
	END

	-- 5. Address
	BEGIN
		-- 5.1 Load json data
		DECLARE @addressJson VARCHAR(MAX)
		SELECT @addressJson=BulkColumn
		FROM OPENROWSET (BULK 'E:\david\github\Power-BI\Datasets\Enorab\address.json', SINGLE_CLOB) import

		INSERT INTO staging.Address SELECT * FROM staging.fnAddress(@personJson)
	END

	-- 6. Region Weighting (weight the regions based on number of addresses in that region)
	BEGIN
		INSERT INTO
			staging.RegionWeighting
		SELECT
			Region,
			COUNT(1) Weighting,
			0 HasBank
		FROM
			staging.Address
		GROUP BY
			Region

		-- Make the weighting a number between 0 and 1 (with 1 representing the region with the most addresses, and all other weightings relative to this).;
		UPDATE
			staging.RegionWeighting
		SET
			Weighting = CAST(Weighting AS FLOAT) / (SELECT MAX(Weighting) FROM #RegionWeighting)
	END

	-------------------------------------
	-- FINAL TABLES
	--
	-- These are the final tables used
	-------------------------------------
	BEGIN
		
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
	END
END

-------------------------------------
-- MAIN DAILY DATA GENERATION ROUTINE
--
-- This routine loops for each day
-- for 10 year history. For each day
-- simulates a number of activities
-- to generate a fully synthesised
-- banking dataset
-------------------------------------
BEGIN

	DECLARE @Date DATE
	SET @Date = @StartDate
	WHILE @Date < GETDATE()
	BEGIN
		SELECT @Random1 = RAND()
		SELECT @Random2 = RAND()

		-- 1.1 Creation of new branch
		BEGIN
			DECLARE @NewBankRegion VARCHAR(50)

			SELECT
				@NewBankRegion = (
					SELECT
						TOP(1) Region
					FROM
						#RegionWeighting rw
					WHERE
						NOT EXISTS (
							SELECT
								NULL
							FROM
								Branch b
							INNER JOIN
								Address a
							ON
								b.BranchAddressId = a.AddressId
								AND a.Region = rw.Region
						)
						AND @Random1 <= CAST(Weighting AS FLOAT)
						AND @Random2 > 1 - @NewBranchOpeningRate
				)
	
			IF @NewBankRegion IS NOT NULL
			BEGIN
				-- Create new Branch Address
				DECLARE @Bank_Address_Id INT
				SELECT @Bank_Address_Id = MIN(AddressId)
				FROM
					#Addresses1
				WHERE
					1=1
					AND AddressLine2 IS NULL	-- For branches, don't select an address that is a flat with 2 address lines
					AND Region = @NewBankRegion

				-- Possible for a region to only have single address, and it to be a flat only address - if so we don't bother creating the branch.
				IF @Bank_Address_Id IS NOT NULL
				BEGIN
					INSERT INTO Address (
						AddressId,
						AddressLine1,
						AddressLine2,
						Town,
						Region,
						Postcode,
						Country)
					SELECT
						AddressId,
						AddressLine1,
						AddressLine2,
						Town,
						Region,
						Postcode,
						Country	
					FROM
						#Addresses1
					WHERE AddressId = @Bank_Address_Id

					-- CREATE NEW BRANCH
					DECLARE @BranchId INT
					SELECT @BranchId = NEXT VALUE FOR SeqBranch

					INSERT INTO Branch (
						BranchId,
						BranchName,
						BranchOpenDateId,
						BranchAddressId)
					SELECT
						@BranchId,
						@NewBankRegion,
						dbo.DateToInt(@Date),
						@Bank_Address_Id
				END
			END
		END

		-- 1.2 People creating new account
		SET @Date = DATEADD(d, 1, @Date)

	END
END

-- Final Data
SELECT * FROM DateTableView
SELECT * FROM #People ORDER BY Surname
SELECT * FROM #Addresses
SELECT * FROM #Addresses1
SELECT * FROM #RegionWeighting
SELECT * FROM Address
SELECT * FROM Branch

ROLLBACK
