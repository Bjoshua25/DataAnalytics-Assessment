-- Assessment_Q4 Solution

-- CTE total profits made from each users
WITH user_txns AS (
    SELECT 
        owner_id,
        COUNT(*) AS total_transactions,
        ROUND(SUM(confirmed_amount) * 0.001 / 100, 2) AS total_profit -- 0.1% of the total sum of confirmed_amount (kobo) then coverted to Naira
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0
    GROUP BY owner_id
),

-- CTE that saves information about user's tenure from date joined
user_tenure AS (
    SELECT 
        id AS customer_id,
        name,
        TIMESTAMPDIFF(MONTH, date_joined, CURRENT_DATE) AS tenure_months
    FROM users_customuser
),

-- CTE that calculates the Customer Life Value
clv_calc AS (
    SELECT 
        t.customer_id,
        t.name,
        t.tenure_months,
        COALESCE(tx.total_transactions, 0) AS total_transactions,
        COALESCE(tx.total_profit, 0) AS total_profit,
        ROUND((COALESCE(tx.total_transactions, 0) / NULLIF(t.tenure_months, 0)) * 12 * 
              (COALESCE(tx.total_profit, 0) / NULLIF(tx.total_transactions, 0)), 2) AS estimated_clv -- Calculates CLV
    FROM user_tenure AS t
    LEFT JOIN user_txns AS tx 
		ON t.customer_id = tx.owner_id
)

-- Actual Query: Ouputs the total profits and estimated_CLV for each users
SELECT *
FROM clv_calc
ORDER BY estimated_clv DESC;
