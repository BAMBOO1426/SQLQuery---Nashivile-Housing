-- Review dataset
SELECT * FROM ZY_Portfolio.dbo.Nashivilehousingaddress;

-- Standardize date information (add a new table with unuseful timestamp removed)
ALTER TABLE ZY_Portfolio.dbo.Nashivilehousingaddress
ADD DateofSale DATE

UPDATE ZY_Portfolio.dbo.Nashivilehousingaddress
SET DateofSale = CONVERT(DATE, SaleDate);

-- Fill in missing property address (per observed, same parcelID share same property address)
-- Self-join the table, when property address is null, using address info in rows with same parcelID but different uniqueID to fill in the missing value 

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ZY_Portfolio.dbo.Nashivilehousingaddress as a
JOIN ZY_Portfolio.dbo.Nashivilehousingaddress as b ON a.ParcelID = b.ParcelID
WHERE a.PropertyAddress IS NULL AND a.[UniqueID ] != b.[UniqueID ]

-- Break down owner address into useable location information using PARSENAME

--add column for property street info only
ALTER TABLE ZY_Portfolio.dbo.Nashivilehousingaddress
ADD Propertystreet NCHAR(255)

UPDATE ZY_Portfolio.dbo.Nashivilehousingaddress
SET Propertystreet = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2)

--add column for property city info only
ALTER TABLE ZY_Portfolio.dbo.Nashivilehousingaddress
ADD Propertycity NCHAR(255)

UPDATE ZY_Portfolio.dbo.Nashivilehousingaddress
SET Propertycity = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)

-- Organize values in SoldAsVacant, update the values from "Yes, Y, No, N" to "Yes, No"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) FROM ZY_Portfolio.dbo.Nashivilehousingaddress
GROUP BY SoldAsVacant
ORDER BY 2 DESC

UPDATE ZY_Portfolio.dbo.Nashivilehousingaddress
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
			            ELSE SoldAsVacant
	               END 

-- Combine two Nashivile housing worksheets for house price prediction 

SELECT * FROM ZY_Portfolio.dbo.Nashivilehousingaddress AS address 
LEFT JOIN ZY_Portfolio.dbo.Nashivilehousingprice AS price ON address.[UniqueID ] = price.[UniqueID ]


