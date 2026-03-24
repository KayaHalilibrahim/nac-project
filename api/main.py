from fastapi import FastAPI, Request
import os
import psycopg2
from psycopg2.extras import RealDictCursor

app = FastAPI(title="NAC Policy Engine")

# Veritabanı bağlantı bilgileri (Environment variables'dan alıyoruz)
DB_USER = os.getenv("DB_USER", "radius_user")
DB_PASSWORD = os.getenv("DB_PASSWORD", "radius_pass")
DB_NAME = "radius_db"
DB_HOST = "localhost" # Host network kullandığımız için localhost

def get_db_connection():
    return psycopg2.connect(
        dbname=DB_NAME, 
        user=DB_USER, 
        password=DB_PASSWORD, 
        host=DB_HOST
    )

@app.get("/")
def read_root():
    return {"status": "NAC API is running"}

@app.get("/health")
def health_check():
    """Sistemin ayakta olduğunu kontrol eder"""
    return {"status": "alive"}

# RADIUS Buraya soracak: "Bu kullanıcı ve şifre doğru mu?"
@app.post("/auth")
async def authenticate(request: Request):
    try:
        data = await request.json()
        username = data.get("username")
        password = data.get("password")

        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        # Veritabanında kullanıcıyı ve şifresini sorgula
        query = "SELECT value FROM radcheck WHERE username=%s AND attribute='Cleartext-Password'"
        cur.execute(query, (username,))
        result = cur.fetchone()
        
        cur.close()
        conn.close()

        # Şifre kontrolü ve Yanıt
        if result and result['value'] == password:
            # Başarılı: RADIUS'a 'accept' ve atanacak VLAN bilgisini dönüyoruz
            return {"status": "accept", "vlan": "10"}
        
        # Hatalı şifre veya kullanıcı yoksa
        return {"status": "reject"}

    except Exception as e:
        # Bir hata oluşursa (DB bağlantısı vb.) reddet ve hatayı belirt
        return {"status": "reject", "error": str(e)}
