--cleaning data in sql queries

select* from PortfolioProjects..NashvilleHousing

--Standardized date format

Select SaleDate
from PortfolioProjects..NashvilleHousing

Alter table PortfolioProjects..NashvilleHousing
alter column Saledate date

--Populate Property address data

Select*
from PortfolioProjects..NashvilleHousing
where PropertyAddress is NULL				/* Viewing Blank Addresses */
order by ParcelID							/* Observed pattern in ParcelID and Property Address */

Select a.PropertyAddress,a.ParcelID, b.PropertyAddress,b.ParcelID,ISNULL(a.propertyaddress,b.PropertyAddress) as NewPropertAddress
from PortfolioProjects..NashvilleHousing a
join PortfolioProjects..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is NULL
 
update a
set a.PropertyAddress=b.propertyaddress
from PortfolioProjects..NashvilleHousing a
join PortfolioProjects..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is NULL

--Breaking out address into individual columns(address,city,state)

--1.PropertyAddress

select ParcelID, SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) address,SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,len(propertyaddress)) city 
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress=SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity=SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,len(propertyaddress))

--2.OwnerAddress

Select PARSENAME(replace(owneraddress,',','.'),3) address
,PARSENAME(replace(owneraddress,',','.'),2) city
,PARSENAME(replace(owneraddress,',','.'),1) state
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress=PARSENAME(replace(owneraddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity=PARSENAME(replace(owneraddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set Ownersplitstate=PARSENAME(replace(owneraddress,',','.'),1)


--change 'Y' and 'N' as 'Yes' and 'No' in SoldAsVacant

select distinct(SoldAsVacant),count(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
order by count(soldasvacant)

select soldasvacant,
case
when SoldAsVacant='Y' Then 'Yes'
when SoldAsVacant='N'then 'No'
else SoldAsVacant
end CorrectedSoldAsVacant
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant='Yes' where SoldAsVacant='Y' 

update NashvilleHousing
set SoldAsVacant='No' where SoldAsVacant='N'

--removing duplicates

with RowNum
as
(select*, ROW_NUMBER() over(partition by ParcelID,SaleDate,LegalReference,SalePrice,SaleDate order by ParcelID) row_num
from NashvilleHousing
)

--Delete
--from RowNum
--where row_num>1

select* from RowNum
where row_num>1
order by ParcelID

--Deleting unused columns

alter table NashvilleHousing   
drop column propertyaddress,owneraddress,taxdistrict  