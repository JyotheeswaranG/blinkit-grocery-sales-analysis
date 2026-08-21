-- ============================================================
-- BLINKIT GROCERY SALES ANALYSIS
-- Complete MySQL Analysis Queries
-- Table assumed: blinkit_sales
-- ============================================================

CREATE DATABASE IF NOT EXISTS blinkit_analysis;
USE blinkit_analysis;

-- ------------------------------------------------------------
-- 0. EXPECTED TABLE STRUCTURE
-- ------------------------------------------------------------
-- item_identifier
-- item_weight
-- item_fat_content
-- item_visibility
-- item_type
-- item_mrp
-- outlet_identifier
-- outlet_establishment_year
-- outlet_size
-- outlet_location_type
-- outlet_type
-- sales
-- rating

-- If your imported table uses spaces/capital letters, either
-- rename columns or replace the column names below accordingly.

-- ------------------------------------------------------------
-- 1. DATA VALIDATION
-- ------------------------------------------------------------
SELECT COUNT(*) AS total_records
FROM blinkit_sales;

SELECT COUNT(*) AS distinct_items
FROM blinkit_sales;

SELECT COUNT(DISTINCT outlet_identifier) AS total_outlets
FROM blinkit_sales;

SELECT
    SUM(CASE WHEN item_identifier IS NULL OR item_identifier = '' THEN 1 ELSE 0 END) AS missing_item_id,
    SUM(CASE WHEN item_type IS NULL OR item_type = '' THEN 1 ELSE 0 END) AS missing_item_type,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS missing_sales,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS missing_rating
FROM blinkit_sales;

SELECT
    item_identifier,
    COUNT(*) AS duplicate_count
FROM blinkit_sales
GROUP BY item_identifier
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- ------------------------------------------------------------
-- 2. OVERALL KPIs
-- ------------------------------------------------------------
SELECT
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS average_sales,
    ROUND(AVG(rating), 2) AS average_rating,
    COUNT(*) AS total_records,
    COUNT(DISTINCT item_identifier) AS distinct_items,
    COUNT(DISTINCT outlet_identifier) AS total_outlets
FROM blinkit_sales;

-- Total sales / average sales
SELECT ROUND(SUM(sales), 2) AS total_sales
FROM blinkit_sales;

SELECT ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales;

-- ------------------------------------------------------------
-- 3. SALES BY ITEM TYPE
-- ------------------------------------------------------------
SELECT
    item_type,
    COUNT(*) AS item_count,
    ROUND(SUM(sales), 2) AS revenue,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY item_type
ORDER BY revenue DESC;

-- Top 10 item categories
SELECT
    item_type,
    ROUND(SUM(sales), 2) AS revenue
FROM blinkit_sales
GROUP BY item_type
ORDER BY revenue DESC
LIMIT 10;

-- Bottom 10 item categories
SELECT
    item_type,
    ROUND(SUM(sales), 2) AS revenue
FROM blinkit_sales
GROUP BY item_type
ORDER BY revenue ASC
LIMIT 10;

-- ------------------------------------------------------------
-- 4. FAT CONTENT ANALYSIS
-- ------------------------------------------------------------
SELECT
    item_fat_content,
    COUNT(*) AS item_count,
    ROUND(SUM(sales), 2) AS revenue,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY item_fat_content
ORDER BY revenue DESC;

-- ------------------------------------------------------------
-- 5. OUTLET ANALYSIS
-- ------------------------------------------------------------
SELECT
    outlet_type,
    COUNT(DISTINCT outlet_identifier) AS outlet_count,
    ROUND(SUM(sales), 2) AS revenue,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY outlet_type
ORDER BY revenue DESC;

SELECT
    outlet_size,
    COUNT(DISTINCT outlet_identifier) AS outlet_count,
    ROUND(SUM(sales), 2) AS revenue,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY outlet_size
ORDER BY revenue DESC;

SELECT
    outlet_location_type,
    COUNT(DISTINCT outlet_identifier) AS outlet_count,
    ROUND(SUM(sales), 2) AS revenue,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY outlet_location_type
ORDER BY revenue DESC;

-- ------------------------------------------------------------
-- 6. OUTLET ESTABLISHMENT YEAR
-- ------------------------------------------------------------
SELECT
    outlet_establishment_year,
    COUNT(DISTINCT outlet_identifier) AS outlet_count,
    ROUND(SUM(sales), 2) AS revenue,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY outlet_establishment_year
