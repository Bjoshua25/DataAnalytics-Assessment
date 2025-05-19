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
