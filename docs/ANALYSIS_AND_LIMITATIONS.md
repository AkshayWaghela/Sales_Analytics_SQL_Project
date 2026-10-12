# Analysis Approach, Findings & Limitations

## Scope

The completed-order analytical dataset spans **2024-01-01 to 2026-06-30**. It contains 2,643 completed-order item rows, representing 1,431 distinct completed orders, 476 customers with completed activity and 4,322 units.

## Summary snapshot from the synthetic sample data

| Metric | Result |
|---|---:|
| Completed-order line revenue | 17,499,251.94 |
| Estimated product profit | 6,312,997.82 |
| Profit margin | 36.08% |
| Distinct completed orders | 1,431 |
| Customers with completed activity | 476 |
| Units across completed order lines | 4,322 |
| Revenue per distinct completed order (AOV) | 12,228.69 |

These values describe the generated sample dataset only. They are not industry benchmarks or real-company results.

## Descriptive highlights

- Highest-revenue category in this sample: **Electronics** (revenue 6,264,511.03).
- Highest-revenue product in this sample: **USB Hub** (revenue 1,807,996.75).
- Highest-revenue customer in this sample: **Aditya Desai** (revenue 159,968.04).

Treat these as outputs to validate and explain, not as universal business recommendations. A portfolio discussion should focus on how the queries identify the results and what additional context management would need before acting.

## Business questions and next investigative steps

1. **Revenue and profit trend:** identify months with material changes; validate whether the change comes from order volume, units per order, product mix or pricing.
2. **Category performance:** compare revenue, profit and margin together; high revenue alone does not imply high profitability.
3. **Product performance:** compare units, unique customers and margin; investigate high-volume products with weak margins.
4. **Customer value:** compare completed-order frequency and monetary value; check whether revenue is concentrated among a small group of customers.
5. **RFM:** use the scoring rules to create interpretable groups, then define a business action hypothesis for each group.
6. **Data quality:** validate foreign-key consistency, allowed statuses, nonnegative prices/costs, positive quantities, duplicate patterns and future-dated orders.

## Limitations

- Data is synthetic and suitable for technical demonstration only.
- Revenue uses listed price × quantity; no discounts, taxes, shipping, refunds or promotions are modeled.
- Profit is a simplified gross-profit proxy using listed unit cost, not full accounting profit.
- `completed_order_details` excludes Pending, Cancelled and Returned orders. It cannot be used by itself to report the full order-status funnel.
- Cohort and RFM results depend on snapshot dates, scoring rules and data coverage.
- Correlation or descriptive patterns do not prove causation.