ORDER BY outlet_establishment_year;

-- ------------------------------------------------------------
-- 7. ITEM VISIBILITY
-- ------------------------------------------------------------
SELECT
    item_type,
    ROUND(AVG(item_visibility), 4) AS avg_visibility,
    ROUND(SUM(sales), 2) AS revenue
FROM blinkit_sales
GROUP BY item_type
ORDER BY revenue DESC;

SELECT
    CASE
        WHEN item_visibility = 0 THEN 'Zero Visibility'
        WHEN item_visibility < 0.05 THEN 'Low Visibility'
        WHEN item_visibility < 0.15 THEN 'Medium Visibility'
        ELSE 'High Visibility'
    END AS visibility_band,
    COUNT(*) AS records,
    ROUND(SUM(sales), 2) AS revenue,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY visibility_band
ORDER BY revenue DESC;

-- ------------------------------------------------------------
-- 8. PRICE / MRP ANALYSIS
-- ------------------------------------------------------------
SELECT
    item_type,
    ROUND(AVG(item_mrp), 2) AS avg_mrp,
    ROUND(MIN(item_mrp), 2) AS min_mrp,
    ROUND(MAX(item_mrp), 2) AS max_mrp,
    ROUND(SUM(sales), 2) AS revenue
FROM blinkit_sales
GROUP BY item_type
ORDER BY revenue DESC;

SELECT
    CASE
        WHEN item_mrp < 50 THEN 'Below 50'
        WHEN item_mrp < 100 THEN '50-99'
        WHEN item_mrp < 150 THEN '100-149'
        WHEN item_mrp < 200 THEN '150-199'
        ELSE '200+'
    END AS mrp_band,
    COUNT(*) AS records,
    ROUND(SUM(sales), 2) AS revenue
FROM blinkit_sales
GROUP BY mrp_band
ORDER BY revenue DESC;

-- ------------------------------------------------------------
-- 9. RATING ANALYSIS
-- ------------------------------------------------------------
SELECT
    ROUND(AVG(rating), 2) AS overall_average_rating,
    ROUND(MIN(rating), 2) AS minimum_rating,
    ROUND(MAX(rating), 2) AS maximum_rating
FROM blinkit_sales;

SELECT
    CASE
        WHEN rating < 3 THEN 'Below 3'
        WHEN rating < 4 THEN '3 to <4'
        WHEN rating < 5 THEN '4 to <5'
        ELSE '5'
    END AS rating_band,
    COUNT(*) AS records,
    ROUND(SUM(sales), 2) AS revenue,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY rating_band
ORDER BY rating_band;

SELECT
    item_type,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(SUM(sales), 2) AS revenue
FROM blinkit_sales
GROUP BY item_type
ORDER BY avg_rating DESC;

-- ------------------------------------------------------------
-- 10. TOP PRODUCTS / ITEMS
-- ------------------------------------------------------------
SELECT
    item_identifier,
    item_type,
    item_fat_content,
    ROUND(item_mrp, 2) AS mrp,
    ROUND(sales, 2) AS sales,
    ROUND(rating, 2) AS rating
FROM blinkit_sales
ORDER BY sales DESC
LIMIT 20;

-- ------------------------------------------------------------
-- 11. OUTLET-LEVEL PERFORMANCE
-- ------------------------------------------------------------
SELECT
    outlet_identifier,
    outlet_type,
    outlet_size,
    outlet_location_type,
    ROUND(SUM(sales), 2) AS revenue,
    ROUND(AVG(sales), 2) AS average_sales,
    COUNT(*) AS records
FROM blinkit_sales
GROUP BY outlet_identifier, outlet_type, outlet_size, outlet_location_type
ORDER BY revenue DESC;

-- Top 10 outlets
SELECT
    outlet_identifier,
    ROUND(SUM(sales), 2) AS revenue
FROM blinkit_sales
GROUP BY outlet_identifier
ORDER BY revenue DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 12. OUTLET + ITEM TYPE PERFORMANCE
-- ------------------------------------------------------------
SELECT
    outlet_type,
    item_type,
    ROUND(SUM(sales), 2) AS revenue,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY outlet_type, item_type
ORDER BY outlet_type, revenue DESC;

-- ------------------------------------------------------------
-- 13. LOCATION + ITEM TYPE
-- ------------------------------------------------------------
SELECT
    outlet_location_type,
    item_type,
    ROUND(SUM(sales), 2) AS revenue
