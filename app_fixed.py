# app_fixed.py - COPIA Y PEGA ESTO
from flask import Flask, jsonify, send_from_directory
from flask_cors import CORS
import os

app = Flask(__name__, static_folder='static', template_folder='templates')
CORS(app)

print("""
╔══════════════════════════════════════╗
║      VEREDICT - BACKEND READY        ║
╠══════════════════════════════════════╣
║  Status: ONLINE                      ║
║  URL: http://localhost:5500          ║
║  Static: /static                     ║
║  Templates: /templates               ║
╚══════════════════════════════════════╝
""")

@app.route('/')
def home():
    if os.path.exists('templates/index.html'):
        return send_from_directory('templates', 'index.html')
    return """
    <!DOCTYPE html>
    <html>
    <head><title>Veredict</title>
    <style>
        body { font-family: Arial; padding: 40px; text-align: center; }
        h1 { color: #f4630c; }
        .box { background: white; padding: 30px; border-radius: 10px; 
               box-shadow: 0 0 20px rgba(0,0,0,0.1); max-width: 600px; margin: 0 auto; }
    </style>
    </head>
    <body style="background: #f5f7fa;">
        <div class="box">
            <h1>🚀 Veredict - Funcionando</h1>
            <p>El backend se está ejecutando correctamente.</p>
            <div style="margin: 20px 0;">
                <a href="/api/health" style="background: #f4630c; color: white; 
                   padding: 10px 20px; border-radius: 5px; text-decoration: none;">
                   Verificar Salud
                </a>
            </div>
            <p><strong>Endpoints disponibles:</strong></p>
            <ul style="text-align: left; display: inline-block;">
                <li><code>GET /</code> - Página principal</li>
                <li><code>GET /api/health</code> - Estado del servidor</li>
                <li><code>GET /api/posts</code> - Lista de publicaciones</li>
                <li><code>POST /api/auth/login</code> - Inicio de sesión</li>
            </ul>
        </div>
    </body>
    </html>
    """

@app.route('/api/health')
def health():
    return jsonify({
        "status": "OK",
        "service": "Veredict Backend",
        "version": "1.0.0",
        "endpoints": [
            "/api/health",
            "/api/posts",
            "/api/auth/login"
        ]
    })

@app.route('/api/posts')
def get_posts():
    posts = [
        {
            "id": 1,
            "title": "NVIDIA RTX 4080",
            "content": "Excelente rendimiento en 4K, consumo de energía moderado.",
            "category": "GPU",
            "rating": 5,
            "author": "Alex",
            "likes": 42,
            "comments": 8,
            "date": "2024-03-15"
        },
        {
            "id": 2,
            "title": "AMD Ryzen 7 7800X3D",
            "content": "Increíble para gaming, la cache 3D hace la diferencia.",
            "category": "CPU",
            "rating": 5,
            "author": "Marta",
            "likes": 36,
            "comments": 12,
            "date": "2024-03-14"
        }
    ]
    return jsonify({"posts": posts, "count": len(posts)})

@app.route('/api/auth/login', methods=['POST'])
def login():
    return jsonify({
        "token": "demo_jwt_token_12345",
        "user": {
            "id": 1,
            "name": "Usuario Demo",
            "email": "demo@veredict.com",
            "avatar": "https://i.pravatar.cc/150?img=1"
        },
        "message": "Inicio de sesión exitoso"
    })

@app.route('/static/<path:filename>')
def static_files(filename):
    return send_from_directory('static', filename)

if __name__ == '__main__':
    # Crear carpetas si no existen
    folders = ['static', 'templates', 'uploads/avatars', 'uploads/posts']
    for folder in folders:
        os.makedirs(folder, exist_ok=True)
    
    app.run(debug=True, host='0.0.0.0', port=5500)