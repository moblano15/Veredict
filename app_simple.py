# app_simple.py
from flask import Flask, jsonify, send_from_directory
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)

# Rutas básicas
@app.route('/')
def home():
    return send_from_directory('.', 'index.html') if os.path.exists('index.html') else "Veredict Funcionando"

@app.route('/api/health')
def health():
    return jsonify({"status": "ok", "message": "Backend funcionando"})

@app.route('/api/posts')
def get_posts():
    # Datos de ejemplo
    posts = [
        {"id": 1, "title": "RTX 4080", "content": "Excelente rendimiento", "category": "GPU", "rating": 5, "author": "Juan"},
        {"id": 2, "title": "Ryzen 7 5800X", "content": "Muy buen procesador", "category": "CPU", "rating": 4, "author": "Maria"}
    ]
    return jsonify({"posts": posts})

if __name__ == '__main__':
    print("✅ Servidor ejecutándose en http://localhost:5000")
    app.run(debug=True, port=5000, host='0.0.0.0')