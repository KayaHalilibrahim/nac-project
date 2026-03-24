from fastapi import FastAPI
import psycopg2
import redis
import os
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()
app = FastAPI()

# DB Bağlantısı
def get_db_conn():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        database=os.getenv("DB_NAME", "radius_db"),
        user=os.getenv("DB_USER", "radius_user"),
        password=os.getenv("DB_PASSWORD", "radius_password")
    )

# Redis Bağlantısı (Aktif oturum takibi için)
r = redis.Redis(host=os.getenv("REDIS_HOST", "localhost"), port=6379, db=0)

@app.post("/auth")
async def auth(data: dict):
    username = data.get("username")
    password = data.get("password")
    # Ödev: Basit auth ve VLAN ataması
    if username == "kaya" and password == "123456":
        return {"status": "accept", "vlan": "10"}
    return {"status": "reject"}

@app.post("/accounting")
async def accounting(data: dict):
    username = data.get("username")
    status = data.get("status")
    session_id = data.get("session_id")
    nas_ip = "127.0.0.1"
    
    conn = get_db_conn()
    cur = conn.cursor()
    try:
        if status == "Start":
            # DB'ye kaydet
            cur.execute("""
                INSERT INTO radacct (acctsessionid, acctuniqueid, username, nasipaddress, acctstarttime, acctupdatetime)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (session_id, f"unique-{session_id}", username, nas_ip, datetime.now(), datetime.now()))
            # Ödev 3.4: Aktif oturumu Redis'te cache'le (1 saatlik ömürle)
            r.setex(f"active_session:{username}", 3600, session_id)
            
        elif status == "Stop":
            cur.execute("""
                UPDATE radacct SET acctstoptime = %s, acctupdatetime = %s WHERE acctsessionid = %s
            """, (datetime.now(), datetime.now(), session_id))
            # Ödev 3.4: Oturum bittiğinde Redis'ten sil
            r.delete(f"active_session:{username}")
            
        conn.commit()
    except Exception as e:
        conn.rollback()
    finally:
        cur.close()
        conn.close()
    return {"status": "success"}

@app.get("/users")
async def get_users():
    # Ödev 3.5: Kullanıcı listesi
    conn = get_db_conn()
    cur = conn.cursor()
    cur.execute("SELECT username FROM radacct GROUP BY username")
    users = [row[0] for row in cur.fetchall()]
    cur.close()
    conn.close()
    return {"registered_users": users}

@app.get("/sessions/active")
async def get_active_sessions():
    # Ödev 3.5: Aktif oturumları Redis'ten sorgula
    keys = r.keys("active_session:*")
    active_users = [k.decode().split(":")[1] for k in keys]
    return {"active_sessions_count": len(active_users), "users": active_users}
