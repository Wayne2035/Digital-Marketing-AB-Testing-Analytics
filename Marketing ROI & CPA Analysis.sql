-- 1. Creating a data warehouse for analyzing ROI 
create database CVSMarketingDW;

--2. Populating all CSV files into the data warehouse mannually

--3. Testing whether all dataset were successfully migrated to the warehouse CVSMarketingDW

SELECT TOP (10)*
  FROM [CVSMarketingDW].[dbo].[AB_Testing_Dataset];

SELECT TOP (10)*
  FROM [CVSMarketingDW].[dbo].[campaign_performance];

  SELECT TOP (10)*
  FROM [CVSMarketingDW].[dbo].[user_journey];

--4. Conducting SQL Analysis on ROI AND CPA

-- 4.1

SELECT
    channel,
    SUM(spend)      AS total_spend,
    SUM(revenue)    AS total_revenue,
    SUM(orders)     AS total_orders,
    SUM(new_customers) AS total_new_customers,
    SUM(revenue) / NULLIF(SUM(spend), 0)       AS ROI,
    SUM(spend) / NULLIF(SUM(orders), 0)        AS CPA,
    SUM (orders) * 1.0 / NULLIF(SUM(clicks), 0)AS purchase_rate
FROM [CVSMarketingDW].[dbo].[campaign_performance]
GROUP BY channel
ORDER BY ROI DESC;

--4.2 conduct funnel analysis based on the user_journey dataset

Select top 10 * from [CVSMarketingDW].[dbo].[user_journey];

WITH Steps AS(
SELECT
      channel,
      user_id,
      step
FROM [CVSMarketingDW].[dbo].[user_journey]
GROUP BY channel,user_id, step),

Funnel AS (
    SELECT
        channel,
        COUNT(DISTINCT CASE WHEN step = 'Landing' THEN user_id END)        AS landing_users,
        COUNT(DISTINCT CASE WHEN step = 'Product_View' THEN user_id END)   AS product_view_users,
        COUNT(DISTINCT CASE WHEN step = 'Add_To_Cart' THEN user_id END)    AS add_to_cart_users,
        COUNT(DISTINCT CASE WHEN step = 'Checkout' THEN user_id END)       AS checkout_users,
        COUNT(DISTINCT CASE WHEN step = 'Purchase' THEN user_id END)       AS purchase_users
    FROM Steps
    GROUP BY channel)


SELECT
    channel,
    landing_users,
    product_view_users,
    add_to_cart_users,
    checkout_users,
    purchase_users,
 ROUND(  (1.0 * purchase_users / landing_users),2) AS lead_to_customer_conversion
FROM Funnel

ORDER BY lead_to_customer_conversion DESC ;





--based on the findings, we can reallocate budget towards channels where purchase rate is relatively low.--

