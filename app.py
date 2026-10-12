import os
import pandas as pd
import plotly.express as px
import streamlit as st
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

st.set_page_config(page_title="E-Commerce Analytics", page_icon="📊", layout="wide")
st.title("📊 E-Commerce Sales & Customer Analytics")
st.caption("PostgreSQL / Supabase · SQL analytics · Customer and product performance")

def setting(key, default=None):
    try:
        if key in st.secrets:
            return st.secrets[key]
    except Exception:
        pass
    return os.getenv(key, default)

@st.cache_resource
def engine():
    db_url = setting("DATABASE_URL")
    if db_url:
        return create_engine(db_url, pool_pre_ping=True)
    host, password = setting("SUPABASE_DB_HOST"), setting("SUPABASE_DB_PASSWORD")
    if not host or not password:
        raise ValueError("Configure database credentials in .streamlit/secrets.toml. See README.md.")
    url = URL.create(
        "postgresql+psycopg2",
        username=setting("SUPABASE_DB_USER", "postgres"),
        password=password,
        host=host,
        port=int(setting("SUPABASE_DB_PORT", "5432")),
        database=setting("SUPABASE_DB_NAME", "postgres"),
        query={"sslmode": setting("SUPABASE_DB_SSLMODE", "require")},
    )
    return create_engine(url, pool_pre_ping=True, pool_recycle=300)

def query(sql, params=None):
    with engine().connect() as conn:
        return pd.read_sql_query(text(sql), conn, params=params or {})

@st.cache_data(ttl=300)
def bounds():
    d = query("SELECT MIN(order_date)::date AS lo, MAX(order_date)::date AS hi FROM public.completed_order_details")
    return pd.to_datetime(d.loc[0, "lo"]).date(), pd.to_datetime(d.loc[0, "hi"]).date()

try:
    min_date, max_date = bounds()
except Exception as exc:
    st.error("Could not connect to Supabase or find public.completed_order_details.")
    st.markdown("Check your database credentials, SSL settings, tables and SQL view. See the README for setup.")
    with st.expander("Technical error"):
        st.code(str(exc))
    st.stop()

with st.sidebar:
    st.header("Filters")
    st.caption("Sales pages use completed orders. The status chart includes all order statuses.")
    dates = st.date_input("Order date range", value=(min_date, max_date), min_value=min_date, max_value=max_date)
    if isinstance(dates, (tuple, list)) and len(dates) == 2:
        start, end = dates
    else:
        start = end = dates
    cats = query("SELECT DISTINCT category FROM public.products ORDER BY category")["category"].dropna().tolist()
    selected_cats = st.multiselect("Category", cats)
    states = query("SELECT DISTINCT state FROM public.customers WHERE state IS NOT NULL ORDER BY state")["state"].dropna().tolist()
    selected_states = st.multiselect("Customer state", states)
    if st.button("Refresh data"):
        st.cache_data.clear()
        st.rerun()

try:
    sql = """
    SELECT d.order_id, d.order_date, d.customer_id, d.customer_name,
           c.state, d.product_id, d.product_name, d.category,
           d.quantity, d.price, d.cost, d.revenue, d.cost_amount, d.profit
    FROM public.completed_order_details d
    JOIN public.customers c ON c.customer_id = d.customer_id
    WHERE d.order_date >= :start_date
      AND d.order_date < (:end_date + INTERVAL '1 day')
      AND (:all_categories OR d.category = ANY(:categories))
      AND (:all_states OR c.state = ANY(:states))
    """
    df = query(sql, {
        "start_date": start, "end_date": end,
        "all_categories": not selected_cats, "categories": selected_cats or [],
        "all_states": not selected_states, "states": selected_states or [],
    })
    status = query("""
        SELECT order_status, COUNT(*) AS orders
        FROM public.orders
        WHERE order_date >= :start_date AND order_date < (:end_date + INTERVAL '1 day')
        GROUP BY order_status ORDER BY orders DESC
    """, {"start_date": start, "end_date": end})
except Exception as exc:
    st.error("A data query failed. Confirm the project schema and view names.")
    with st.expander("Technical error"):
        st.code(str(exc))
    st.stop()

