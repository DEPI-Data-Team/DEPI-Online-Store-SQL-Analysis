use depiecommerce;

-- 8.	Investor Relations
-- 8.1. KPIs: Growth over 3 years, Efficiency gains, Channel diversification, Product portfolio impact
-- 8.1.1.  Growth over 3 years: Measures the overall increase in key performance indicators (such as revenue or orders) across three consecutive years to evaluate long-term business expansion.
SELECT 
    YEAR(created_at) AS year,
    SUM(price_usd) AS total_revenue
FROM orders
GROUP BY YEAR(created_at)
ORDER BY YEAR(created_at);

-- 8.1.2.  Efficiency gains: Reflects improvements in operational performance, such as higher revenue per order or session, lower costs per transaction, or reduced refund rates — showing how the company became more productive over time.
SELECT
    YEAR(o.created_at) AS year,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    ROUND(SUM(o.price_usd) / COUNT(DISTINCT o.order_id), 2) AS AOV,   -- Average Order Value
    ROUND(SUM(o.price_usd) / COUNT(DISTINCT ws.website_session_id), 2) AS RPS  -- Revenue per Session
FROM orders o
LEFT JOIN website_sessions ws
    ON ws.website_session_id = o.website_session_id
GROUP BY YEAR(o.created_at)
ORDER BY YEAR(o.created_at);

-- 8.1.3. Channel diversification: ndicates how sales or revenue are distributed across different marketing or sales channels (e.g., website, app, social media, affiliates) to assess dependency and market reach.
SELECT 
    COALESCE(ws.utm_source, 'Direct') AS channel,
    ROUND(SUM(o.price_usd), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY COALESCE(ws.utm_source, 'Direct')
ORDER BY total_revenue DESC;

-- 8.1.4. Product portfolio impact: Measures how various product categories contribute to overall revenue or profit, highlighting which products drive growth and which ones have limited impact.
SELECT
    p.product_name,
    ROUND(SUM(oi.price_usd), 2) AS revenue,
    COUNT(DISTINCT oi.order_id) AS orders_count
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;
-- ----------------------------------------------------------------------------------------------------------
-- 8.2. Outputs for Dashboard: Executive Dashboard, Growth Timeline, Incremental Gains waterfall, Channel Mix pie chart
-- all previous data to  be extracted in power Bi from the following query

SELECT
    o.order_id,
    o.created_at AS order_time,
    YEAR(o.created_at) AS order_year,
    ws.website_session_id,
    COALESCE(ws.utm_source, 'Direct') AS channel,     -- 🔹 Replace NULL with 'Direct'
    p.product_name,
    o.price_usd AS revenue,
    r.refund_amount_usd AS refund,
    ROUND(COALESCE(o.price_usd, 0) - COALESCE(r.refund_amount_usd, 0), 2) AS net_revenue
FROM orders o
LEFT JOIN website_sessions ws
    ON ws.website_session_id = o.website_session_id
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN order_item_refunds r
    ON oi.order_item_id = r.order_item_id
ORDER BY o.created_at;
-- ---------------------------------------------------------------------------------------------------