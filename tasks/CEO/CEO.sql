use depiecommerce;

-- 1. CEO (Growth & Strategy)

-- 1.1. KPIs: Sessions, Orders, Revenue, Net Revenue, Conversion Rate, RPS, AOV

-- 1.1.1. sessions
select count( distinct website_session_id) as Sessions_Count
from website_sessions ;

-- 1.1.2. Orders
select count(distinct order_id) as Orders_Count
from orders;

-- 1.1.3. Revenue (Gross Revenue): The total amount of money generated from sales before deducting any returns, refunds, or costs.
select sum( orders.price_usd) as Revenue
from orders;

-- 1.1.4. Net Revenue: The actual revenue retained by the company after subtracting refunds or returns from the gross revenue.
select sum(oi.price_usd)  - sum(r.refund_amount_usd) as Net_Revenue
from order_items as oi
left join order_item_refunds as r
on oi.order_item_id = r.order_item_id;

-- 1.1.5. Conversion Rate (CVR): The percentage of website sessions that result in at least one order.
select 
  (select count(distinct order_id) from orders) * 100.0
  / (select count(distinct website_session_id) from website_sessions) 
  as CVR;

-- 1.1.6. Revenue per Session (RPS): Average revenue generated per website session.
select
    (select sum( orders.price_usd) from orders) 
    / (select count(*) FROM website_sessions)
as RPS;
   
-- 1.1.7. Average Order Value (AOV): Average revenue per order
select
    (select sum( orders.price_usd) from orders)
    / (select count(*) FROM orders)
as AOV;
-- -------------------------------------------------------------------------------------------------------------------------
-- 1.2. Outputs for Dashboard: Trend charts (Sessions vs Orders), KPI cards (CVR, RPS, AOV), Waterfall (Revenue breakdown)

-- 1.2.1.  Trend charts (Sessions vs Orders), KPI cards (CVR, RPS, AOV):
-- all previous data to  be extracted in power Bi from the following query

select ws.created_at as Order_Time, 
		ws.website_session_id as Sessions_count, 
        o.order_id as Orders_count
from website_sessions as ws 
left join orders as o
on o.website_session_id = ws.website_session_id
order by ws.created_at;

-- 1.2.2. Waterfall (Revenue breakdown):
select
    o.created_at AS Order_Time,
    o.order_id,
    sum(o.price_usd) as revenue,
    COALESCE(sum(r.refund_amount_usd),0) as refunds,
    (sum(o.price_usd) - COALESCE(sum(r.refund_amount_usd),0)) as Net_Revenue
from orders o
left join order_items oi 
    on o.order_id = oi.order_id
left join order_item_refunds r 
    on oi.order_item_id = r.order_item_id
group by o.order_id, o.created_at
order by o.created_at;
-- -----------------------------------------------------------------------------------------------------------------------