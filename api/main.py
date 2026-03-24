from fastapi import FastAPI, Request
import psycopg2
import redis
import os
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

# Veritabanı Bağlantısı
def get_db_conn():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        database=os.getenv("DB_NAME", "radius_db"),
        user=os.getenv("DB_USER", "radius_user"),
        password=os.getenv("DB_PASSWORD", "radius_password")
    )

# Redis Bağlantısı
r = redis.Redis(host=os.getenv("REDIS_HOST", "localhost"), port=6379, db=0)

@app.post("/auth")
async def auth(data: dict):
    username = data.get("username")
    password = data.get("password")
    
    # Basit bir kontrol: Kullanıcı 'kaya' ise VLAN 10 ile kabul et
    if username == "kaya" and password == "123456":
        # Redis'e giriş bilgisini işle (opsiyonel)
        r.set(f"user:{username}:status", "online")
        return {"status": "accept", "vlan": "10"}
    
    return {"status": "reject"}

@app.post("/accounting")
async def accounting(data: dict):
    username = data.get("username")
    status = data.get("status")
    session_id = data.get("session_id")
    
    # Veritabanındaki NOT NULL kısıtlamalarını aşmak için varsayılan değerler
    nas_ip = "127.0.0.1"
    acct_unique_id = f"unique-{session_id}"
    
    conn = get_db_conn()
    cur = conn.cursor()
    
    try:
        if status == "Start":
            # Zorunlu alanları (nasipaddress, acctuniqueid) ekleyerek kaydediyoruz
            cur.execute("""
                INSERT INTO radacct (
                    acctsessionid, acctuniqueid, username, 
                    nasipaddress, acctstarttime, acctupdatetime
                )
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (
                session_id, acct_unique_id, username, 
                nas_ip, datetime.now(), datetime.now()
            ))
            print(f"DEBUG: Accounting Start recorded for {username}")
            
        elif status == "Stop":
            cur.execute("""
                UPDATE radacct 
                SET acctstoptime = %s, acctupdatetime = %s 
                WHERE acctsessionid = %s
            """, (datetime.now(), datetime.now(), session_id))
            print(f"DEBUG: Accounting Stop recorded for {username}")

        conn.commit()
    except Exception as e:
        print(f"DATABASE ERROR: {e}")
        conn.rollback()
    finally:
        cur.close()
        conn.close()
        
    return {"status": "success"}

@app.get("/health")
async def health():
    return {"status": "healthy"}
