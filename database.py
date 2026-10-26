import re
import streamlit as st
import mysql.connector


def get_db_config():
    return st.session_state.get(
        "db_config",
        {
            "host": "localhost",
            "user": "root",
            "password": "",
            "database": "credit_card_db",
            "port": 3307
        }
    ).copy()


def get_connection():
    config = get_db_config()
    return mysql.connector.connect(**config)


def initialize_database():
    config = get_db_config()
    database_name = config["database"].strip()

    if not re.fullmatch(r"[A-Za-z0-9_]+", database_name):
        raise ValueError("Invalid database name.")

    server_config = config.copy()
    server_config.pop("database")

    # Create database if it does not exist
    connection = mysql.connector.connect(**server_config)

    try:
        cursor = connection.cursor()
        cursor.execute(
            f"CREATE DATABASE IF NOT EXISTS `{database_name}`"
        )
        cursor.close()
    finally:
        connection.close()

    # Connect to the selected database
    connection = mysql.connector.connect(**config)
    cursor = connection.cursor()

    try:
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS customers (
                customer_id INT AUTO_INCREMENT PRIMARY KEY,
                customer_name VARCHAR(100) NOT NULL,
                email VARCHAR(100) UNIQUE NOT NULL,
                phone VARCHAR(15),
                city VARCHAR(50),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS accounts (
                account_id INT AUTO_INCREMENT PRIMARY KEY,
                customer_id INT NOT NULL,
                account_number VARCHAR(20) UNIQUE NOT NULL,
                card_number VARCHAR(20) UNIQUE NOT NULL,
                card_type VARCHAR(30),
                credit_limit DECIMAL(12,2),
                account_status VARCHAR(20) DEFAULT 'Active',
                FOREIGN KEY (customer_id)
                    REFERENCES customers(customer_id)
            )
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS transactions (
                transaction_id INT AUTO_INCREMENT PRIMARY KEY,
                account_id INT NOT NULL,
                transaction_amount DECIMAL(12,2) NOT NULL,
                transaction_date DATETIME NOT NULL,
                merchant_name VARCHAR(100),
                location VARCHAR(100),
                device VARCHAR(100),
                transaction_type VARCHAR(30),
                transaction_status VARCHAR(30),
                FOREIGN KEY (account_id)
                    REFERENCES accounts(account_id)
            )
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS fraud_alerts (
                alert_id INT AUTO_INCREMENT PRIMARY KEY,
                transaction_id INT NOT NULL,
                risk_score INT,
                risk_level VARCHAR(20),
                alert_reason VARCHAR(255),
                alert_status VARCHAR(30) DEFAULT 'Pending',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (transaction_id)
                    REFERENCES transactions(transaction_id)
            )
        """)

        connection.commit()

    finally:
        cursor.close()
        connection.close()