-- Assessment_Q1 Solution

-- Disable Safe Mode
SET SQL_SAFE_UPDATES = 0;

-- Clean the "name" column in users_customuser table
UPDATE users_customuser
SET name = CONCAT(IFNULL(last_name, ''), ' ', IFNULL(first_name, ''))
WHERE name IS NULL;

-- CTE to Get the sum of all confirmed deposits per users
WITH savings_summary AS (
	SELECT owner_id, 
			SUM(confirmed_amount) AS total_savings
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0
    GROUP BY owner_id
),

-- CTE to Get Count of savings and investments plans per users
plans_summary AS (
	SELECT 
		owner_id,
		COUNT(DISTINCT CASE WHEN is_regular_savings = 1 THEN id END) AS savings_count, -- count distinct "id" when there is regular savings
        COUNT(DISTINCT CASE WHEN is_a_fund = 1 THEN id END) AS investment_count -- count distinct "id" when there is regular investments
    FROM plans_plan
    GROUP BY owner_id
)


-- General Query that combines the customer table with the savings and plan CTEs
SELECT 
	u.id AS owner_id,
	u.name,
    p.savings_count,
    p.investment_count,
    ROUND(s.total_savings / 100, 2) AS total_deposits -- Converts kobo into Naira
FROM users_customuser u
JOIN plans_summary AS p -- Joins the plans summary CTE created above
	ON p.owner_id = u.id
JOIN savings_summary s -- Joins the savings summary CTE created above
	ON u.id = s.owner_id
WHERE p.savings_count >= 1 AND p.investment_count >= 1 -- Filter by savings counts and investment counts more than 1
ORDER BY total_deposits DESC;
