# Data Dictionary & Metric Definitions

## Tables

### `customers`
| Field | Meaning |
|---|---|
| `customer_id` | Unique customer identifier (primary key) |
| `customer_name` | Synthetic customer display name |
| `email` | Unique synthetic email |
| `city`, `state` | Customer location fields |
| `signup_date` | Customer registration date |

### `products`
| Field | Meaning |
|---|---|
| `product_id` | Unique product identifier (primary key) |
| `product_name` | Product name |
| `category` | Product category |
| `price` | Listed selling price per unit |
| `cost` | Unit cost used for gross-profit approximation |

### `orders`
| Field | Meaning |
|---|---|
| `order_id` | Unique order identifier (primary key) |
| `customer_id` | Customer who placed the order (foreign key) |
| `order_date` | Date the order was placed |
| `order_status` | Completed, Pending, Cancelled or Returned |

### `order_items`
| Field | Meaning |
|---|---|
| `order_item_id` | Unique order-line identifier (primary key) |
| `order_id` | Parent order (foreign key) |
| `product_id` | Purchased product (foreign key) |
| `quantity` | Number of units in the order line |

## Analytical views

### `completed_order_details`
One row per item line on a completed order. Includes order date, customer, product, category, quantity, price, cost, revenue, cost amount and profit.

### `customer_order_summary`
One row per customer with completed-order activity: order count, units, revenue, cost, profit, average order value, first order date and last order date.

### `product_performance_summary`
One row per product with order count, units sold, unique customers, revenue, cost, profit, profit margin percentage and average selling price.

## Metric definitions

| Metric | Definition | Important note |
|---|---|---|
| Revenue | `quantity * price` | Excludes discounts, tax, shipping and refunds |
| Cost amount | `quantity * cost` | Uses the synthetic unit cost |
| Profit | `revenue - cost_amount` | A simplified product-level profit estimate, not audited accounting profit |
| Profit margin % | `profit / revenue * 100` | Guard against zero revenue |
| Average order value (AOV) | Completed-order revenue / distinct completed orders | Calculate from order-level totals for rigorous order-level AOV; line-level sums must be deduplicated by order |
| Units sold | Sum of item quantities | In the core analytical view, completed orders only |
| Customer recency | Snapshot date minus most recent completed order date | Depends on the selected snapshot date |
| RFM | Recency, frequency and monetary-value scores | Segment labels depend on scoring rules and thresholds |

## Grain and join cautions

- `orders` is at order grain.
- `order_items` is at order-line grain.
- `completed_order_details` is at order-line grain, not order grain.
- When counting orders after joining to line items, use `COUNT(DISTINCT order_id)`.
- When computing AOV, first aggregate revenue to order grain, then average those order totals. Do not average line-level revenue.
