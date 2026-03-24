FROM python:3.13-slim

WORKDIR /app

# Sorun çıkaran apt-get kısımlarını şimdilik kaldırdık
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["fastapi", "run", "main.py", "--port", "8000"]
