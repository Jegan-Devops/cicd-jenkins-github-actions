FROM python:3.12-slim

WORKDIR /app

# Copy requirements first so Docker caches this layer — it only re-installs
# dependencies when requirements.txt actually changes, not on every code edit.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

# Healthcheck lets ECS/Docker know the container is actually serving traffic,
# not just that the process started.
HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

CMD ["python", "app.py"]
