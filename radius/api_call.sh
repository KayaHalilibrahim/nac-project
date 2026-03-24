#!/bin/bash
# RADIUS'tan gelen kullanıcı ve şifreyi alıp API'ye POST atar
RESPONSE=$(curl -s -X POST http://127.0.0.1:8000/auth \
     -H "Content-Type: application/json" \
     -d "{\"username\": \"$1\", \"password\": \"$2\"}")

if [[ "$RESPONSE" == *"accept"* ]]; then
    exit 0 # Başarılı
else
    exit 1 # Red
fi
