/* =========================================================
Project : MarketPulse 360
Advanced ECommerce Competitor, Pricing & Sentiment Analytics

========================================================= */

---------------------------------------------------------
-- CREATE DATABASE
---------------------------------------------------------

CREATE DATABASE MarketPulse360;
GO

USE MarketPulse360;
GO


---------------------------------------------------------
-- CUSTOMERS TABLE
---------------------------------------------------------

CREATE TABLE customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(255),
    Gender VARCHAR(10),
    City VARCHAR(255),
    State VARCHAR(255),
    Email VARCHAR(255),
    RegistrationDate DATE,
    LoyaltyTier VARCHAR(50)
);


---------------------------------------------------------
-- PRODUCT TABLE
---------------------------------------------------------

CREATE TABLE product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(255),
    Category VARCHAR(255),
    Brand VARCHAR(50),
    BasePrice DECIMAL(10,2),
    LaunchDate DATE
);


---------------------------------------------------------
-- SALES TABLE
---------------------------------------------------------

CREATE TABLE sales (
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    CustomerID INT,
    Date DATE,
    UnitsSold INT,
    Returns INT,
    Discount DECIMAL(3,2),
    OurPrice DECIMAL(10,2),
    CompetitorPrice DECIMAL(10,2),
    Revenue DECIMAL(10,2),
    AcquisitionChannel VARCHAR(255),

    FOREIGN KEY (ProductID) REFERENCES product(ProductID),
    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID)
);


---------------------------------------------------------
-- REVIEWS TABLE
---------------------------------------------------------

CREATE TABLE reviews (
    ProductID INT,
    CustomerID INT,
    ReviewDate DATE,
    Rating INT,
    ReviewText VARCHAR(MAX),
    SentimentScore DECIMAL(5,4),

    FOREIGN KEY (ProductID) REFERENCES product(ProductID),
    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID)
);


=========================================================
ANALYSIS
=========================================================


---------------------------------------------------------
1 TOTAL REVENUE, UNITS SOLD, RETURN RATE
---------------------------------------------------------

SELECT
SUM(Revenue) AS Total_Revenue,
SUM(UnitsSold) AS Total_Units_Sold,
(SUM(Returns)*100.0)/SUM(UnitsSold) AS Return_Rate
FROM sales;



---------------------------------------------------------
2 MONTHLY REVENUE TREND
---------------------------------------------------------

SELECT
DATENAME(MONTH, Date) AS Month,
SUM(Revenue) AS Revenue
FROM sales
GROUP BY DATENAME(MONTH, Date);



---------------------------------------------------------
3 MONTHLY UNITS SOLD
---------------------------------------------------------

SELECT
DATENAME(MONTH, Date) AS Month,
SUM(UnitsSold) AS UnitsSold
FROM sales
GROUP BY DATENAME(MONTH, Date);



---------------------------------------------------------
4 TOP 10 REVENUE DAYS
---------------------------------------------------------

SELECT TOP 10
Date,
SUM(Revenue) AS Revenue
FROM sales
GROUP BY Date
ORDER BY Revenue DESC;



---------------------------------------------------------
5 AVERAGE ORDER VALUE
---------------------------------------------------------
SELECT 
AVG(Revenue * 1.0 / NULLIF(UnitsSold,0)) AS Avg_Order_Value
FROM sales;

---------------------------------------------------------
6 REVENUE BY ACQUISITION CHANNEL
---------------------------------------------------------
SELECT
AcquisitionChannel,
SUM(Revenue) AS Revenue
FROM sales
GROUP BY AcquisitionChannel;



=========================================================
CUSTOMER ANALYSIS
=========================================================


---------------------------------------------------------
7 UNIQUE CUSTOMERS
---------------------------------------------------------

SELECT
COUNT(DISTINCT CustomerID) AS Customers
FROM sales;



---------------------------------------------------------
8 CUSTOMER COUNT BY STATE
---------------------------------------------------------

SELECT
State,
COUNT(CustomerID) AS Customers
FROM customers
GROUP BY State
ORDER BY COUNT(CustomerID);



---------------------------------------------------------
9 TOP 10 CITIES BY CUSTOMERS
---------------------------------------------------------

SELECT TOP 10
City,
COUNT(CustomerID) AS Customers
FROM customers
GROUP BY City
ORDER BY COUNT(CustomerID) DESC;



---------------------------------------------------------
10 NEW CUSTOMERS PER MONTH
---------------------------------------------------------

SELECT
DATENAME(MONTH, RegistrationDate) AS Month,
COUNT(CustomerID) AS Customers
FROM customers
GROUP BY DATENAME(MONTH, RegistrationDate);



---------------------------------------------------------
11 REVENUE BY GENDER
---------------------------------------------------------

SELECT
c.Gender,
SUM(s.Revenue) AS Revenue,
AVG(s.Revenue) AS Avg_Spend
FROM customers c
JOIN sales s
ON c.CustomerID = s.CustomerID
GROUP BY c.Gender;



---------------------------------------------------------
12 REVENUE BY LOYALTY TIER
---------------------------------------------------------

