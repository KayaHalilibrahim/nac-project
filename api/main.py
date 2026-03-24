from fastapi import FastAPI
import os
import redis
import psycopg2

app = FastAPI(title="NAC Policy Engine")

# Ortam değişkenlerini al
DB_USER = os.getenv("DB_USER", "radius_user")
DB_PASSWORD = os.getenv("DB_PASSWORD", "radius_pass")
DB_NAME = "radius_db"
DB_HOST = "db"
REDIS_HOST = "redis"

@app.get("/")
def read_root():
    return {"status": "NAC API is running"}

@app.get("/health")
def health_check():
    # DB Kontrolü
    db_status = "Down"
    try:
        conn = psycopg2.connect(
            dbname=DB_NAME, user=DB_USER, password=DB_PASSWORD, host=DB_HOST
        )
        db_status = "Up"
        conn.close()
    except Exception as e:
        db_status = f"Down: {str(e)}"

    # Redis Kontrolü
    redis_status = "Down"
    try:
        r = redis.Redis(host=REDIS_HOST, port=6379, decode_responses=True)
        if r.ping():
            redis_status = "Up"
    except Exception:
        pass

    return {
        "database": db_status,
        "redis": redis_status
    }
