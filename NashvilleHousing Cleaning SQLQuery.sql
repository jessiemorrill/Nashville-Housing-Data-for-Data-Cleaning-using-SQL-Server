/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]

  */
  Cleaning Data in SQL Queries
  */
  SELECT * 
  FROM PortfolioProject.dbo.NashvilleHousing
-- standardize Date fomat

SELECT SaleDate, CONVERT(Date,SaleDate) 
  FROM PortfolioProject.dbo.NashvilleHousing

  Update NashvilleHousing
  SET SaleDate = CONVERT(Date,SaleDate)

  ALTER TABLE NashvilleHousing
  Add SaleDateConverted Date;

  Update NashvilleHousing
  SET SaleDateConverted = CONVERT(Date,SaleDate)

 -- Populate Property Address data

 SELECT *
  FROM PortfolioProject.dbo.NashvilleHousing
  --where PropertyAddress is null
  ORDER BY ParcelID

  --Selfjoin
  SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
  From PortfolioProject.dbo.NashvilleHousing a
  JOIN PortfolioProject.dbo.NashvilleHousing b
       ON a.ParcelID = b.ParcelID
	   AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress is null

  Update a
  SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
  From PortfolioProject.dbo.NashvilleHousing a
  JOIN PortfolioProject.dbo.NashvilleHousing b
       ON a.ParcelID = b.ParcelID
	   AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress is null

  -- Breaking out Address into Individual Columns (Address, City, State)

  SELECT PropertyAddress
  FROM PortfolioProject.dbo.NashvilleHousing
  --Where PropertyAddress is null
  --order by ParcelID

  SELECT 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
  FROM PortfolioProject.dbo.NashvilleHousing

  ALTER TABLE NashvilleHousing
  Add PropertySplitAddress Nvarchar(255);

  Update NashvilleHousing
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

  ALTER TABLE NashvilleHousing
  Add PropertySplitCity Nvarchar(255);

  Update NashvilleHousing
  SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

  SELECT *
  FROM PortfolioProject.dbo.NashvilleHousing

  SELECT OwnerAddress
  FROM PortfolioProject.dbo.NashvilleHousing

  SELECT
  PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
  PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
  PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
  FROM PortfolioProject.dbo.NashvilleHousing

  
  ALTER TABLE NashvilleHousing
  Add OwnerSplitAddress Nvarchar(255);

  Update NashvilleHousing
  SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
  
  ALTER TABLE NashvilleHousing
  Add OwnerSplitCity Nvarchar(255);

  Update NashvilleHousing
  SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

  ALTER TABLE NashvilleHousing
  Add OwnerSplitState Nvarchar(255);

  Update NashvilleHousing
  SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


  SELECT *
  FROM PortfolioProject.dbo.NashvilleHousing



  --Change Y and N to Yes and No in "Sold as Vacant" field

  SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
  From PortfolioProject.dbo.NashvilleHousing
  GROUP BY SoldAsVacant
  ORDER BY 2

 SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
 From PortfolioProject.dbo.NashvilleHousing

 Update PortfolioProject.dbo.NashvilleHousing
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


--Remove Duplicates

WITH RowNumCTE AS 
(SELECT *,
      ROW_NUMBER() OVER (
	  PARTITION BY ParcelID,
	                       PropertySplitAddress,
				           SalePrice,
				           SaleDateConverted,
				           LegalReference
				           ORDER BY
				                   UniqueID
				                   ) row_num
FROM PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--order by PropertyAddress


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Delete Unused Columns
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

