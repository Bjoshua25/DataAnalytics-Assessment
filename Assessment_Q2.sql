-- Assessment_Q2 Solutions


-- CTE to get total transactions per user
WITH user_transactions AS (
    SELECT 
        owner_id,
        COUNT(*) AS total_txn, -- counts total transactions Assumming each rows of the table represents deposit transactions
        TIMESTAMPDIFF(MONTH, MIN(created_on), MAX(created_on)) AS raw_months -- total span in months between the user's first and most recent transaction.
    FROM savings_savingsaccount
    GROUP BY owner_id
),

-- CTE that calculates Average Transactions per month
monthly_avg AS (
    SELECT 
        owner_id,
        total_txn, -- from user transactions CTE
        CASE 
            WHEN raw_months = 0 THEN 1 
            ELSE raw_months 
        END AS months, -- A refinement of raw_months column that approximate 0 to mean 1
        ROUND(total_txn / CASE WHEN raw_months = 0 THEN 1 ELSE raw_months END, 2) AS avg_txn_per_month -- Average months rounded to 2 d.p
    FROM user_transactions
),

-- CTE that groups users into "High Frequency", "Low Frequency", and "Medium Frequency" 
categorized AS (
    SELECT
        CASE 
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txn_per_month BETWEEN 3 AND 9.99 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category, -- Categorizes Users into groups
        avg_txn_per_month
    FROM monthly_avg
)

-- General query that combines all CTEs
SELECT 
	frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 2) AS avg_transactions_per_month -- Average of the average transactns per month for each groups
FROM categorized
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');