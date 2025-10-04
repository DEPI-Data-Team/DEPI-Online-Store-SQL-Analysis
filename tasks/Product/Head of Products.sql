USE depiecommerce;

-- 7. Head of Product

-- 7.1 KPIs: Orders, Revenue, Margin by Product, Clickthrough from /products, Conversion Funnels

-- 7.1.1 Orders
SELECT COUNT(DISTINCT o.order_id) AS Orders
FROM orders o;

-- 7.1.2 Revenue
SELECT COUNT(oi.price_usd) AS Revenue
FROM order_items oi;

-- 7.1.3 Margin by Product
SELECT 
p.product_name,
SUM(oi.price_usd) - SUM(oi.cogs_usd) AS Gross_Margin
FROM 
	products p join order_items oi
    ON p.product_id = oi.product_id
GROUP BY 
	p.product_name;
    
-- 7.1.4 Clickthrough from /products
WITH product_page_sessions AS (
    SELECT DISTINCT website_session_id
    FROM website_pageviews
    WHERE pageview_url = '/products'
),
next_pageviews AS (
    SELECT
        w1.website_session_id,
        MIN(w2.pageview_url) AS next_page 
    FROM website_pageviews w1
    JOIN website_pageviews w2
        ON w1.website_session_id = w2.website_session_id
       AND w2.created_at > w1.created_at
    WHERE w1.pageview_url = '/products'
    GROUP BY w1.website_session_id
)
SELECT
    COUNT(DISTINCT p.website_session_id) AS sessions_with_products,
    COUNT(DISTINCT CASE WHEN n.next_page LIKE '/the-original%' THEN n.website_session_id END) 
        AS sessions_clicked_product,
    ROUND(
        (COUNT(DISTINCT CASE WHEN n.next_page LIKE '/the-original%' THEN n.website_session_id END) 
        * 1.0 / COUNT(DISTINCT p.website_session_id)) * 100, 2
    ) AS clickthrough_rate_pct
FROM product_page_sessions p
LEFT JOIN next_pageviews n
    ON p.website_session_id = n.website_session_id;

-- 7.1.5 Conversion Funnels
SELECT
  COUNT(DISTINCT s.website_session_id) AS total_sessions,
  COUNT(DISTINCT CASE WHEN p.pageview_url LIKE '%/product%' THEN s.website_session_id END) AS product_page_sessions,
  COUNT(DISTINCT o.website_session_id) AS sessions_with_orders,
  ROUND(
    COUNT(DISTINCT o.website_session_id) / COUNT(DISTINCT s.website_session_id) * 100, 2
  ) AS session_to_order_conversion,
  ROUND(
    COUNT(DISTINCT o.website_session_id) / COUNT(DISTINCT CASE WHEN p.pageview_url LIKE '%/product%' THEN s.website_session_id END) * 100, 2
  ) AS product_to_order_conversion
FROM website_sessions s
LEFT JOIN website_pageviews p
  ON s.website_session_id = p.website_session_id
LEFT JOIN orders o
  ON s.website_session_id = o.website_session_id;
  
  -- ------------------------------------------------------------------
  
  -- 7.2 Outputs: Revenue trend lines, Conversion funnels per product, Cross-sell charts
  
  -- 7.2.1 Revenue trend lines
SELECT
    DATE(o.created_at) AS order_date,
    s.device_type,
    SUM(o.price_usd) AS revenue,
    IFNULL(SUM(r.refund_amount_usd), 0) AS total_refunds,
    (SUM(o.price_usd) - IFNULL(SUM(r.refund_amount_usd), 0)) AS net_revenue,
    SUM(o.cogs_usd) AS total_cost,
    (SUM(o.price_usd - o.cogs_usd)) AS gross_profit,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
LEFT JOIN order_item_refunds r
    ON o.order_id = r.order_id
JOIN website_sessions s
    ON o.website_session_id = s.website_session_id
GROUP BY DATE(o.created_at), s.device_type
ORDER BY order_date, s.device_type;


  -- 7.2.1 Conversion funnels per product

WITH product_views AS (
    SELECT 
        p.product_id,
        COUNT(DISTINCT wp.website_session_id) AS sessions_viewed
    FROM website_pageviews wp
    JOIN products p 
        ON wp.pageview_url LIKE CONCAT('%/product/', p.product_id, '%')
    GROUP BY p.product_id
),

product_orders AS (
    SELECT 
        oi.product_id,
        COUNT(DISTINCT o.website_session_id) AS sessions_with_orders,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.price_usd) AS revenue_usd
    FROM order_items oi
    JOIN orders o 
        ON oi.order_id = o.order_id
    GROUP BY oi.product_id
)

SELECT 
    p.product_id,
    p.product_name,
    po.sessions_with_orders,
    po.total_orders,
    po.revenue_usd
FROM products p
LEFT JOIN product_views pv ON p.product_id = pv.product_id
LEFT JOIN product_orders po ON p.product_id = po.product_id
ORDER BY p.product_id;
  

  -- 7.2.1 Cross-sell charts
SELECT
    pm.product_name AS product_main,
    pc.product_name AS product_cross,
    COUNT(DISTINCT a.order_id) AS times_bought_together
FROM order_items a
JOIN order_items b
    ON a.order_id = b.order_id
    AND a.product_id <> b.product_id
JOIN products pm
    ON a.product_id = pm.product_id
JOIN products pc
    ON b.product_id = pc.product_id
GROUP BY pm.product_name, pc.product_name
ORDER BY pm.product_name, times_bought_together DESC;


-- -----------------------------------