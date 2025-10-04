USE depiecommerce;

-- 5. Website Performance Manager

-- 5.1 KPIs: Top Pages, Entry Pages, Bounce Rates, Funnel Conversion %, A/B Test results

-- 5.1.1 Top Pages
SELECT
    pageview_url,
    COUNT(website_pageview_id) AS total_pageviews
FROM
    website_pageviews
GROUP BY
    1
ORDER BY
    total_pageviews DESC
LIMIT 10; 

-- 5.1.2 Entry Pages
WITH first_page_view AS (
    -- 1. Find the first pageview ID for each session
    SELECT
        website_session_id,
        MIN(website_pageview_id) AS first_pageview_id
    FROM
        website_pageviews
    GROUP BY
        website_session_id
)
SELECT
    wp.pageview_url AS entry_page,
    COUNT(fpv.website_session_id) AS total_entries
FROM
    first_page_view fpv
JOIN
    website_pageviews wp
    ON fpv.first_pageview_id = wp.website_pageview_id
GROUP BY
    1
ORDER BY
    total_entries DESC;
    
-- 5.1.3 Bounce Rates
WITH session_page_counts AS (
    -- 1. Count the number of pageviews for each session
    SELECT
        website_session_id,
        COUNT(website_pageview_id) AS pageview_count
    FROM
        website_pageviews
    GROUP BY
        website_session_id
)
SELECT
    COUNT(CASE WHEN spc.pageview_count = 1 THEN spc.website_session_id ELSE NULL END) AS bounced_sessions,
    COUNT(spc.website_session_id) AS total_sessions,
    COUNT(CASE WHEN spc.pageview_count = 1 THEN spc.website_session_id ELSE NULL END) / COUNT(spc.website_session_id) AS overall_bounce_rate
FROM
    session_page_counts spc;
    
-- 5.1.4 Funnel Conversion %
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
  
-- 5.1.5 A/B Test results
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