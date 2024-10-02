-- Sales Data Overview
SELECT *
FROM sales_data;

-- Top Revenue-Generating Product Line
SELECT PRODUCTLINE AS Product, SUM(SALES) AS Revenue
FROM sales_data
GROUP BY PRODUCTLINE
ORDER BY Revenue DESC;  -- Classic Cars generates the most revenue for the company.

-- Highest Revenue Year
SELECT YEAR_ID AS Year, SUM(SALES) AS Revenue
FROM sales_data
GROUP BY YEAR_ID
ORDER BY Revenue DESC;  -- 2004 was the company's best year for sales.

-- Revenue by Deal Size
SELECT DEALSIZE AS DealSize, SUM(SALES) AS Revenue, COUNT(ORDERNUMBER) AS OrderCount
FROM sales_data
GROUP BY DEALSIZE
ORDER BY Revenue DESC;  -- Medium deals generate the most revenue.

-- Monthly Sales Performance
SELECT MONTH_ID AS Month, SUM(SALES) AS Revenue
FROM sales_data
GROUP BY MONTH_ID
ORDER BY Revenue DESC;  -- November was the top-performing month for sales.

-- Best-Selling Month of 2005
SELECT MONTH_ID AS Month, SUM(SALES) AS Revenue, COUNT(ORDERNUMBER) AS OrdersReceived
FROM sales_data
WHERE YEAR_ID = "2005"
GROUP BY MONTH_ID
ORDER BY Revenue DESC;  -- May had the highest sales in 2005.

-- Best-Selling Month of 2004
SELECT MONTH_ID AS Month, SUM(SALES) AS Revenue, COUNT(ORDERNUMBER) AS OrdersReceived
FROM sales_data
WHERE YEAR_ID = "2004"
GROUP BY MONTH_ID
ORDER BY Revenue DESC;  -- November was the top-selling month in 2004.

-- Best-Selling Month of 2003
SELECT MONTH_ID AS Month, SUM(SALES) AS Revenue, COUNT(ORDERNUMBER) AS OrdersReceived
FROM sales_data
WHERE YEAR_ID = "2003"
GROUP BY MONTH_ID
ORDER BY Revenue DESC;  -- November was the best month for sales in 2003.

-- Product Popularity
SELECT PRODUCTLINE AS ProductLine, SUM(ORDERNUMBER) AS Frequency
FROM sales_data
GROUP BY PRODUCTLINE
ORDER BY Frequency DESC;  -- Classic Cars are the most frequently purchased.


-- Top Countries by Total Sales
SELECT COUNTRY, SUM(SALES) AS Total_Sales, COUNT(ORDERNUMBER) AS Frequency
FROM sales_data
GROUP BY COUNTRY
ORDER BY Total_Sales DESC;  -- The United States contributes the highest sales.

-- RFM Customer Segmentation
SHOW COLUMNS FROM sales_data;

WITH RFM AS (
    SELECT CUSTOMERNAME,
           DATEDIFF("2005-05-31", MAX(STR_TO_DATE(ORDERDATE, '%m/%d/%Y %H:%i'))) AS Recency,  -- Recency: Days since last order
           COUNT(ORDERNUMBER) AS Frequency,   -- Frequency: Number of orders per customer
           SUM(SALES) AS MonetaryValue        -- Monetary Value: Total sales per customer
    FROM sales_data
    GROUP BY CUSTOMERNAME
)

, RFM_Rank AS (
    SELECT CUSTOMERNAME, Recency, Frequency, MonetaryValue,
           NTILE(4) OVER (ORDER BY Recency ASC) AS RFM_Recency,					-- Recency divided into 4 quartiles in ASC order as more recent = More loyal
           NTILE(4) OVER (ORDER BY Frequency DESC) AS RFM_Frequency,			-- Frequency divided into 4 quartiles in DESC order as higher frequency = More orders
           NTILE(4) OVER (ORDER BY MonetaryValue DESC) AS RFM_Monetary			-- Monetary divided into 4 quartiles in DESC order as higher monetary = More income
    FROM RFM
)

SELECT CUSTOMERNAME, RFM_Recency, RFM_Frequency, RFM_Monetary, 
       (RFM_Recency + RFM_Frequency + RFM_Monetary) AS RFM_Score
FROM RFM_Rank
ORDER BY RFM_Score ASC;  -- Lower scores indicate more valuable customers.
