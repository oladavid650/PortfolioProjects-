USE PortfolioProject;

SELECT *
FROM PortfolioProject.dbo.NashvileHousing 


---Standardize SaleDate Format 
------------------------------------------------------------------------

--Select the Saledate and convert to Date format

SELECT SaleDate, CAST (SaleDate AS date) AS 'Date'
FROM PortfolioProject.dbo.NashvileHousing 


--Add a new column named SaleDateConverted 

ALTER TABLE NashvileHousing 
ADD NewSaleDate Date; 

--Update  the new Column (SaleDateConverted )
UPDATE NashvileHousing
SET NewSaleDate = CAST (SaleDate AS date)


--Displaying the new  SaleDate column

SELECT NewSaleDate, CAST (SaleDate AS date)
FROM PortfolioProject.dbo.NashvileHousing 


--------------------------------------------------------------------------------------------------------------



--Populate Property Address Data

SELECT PropertyAddress 
FROM PortfolioProject.dbo.NashvileHousing 
WHERE PropertyAddress IS NULL


--Joining tha table with itself 


SELECT a.ParcelID , a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvileHousing  a
JOIN PortfolioProject.dbo.NashvileHousing  b
ON a.ParcelID  = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvileHousing  a
JOIN PortfolioProject.dbo.NashvileHousing  b
ON a.ParcelID  = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


------------------------------------------------------------------------------

---Breaking out Address into individual columns (Address, City, State)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvileHousing 


--Add the columns to the existing table

--Add  the new Column (Address)
ALTER TABLE NashvileHousing 
ADD PropertySplitAddress Nvarchar(225)

--Update  the new Column (Address)
UPDATE NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

--Add the columns to the existing table
--Add  the new Column (City)
ALTER TABLE NashvileHousing 
ADD PropertySplitCity Nvarchar(255); 

--Update  the new Column (City)
UPDATE NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 


-------------------------------------------------------------------------------------------------------------------------------


---Spliting OwnerAddress using PARSENAME()

SELECT 
PARSENAME (REPLACE (OwnerAddress, ',', '.'), 3),
PARSENAME (REPLACE (OwnerAddress, ',', '.'), 2),
PARSENAME (REPLACE (OwnerAddress, ',', '.'), 1)
FROM  NashvileHousing

--Adding and updating the columns to the existing table
ALTER TABLE  NashvileHousing 
ADD Owner_Address Nvarchar(225)

UPDATE NashvileHousing 
SET Owner_Address = PARSENAME(REPLACE (OwnerAddress, ',','.'),3) 

ALTER TABLE  NashvileHousing 
ADD Owner_City Nvarchar(225)

UPDATE NashvileHousing 
SET Owner_City = PARSENAME(REPLACE (OwnerAddress, ',','.'),2) 

ALTER TABLE  NashvileHousing 
ADD Owner_State Nvarchar(225)

UPDATE NashvileHousing 
SET Owner_State = PARSENAME(REPLACE (OwnerAddress, ',','.'),1) 

-----------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Solid as Vacant' Field

--Count and Select the Distinct Values

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvileHousing 
GROUP BY SoldAsVacant
ORDER  BY 2 

--Change Y or N into Yes or No
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant  ='Y' THEN 'Yes'
	 WHEN SoldAsVacant  ='N' THEN 'No'
	 ELSE SoldAsVacant 
	 END
FROM PortfolioProject.dbo.NashvileHousing 

--Update the SoldAsVacant column

UPDATE NashvileHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant  ='Y' THEN 'Yes'
	 WHEN SoldAsVacant  ='N' THEN 'No'
	 ELSE SoldAsVacant 
	 END

------------------------------------------------------------------------------
--Remove Duplicate


WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, 
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
			 UniqueID 
			 )row_num
 FROM PortfolioProject..NashvileHousing
 )

SELECT*
FROM RowNumCTE 
 WHERE row_num > 1

 ----------------------------------------------------------------------------------------------------

 --DELETE Unused Columns

 SELECT *
FROM PortfolioProject.dbo.NashvileHousing 


 ALTER TABLE PortfolioProject..NashvileHousing
 DROP COLUMN  OwnerAddress, PropertyAddress, SaleDate

