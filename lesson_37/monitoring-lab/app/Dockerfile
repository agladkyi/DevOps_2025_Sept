FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN python -m pip install --no-cache-dir -r /app/requirements.txt

COPY app.py /app/app.py

EXPOSE 8080
ENV PYTHONUNBUFFERED=1

CMD ["python", "/app/app.py"]
