USE depiecommerce;

-- 3. CMO (Marketing & Acquisition KPIs)

-- 3.1 KPIs: Sessions & Orders by Channel/Device, CVR, RPC, RPS, New vs Repeat Customers

-- 3.1.1 Sessions & Orders by Channel/Device
SELECT
    ws.utm_source AS channel,
    ws.device_type AS device,
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM
    website_sessions ws
LEFT JOIN
    orders o ON ws.website_session_id = o.website_session_id
GROUP BY
    1, 2
ORDER BY
    total_sessions DESC, total_orders DESC;


-- 3.1.2 CVR
SELECT
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conversion_rate
FROM
    website_sessions ws
LEFT JOIN
    orders o ON ws.website_session_id = o.website_session_id;
    
-- 3.1.3 RPC
    SELECT
    SUM(o.price_usd) / COUNT(DISTINCT ws.website_session_id) AS revenue_per_click
FROM
    website_sessions ws
LEFT JOIN
    orders o ON ws.website_session_id = o.website_session_id
WHERE
    ws.utm_source IS NOT NULL; 
    
    
    
    
 -- 3.1.4 RPS   
SELECT
    SUM(o.price_usd) / COUNT(DISTINCT ws.website_session_id) AS revenue_per_session
FROM
    website_sessions ws
LEFT JOIN
    orders o ON ws.website_session_id = o.website_session_id;
    
    
-- 3.1.5 New vs Repeat Customers
SELECT
    CASE
        WHEN ws.is_repeat_session = 1 THEN 'Repeat Customer'
        ELSE 'New Customer'
    END AS customer_type,
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM
    website_sessions ws
LEFT JOIN
    orders o ON ws.website_session_id = o.website_session_id
GROUP BY
    1
ORDER BY
    total_sessions DESC;