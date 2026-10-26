import pandas as pd
from database import get_connection


def get_transactions():

    connection = get_connection()

    query = """
    SELECT
        t.transaction_id,
        t.account_id,
        a.customer_id,
        t.transaction_amount,
        t.transaction_date,
        t.merchant_name,
        t.location,
        t.device,
        t.transaction_type,
        t.transaction_status
    FROM transactions t
    JOIN accounts a
        ON t.account_id = a.account_id
    """

    df = pd.read_sql(query, connection)

    connection.close()

    return df


def calculate_risk(row):

    score = 0
    reasons = []

    # High transaction amount
    if row["transaction_amount"] >= 50000:
        score += 30
        reasons.append("High transaction amount")

    # Unknown device
    if row["device"] == "Unknown Device":
        score += 25
        reasons.append("Unknown device")

    # Unusual location
    if row["location"] not in ["Hyderabad", "Vijayawada", "Bangalore", "Chennai"]:
        score += 20
        reasons.append("Unusual location")

    # Late night transaction
    hour = pd.to_datetime(row["transaction_date"]).hour

    if hour >= 23 or hour < 5:
        score += 20
        reasons.append("Unusual transaction time")

    # Determine risk level
    if score >= 70:
        risk_level = "High"

    elif score >= 40:
        risk_level = "Medium"

    else:
        risk_level = "Low"

    return score, risk_level, ", ".join(reasons)


def analyze_transactions():

    df = get_transactions()

    results = []

    for _, row in df.iterrows():

        score, risk_level, reason = calculate_risk(row)

        results.append({
            "transaction_id": row["transaction_id"],
            "risk_score": score,
            "risk_level": risk_level,
            "alert_reason": reason
        })

    return pd.DataFrame(results)


def save_alerts(results):

    connection = get_connection()

    cursor = connection.cursor()

    for _, row in results.iterrows():

        # Create alerts only for Medium and High risk
        if row["risk_level"] in ["Medium", "High"]:

            # Check whether alert already exists
            check_query = """
            SELECT COUNT(*)
            FROM fraud_alerts
            WHERE transaction_id = %s
            """

            cursor.execute(
                check_query,
                (int(row["transaction_id"]),)
            )

            count = cursor.fetchone()[0]

            # Insert only if alert does not already exist
            if count == 0:

                insert_query = """
                INSERT INTO fraud_alerts
                (
                    transaction_id,
                    risk_score,
                    risk_level,
                    alert_reason
                )
                VALUES (%s, %s, %s, %s)
                """

                values = (
                    int(row["transaction_id"]),
                    int(row["risk_score"]),
                    row["risk_level"],
                    row["alert_reason"]
                )

                cursor.execute(insert_query, values)

    connection.commit()

    cursor.close()
    connection.close()


if __name__ == "__main__":

    results = analyze_transactions()

    print("\nFraud Detection Results")
    print("========================")

    print(results)

    save_alerts(results)

    print("\nFraud alerts saved successfully!")