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

### **Logic Overview**

* A **savings plan**: `is_regular_savings = 1`
* An **investment plan**: `is_a_fund = 1`
* Only consider **funded plans** where `confirmed_amount > 0`
* Count plan types per user using `COUNT(DISTINCT CASE ...)`
* Aggregate confirmed deposits (converted from **kobo to naira**)
* Filter to include only customers meeting **both** savings and investment criteria

---

### **Output Format**

| owner\_id                        | name         | savings\_count | investment\_count | total\_deposits |
| -------------------------------- | ------------ | -------------- | ----------------- | --------------- |
| 1909df3eba2548cfa3b9c270112bd262 | Ataman Chima | 3              | 9                 | 890312215.48    |
| 5572810f38b543429ffb218ef15243fc | David Obi    | 108            | 60                | 389632644.11    |

---
check out the solution in:
🔗 [Assessment\_Q1.sql](./Assessment_Q1.sql)
