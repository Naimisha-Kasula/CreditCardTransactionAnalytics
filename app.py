
import streamlit as st
import pandas as pd
import plotly.express as px
import mysql.connector
from mysql.connector import Error
from datetime import datetime

# =====================================================
# PAGE CONFIGURATION
# =====================================================
st.set_page_config(
    page_title="FraudGuard | Digital Fraud Analytics",
    page_icon="🛡️",
    layout="wide"
)

# =====================================================
# PROFESSIONAL THEME
# =====================================================
st.markdown("""
<style>
.stApp {
    background: #f5f3ff;
}
[data-testid="stSidebar"] {
    background: #17152e;
}
[data-testid="stSidebar"] * {
    color: white;
}
h1, h2, h3 {
    color: #5b21b6;
}
div[data-testid="stMetric"] {
    background: white;
    border: 1px solid #ddd6fe;
    border-left: 5px solid #7c3aed;
    border-radius: 12px;
    padding: 16px;
}
.stButton > button {
    background: #6d28d9;
    color: white;
    border-radius: 8px;
}
/* Fix MySQL settings input visibility */
.stApp input,
.stApp textarea,
div[data-baseweb="input"] input {
    color: #111111 !important;
    -webkit-text-fill-color: #111111 !important;
    caret-color: #111111 !important;
    background-color: #FFFFFF !important;
    opacity: 1 !important;
}

/* Make placeholders readable */
.stApp input::placeholder {
    color: #666666 !important;
    -webkit-text-fill-color: #666666 !important;
    opacity: 1 !important;
}
</style>
""", unsafe_allow_html=True)

# =====================================================
# DATABASE CONNECTION
# =====================================================
with st.sidebar.form("mysql_settings"):
    st.subheader("MySQL Settings")

    host = st.text_input("Host", value="localhost")
    username = st.text_input("Username", value="root")
    password = st.text_input("MySQL Password", type="password")
    database = st.text_input("Database", value="credit_card_db")
    port = st.number_input("Port", value=3307, step=1)

    submitted = st.form_submit_button("Submit")

if submitted:
    st.session_state["db_host"] = host
    st.session_state["db_user"] = username
    st.session_state["db_password"] = password
    st.session_state["db_name"] = database
    st.session_state["db_port"] = port
    st.success("Settings saved!")

def get_connection():
    return mysql.connector.connect(
        host=st.session_state.get("db_host", "localhost"),
        user=st.session_state.get("db_user", "root"),
        password=st.session_state.get("db_password", ""),
        database=st.session_state.get("db_name", "credit_card_db"),
        port=int(st.session_state.get("db_port", 3307)),
        connection_timeout=5
    )
def read_sql(query, params=None):
    conn = get_connection()
    try:
        return pd.read_sql(query, conn, params=params)
    finally:
        conn.close()

def get_tables():
    return read_sql("SHOW TABLES").iloc[:, 0].tolist()

def get_columns(table):
    allowed = get_tables()
    if table not in allowed:
        raise ValueError("Table not found.")
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(f"SHOW COLUMNS FROM `{table}`")
        return [row[0] for row in cursor.fetchall()]
    finally:
        conn.close()

# =====================================================
# RULE-BASED RISK DETECTION
# =====================================================
def calculate_risk(row):
    score = 0
    reasons = []

    amount_col = next(
        (c for c in ["transaction_amount", "amount"]
         if c in row.index), None
    )
    location_col = next(
        (c for c in ["location", "transaction_location"]
         if c in row.index), None
    )
    device_col = next(
        (c for c in ["device", "device_type"]
         if c in row.index), None
    )

    if amount_col:
        try:
            amount = float(row[amount_col] or 0)
            if amount >= 50000:
                score += 60
                reasons.append("Very high transaction amount")
            elif amount >= 15000:
                score += 30
                reasons.append("High transaction amount")
        except (TypeError, ValueError):
            pass

    if location_col:
        location = str(row[location_col]).strip().lower()
        if location in ["unknown", "unrecognized", ""]:
            score += 40
            reasons.append("Unknown location")

    if device_col:
        device = str(row[device_col]).strip().lower()
        if device in ["unknown", "unrecognized"]:
            score += 30
            reasons.append("Unrecognized device")

    if score >= 60:
        level = "High"
    elif score >= 30:
        level = "Medium"
    else:
        level = "Low"

    return pd.Series({
        "Risk Score": min(score, 100),
        "Risk Level": level,
        "Risk Reason": ", ".join(reasons) if reasons else "No rule triggered"
    })

