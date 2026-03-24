#!/bin/bash
# API'ye sor
RESPONSE=$(curl -s -X POST http://127.0.0.1:8000/auth \
     -H "Content-Type: application/json" \
     -d "{\"username\": \"$1\", \"password\": \"$2\"}")

if [[ "$RESPONSE" == *"accept"* ]]; then
    # RADIUS'a VLAN bilgisini fısılda
    echo "Tunnel-Type = VLAN, Tunnel-Medium-Type = IEEE-802, Tunnel-Private-Group-Id = 10"
    exit 0
else
    exit 1
fi
