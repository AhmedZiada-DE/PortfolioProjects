--Cleaning the data by SQL queries

Select *
From PortfolioProject.dbo.NashvilleHousing;


--Standarize SaleDate

Select SaleDate, CONVERT(date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

use PortfolioProject;

--UPDATE NashvilleHousing
--SET SaleDate=CONVERT(date,SaleDate)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ALTER Column SaleDate date;




--Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




--Breaking out Address into individual columns ( Address, City, State)



Select 
SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress )-1) as Address,
SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress )+1, LEN(PropertyAddress)) asAddress

From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add ProperitySplitAddress nvarchar(255);

Update NashvilleHousing
SET ProperitySplitAddress=SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress )-1) 


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add ProperitySplitCity nvarchar(255);

Update NashvilleHousing
SET ProperitySplitCity=SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress )+1, LEN(PropertyAddress))



Select *
From PortfolioProject.dbo.NashvilleHousing





--Breaking out OwnerAddress with a different method


Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing




ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)



Select *
From PortfolioProject..NashvilleHousing




--Change Y and N to Yes and No in SoldAsVacant


Select DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant,
	Case When SoldAsVacant='Y' Then 'Yes' 
		 When SoldAsVacant='N' Then 'No'
		 Else SoldAsVacant
		 END
From PortfolioProject..NashvilleHousing



Update NashvilleHousing
SET SoldAsVacant=Case When SoldAsVacant='Y' Then 'Yes' 
					  When SoldAsVacant='N' Then 'No'
					  Else SoldAsVacant
					  END



Select DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2




--Remove Duplicates


WITH RowNumCTE AS (
Select *,
	   ROW_NUMBER() OVER(
	   PARTITION BY ParcelID,
					PropertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
					ORDER BY UniqueID
					)	AS row_number

From PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)

--DELETE
--FROM RowNumCTE
--Where row_number>1


SELECT *
FROM RowNumCTE
Where row_number>1





--Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
Drop COLUMN PropertyAddress,OwnerAddress,TaxDistrict