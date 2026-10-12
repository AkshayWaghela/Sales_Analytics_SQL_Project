# E-Commerce Sales & Customer Analytics — Streamlit

Interactive multi-tab dashboard connected directly to your Supabase PostgreSQL database.

## Features
- Executive KPIs: revenue, profit, margin, completed orders, customers, units and average order value
- Monthly revenue and profit trend
- Order status distribution using the `orders` table
- Category revenue and profitability
- Product and customer performance
- RFM customer segmentation
- Data explorer with CSV download
- Date, category and customer-state filters

## Setup
1. Install Python 3.10+.
2. Create and activate a virtual environment.
3. Install dependencies: `pip install -r requirements.txt`
4. Copy `.streamlit/secrets.toml.example` to `.streamlit/secrets.toml`.
5. Fill in your database credentials from Supabase's **Connect** panel. Keep SSL mode set to `require`.
6. Run: `streamlit run app.py`

Windows PowerShell:
```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
streamlit run app.py
```

## Database objects expected
- `public.customers(customer_id, customer_name, state)`
- `public.products(product_id, category)`
- `public.orders(order_id, order_date, order_status)`
- `public.completed_order_details(order_id, order_date, customer_id, customer_name, product_id, product_name, category, quantity, price, cost, revenue, cost_amount, profit)`

The app uses completed orders for sales analytics and queries `orders` separately for the full status chart.

## Security
Do not upload `.streamlit/secrets.toml` or any database password/API key to GitHub. For cloud deployment, store credentials in the deployment platform's secrets manager. Prefer a read-only database user for dashboard access.

## Metric caveat
Profit is a simplified estimate (`revenue - cost`) and excludes discounts, taxes, shipping, refunds and operating expenses. RFM is an exploratory scoring approach. The dataset is synthetic.
