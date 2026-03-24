#!/bin/bash

# RADIUS'tan gelen parametreleri değişkenlere atıyoruz
ACTION=$1   # auth veya acct
USER=$2     # Kullanıcı adı
DATA=$3     # Şifre (auth ise) veya Durum (acct ise: Start/Stop)
SESSID=$4   # Oturum ID (sadece acct için)

if [ "$ACTION" == "auth" ]; then
    # 1. API'ye Kimlik Doğrulama isteği gönder
    RESPONSE=$(curl -s -X POST http://127.0.0.1:8000/auth \
         -H "Content-Type: application/json" \
         -d "{\"username\": \"$USER\", \"password\": \"$DATA\"}")

    # 2. Eğer API cevabı "accept" içeriyorsa RADIUS'a VLAN özniteliklerini bas
    if [[ "$RESPONSE" == *"accept"* ]]; then
        # RADIUS bu çıktıları okuyup pakete ekler (VLAN Steering)
        echo 'Tunnel-Type = 13'
        echo 'Tunnel-Medium-Type = 6'
        echo 'Tunnel-Private-Group-Id = "10"'
        exit 0
    else
        # Reddet
        exit 1
    fi

elif [ "$ACTION" == "acct" ]; then
    # 3. Muhasebe (Start/Stop) bilgisini API'ye gönder
    # Çıktıyı /dev/null'a atıyoruz ki RADIUS "Invalid attribute" hatası vermesin
    curl -s -X POST http://127.0.0.1:8000/accounting \
         -H "Content-Type: application/json" \
         -d "{\"username\": \"$USER\", \"status\": \"$DATA\", \"session_id\": \"$SESSID\"}" > /dev/null
    
    # Muhasebe paketlerinde RADIUS'a bir öznitelik dönmemize gerek yok
    exit 0
fi