if df.empty:
    st.warning("No rows match the selected filters.")
    st.stop()

df["order_date"] = pd.to_datetime(df["order_date"])
for col in ["revenue", "cost_amount", "profit", "quantity"]:
    df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0)
revenue, profit, cost = df.revenue.sum(), df.profit.sum(), df.cost_amount.sum()
orders, customers, units = df.order_id.nunique(), df.customer_id.nunique(), df.quantity.sum()
order_totals = df.groupby("order_id").revenue.sum()
aov = order_totals.mean() if len(order_totals) else 0
margin = profit / revenue * 100 if revenue else 0

df["month"] = df.order_date.dt.to_period("M").dt.to_timestamp()
monthly = df.groupby("month", as_index=False).agg(revenue=("revenue","sum"), profit=("profit","sum"), orders=("order_id","nunique"))
category = df.groupby("category", as_index=False).agg(revenue=("revenue","sum"), profit=("profit","sum"), units=("quantity","sum"), orders=("order_id","nunique"))
category["margin_pct"] = category.profit.div(category.revenue.replace(0, pd.NA)) * 100
products = df.groupby(["product_name","category"], as_index=False).agg(revenue=("revenue","sum"), profit=("profit","sum"), units=("quantity","sum"), orders=("order_id","nunique")).sort_values("revenue", ascending=False)
products["margin_pct"] = products.profit.div(products.revenue.replace(0, pd.NA)) * 100
cust = df.groupby(["customer_id","customer_name","state"], as_index=False).agg(revenue=("revenue","sum"), profit=("profit","sum"), orders=("order_id","nunique"), units=("quantity","sum"), last_order=("order_date","max")).sort_values("revenue", ascending=False)
rfm = df.groupby(["customer_id","customer_name"], as_index=False).agg(last_order=("order_date","max"), frequency=("order_id","nunique"), monetary=("revenue","sum"))
rfm["recency_days"] = (df.order_date.max() - rfm.last_order).dt.days
try:
    rfm["R"] = pd.qcut(rfm.recency_days.rank(method="first"), 5, labels=[5,4,3,2,1]).astype(int)
    rfm["F"] = pd.qcut(rfm.frequency.rank(method="first"), 5, labels=[1,2,3,4,5]).astype(int)
    rfm["M"] = pd.qcut(rfm.monetary.rank(method="first"), 5, labels=[1,2,3,4,5]).astype(int)
    rfm["RFM_score"] = rfm[["R","F","M"]].sum(axis=1)
    def label(r):
        if r.R >= 4 and r.F >= 4 and r.M >= 4: return "Champions"
        if r.R >= 4 and r.F >= 3: return "Loyal Customers"
        if r.R >= 4 and r.F <= 2: return "Recent Customers"
        if r.R <= 2 and r.F >= 3: return "At Risk"
        if r.R <= 2 and r.F <= 2: return "Hibernating"
        return "Needs Attention"
    rfm["segment"] = rfm.apply(label, axis=1)
except ValueError:
    rfm["segment"] = "Insufficient data"

tabs = st.tabs(["Executive Overview", "Sales & Categories", "Products", "Customers", "RFM Segmentation", "Data Explorer"])
with tabs[0]:
    st.subheader("Executive Overview")
    a,b,c,d = st.columns(4)
    a.metric("Revenue", f"₹{revenue:,.0f}")
    b.metric("Profit", f"₹{profit:,.0f}")
    c.metric("Completed orders", f"{orders:,}")
    d.metric("Customers", f"{customers:,}")
    a,b,c,d = st.columns(4)
    a.metric("Profit margin", f"{margin:.1f}%")
    b.metric("Average order value", f"₹{aov:,.0f}")
    c.metric("Units sold", f"{units:,.0f}")
    d.metric("Cost", f"₹{cost:,.0f}")
    left,right = st.columns([1.6,1])
    with left:
        fig = px.line(monthly, x="month", y=["revenue","profit"], markers=True, title="Monthly Revenue & Profit")
        st.plotly_chart(fig, use_container_width=True)
    with right:
        fig = px.pie(status, names="order_status", values="orders", hole=.5, title="Order Status (all orders)")
        st.plotly_chart(fig, use_container_width=True)
    left,right = st.columns(2)
    with left:
        st.plotly_chart(px.bar(category.sort_values("revenue", ascending=False), x="category", y="revenue", title="Revenue by Category"), use_container_width=True)
    with right:
        st.plotly_chart(px.bar(category.sort_values("profit", ascending=False), x="category", y="profit", title="Profit by Category"), use_container_width=True)
    left,right = st.columns(2)
    with left:
        st.markdown("**Top 10 Products**")
        st.dataframe(products.head(10), use_container_width=True, hide_index=True)
    with right:
        st.markdown("**Top 10 Customers**")
        st.dataframe(cust.head(10), use_container_width=True, hide_index=True)

