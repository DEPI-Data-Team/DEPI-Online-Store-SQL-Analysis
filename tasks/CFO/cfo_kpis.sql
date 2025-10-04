-- 2. CFO (Financial Health & Profitability)

-- 2.1 KPIs Revenue , COGS, Gross_Margin, AOV, Refund %, Incremental Test Gains

-- 2.1.1 Revenue
SELECT sum(oi.price_usd) AS Revenue
FROM order_items oi;

-- 2.1.2 COGS (Cost of Goods Sold)
SELECT sum(oi.cogs_usd) AS COGS
FROM order_items oi;

-- 2.1.3 Gross_Margin
SELECT sum(oi.price_usd) - sum(oi.cogs_usd) AS Gross_Margin
FROM order_items oi;

-- 2.1.4 AOV (Average Order Value)
SELECT 
	sum(oi.price_usd)  / count(DISTINCT o.order_id) AS AOV
FROM
	order_items oi JOIN orders o
    ON oi.order_id = o.order_id;

-- 2.1.5 Refund %
SELECT 
	ROUND(
		SUM(r.refund_amount_usd) * 100 / SUM(oi.price_usd) , 2
		) AS Refund_Percentage
FROM order_items oi  left join order_item_refunds r
ON oi.order_item_id = r.order_item_id;


-- 2.1.6 Incremental Test Gains    
WITH campaign_data AS (
    SELECT 
        ws.utm_campaign,
        COUNT(DISTINCT ws.website_session_id) AS sessions,
        COUNT(DISTINCT o.order_id) AS orders,
        COUNT(DISTINCT o.order_id)  / COUNT(DISTINCT ws.website_session_id) AS conversion_rate
    FROM website_sessions ws
    LEFT JOIN orders o 
        ON ws.website_session_id = o.website_session_id
    WHERE ws.utm_campaign IN ('brand', 'nonbrand')
    GROUP BY ws.utm_campaign
)
SELECT
    MAX(CASE WHEN utm_campaign = 'nonbrand' THEN conversion_rate END) AS nonbrand_C,
    MAX(CASE WHEN utm_campaign = 'brand' THEN conversion_rate END) AS brand_T,
    (MAX(CASE WHEN utm_campaign = 'brand' THEN conversion_rate END) -
     MAX(CASE WHEN utm_campaign = 'nonbrand' THEN conversion_rate END)) 
     / MAX(CASE WHEN utm_campaign = 'nonbrand' THEN conversion_rate END) * 100 
     AS incremental_gain_percent
FROM campaign_data;

-- ----------------------------------------------------------------------------------------------------

-- 2.2 Outputs: Revenue vs Net Revenue vs Margin chart, Refund % by Product, Test impact tables
-- 2.2.1 Revenue vs Net Revenue vs Margin chart
SELECT
    DATE_FORMAT(o.created_at, '%Y-%m-%d') AS Day,
    SUM(oi.price_usd) AS Revenue,
    (SUM(oi.price_usd) - IFNULL(SUM(r.refund_amount_usd), 0)) AS Net_Revenue,
    (SUM(oi.price_usd) - SUM(oi.cogs_usd)) AS Gross_Margin
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN order_item_refunds r
    ON oi.order_item_id = r.order_item_id
GROUP BY DATE_FORMAT(o.created_at, '%Y-%m-%d')
ORDER BY Day;

-- 2.2.1 Refund % by Product
SELECT 
    p.product_name,
    ROUND(
        (SUM(r.refund_amount_usd) / SUM(oi.price_usd)) * 100, 2
    ) AS refund_percentage
FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
LEFT JOIN order_item_refunds r 
    ON oi.order_item_id = r.order_item_id
GROUP BY p.product_name
ORDER BY refund_percentage DESC;

-- 2.2.3 Test impact tables
WITH campaign_performance AS (
    SELECT
        ws.utm_campaign,
        COUNT(DISTINCT ws.website_session_id) AS sessions,
        COUNT(DISTINCT o.order_id) AS orders,
        SUM(oi.price_usd) AS revenue,
        SUM(oi.cogs_usd) AS cogs,
        SUM(r.refund_amount_usd) AS refunds,
        SUM(oi.price_usd) - IFNULL(SUM(r.refund_amount_usd), 0) AS net_revenue
    FROM website_sessions ws
    LEFT JOIN orders o 
        ON ws.website_session_id = o.website_session_id
    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id
    LEFT JOIN order_item_refunds r
        ON oi.order_item_id = r.order_item_id
    GROUP BY ws.utm_campaign
)
SELECT
    utm_campaign,
    sessions,
    orders,
    ROUND((orders / sessions) * 100, 2) AS CR_Percentage,
    ROUND(revenue, 2) AS Revenue,
    ROUND(net_revenue, 2) AS Net_Revenue,
    ROUND((net_revenue / NULLIF(orders,0)), 2) AS AOV,
    ROUND((revenue - cogs), 2) AS Gross_Margin,
    ROUND((IFNULL(refunds,0) / NULLIF(revenue,0)) * 100, 2) AS Refund_Percentage
FROM campaign_performance
ORDER BY utm_campaign;
