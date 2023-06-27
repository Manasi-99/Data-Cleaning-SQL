USE PortfolioDB
GO

-- Checking out the Data
SELECT *
FROM [dbo].[HousingData]


-- Standerize 'SaleDate' Date Format

/*SELECT SaleDate, CONVERT(date, SaleDate)
FROM HousingData*/

ALTER TABLE [dbo].[HousingData]
ADD SaleDateConverted DATE;

UPDATE HousingData
SET SaleDateConverted = CONVERT(DATE, SaleDate)


--------------------------------------------------------


-- Populate Property Address Data

SELECT *
FROM HousingData
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- hd1
UPDATE hd1
SET PropertyAddress = ISNULL(hd1.PropertyAddress, hd2.PropertyAddress)
FROM [dbo].[HousingData] hd1
JOIN [dbo].[HousingData] hd2 ON hd1.ParcelID = hd2.ParcelID
	AND hd1.[UniqueID ] <> hd2.[UniqueID ]
	WHERE hd1.PropertyAddress IS NULL

SELECT hd1.ParcelID, hd1.PropertyAddress, hd2.ParcelID, hd2.PropertyAddress, ISNULL(hd1.PropertyAddress, hd2.PropertyAddress)
FROM [dbo].[HousingData] hd1
JOIN [dbo].[HousingData] hd2 ON hd1.ParcelID = hd2.ParcelID
	AND hd1.[UniqueID ] <> hd2.[UniqueID ]
WHERE hd1.PropertyAddress IS NULL


-----------------------------------------------------------------------------


-- Separating out the adress field components into (Address, City, State)

SELECT PropertyAddress
FROM [dbo].[HousingData]
-- WHERE PropertyAddress IS NULL
-- ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address, -- -1 is to eliminate the comma
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM [dbo].[HousingData]

ALTER TABLE [dbo].[HousingData]
ADD SplitAddress NVARCHAR(255)

UPDATE HousingData
SET SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)



ALTER TABLE [dbo].[HousingData]
ADD SplitCity NVARCHAR(100)

UPDATE HousingData
SET SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--------------------------------------------------------------------------


SELECT OwnerAddress
FROM [dbo].[HousingData]

-- (Parsename can separate by recognizing '.' ONLY)
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS [Owner's Address],
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS [Owner's City],
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS [Owner's State]
FROM [dbo].[HousingData]

ALTER TABLE [dbo].[HousingData]
ADD [Owner's Address] NVARCHAR(100)

UPDATE HousingData
SET [Owner's Address] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



ALTER TABLE [dbo].[HousingData]
ADD [Owner's City] NVARCHAR(100)

UPDATE HousingData
SET [Owner's City] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE [dbo].[HousingData]
ADD [Owner's State] NVARCHAR(100)

UPDATE HousingData
SET [Owner's State] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

------------------------------------------------

-- Change Y and N to Yes and No in SoldAsVacant Column

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM [dbo].[HousingData]
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
	END
FROM [dbo].[HousingData]


UPDATE HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
	END


--------------------------------------------------------------------------

-- Remove Duplicates

WITH duplCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID
	) row_num

FROM [dbo].[HousingData]
)

SELECT *
FROM duplCTE
WHERE row_num > 1


--------------------------------------------------

-- Deleting unwanted columns

SELECT *
FROM [dbo].[HousingData]

ALTER TABLE [dbo].[HousingData]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [dbo].[HousingData]
DROP COLUMN SaleDate