SELECT
c.LoyaltyTier,
SUM(s.Revenue) AS Revenue
FROM customers c
JOIN sales s
ON c.CustomerID = s.CustomerID
GROUP BY c.LoyaltyTier;



---------------------------------------------------------
13 TOP 10 SPENDERS
---------------------------------------------------------

SELECT TOP 10
c.Name,
SUM(s.Revenue) AS Revenue
FROM customers c
JOIN sales s
ON c.CustomerID = s.CustomerID
GROUP BY c.Name
ORDER BY Revenue DESC;



=========================================================
PRODUCT PERFORMANCE
=========================================================


---------------------------------------------------------
14 TOP 10 PRODUCTS BY UNITS SOLD
---------------------------------------------------------

SELECT TOP 10
p.ProductName,
SUM(s.UnitsSold) AS UnitsSold
FROM product p
JOIN sales s
ON p.ProductID = s.ProductID
GROUP BY p.ProductName
ORDER BY UnitsSold DESC;



---------------------------------------------------------
15 TOP 10 PRODUCTS BY REVENUE
---------------------------------------------------------

SELECT TOP 10
p.ProductName,
SUM(s.Revenue) AS Revenue
FROM product p
JOIN sales s
ON p.ProductID = s.ProductID
GROUP BY p.ProductName
ORDER BY Revenue DESC;



---------------------------------------------------------
16 REVENUE BY CATEGORY
---------------------------------------------------------

SELECT
p.Category,
SUM(s.Revenue) AS Revenue
FROM product p
JOIN sales s
ON p.ProductID = s.ProductID
GROUP BY p.Category;



---------------------------------------------------------
17 REVENUE BY BRAND
---------------------------------------------------------

SELECT
p.Brand,
SUM(s.Revenue) AS Revenue
FROM product p
JOIN sales s
ON p.ProductID = s.ProductID
GROUP BY p.Brand;



---------------------------------------------------------
18 PRODUCTS WITH HIGHEST RETURN RATE
---------------------------------------------------------

SELECT TOP 5
p.ProductName,
(SUM(s.Returns)*100.0)/SUM(s.UnitsSold) AS ReturnRate
FROM product p
JOIN sales s
ON p.ProductID = s.ProductID
GROUP BY p.ProductName
ORDER BY ReturnRate DESC;



=========================================================
REVIEW & SENTIMENT ANALYSIS
=========================================================


---------------------------------------------------------
19 RATING DISTRIBUTION
---------------------------------------------------------

SELECT
Rating,
COUNT(*) AS RatingCount
FROM reviews
GROUP BY Rating
ORDER BY Rating;



---------------------------------------------------------
20 TOP RATED PRODUCTS
---------------------------------------------------------
SELECT TOP 10
p.ProductName,
AVG(r.Rating) AS AvgRating,
COUNT(*) AS Reviews
FROM reviews r
JOIN product p
ON r.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY AvgRating DESC;




---------------------------------------------------------
21 AVERAGE RATING BY CATEGORY
---------------------------------------------------------

SELECT
p.Category,
ROUND(AVG(r.Rating),2) AS AvgRating
FROM reviews r
JOIN product p
ON r.ProductID = p.ProductID
GROUP BY p.Category;



---------------------------------------------------------
22 SENTIMENT SCORE BY BRAND
---------------------------------------------------------

SELECT
p.Brand,
ROUND(AVG(r.SentimentScore),2) AS AvgSentiment
FROM reviews r
JOIN product p
ON r.ProductID = p.ProductID
GROUP BY p.Brand;



=========================================================
ADVANCED INSIGHTS
=========================================================


---------------------------------------------------------
23 TOP REVENUE PRODUCTS WITH RATING
---------------------------------------------------------

SELECT TOP 10
p.ProductName,
SUM(s.Revenue) AS Revenue,
AVG(r.Rating) AS AvgRating,
(SUM(s.Returns)*100.0)/SUM(s.UnitsSold) AS ReturnRate
FROM product p
JOIN sales s
ON p.ProductID = s.ProductID
JOIN reviews r
ON s.ProductID = r.ProductID
GROUP BY p.ProductName
ORDER BY Revenue DESC;



---------------------------------------------------------
24 BEST CATEGORY PURCHASED BY GOLD CUSTOMERS
---------------------------------------------------------

SELECT TOP 3
p.Category,
SUM(s.UnitsSold) AS Units
FROM product p
JOIN sales s
ON p.ProductID = s.ProductID
JOIN customers c
ON s.CustomerID = c.CustomerID
WHERE c.LoyaltyTier = 'Gold'
GROUP BY p.Category
ORDER BY Units DESC;



---------------------------------------------------------
25 AVG DAYS FROM REGISTRATION TO FIRST PURCHASE
---------------------------------------------------------

WITH first_purchase AS
(
SELECT
CustomerID,
MIN(Date) AS FirstPurchaseDate
FROM sales
GROUP BY CustomerID
)

SELECT
AVG(DATEDIFF(DAY,c.RegistrationDate,fp.FirstPurchaseDate))
AS AvgDaysToPurchase
FROM first_purchase fp
JOIN customers c
ON fp.CustomerID = c.CustomerID;