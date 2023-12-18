/*

Cleaning Data in SQL Queries 

*/

Select *
From PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing 
Set SaleDateConverted = CONVERT(date, SaleDate)

------------------------------------------------------------------------------

--Populate Property Address

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null

--self join the table
Select a.parcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress
From PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b 
	on a.parcelID = b.parcelID
	AND a.uniqueID <> b.uniqueID
Where a.PropertyAddress is null

--Use ISNULL to create populated addresses
Select a.parcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b 
	on a.parcelID = b.parcelID
	AND a.uniqueID <> b.uniqueID
Where a.PropertyAddress is null

--Update the table
Update a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b 
	on a.parcelID = b.parcelID
	AND a.uniqueID <> b.uniqueID
Where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City 
From PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing 
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table NashvilleHousing
Add PropertySPlitCity nvarchar(255);

Update NashvilleHousing 
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

--OwnerAddress Split

Select OwnerAddress 
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)  as city,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as state
From PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing 
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing 
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing 
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in 'Sold as Vacant' Field 

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
From PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
	SET SoldAsVacant =
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
			 END
-------------------------------------------------------------------------------
--Remove Duplicates 

WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) as row_num
From PortfolioProject..NashvilleHousing

)
--Delete 
--From RowNumCTE
--Where row_num > 1

Select * 
From RowNumCTE
Where row_num > 1

-------------------------------------------------------------
		
--Remove unused Columns 
-------------------------------------------------------------------
--Create view with columns you'd use
--Drop view AddressFixed


Use PortfolioProject
GO
Create View AddressFixed as 
		Select UniqueID,
			   ParcelID,
			   LandUse,
			   PropertySplitAddress as Address,
			   PropertySPlitCity as City,
			   SaleDateConverted as SaleDate,
			   SalePrice,
			   LegalReference,
			   SoldAsVacant,
			   OwnerName,
			   OwnerSplitAddress as OwnerAddress,
			   OwnerSplitCity as OwnerCity,
			   OwnerSplitState as OwnerState,
			   Acreage,
			   TaxDistrict,
			   LandValue,
			   BuildingValue,
			   TotalValue,
			   YearBuilt,
			   Bedrooms,
			   FullBath,
			   HalfBath
From portfolioproject..NashvilleHousing