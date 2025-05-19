# DataAnalytics-Assessment

## 🧩 Assessment\_Q1: High-Value Customers with Multiple Products

### **Problem Statement**

**Scenario**:
The business wants to identify customers who have **both a savings and an investment plan**, signaling an opportunity for **cross-selling** and deeper engagement. The goal is to find high-value customers who are actively using multiple financial products.

---

### **Objective**

Identify customers who have:

* At least **one funded savings plan**, and
* At least **one funded investment plan**
  Then, calculate the **total amount deposited** and sort the results in descending order of deposit value.

---

### **Tables Used**

* `users_customuser` – Customer demographic info
* `savings_savingsaccount` – Deposit transaction history
* `plans_plan` – Plan types and ownership

---

### Logic Overview – Assessment\_Q1

This solution uses two Common Table Expressions (CTEs) to modularize and simplify the logic:

1. **`savings_summary` CTE**:
   Aggregates total confirmed deposits from the `savings_savingsaccount` table for each customer (`owner_id`). Only positive (`> 0`) `confirmed_amount` values are considered. The values remain in *kobo* at this stage.

2. **`plans_summary` CTE**:
   Counts the number of savings plans (`is_regular_savings = 1`) and investment plans (`is_a_fund = 1`) per customer from the `plans_plan` table. This ensures distinct counting of plan IDs under each category.

The final query joins both CTEs to the `users_customuser` table to retrieve customer details, applying filters to return only those customers with **at least one savings and one investment plan**, and computes the total deposits in **naira** by dividing the `total_savings` by 100. Results are ordered by the deposit amount in descending order.


---

### **Output Format**

| owner\_id                        | name         | savings\_count | investment\_count | total\_deposits |
| -------------------------------- | ------------ | -------------- | ----------------- | --------------- |
| 1909df3eba2548cfa3b9c270112bd262 | Ataman Chima | 3              | 9                 | 890312215.48    |
| 5572810f38b543429ffb218ef15243fc | David Obi    | 108            | 60                | 389632644.11    |

check out the solution in:
🔗 [Assessment\_Q1.sql](./Assessment_Q1.sql)

---

## 📊 Assessment\_Q2: Transaction Frequency Analysis

### Problem Statement

**Scenario:**
The finance team wants to better understand customer transaction behavior to enable user segmentation. Specifically, they need to analyze how frequently customers transact and classify them as **High**, **Medium**, or **Low Frequency** users based on their activity.

---

### Objective

To calculate the **average number of transactions per customer per month**, and classify them as follows:

* **High Frequency**: ≥ 10 transactions/month
* **Medium Frequency**: 3–9.99 transactions/month
* **Low Frequency**: ≤ 2 transactions/month

---

### Tables Used

* `users_customuser` – Customer profile data
* `savings_savingsaccount` – Each row represents a deposit transaction made by a user (assumption)

---

### Logic Overview

The query is composed of **three key CTEs** and one final aggregation step:

#### 1. `user_transactions`

This CTE calculates:

* **`total_txn`**: the total number of transactions per user.
* **`raw_months`**: the span (in months) between the user’s **first** and **latest** transaction.

```sql
TIMESTAMPDIFF(MONTH, MIN(created_on), MAX(created_on))
```

This assumes:

* Each row in `savings_savingsaccount` is one transaction.
* The time difference between earliest and latest transaction approximates the active period.

---

#### 2. `monthly_avg`

Refines the transaction span:

* Handles users who transacted **only within a single month** (where `raw_months = 0`) by setting their transaction period to **1 month** — to avoid division by zero.
* Computes the **average transactions per month**.

```sql
ROUND(total_txn / CASE WHEN raw_months = 0 THEN 1 ELSE raw_months END, 2)
```

---

#### 3. `categorized`

Classifies users into frequency bands:

* **High Frequency**: ≥ 10 txns/month
* **Medium Frequency**: 3–9.99 txns/month
* **Low Frequency**: ≤ 2 txns/month

---

#### Final SELECT

Aggregates by frequency category:

* Counts the number of users per category
* Computes the average of each group’s average transactions per month

```sql
ROUND(AVG(avg_txn_per_month), 2)
```

---

### Assumptions

* Each row in `savings_savingsaccount` is a **unique deposit transaction**.
* A user’s **activity duration** is approximated by the difference between their earliest and latest transaction dates.
* Users with transactions in only **one month** are assumed to have a **1-month tenure** for proper ratio calculation.

---

### Output

| frequency\_category | customer\_count | avg\_transactions\_per\_month |
| ------------------- | --------------- | ----------------------------- |
| High Frequency      | 139             | 43.61                          |
| Medium Frequency    | 175             | 4.75                           |
| Low Frequency       | 559             | 1.22                           |

check out the solution in:
🔗 [Assessment\_Q2.sql](./Assessment_Q2.sql)

---

## 🛑 Assessment\_Q3: Account Inactivity Alert

### Problem Statement

**Scenario:**
The operations team wants to proactively identify **active accounts** that have shown **no deposit activity in over one year**. These dormant accounts can be flagged for re-engagement campaigns or further investigation.

---

### Objective

Find customers who own either a **savings** or **investment** plan but have **not made any deposit transactions** in the **past 365 days**.

---

### Tables Used

