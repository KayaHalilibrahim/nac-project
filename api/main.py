from fastapi import FastAPI, Request
import os
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime

app = FastAPI(title="NAC Policy Engine")

# DB Bağlantı Ayarları
DB_CONFIG = {
    "dbname": "radius_db",
    "user": os.getenv("DB_USER", "radius_user"),
    "password": os.getenv("DB_PASSWORD", "radius_pass"),
    "host": "localhost"
}

def get_db_connection():
    return psycopg2.connect(**DB_CONFIG)

@app.post("/auth")
async def authenticate(request: Request):
    data = await request.json()
    username = data.get("username")
    password = data.get("password")

    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute("SELECT value FROM radcheck WHERE username=%s AND attribute='Cleartext-Password'", (username,))
    result = cur.fetchone()
    cur.close()
    conn.close()

    if result and result['value'] == password:
        return {"status": "accept", "vlan": "10"}
    return {"status": "reject"}

@app.post("/accounting")
async def accounting(request: Request):
    data = await request.json()
    status = data.get("status") # "Start" veya "Stop"
    username = data.get("username")
    session_id = data.get("session_id", "unknown")

    conn = get_db_connection()
    cur = conn.cursor()

    if status == "Start":
        # Yeni oturum kaydı oluştur
        cur.execute("""
            INSERT INTO radacct (acctsessionid, username, acctstarttime)
            VALUES (%s, %s, %s)
        """, (session_id, username, datetime.now()))
    
    elif status == "Stop":
        # Mevcut oturumu sonlandır
        cur.execute("""
            UPDATE radacct 
            SET acctstoptime = %s 
            WHERE acctsessionid = %s AND acctstoptime IS NULL
        """, (datetime.now(), session_id))

    conn.commit()
    cur.close()
    conn.close()
    return {"status": "success"}