# =====================================================
# APPLICATION HEADER
# =====================================================
st.sidebar.title("🛡️ FraudGuard")
st.sidebar.caption("DIGITAL FRAUD DETECTION")
st.sidebar.divider()

page = st.sidebar.radio(
    "NAVIGATION",
    [
        "📊 Dashboard",
        "💳 Transactions",
        "🚨 Fraud Alerts",
        "👤 Customer Analysis",
        "📈 Risk Analysis",
        "📥 Reports & Export"
    ]
)

# =====================================================
# LOAD MYSQL DATA
# =====================================================
try:
    tables = get_tables()

    if "transactions" not in tables:
        st.error(
            "The transactions table was not found in database "
            f"'{db_name}'. Check your database name and SQL setup."
        )
        st.stop()

    df = read_sql("SELECT * FROM transactions")

    if df.empty:
        st.warning(
            "MySQL connected, but transactions table is empty. "
            "Add transaction records using your database setup."
        )

    if not df.empty:
        risk_data = df.apply(calculate_risk, axis=1)
        df = pd.concat([df, risk_data], axis=1)

except (Error, ValueError) as exc:
    st.error("Unable to connect to MySQL or load project data.")
    st.code(str(exc))
    st.info(
        "Verify that MySQL Server is running, the database exists, "
        "the port is correct, and the password is correct."
    )
    st.stop()

st.sidebar.success("MySQL connected")
st.sidebar.caption(f"Transactions loaded: {len(df)}")

# =====================================================
# DASHBOARD
# =====================================================
if page == "📊 Dashboard":
    st.title("🛡️ FraudGuard Analytics Dashboard")
    st.write(
        "Credit card transaction monitoring and rule-based risk analysis."
    )

    amount_col = next(
        (c for c in ["transaction_amount", "amount"]
         if c in df.columns), None
    )

    total_amount = (
        pd.to_numeric(df[amount_col], errors="coerce").fillna(0).sum()
        if amount_col and not df.empty else 0
    )

    high = int((df["Risk Level"] == "High").sum()) if not df.empty else 0
    medium = int((df["Risk Level"] == "Medium").sum()) if not df.empty else 0
    low = int((df["Risk Level"] == "Low").sum()) if not df.empty else 0

    c1, c2, c3, c4 = st.columns(4)
    c1.metric("💳 Total Transactions", len(df))
    c2.metric("💰 Transaction Volume", f"₹{total_amount:,.2f}")
    c3.metric("🚨 High Risk", high)
    c4.metric("⚠️ Medium Risk", medium)

    st.divider()

    left, right = st.columns(2)

    with left:
        st.subheader("Risk Distribution")
        if not df.empty:
            chart_df = pd.DataFrame({
                "Risk Level": ["Low", "Medium", "High"],
                "Count": [low, medium, high]
            })
            fig = px.pie(
                chart_df,
                names="Risk Level",
                values="Count",
                hole=0.5,
                color="Risk Level",
                color_discrete_map={
                    "Low": "#16a34a",
                    "Medium": "#f59e0b",
                    "High": "#dc2626"
                }
            )
            st.plotly_chart(fig, use_container_width=True)
        else:
            st.info("No transaction data available.")

    with right:
        st.subheader("Transaction Amounts")
        if amount_col and not df.empty:
            fig = px.bar(
                df,
                x=df.columns[0],
                y=amount_col,
                color="Risk Level",
                color_discrete_map={
                    "Low": "#16a34a",
                    "Medium": "#f59e0b",
                    "High": "#dc2626"
                }
            )
            st.plotly_chart(fig, use_container_width=True)
        else:
            st.info("Transaction amount data is unavailable.")

    st.subheader("Recent Transactions")
    st.dataframe(df.tail(10), use_container_width=True, hide_index=True)