with tabs[1]:
    st.subheader("Sales & Categories")
    left,right = st.columns(2)
    with left:
        st.plotly_chart(px.bar(category, x="category", y="revenue", title="Revenue by Category"), use_container_width=True)
    with right:
        st.plotly_chart(px.bar(category, x="category", y="margin_pct", title="Profit Margin by Category"), use_container_width=True)
    st.plotly_chart(px.line(monthly, x="month", y=["revenue","profit"], markers=True, title="Monthly Trend"), use_container_width=True)
    st.dataframe(monthly.sort_values("month", ascending=False), use_container_width=True, hide_index=True)

with tabs[2]:
    st.subheader("Product Performance")
    st.plotly_chart(px.bar(products.head(15).sort_values("revenue"), x="revenue", y="product_name", color="category", orientation="h", title="Top Products by Revenue"), use_container_width=True)
    st.dataframe(products, use_container_width=True, hide_index=True)

with tabs[3]:
    st.subheader("Customer Analytics")
    left,right = st.columns(2)
    with left:
        st.plotly_chart(px.bar(cust.head(10).sort_values("revenue"), x="revenue", y="customer_name", orientation="h", title="Top Customers by Revenue"), use_container_width=True)
    with right:
        st.plotly_chart(px.scatter(cust, x="orders", y="revenue", color="state", hover_name="customer_name", title="Customer Revenue vs Order Frequency"), use_container_width=True)
    st.dataframe(cust, use_container_width=True, hide_index=True)

with tabs[4]:
    st.subheader("RFM Customer Segmentation")
    st.caption("Calculated from the selected completed-order data; snapshot date is the latest order in the filtered data.")
    if not rfm.empty and "segment" in rfm:
        left,right = st.columns(2)
        with left:
            seg = rfm.groupby("segment", as_index=False).agg(customers=("customer_id","nunique"))
            st.plotly_chart(px.pie(seg, names="segment", values="customers", hole=.45, title="Customers by Segment"), use_container_width=True)
        with right:
            seg_value = rfm.groupby("segment", as_index=False).agg(revenue=("monetary","sum"))
            st.plotly_chart(px.bar(seg_value, x="segment", y="revenue", title="Revenue by Segment"), use_container_width=True)
        st.dataframe(rfm.sort_values("monetary", ascending=False), use_container_width=True, hide_index=True)

with tabs[5]:
    st.subheader("Data Explorer")
    choice = st.selectbox("Dataset", ["Completed order details","Monthly summary","Category summary","Product summary","Customer summary","RFM summary","Order status"])
    frames = {"Completed order details":df, "Monthly summary":monthly, "Category summary":category, "Product summary":products, "Customer summary":cust, "RFM summary":rfm, "Order status":status}
    selected = frames[choice]
    st.caption(f"{len(selected):,} rows · {len(selected.columns)} columns")
    st.dataframe(selected, use_container_width=True, hide_index=True)
    st.download_button("Download CSV", selected.to_csv(index=False).encode("utf-8"), file_name=choice.lower().replace(" ","_")+".csv", mime="text/csv")

st.divider()
st.caption("Metric notes: revenue = quantity × listed price; cost = quantity × listed cost; profit = revenue − cost. Profit is a simplified estimate excluding discounts, taxes, shipping, refunds and operating expenses. Sales KPIs use completed orders; order-status chart uses all orders.")
