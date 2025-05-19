-- Assessment_Q3 Solution

-- CTE to obtain last transaction date for each user
WITH latest_txn AS (
    SELECT 
        owner_id,
        MAX(created_on) AS last_transaction_date
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0 -- Filter for only the users who made deposits
    GROUP BY owner_id
),

-- CTE to Tag plan type as either Savings or Investment 
plan_type AS (
    SELECT 
        id AS plan_id,
        owner_id,
        CASE 
            WHEN is_regular_savings = 1 THEN 'Savings'
            WHEN is_a_fund = 1 THEN 'Investment'
            ELSE 'Unknown'
        END AS type -- column to Group users according to his plan type
    FROM plans_plan
),

-- CTE that stores inactivity days for each account users
inactivity_report AS (
    SELECT 
        p.plan_id,
        p.owner_id,
        p.type,
        lt.last_transaction_date,
        DATEDIFF(CURRENT_DATE, lt.last_transaction_date) AS inactivity_days -- Cal. the difference betwwen "today's date" and the last transactn date
    FROM plan_type AS p
    LEFT JOIN latest_txn AS lt 
		ON p.owner_id = lt.owner_id -- the latest_txn CTE
)

-- Actual query: Obtain Active accounts with no transaction in over 1 year
SELECT *
FROM inactivity_report
WHERE inactivity_days > 365
ORDER BY inactivity_days DESC;
