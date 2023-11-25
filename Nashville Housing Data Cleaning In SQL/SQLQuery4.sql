/*

Cleaning Data in SQL Queries

*/

Select Top 1000 * 
From [HousingProject].[dbo].[NashvilleHousing]

---------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDateConverted, CONVERT(DATE, SaleDate)
From [HousingProject].[dbo].[NashvilleHousing]


UPDATE [HousingProject].[dbo].[NashvilleHousing]
SET SaleDate = CONVERT(DATE, SaleDate)

-- If it doesn't Update properly

ALTER TABLE [HousingProject].[dbo].[NashvilleHousing]
ADD SaleDateConverted DATE

UPDATE [HousingProject].[dbo].[NashvilleHousing]
SET SaleDateConverted = CONVERT(DATE, SaleDate)

--------------------------------------------------------------------------------------------------------------------------

/*
	REPLACING NULL VALUES IN THE PROPERTYADDRESS COLUMN
*/

 -- QUERY TO SHOW ALL PROPERTYADDRESS THAT IS NULL
 SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM [dbo].[NashvilleHousing] AS a
 JOIN [dbo].[NashvilleHousing] AS b
 ON a.ParcelID = b.ParcelID
 AND a.UniqueID <> b.UniqueID
 WHERE b.PropertyAddress IS NULL

 -- QUERY TO REPLACE ALL NULL VALUES IN PROPERTYADDRESS
 UPDATE a
 SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM [dbo].[NashvilleHousing] AS a
 JOIN [dbo].[NashvilleHousing] AS b
 ON a.ParcelID = b.ParcelID
 AND a.UniqueID <> b.UniqueID
 WHERE a.PropertyAddress IS NULL


 --------------------------------------------------------------------------------------------------------------------------

 -- SPLIT THE PROPERTYADDRESS INTO ADDRESS AND CITY
 SELECT PropertyAddress, 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress, 1)-1) AS Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress, 1)+1, LEN(PropertyAddress)) AS City
 FROM [dbo].[NashvilleHousing]

 ALTER TABLE [dbo].[NashvilleHousing]
 ADD PropertySplitAddress NVARCHAR(255)

 UPDATE [dbo].[NashvilleHousing]
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress, 1)-1)

 ALTER TABLE [dbo].[NashvilleHousing]
 ADD PropertySplitCity NVARCHAR(255)

 UPDATE [dbo].[NashvilleHousing]
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress, 1)+1, LEN(PropertyAddress))


 /*
	Next is to split the owneraddress into owner address, owner city and owner state
 */

 SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
 FROM [dbo].[NashvilleHousing]

 ALTER TABLE [dbo].[NashvilleHousing]
 ADD OwnerSplitAddress NVARCHAR(255)

 UPDATE [dbo].[NashvilleHousing]
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

 ALTER TABLE [dbo].[NashvilleHousing]
 ADD OwnerSplitCity NVARCHAR(255)

 UPDATE [dbo].[NashvilleHousing]
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

 ALTER TABLE [dbo].[NashvilleHousing]
 ADD OwnerSplitState NVARCHAR(255)

 UPDATE [dbo].[NashvilleHousing]
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

 --------------------------------------------------------------------------------------------------------------------------

 /*
 Replacing Y with Yes and N with No in the SoldAsVacant Column
 */

 SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END AS Fix
 FROM [dbo].[NashvilleHousing]
 WHERE SoldAsVacant IN ('Y', 'N')

 UPDATE [dbo].[NashvilleHousing]
 SET SoldAsVacant = 
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END;


--------------------------------------------------------------------------------------------------------------------------


/*
Remove Duplicates
*/
WITH ParcelCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		ORDER BY UniqueID) AS row_num
FROM [dbo].[NashvilleHousing]
)

SELECT * 
FROM ParcelCTE 
WHERE row_num > 1 
ORDER BY row_num DESC

DELETE FROM ParcelCTE 
WHERE row_num > 1

--------------------------------------------------------------------------------------------------------------------------

-- DELETE UNUSED COLUMNS
SELECT * FROM [dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate