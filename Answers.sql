-- ANSWERS.
-- 1.

SELECT 
    payment_method,
    COUNT(*) AS total_transactions,
    SUM(quantity) AS no_of_quantity_sold
FROM 
    walmart
GROUP BY 
    payment_method;


-- 2.

SELECT *
FROM (
    SELECT
        branch,
        category,
        AVG(rating) AS average,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
    FROM walmart
    GROUP BY branch, category
) AS ranked_data
WHERE rank = 1;


-- 3.

SELECT * 
FROM (
    SELECT
        branch,
        TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'DAY') AS formatted_date,
        COUNT(*) AS transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'DAY')
    ORDER BY branch, transactions DESC
) AS ranked_data
WHERE rank = 1;


-- 4.

SELECT
  payment_method,
  COUNT(*) AS transactions,
  SUM(quantity) AS units_sold
FROM walmart
GROUP BY payment_method;


-- 5.

SELECT 
    city, 
    ROUND(AVG(total::NUMERIC), 2) AS avg_transaction
FROM walmart
GROUP BY city
ORDER BY avg_transaction DESC
LIMIT 1;


-- 6.

SELECT
    category,
    city,
    ROUND(AVG(rating::NUMERIC), 2) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM walmart
GROUP BY category, city;


-- 7.

SELECT 
    category, 
    SUM(total::NUMERIC) AS total_revenue
FROM walmart
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 1;


-- 8.

SELECT 
    category,
    ROUND(SUM(total*profit_margin)::NUMERIC, 2) AS total_profit,
    ROUND(SUM(total::NUMERIC), 2) AS revenue
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;


-- 9.

SELECT 
    branch,
    payment_method,
    count
FROM (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS count,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, payment_method
) ranked_methods
WHERE rank = 1;


-- 10.

SELECT
    branch,
    CASE
        WHEN EXTRACT(HOUR FROM (time::time)) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS transaction_count
FROM walmart
GROUP BY branch, day_time
ORDER BY branch, transaction_count;


-- 11.

WITH prev_year_rev AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 
    GROUP BY branch
),
curr_year_rev AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023 
    GROUP BY branch
)
SELECT 
    pyr.branch,
    ROUND(pyr.revenue::numeric, 2) AS previous_year_revenue,
    ROUND(cyr.revenue::numeric, 2) AS current_year_revenue,
    ROUND((pyr.revenue - cyr.revenue)::numeric/pyr.revenue::numeric * 100, 2) as rev_decreasing_ratio
FROM prev_year_rev pyr
JOIN curr_year_rev cyr ON pyr.branch = cyr.branch
WHERE pyr.revenue > cyr.revenue
ORDER BY rev_decreasing_ratio DESC
LIMIT 5;


