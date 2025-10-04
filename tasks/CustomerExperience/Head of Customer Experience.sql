use depiecommerce;

-- 6. Head of Customer Experience

-- 6.1. KPIs: Repeat vs New Customers (sessions, orders, revenue), Loyalty metrics (days between visits)

-- 6.1.1. Repeat vs New Customers (sessions, orders, revenue)
select distinct ws.is_repeat_session , 
	count(distinct ws.website_session_id) as Sessions_count, 
	count(distinct o.order_id ) as Orders_count,
    sum( o.price_usd) as Revenue,
     COALESCE(SUM(r.refund_amount_usd), 0) AS refunds
from website_sessions as ws 
left join orders as o
	on o.website_session_id = ws.website_session_id
left join order_items as oi
	on o.order_id = oi.order_id
left join order_item_refunds as r 
    ON oi.order_item_id = r.order_item_id
group by ws.is_repeat_session;

-- 6.1.2. Loyalty metrics (days between visits)
SELECT
    user_id,
    website_session_id,
    created_at as session_date,
    LAG(created_at) OVER (PARTITION BY user_id ORDER BY created_at) AS previous_visit,
    DATEDIFF(created_at, LAG(created_at) OVER (PARTITION BY user_id ORDER BY created_at)) AS days_between_visits
FROM website_sessions
ORDER BY user_id, created_at;
 -- --------------------------------------------------------------------------------------------- 
-- 6.2. Outputs for Dashboard: Cohort charts, KPI cards (Repeat CVR), Refund rate comparison
-- all previous data to  be extracted in power Bi from the following query
SELECT 
    ws.website_session_id,
    ws.user_id,
    ws.created_at AS session_time,
    ws.is_repeat_session,               -- 0 = New, 1 = Repeat
    o.order_id,
    o.price_usd AS revenue,
    r.refund_amount_usd AS refund_amount,
    CASE WHEN o.order_id IS NOT NULL THEN 1 ELSE 0 END AS has_order,
    CASE WHEN r.refund_amount_usd IS NOT NULL THEN 1 ELSE 0 END AS has_refund
FROM website_sessions ws
LEFT JOIN orders o 
    ON ws.website_session_id = o.website_session_id
LEFT JOIN order_items oi 
    ON o.order_id = oi.order_id
LEFT JOIN order_item_refunds r 
    ON oi.order_item_id = r.order_item_id
ORDER BY ws.user_id, ws.created_at;