# =====================================================
# TRANSACTION MONITORING
# =====================================================
elif page == "💳 Transactions":
    st.title("💳 Transaction Monitoring")

    search = st.text_input("Search transaction details")
    risk_filter = st.selectbox(
        "Risk Level", ["All", "Low", "Medium", "High"]
    )

    view = df.copy()

    if search:
        mask = view.astype(str).apply(
            lambda col: col.str.contains(search, case=False, na=False)
        ).any(axis=1)
        view = view[mask]

    if risk_filter != "All":
        view = view[view["Risk Level"] == risk_filter]

    st.caption(f"{len(view)} matching transactions")
    st.dataframe(view, use_container_width=True, hide_index=True)

    st.download_button(
        "⬇️ Download Transactions CSV",
        data=view.to_csv(index=False).encode("utf-8-sig"),
        file_name="transactions.csv",
        mime="text/csv"
    )

# =====================================================
# FRAUD ALERTS
# =====================================================
elif page == "🚨 Fraud Alerts":
    st.title("🚨 Fraud Monitoring Center")

    alerts = df[df["Risk Level"] == "High"].copy()

    if alerts.empty:
        st.success("No high-risk transactions were detected by the rules.")
    else:
        st.warning(f"{len(alerts)} high-risk transactions require review.")
        st.dataframe(alerts, use_container_width=True, hide_index=True)

    st.caption(
        "High risk is a rule-based warning, not proof that fraud occurred."
    )

# =====================================================
# CUSTOMER ANALYSIS
# =====================================================
elif page == "👤 Customer Analysis":
    st.title("👤 Customer Analysis")

    customer_col = next(
        (c for c in ["customer_name", "customer_id", "account_id"]
         if c in df.columns), None
    )

    if customer_col and not df.empty:
        st.subheader("Transactions by Customer or Account")
        summary = df.groupby(customer_col).size().reset_index(
            name="Transaction Count"
        )
        st.dataframe(summary, use_container_width=True, hide_index=True)

        st.bar_chart(summary.set_index(customer_col))
    else:
        st.info(
            "Customer details are not available in the transactions table. "
            "Check the customers and accounts tables in MySQL."
        )

# =====================================================
# RISK ANALYSIS
# =====================================================
elif page == "📈 Risk Analysis":
    st.title("📈 Rule-Based Risk Analysis")

    if not df.empty:
        st.dataframe(
            df[["Risk Score", "Risk Level", "Risk Reason"]].join(
                df,
                rsuffix="_original"
            ),
            use_container_width=True,
            hide_index=True
        )

        st.subheader("Risk Counts")
        st.bar_chart(df["Risk Level"].value_counts())
    else:
        st.info("No data available for risk analysis.")

# =====================================================
# REPORTS
# =====================================================
elif page == "📥 Reports & Export":
    st.title("📥 Reports & Export")

    st.write("Export transaction records with rule-based risk results.")

    st.download_button(
        "⬇️ Download Complete Risk Report",
        data=df.to_csv(index=False).encode("utf-8-sig"),
        file_name=f"fraudguard_report_{datetime.now():%Y%m%d_%H%M}.csv",
        mime="text/csv"
    )

    st.subheader("Risk Summary")
    if not df.empty:
        summary = (
            df.groupby("Risk Level")
            .size()
            .reset_index(name="Transactions")
        )
        st.dataframe(summary, use_container_width=True, hide_index=True)

st.sidebar.divider()
st.sidebar.caption("FraudGuard • Rule-based monitoring • MySQL")
