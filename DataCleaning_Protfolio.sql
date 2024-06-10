/*
Cleaning Data in SQl Queries
*/


select *
from ProtfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------

--Standardize Data Format
--There is no use of time, so we can remove the time.

select SaleDate, convert(date,SaleDate)
from ProtfolioProject..NashvilleHousing

--update NashvilleHousing
--set SaleDate = convert(date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted date;
update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)
select SaleDateConverted
from ProtfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data

select *
from ProtfolioProject..NashvilleHousing
where PropertyAddress is null


select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from ProtfolioProject..NashvilleHousing a
join ProtfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from ProtfolioProject..NashvilleHousing a
join ProtfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------------------

--Breaking out address individual columns (address, city, state)

select PropertyAddress
from ProtfolioProject..NashvilleHousing
--where PropertyAddress is null

select
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City
from ProtfolioProject..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(225);
update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(225);
update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))


-- spliting the owner Address using parsename

--parsename breakes the string form the periods so we converted the comma into periods.
--and it's also start from the  beginning

select [UniqueID ], ParcelID, OwnerAddress
from ProtfolioProject..NashvilleHousing

select
PARSENAME(replace(OwnerAddress, ',', '.'),3),
PARSENAME(replace(OwnerAddress, ',', '.'),2),
PARSENAME(replace(OwnerAddress, ',', '.'),1)
from ProtfolioProject..NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(225);
update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(225);
update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(225);
update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'),1)

select *
from ProtfolioProject..NashvilleHousing


-------------------------------------------------------------------------------------------------------------------

--change Y and N to yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant), count(SoldAsVacant)
from ProtfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from ProtfolioProject..NashvilleHousing


update NashvilleHousing
set SoldAsVacant = 
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end


-----------------------------------------------------------------------------------------------------

--Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID) row_num
from ProtfolioProject..NashvilleHousing
--order by ParcelID
)
delete
from RowNumCTE
where row_num> 1
--order by PropertyAddress

-------------------------------------------------------------------------------------------

--Delete unused columns

alter table ProtfolioProject..NashvilleHousing
drop column  OwnerAddress, PropertyAddress

alter table ProtfolioProject..NashvilleHousing
drop column  SaleDate