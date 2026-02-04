CREATE TABLE cosmeticpopups (
	event_id varchar(255) PRIMARY KEY,
	brand varchar(255),
	region varchar(255),
	city varchar(255),
	location_type varchar(255),
	event_type varchar(255),
	start_date DATE,
	end_date DATE, 
	lease_length_days int,
	sku varchar(255),
	product_name varchar(255),
	price_usd DOUBLE,
	avg_daily_footfall int,
	units_sold int,
	sell_through_pct DOUBLE,
);

SELECT * FROM cosmeticpopups

-- DATA CLEANING --
-- Check Null Values
SELECT *
FROM cosmeticpopups
WHERE event_id IS NULL
    OR brand IS NULL
    OR region IS NULL
    OR city IS NULL
	OR location_type IS NULL
	OR event_type IS NULL
	OR start_date IS NULL
	OR end_date IS NULL
	OR lease_length_days IS NULL
	OR sku IS NULL
	OR product_name IS NULL
	OR price_usd IS NULL
	OR avg_daily_footfall IS NULL
	OR units_sold IS NULL
	OR sell_through_pct IS NULL;

-- Fill Unknown City
UPDATE cosmeticpopups
SET city = 'Unknown'
WHERE city IS NULL OR city = '';

SELECT *
FROM cosmeticpopups
WHERE city IS NULL;

-- Handling NULL end_date
-- Null values in the end_date column were assumed to represent ongoing events, so we add new category:

ALTER TABLE cosmeticpopups
ADD COLUMN event_status VARCHAR(100);

UPDATE cosmeticpopups
SET event_status =
CASE
	WHEN end_date IS NULL THEN 'Ongoing'
	ELSE 'Completed'
	END;

SELECT *
FROM cosmeticpopups
WHERE end_date IS NULL;

-- Business Analysis
-- Q1: Which brand has the best performance?
SELECT brand, 
	COUNT(*) AS total_events, 
	SUM(units_sold) AS total_units,
	AVG(sell_through_pct) AS avg_sell_through
FROM cosmeticpopups
GROUP BY brand
ORDER BY total_units DESC;

-- Insights:
-- By the total units sold, Huda Beauty have the first place, followed by YSL Beauty just with the gap of 2 units. So, Huda Beauty and YSL show suggesting competitive performance rather than dominance. Huda Beauty’s social media strength and trend appeal may drive volume because it is also on trend at that time with the influencer-driven target market, whereas YSL’s luxury positioning could contribute to consistent performance across premium segments. Huda Beauty also have more events held, which could made more people engaged to this brand.

-- Business Implication:
-- Huda Beauty could leverage its social media presence and trend appeal to further boost sales, while YSL Beauty might focus on enhancing its luxury experience to attract high-end consumers. Total units alone may not fully represent brand strength. It is also important to consider sales per event or sell-through efficiency to evaluate true performance.

-- Q1: Which city has the most units sold?
SELECT
    city,
    COUNT(*) AS events,
    SUM(units_sold) AS total_units
FROM cosmeticpopups
WHERE city <> 'Unknown'
GROUP BY city
ORDER BY total_units DESC;

-- Insight:
-- The most sold units is in Hong Kong, this might caused by the most events held are in Hong Kong as well.

-- Business Implication:
-- Cities with high retail density and strong beauty consumption habits can generate strong aggregate sales. However, brands should also explore emerging cities with strong per-event conversion potential.

-- Q3: Which Region has the most customers visit and units sold?
SELECT
    region,
    ROUND(AVG(units_sold), 1) AS avg_units,
    ROUND(AVG(avg_daily_footfall), 0) AS avg_footfall
FROM cosmeticpopups
GROUP BY region
ORDER BY avg_footfall DESC;

-- Insight:
-- Asia-Pacific is the region with the highest average daily footfall, indicating strong consumer interest and high visibility for popup events. This aligns with the region’s urban centers and strong beauty consumption culture.

-- Business Implication:
-- Asia-Pacific is a strong region for brand exposure and awareness-building through popups. We can use Asia-Pacific markets for high-visibility launches and trend-driven campaigns. Also, focus on conversion strategies to turn footfall into sales.

-- Q4: Is there any impact by the duration held?
SELECT
    lease_length_days,
    COUNT(*) AS total_events,
    AVG(units_sold) AS avg_units_sold,
    AVG(sell_through_pct) AS avg_sell_through
FROM cosmeticpopups
WHERE lease_length_days IS NOT NULL
GROUP BY lease_length_days
HAVING COUNT(*) >= 5 
ORDER BY avg_units_sold DESC;

-- Insight:
-- Popup events with a duration of approximately 30 days/a month appear to be the most efficient and achieving higher average units sold and stable sell-through rates. However, the observed performance might be also because the other factors such as location and footfall.

-- Business Implication:
-- A 3–4 week popup duration may offer the best balance between cost and performance. Still, duration decisions should consider location type and brand objectives.

-- Q5: When footfall is high, will the sales always increases?
SELECT
    ROUND(avg_daily_footfall, -2) AS footfall_bucket,
    AVG(units_sold) AS avg_units_sold
FROM cosmeticpopups
GROUP BY footfall_bucket
ORDER BY footfall_bucket DESC;

-- Insight:
-- The relationship between average daily footfall and units sold is not strictly linear. While higher footfall increases exposure, it does not consistently translate into higher sales. This suggests that conversion efficiency and in-store engagement play a more significant role than visitor volume alone in driving popup performance.

-- Business Implication:
-- Prioritize audience fit and experience quality over raw visitor numbers. Brands need to focus on conversion-based metrics.