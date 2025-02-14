SELECT *
FROM app_store_apps;

SELECT *
FROM play_store_apps;

--2a
SELECT *,
CASE WHEN price *10000 < 25000 THEN 25000
	ELSE price *10000
END AS purchase_cost
	FROM app_store_apps;

SELECT *,
CASE WHEN price::money::numeric *10000 < 25000 THEN 25000
	ELSE price::money::numeric *10000
END AS purchase_cost
	FROM play_store_apps;

--2b
SELECT *, 
	CASE WHEN rating > 0 THEN rating*1000
	ELSE 0 END AS app_earnings_per_month
FROM app_store_apps;

SELECT *, 
	CASE WHEN rating > 0 THEN rating*1000
	ELSE 0 END AS app_earnings_per_month
FROM play_store_apps;

--2c
SELECT *, 
	CASE WHEN a.name = p.name THEN 500::numeric
	ELSE 1000 END AS marketing_cost_shared_apps
FROM app_store_apps AS a
FULL JOIN play_store_apps AS p
USING(name);

--2d
SELECT *, 
	CASE WHEN rating = 0 THEN 12
	WHEN rating > 0 THEN ROUND(((((FLOOR(rating/0.25)*0.25)/0.25))*6)+12, 0)
	ELSE rating END AS projected_lifespan_months
FROM app_store_apps;

SELECT *, 
	CASE WHEN rating = 0 THEN 12
	WHEN rating > 0 THEN ROUND(((((FLOOR(rating/0.25)*0.25)/0.25))*6)+12, 0)
	ELSE rating END AS projected_lifespan_months
FROM play_store_apps;

--2e

SELECT a.name, FLOOR((SUM(DISTINCT(a.rating+p.rating))/2)/0.25)*0.25 AS avg_rating
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
USING(name)
WHERE a.rating IS NOT NULL 
	AND p.rating IS NOT NULL
GROUP BY a.name;

--divide by 0.25 floor then multiply by 0.25
--lifetime earnings
--what is the lifespan in months
--use months to find lifetime revenue
--subtract lifetime advertising and one time purchasing price
--organize those from high to low to pull top 10

WITH basic_attributes AS (SELECT name, ROUND((a.rating + p.rating)/2,2) as avg_rating,
							ROUND((a.price + p.price::money::numeric)/2, 2) AS price
							
						FROM app_store_apps AS a INNER JOIN play_store_apps AS p USING(name)),

     atts_w_longevity AS (SELECT *, FLOOR(avg_rating/0.25)* 6 + 12 AS longevity_months
							FROM basic_attributes),
							
	revenue_and_cost AS  (SELECT *,
						(FLOOR(avg_rating/0.25) * 0.25) * 1000 * longevity_months * 2 AS lifelong_revenue,
						longevity_months * 1000 AS lifelong_ad_costs,
					CASE WHEN price > 2.5 THEN price * 10000
						ELSE 25000 END AS initial_purchase_cost
					FROM atts_w_longevity)
					
SELECT DISTINCT name, lifelong_revenue - lifelong_ad_costs - initial_purchase_cost AS profit
FROM revenue_and_cost
ORDER BY profit DESC
LIMIT 10;


