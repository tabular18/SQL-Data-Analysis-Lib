-- SQL EDA

/*
Orders

- Rename Country/Region > Country
- cast datatypes
- replace postal code nulls with UNKNOWN
- Merged State, City column

*/



/*
Product ID is NOT unique, so generaete new unique ID using an index
source orders
Create unique product ID using product ID and index
*/

-- Quick check - what is the granularity of product data?
-- Unclear so far, looks like we do not have unique fields, so further EDA required...
SELECT COUNT(DISTINCT Product_ID) as count_productID  --1862 more than num names, even though some IDs have multi names? Explore
, COUNT(DISTINCT Product_Name) as count_productNames  --1849
, COUNT(DISTINCT Sub_Category) as count_subcats  --17
, COUNT(DISTINCT Category) as count_cats  --3
 FROM DEMODATA.dbo.superstore_order


-- Show sample of products where a product ID has multiple product name rows
SELECT DISTINCT top 20 
Category
,Product_ID
,Product_Name
,Sub_Category
 FROM DEMODATA.dbo.superstore_order 
WHERE PRODUCT_ID IN (
    SELECT PRODUCT_ID FROM DEMODATA.dbo.superstore_order
    GROUP BY Product_ID
    HAVING COUNT(DISTINCT Product_Name)>1)
ORDER BY Product_ID; -- can see examples, perhaps product name changed over time?

-- Table showing count of Product IDs in each bin of count_productNames
SELECT count_productNames
, COUNT(DISTINCT Product_ID) FROM (
    SELECT  Product_ID
    ,COUNT(DISTINCT Product_Name) as count_productNames  FROM DEMODATA.dbo.superstore_order
    GROUP BY Product_ID
) as base
group by count_productNames
order by count_productNames ; -- only ever max 2

-- Table showing count of Product IDs in each bin of count_subcategories
SELECT count_subcats
, COUNT(DISTINCT Product_ID) FROM (
    SELECT  Product_ID
    ,COUNT(DISTINCT Sub_Category) as count_subcats  FROM DEMODATA.dbo.superstore_order
    GROUP BY Product_ID
) as base
group by count_subcats
order by count_subcats ; -- only ever multi products in same subcat

-- Table showing count of Product Names in each bin of count_productIDs. Some have >3 IDs
 SELECT count_productIDs
, COUNT(DISTINCT Product_Name) FROM (
    SELECT  Product_Name
    ,COUNT(DISTINCT Product_ID) as count_productIDs  FROM DEMODATA.dbo.superstore_order
    GROUP BY Product_Name
) as base
group by count_productIDs
order by count_productIDs ; 


-- By comparing cost per unit (accounting for discount), we can see that one product_name is not unique - 
-- it likely covers different sizes / multi-packs of the same generic item.
-- As we already know product ID is also not unique, let's assume every combination of product name / product ID is

-- Get range of unit price for one product name, given that it has multiple produtct IDs
SELECT DISTINCT Product_Name
,Sub_Category 
, MIN(ROUND((Sales/Quantity)/(1-Discount), 2)) as min_unit_price
, MAX(ROUND((Sales/Quantity)/(1-Discount), 2)) as max_unit_price

FROM DEMODATA.dbo.superstore_order
WHERE Product_Name IN (
    SELECT  Product_Name FROM DEMODATA.dbo.superstore_order
    GROUP BY Product_Name
    HAVING COUNT(DISTINCT Product_ID)>1
)
GROUP by Product_Name
,Sub_Category 
HAVING  MIN(ROUND((Sales/Quantity)/(1-Discount), 2))<> MAX(ROUND((Sales/Quantity)/(1-Discount), 2))
order by Product_Name
; 

-- We also see variation in unit price when one product ID has multiple product names
SELECT DISTINCT Product_ID
,Sub_Category 
, MIN(ROUND((Sales/Quantity)/(1-Discount), 2)) as min_unit_price
, MAX(ROUND((Sales/Quantity)/(1-Discount), 2)) as max_unit_price

FROM DEMODATA.dbo.superstore_order
WHERE Product_ID IN (
    SELECT  Product_ID FROM DEMODATA.dbo.superstore_order
    GROUP BY Product_ID
    HAVING COUNT(DISTINCT Product_Name)>1
)
GROUP by Product_ID
,Sub_Category 
HAVING  MIN(ROUND((Sales/Quantity)/(1-Discount), 2))<> MAX(ROUND((Sales/Quantity)/(1-Discount), 2))
order by Product_ID
; 


-- check that product IDs with just one product name don't have a range of unit price, otherwise our deduction might not hold...
-- returns 0 rows
SELECT DISTINCT Product_ID
,Sub_Category 
, MIN(ROUND((Sales/Quantity)/(1-Discount), 2)) as min_unit_price
, MAX(ROUND((Sales/Quantity)/(1-Discount), 2)) as max_unit_price

FROM DEMODATA.dbo.superstore_order
WHERE Product_ID NOT IN (
    SELECT  Product_ID FROM DEMODATA.dbo.superstore_order
    GROUP BY Product_ID
    HAVING COUNT(DISTINCT Product_Name)>1
)
GROUP by Product_ID
,Sub_Category 
HAVING  MIN(ROUND((Sales/Quantity)/(1-Discount), 2))<> MAX(ROUND((Sales/Quantity)/(1-Discount), 2))
order by Product_ID
; 

--Trial composite key (Product ID + ProductName Index)
-- This is effective - with the composite key, no records have a range in unit price
-- Note - this suggests that unit price has not changed for each product over the date range of the data, this would not always be the case!!
SELECT TOP 10 Product_Name
, Product_ID
, CONCAT_WS('-', Product_ID, ROW_NUMBER() OVER (PARTITION BY PRODUCT_ID ORDER BY Product_Name) ) as product_index
, MIN(ROUND((Sales/Quantity)/(1-Discount), 2)) as min_unit_price
, MAX(ROUND((Sales/Quantity)/(1-Discount), 2)) as max_unit_price
FROM DEMODATA.dbo.superstore_order
WHERE Product_ID IN (
    SELECT  Product_ID FROM DEMODATA.dbo.superstore_order
    GROUP BY Product_ID
    HAVING COUNT(DISTINCT Product_Name)>1
)
GROUP BY Product_Name, Product_ID
HAVING  MIN(ROUND((Sales/Quantity)/(1-Discount), 2))<> MAX(ROUND((Sales/Quantity)/(1-Discount), 2))
ORDER BY Product_ID, Product_Name


SELECT DISTINCT Sub_Category , count(distinct Category) FROM DEMODATA.dbo.superstore_order GROUP BY Sub_Category HAVING count(distinct Category)>1

SELECT DISTINCT Sub_Category , count(distinct Category) FROM DEMODATA.dbo.superstore_order
GROUP BY 1, Sub_Category
HAVING count(distinct Category)>1 

SELECT count(distinct Category) FROM DEMODATA.dbo.superstore_order
GROUP BY 1
HAVING count(distinct Category)>1 