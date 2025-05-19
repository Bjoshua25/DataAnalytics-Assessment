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

---
check out the solution in:
🔗 [Assessment\_Q1.sql](./Assessment_Q1.sql)
