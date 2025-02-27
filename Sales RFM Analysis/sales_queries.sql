USE shopping_sales;

SELECT *
FROM shopping_trends;

ALTER TABLE shopping_trends 
CHANGE `Customer ID` customer_id int,
CHANGE `Age` age int,
CHANGE `Gender` gender text,
CHANGE `Item Purchased` item_purchased text,
CHANGE `Category` category text,
CHANGE `Purchase Amount (USD)` purchase_amount_usd int,
CHANGE `Location` location text,
CHANGE `Size` size text,
CHANGE `Color` color text,
CHANGE `Season` season text,
CHANGE `Review Rating` review_rating double,
CHANGE `Subscription Status` subscription_status text,
CHANGE `Shipping Type` shipping_type text,
CHANGE `Discount Applied` discount_applied text,
CHANGE `Promo Code Used` promo_code_used text,
CHANGE `Previous Purchases` previous_purchase int,
CHANGE `Payment Method` payment_method text,
CHANGE `Frequency of Purchases` frequency_of_purchase text; -- Changed table for ease of analysis

SELECT
    promo_code_used, 
    COUNT(*) AS usage_count, 
    AVG(purchase_amount_usd) AS average_sale, 
    SUM(purchase_amount_usd) AS total_sales
FROM shopping_trends
WHERE promo_code_used IS NOT NULL
GROUP BY promo_code_used
ORDER BY total_sales DESC; -- Promo code effectiveness

SELECT 
    location, 
    season, 
    SUM(purchase_amount_usd) AS total_sales, 
    COUNT(*) AS purchase_count
FROM shopping_trends
GROUP BY location, season
ORDER BY total_sales DESC; -- Sales by location and season

SELECT 
    location, 
    COUNT(DISTINCT customer_id) AS high_value_customers, 
    SUM(purchase_amount_usd) AS total_revenue
FROM shopping_trends
WHERE purchase_amount_usd > (
    SELECT AVG(purchase_amount_usd) FROM shopping_trends
)
GROUP BY location
ORDER BY high_value_customers DESC; -- High value cutomers by location

SELECT 
    CASE 
        WHEN age < 18 THEN 'Under 18'
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+'
    END AS age_group,
    COUNT(*) AS customer_count,
    SUM(purchase_amount_usd) AS total_revenue,
    AVG(purchase_amount_usd) AS average_order_value
FROM shopping_trends
GROUP BY age_group
ORDER BY total_revenue DESC; -- Purchases by age group (Cohort Analysis)

SELECT 
    customer_id,
    frequency_of_purchase,
    previous_purchase AS frequency,
    SUM(purchase_amount_usd) AS average_purchase_usd,
    CASE
        WHEN frequency_of_purchase = 'Weekly' THEN 1
        WHEN frequency_of_purchase = 'Fortnightly' OR frequency_of_purchase = 'Bi-Weekly' THEN 2
        WHEN frequency_of_purchase = 'Monthly' THEN 3
        WHEN frequency_of_purchase = 'Quarterly' OR frequency_of_purchase = 'Every 3 Months' THEN 4
        WHEN frequency_of_purchase = 'Annually' THEN 5
        ELSE NULL
    END AS recency_score,  -- Estimating recency score based on frequency of purchase
    CASE
		WHEN previous_purchase < 10 THEN 1
        WHEN previous_purchase >= 10 and previous_purchase < 20 THEN 2
        WHEN previous_purchase >= 20 and previous_purchase < 30 THEN 3
        WHEN previous_purchase >= 30 and previous_purchase < 40 THEN 4
        WHEN previous_purchase >= 40 THEN 5
        ELSE NULL
	END AS frequency_score, -- Estimating frequency score based on frequency of purchase
	CASE
		WHEN SUM(purchase_amount_usd) < 36 THEN 1
        WHEN SUM(purchase_amount_usd) >= 36 and SUM(purchase_amount_usd) < 52 THEN 2
        WHEN SUM(purchase_amount_usd) >= 52 and SUM(purchase_amount_usd) < 68 THEN 3
        WHEN SUM(purchase_amount_usd) >= 68 and SUM(purchase_amount_usd) < 84 THEN 4
        WHEN SUM(purchase_amount_usd) >= 84 THEN 5
        ELSE NULL
	END AS monetary_score -- Estimating monetary score based on average purchase amount of customers
FROM shopping_trends
GROUP BY customer_id, frequency_of_purchase, frequency; -- RFM analysis setup
