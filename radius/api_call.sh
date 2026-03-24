#!/bin/bash

# Eğer ilk parametre 'auth' ise doğrulama yap
if [ "$1" == "auth" ]; then
    RESPONSE=$(curl -s -X POST http://127.0.0.1:8000/auth \
         -H "Content-Type: application/json" \
         -d "{\"username\": \"$2\", \"password\": \"$3\"}")

    if [[ "$RESPONSE" == *"accept"* ]]; then
        echo "Tunnel-Type = 13, Tunnel-Medium-Type = 6, Tunnel-Private-Group-Id = \"10\""
        exit 0
    else
        exit 1
    fi

# Eğer ilk parametre 'acct' ise oturum kaydı yap
elif [ "$1" == "acct" ]; then
    # $2: Username, $3: Status (Start/Stop), $4: SessionID
    curl -s -X POST http://127.0.0.1:8000/accounting \
         -H "Content-Type: application/json" \
         -d "{\"username\": \"$2\", \"status\": \"$3\", \"session_id\": \"$4\"}"
    exit 0
fi
