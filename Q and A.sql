SELECT * FROM walmart;

SELECT COUNT(*) from walmart;

SELECT DISTINCT payment_method FROM walmart;

SELECT payment_method, COUNT(*)
FROM walmart
GROUP BY payment_method;

SELECT COUNT(DISTINCT branch) from walmart;

SELECT MAX(quantity) FROM walmart;

SELECT MIN(quantity) FROM walmart;

-- BUSINESS PROBLEMS
-- Q1. Find different paymen_method and number of transactions, number of quantity sold?

SELECT 
    payment_method,
    COUNT(*) AS total_transactions,
    SUM(quantity) AS no_of_quantity_sold
FROM 
    walmart
GROUP BY 
    payment_method;

-- Q2. Which category has the highest average in rating from all the branch?

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


-- Q3. What is the busiest day of the week for each branch based on transaction volume?

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


-- Q4. How many items were sold through each payment method?

SELECT
  payment_method,
  COUNT(*) AS transactions,
  SUM(quantity) AS units_sold
FROM walmart
GROUP BY payment_method;


-- Q5. Which city has the highest average transaction total?

SELECT 
    city, 
    ROUND(AVG(total::NUMERIC), 2) AS avg_transaction
FROM walmart
GROUP BY city
ORDER BY avg_transaction DESC
LIMIT 1;


-- Q6.  What are the average, minimum, and maximum ratings for each category in each city?

SELECT
    category,
    city,
    ROUND(AVG(rating::NUMERIC), 2) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM walmart
GROUP BY category, city;


-- Q7. Which product line had the highest total revenue?

SELECT 
    category, 
    SUM(total::NUMERIC) AS total_revenue
FROM walmart
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 1;


-- Q8. What is the total profit for each category, ranked from highest to lowest?

SELECT 
    category,
    ROUND(SUM(total*profit_margin)::NUMERIC, 2) AS total_profit,
    ROUND(SUM(total::NUMERIC), 2) AS revenue
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;


-- Q9. What is the most frequently used payment method in each branch?

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


-- Q10. How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

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


-- Q11. Which branches experienced the largest decrease in revenue current year(2023) compared to the previous year(2022)?
-- revenue_decreasing_ratio == lastyear_rev - cuurentyear_rev/lastyear_rev*100


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
