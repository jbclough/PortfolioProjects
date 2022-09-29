----CLEANING DATA IN SQL QUERIES

SELECT *
FROM dbo.NashvilleHousing


--STANDARDISE DATE FORMAT

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

----ABOVE DOESN'T WORK

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM dbo.NashvilleHousing

----POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT NH_A.ParcelID, NH_A.PropertyAddress, NH_B.ParcelID, NH_B.PropertyAddress, ISNULL(NH_A.PropertyAddress, NH_B.PropertyAddress)
FROM dbo.NashvilleHousing NH_A
JOIN dbo.NashvilleHousing NH_B
	ON NH_A.ParcelID = NH_B.ParcelID
	AND NH_A.UniqueID <> NH_B.UniqueID
WHERE NH_A.PropertyAddress IS NULL

UPDATE NH_A
SET PropertyAddress = ISNULL(NH_A.PropertyAddress, NH_B.PropertyAddress)
FROM dbo.NashvilleHousing NH_A
JOIN dbo.NashvilleHousing NH_B
	ON NH_A.ParcelID = NH_B.ParcelID
	AND NH_A.UniqueID <> NH_B.UniqueID
WHERE NH_A.PropertyAddress IS NULL

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
--Property Address

SELECT PropertyAddress
FROM dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address

FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM dbo.NashvilleHousing

--Owner Address

SELECT OwnerAddress
FROM dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

--CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM dbo.NashvilleHousing

UPDATE dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--DELETE UNUSED COLUMNS

SELECT *
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN SaleDate

--BONUS - ADD COLUMN LAND VALUE PER ACRE

SELECT Acreage, LandValue, (LandValue / Acreage) LandValuePerAcre
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD LandValuePerAcre INT

UPDATE NashvilleHousing
SET LandValuePerAcre = (LandValue / Acreage)

SELECT PropertySplitCity, TotalValue, Acreage, LandValuePerAcre
FROM dbo.NashvilleHousing
ORDER BY LandValuePerAcre DESC
