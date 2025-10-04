use depiecommerce;

-- 4.  COO (Operations & Scalability)
-- 4.1 KPIs: Seasonality (monthly/weekly), Daily/Hourly traffic, Refund Rates by Product
-- 4.1.1 Seasonality — Monthly (Sessions, Orders, Revenue)
SELECT
  DATE_FORMAT(ws.created_at, '%Y-%m-01') AS month_start,
  COUNT(DISTINCT ws.website_session_id)   AS sessions,
  COUNT(DISTINCT o.order_id)              AS orders,
  ROUND(SUM(COALESCE(o.price_usd,0)), 2)  AS revenue
FROM website_sessions ws
LEFT JOIN orders o
  ON o.website_session_id = ws.website_session_id
GROUP BY DATE_FORMAT(ws.created_at, '%Y-%m-01')
ORDER BY month_start;

-- 4.1.2. Seasonality — Weekly (ISO YearWeek):
SELECT
  YEARWEEK(ws.created_at, 3)              AS iso_yearweek,
  COUNT(DISTINCT ws.website_session_id)   AS sessions,
  COUNT(DISTINCT o.order_id)              AS orders,
  ROUND(SUM(COALESCE(o.price_usd,0)), 2)  AS revenue
FROM website_sessions ws
LEFT JOIN orders o
  ON o.website_session_id = ws.website_session_id
GROUP BY YEARWEEK(ws.created_at, 3)
ORDER BY iso_yearweek;

-- 4.1.3. Daily/Hourly Traffic (Heatmap base)
SELECT
  DAYOFWEEK(ws.created_at) AS dow_1_sun,   -- 1=Sunday ... 7=Saturday
  HOUR(ws.created_at)      AS hour_of_day, -- 0..23
  COUNT(DISTINCT ws.website_session_id) AS sessions
FROM website_sessions ws
GROUP BY DAYOFWEEK(ws.created_at), HOUR(ws.created_at)
ORDER BY dow_1_sun, hour_of_day;

-- 4.1.4. Refund Rates by Product
WITH refunds_per_item AS (
  SELECT
    oi.order_item_id,
    COALESCE(SUM(r.refund_amount_usd), 0) AS refund_usd
  FROM order_items oi
  LEFT JOIN order_item_refunds r
    ON r.order_item_id = oi.order_item_id
  GROUP BY oi.order_item_id
),
refunds_per_order AS (
  SELECT
    oi.product_id,
    oi.order_id,
    MAX(CASE WHEN rpi.refund_usd > 0 THEN 1 ELSE 0 END) AS has_refund
  FROM order_items oi
  LEFT JOIN refunds_per_item rpi
    ON rpi.order_item_id = oi.order_item_id
  GROUP BY oi.product_id, oi.order_id
)
SELECT
  p.product_name,
  COUNT(DISTINCT rpo.order_id)                                         AS orders_count,
  COUNT(DISTINCT CASE WHEN rpo.has_refund=1 THEN rpo.order_id END)     AS orders_with_refund,
  ROUND(
    100.0 * COUNT(DISTINCT CASE WHEN rpo.has_refund=1 THEN rpo.order_id END)
    / NULLIF(COUNT(DISTINCT rpo.order_id), 0), 2
  ) AS refund_rate_pct
FROM refunds_per_order rpo
LEFT JOIN products p
  ON p.product_id = rpo.product_id
GROUP BY p.product_name
ORDER BY refund_rate_pct DESC, orders_count DESC;
-- -----------------------------------------------------------------------

-- 8.2. Outputs for Dashboard: Seasonality line charts, Heatmaps (sessions by hour/day), Refund rate bars
-- all previous data to  be extracted in power Bi from the following query
-- 8.2.1. Seasonality line charts: 
SELECT
  -- Session grain
  ws.website_session_id,
  ws.created_at                                 AS session_time,
  DATE_FORMAT(ws.created_at, '%Y-%m-01')        AS session_month,       -- للـ monthly line
  YEARWEEK(ws.created_at, 3)                    AS session_iso_yearweek, -- للـ weekly line
  COALESCE(ws.utm_source, 'Direct')             AS channel,

  -- Order grain 
  o.order_id,
  o.created_at                                  AS order_time,
  YEAR(o.created_at)                            AS order_year,
  o.price_usd                                   AS order_revenue,
  CASE WHEN o.order_id IS NOT NULL THEN 1 ELSE 0 END AS has_order
FROM website_sessions ws
LEFT JOIN orders o
  ON o.website_session_id = ws.website_session_id
ORDER BY ws.created_at, o.created_at;

-- 8.2.2. Heatmaps (sessions by hour/day):
SELECT
  ws.website_session_id,
  ws.user_id,
  ws.created_at                          AS session_time,
  DAYOFWEEK(ws.created_at)               AS session_dow_1_sun,  -- 1=Sunday..7=Saturday
  HOUR(ws.created_at)                    AS session_hour,        -- 0..23
  COALESCE(ws.utm_source, 'Direct')      AS channel
FROM website_sessions ws
ORDER BY session_dow_1_sun, session_hour, ws.created_at;

-- 8.2.3. Refund rate bars:
SELECT
  o.order_id,
  oi.order_item_id,
  o.created_at                       AS order_time,
  p.product_name,
  COALESCE(oi.price_usd, 0)          AS item_revenue,
  COALESCE(r.refund_amount_usd, 0)    AS item_refund_amount,
  CASE WHEN r.refund_amount_usd IS NOT NULL AND r.refund_amount_usd > 0 
       THEN 1 ELSE 0 END             AS has_refund
FROM orders o
LEFT JOIN order_items oi
  ON oi.order_id = o.order_id
LEFT JOIN products p
  ON p.product_id = oi.product_id
LEFT JOIN order_item_refunds r
  ON r.order_item_id = oi.order_item_id
ORDER BY o.created_at, oi.order_item_id;