* `plans_plan` – Stores account plans and whether they are savings or investments.
* `savings_savingsaccount` – Records deposit transactions for savings plans.

---

### Logic Overview

This solution involves **three key CTEs**, each with a specific role:

---

#### 1. `latest_txn`

Captures the **most recent transaction date** for each user, based only on **confirmed deposits**.

```sql
SELECT owner_id, MAX(created_on) AS last_transaction_date
FROM savings_savingsaccount
WHERE confirmed_amount > 0
GROUP BY owner_id
```

* Ensures only valid financial activity is considered.
* Aggregates at the `owner_id` level, not per plan.

---

#### 2. `plan_type`

Labels each plan as either **Savings**, **Investment**, or **Unknown**, depending on its flags:

```sql
CASE 
    WHEN is_regular_savings = 1 THEN 'Savings'
    WHEN is_a_fund = 1 THEN 'Investment'
    ELSE 'Unknown'
END
```

* Extracts `plan_id` and `owner_id` from `plans_plan`.
* This classification helps in reporting and filtering by account type.

---

#### 3. `inactivity_report`

Joins each **plan** to its owner's **last deposit date**, and computes how long it's been since that activity:

```sql
DATEDIFF(CURRENT_DATE, lt.last_transaction_date) AS inactivity_days
```

* Uses a `LEFT JOIN` to include plans even if the user has **never transacted** (i.e., `last_transaction_date` is `NULL`).
* Calculates the difference between **today's date** and the last transaction date.

---

### Final Output

The final `SELECT` filters for accounts with **inactivity greater than 365 days**:

```sql
WHERE inactivity_days > 365
```

This provides a clean list of **currently active accounts** that have been **dormant for over a year**.

---

### Output

| plan\_id                             | owner\_id                         | type       | last\_transaction\_date | inactivity\_days |
| ------------------------------------ | --------------------------------- | ---------- | ----------------------- | ---------------- |
| 0085b048534140789c69d66da3aed961     | 17d9345656ef4bf397ca59f2b5a32872  | Savings    | 2021-03-24 16:43:54     | 1517             |
| 6771820f18824195a73b8a367dfb6cd4     | 17d9345656ef4bf397ca59f2b5a32872  | Unknown    | 2021-03-24 16:43:54     | 1517             |

---


### Assumptions

* A row in `savings_savingsaccount` represents a **confirmed transaction**.
* If a user has no `confirmed_amount` entries, they are considered **completely inactive**.
* The flag fields (`is_regular_savings`, `is_a_fund`) are **mutually exclusive**, i.e., a plan cannot be both.

check out the solution in:
🔗 [Assessment\_Q3.sql](./Assessment_Q3.sql)

---

## 📊 Assessment\_Q4 – Customer Lifetime Value (CLV) Estimation

### Problem Statement

**Scenario:**
The Marketing team wants to estimate **Customer Lifetime Value (CLV)** using a simplified formula that considers each customer’s tenure and total number of transactions.

> **Objective:** For each customer, calculate their estimated CLV using:
>
> ```
> CLV = (total_transactions / tenure_months) * 12 * average_profit_per_transaction
> ```

Where:

* **Profit per transaction** is fixed at **0.1%** of the transaction value.
* All transaction values are initially stored in **kobo** and must be converted to **naira**.

---

### Query Logic Overview

The final query is structured using **three CTEs** (Common Table Expressions) to modularize the steps:

---

#### `user_txns` – Calculate Total Transactions and Profit per User

* Aggregates each user's deposit activity:

  * `COUNT(*)` gives the **number of confirmed deposit transactions**.
  * `SUM(confirmed_amount)` totals the **value of transactions in kobo**.
  * That value is multiplied by `0.001` (i.e., 0.1%) to estimate the profit, and then divided by `100` to convert to **naira**.
* Filters only **confirmed deposits** (`confirmed_amount > 0`).

---

#### `user_tenure` – Calculate Customer Tenure

* Retrieves user details from the `users_customuser` table.
* Uses `TIMESTAMPDIFF(MONTH, date_joined, CURRENT_DATE)` to compute **tenure in months** from signup to today.

---

#### `clv_calc` – Estimate Customer Lifetime Value

* Joins `user_tenure` with `user_txns` on `customer_id`.
* Handles missing data using `COALESCE(..., 0)` so that inactive users are included with default 0 values.
* Uses `NULLIF(..., 0)` to prevent division by zero in cases where tenure or transaction count is zero.
* Applies the CLV formula:

  ```sql
  (total_transactions / tenure_months) * 12 * (total_profit / total_transactions)
  ```
* The result is rounded to **2 decimal places** and labeled as `estimated_clv`.

---

### Final Output

| customer\_id                      | name         | tenure\_months | total\_transactions | total\_profit | estimated\_clv |
| --------------------------------- | ------------ | -------------- | ------------------- | ------------- | -------------- |
| 1909df3eba2548cfa3b9c270112bd262  | Ataman Chima | 33             | 1254                | 890312.22     | 323749.9       |
| 3097d111f15b4c44ac1bf1f4cd5a12ad  | Obi Obi      | 25             | 585                 | 216203.77     | 103777.81      |

Sorted by `estimated_clv DESC` to prioritize high-value customers.

check out the solution in:
🔗 [Assessment\_Q4.sql](./Assessment_Q4.sql)