FROM blinkit_sales
GROUP BY outlet_location_type, item_type
ORDER BY outlet_location_type, revenue DESC;

-- ------------------------------------------------------------
-- 14. WINDOW FUNCTIONS
-- ------------------------------------------------------------
WITH category_sales AS (
    SELECT
        item_type,
        SUM(sales) AS revenue
    FROM blinkit_sales
    GROUP BY item_type
)
SELECT
    item_type,
    ROUND(revenue, 2) AS revenue,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
    ROUND(100 * revenue / SUM(revenue) OVER (), 2) AS revenue_share_pct
FROM category_sales
ORDER BY revenue_rank;

-- Rank outlets
WITH outlet_sales AS (
    SELECT
        outlet_identifier,
        SUM(sales) AS revenue
    FROM blinkit_sales
    GROUP BY outlet_identifier
)
SELECT
    outlet_identifier,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (ORDER BY revenue DESC) AS outlet_rank
FROM outlet_sales
ORDER BY outlet_rank;

-- ------------------------------------------------------------
-- 15. BUSINESS QUESTIONS
-- ------------------------------------------------------------

-- Q1: Which item category generates the most revenue?
SELECT item_type, ROUND(SUM(sales),2) AS revenue
FROM blinkit_sales
GROUP BY item_type
ORDER BY revenue DESC
LIMIT 1;

-- Q2: Which outlet type generates the most revenue?
SELECT outlet_type, ROUND(SUM(sales),2) AS revenue
FROM blinkit_sales
GROUP BY outlet_type
ORDER BY revenue DESC
LIMIT 1;

-- Q3: Which location tier generates the most revenue?
SELECT outlet_location_type, ROUND(SUM(sales),2) AS revenue
FROM blinkit_sales
GROUP BY outlet_location_type
ORDER BY revenue DESC
LIMIT 1;

-- Q4: Which fat-content segment performs better?
SELECT item_fat_content, ROUND(SUM(sales),2) AS revenue
FROM blinkit_sales
GROUP BY item_fat_content
ORDER BY revenue DESC;

-- Q5: Which outlet is the best performer?
SELECT outlet_identifier, ROUND(SUM(sales),2) AS revenue
FROM blinkit_sales
GROUP BY outlet_identifier
ORDER BY revenue DESC
LIMIT 1;

-- Q6: Which item has the highest sales value?
SELECT item_identifier, item_type, ROUND(sales,2) AS sales
FROM blinkit_sales
ORDER BY sales DESC
LIMIT 1;

-- Q7: Which categories have above-average sales?
WITH category_sales AS (
    SELECT item_type, AVG(sales) AS avg_category_sales
    FROM blinkit_sales
    GROUP BY item_type
)
SELECT *
FROM category_sales
WHERE avg_category_sales > (SELECT AVG(sales) FROM blinkit_sales)
ORDER BY avg_category_sales DESC;

-- Q8: Which outlets have below-average sales?
WITH outlet_sales AS (
    SELECT outlet_identifier, AVG(sales) AS avg_outlet_sales
    FROM blinkit_sales
    GROUP BY outlet_identifier
)
SELECT *
FROM outlet_sales
WHERE avg_outlet_sales < (SELECT AVG(sales) FROM blinkit_sales)
ORDER BY avg_outlet_sales;

-- Q9: High-rated categories with strong revenue
SELECT
    item_type,
    ROUND(AVG(rating),2) AS avg_rating,
    ROUND(SUM(sales),2) AS revenue
FROM blinkit_sales
GROUP BY item_type
HAVING AVG(rating) >= 4
ORDER BY revenue DESC;

-- Q10: Low-visibility but high-revenue categories
SELECT
    item_type,
    ROUND(AVG(item_visibility),4) AS avg_visibility,
    ROUND(SUM(sales),2) AS revenue
FROM blinkit_sales
GROUP BY item_type
HAVING AVG(item_visibility) < 0.10
ORDER BY revenue DESC;

-- ------------------------------------------------------------
-- 16. FINAL MANAGEMENT SUMMARY
-- ------------------------------------------------------------
SELECT
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(AVG(sales),2) AS avg_sales,
    ROUND(AVG(rating),2) AS avg_rating,
    COUNT(*) AS total_records,
    COUNT(DISTINCT item_identifier) AS distinct_items,
    COUNT(DISTINCT outlet_identifier) AS outlets
FROM blinkit_sales;