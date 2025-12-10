# app_mysql.py - Guardar en la misma carpeta
from flask import Flask, jsonify, request, send_from_directory, render_template_string
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from config import Config
from models import db, User, Post, Comment, Like
import os
from datetime import datetime

app = Flask(__name__, static_folder='static', template_folder='templates')
app.config.from_object(Config)

CORS(app)

# Inicializar db con la app
db.init_app(app)

print("=" * 60)
print("🚀 VEREDICT - MYSQL EDITION")
print(f"📊 Base de datos: {app.config['SQLALCHEMY_DATABASE_URI']}")
print("🌐 URL: http://localhost:5000")
print("👤 Admin: http://localhost/phpmyadmin")
print("=" * 60)

# Crear tablas y usuario admin al inicio
with app.app_context():
    try:
        db.create_all()
        print("✅ Tablas creadas/verificadas")
        
        # Crear usuario admin si no existe
        if not User.query.filter_by(username='admin').first():
            admin = User(
                username='admin',
                email='admin@veredict.com',
                is_admin=True
            )
            admin.set_password('admin123')
            db.session.add(admin)
            db.session.commit()
            print("✅ Usuario admin creado:")
            print("   Usuario: admin")
            print("   Contraseña: admin123")
            print("   Email: admin@veredict.com")
        
        # Crear algunos datos de ejemplo si no hay posts
        if Post.query.count() == 0:
            user = User.query.filter_by(username='admin').first()
            if user:
                post1 = Post(
                    title='NVIDIA RTX 4080 - Review',
                    content='Excelente rendimiento en juegos 4K, consumo de energía moderado.',
                    category='GPU',
                    rating=5,
                    user_id=user.id
                )
                post2 = Post(
                    title='AMD Ryzen 7 7800X3D',
                    content='Increíble para gaming, la cache 3D hace la diferencia.',
                    category='CPU',
                    rating=5,
                    user_id=user.id
                )
                db.session.add_all([post1, post2])
                db.session.commit()
                print("✅ Posts de ejemplo creados")
    except Exception as e:
        print(f"⚠️  Error al inicializar: {e}")
        print("⚠️  Asegúrate que MySQL esté ejecutándose en XAMPP")

# Ruta principal - página web o API info
@app.route('/')
def index():
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Veredict - Backend MySQL</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background: #f5f7fa; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 20px rgba(0,0,0,0.1); }
            h1 { color: #f4630c; }
            .endpoint { background: #f8f9fa; padding: 15px; margin: 10px 0; border-radius: 5px; border-left: 4px solid #3498db; }
            .btn { display: inline-block; padding: 10px 20px; background: #3498db; color: white; text-decoration: none; border-radius: 5px; margin: 5px; }
            .btn:hover { background: #2980b9; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 Veredict - Backend MySQL</h1>
            <p>El servidor backend está funcionando correctamente con MySQL.</p>
            
            <h2>🔗 Endpoints disponibles:</h2>
            <div class="endpoint">
                <strong>GET /api/health</strong> - Estado del servidor
            </div>
            <div class="endpoint">
                <strong>GET /api/posts</strong> - Listar publicaciones
            </div>
            <div class="endpoint">
                <strong>GET /admin/dashboard</strong> - Panel de administración
            </div>
            <div class="endpoint">
                <strong>GET /admin/users</strong> - Listar usuarios
            </div>
            
            <h2>📊 Accesos rápidos:</h2>
            <a href="/api/health" class="btn">Verificar Salud</a>
            <a href="/admin/dashboard" class="btn">Panel Admin</a>
            <a href="/api/posts" class="btn">Ver Posts</a>
            <a href="http://localhost/phpmyadmin" target="_blank" class="btn" style="background: #f4630c;">phpMyAdmin</a>
            
            <h2>👤 Credenciales Admin:</h2>
            <p><strong>Usuario:</strong> admin</p>
            <p><strong>Contraseña:</strong> admin123</p>
            <p><strong>Email:</strong> admin@veredict.com</p>
        </div>
    </body>
    </html>
    """

@app.route('/admin/dashboard')
def admin_dashboard():
    """Panel de administración básico"""
    try:
        stats = {
            'users': User.query.count(),
            'posts': Post.query.count(),
            'comments': Comment.query.count(),
            'likes': Like.query.count()
        }
        
        recent_users = User.query.order_by(User.created_at.desc()).limit(5).all()
        
        return jsonify({
            'status': 'ok',
            'admin': True,
            'stats': stats,
            'recent_users': [
                {
                    'id': u.id,
                    'username': u.username,
                    'email': u.email,
                    'is_admin': u.is_admin,
                    'created_at': u.created_at.isoformat() if u.created_at else None
                }
                for u in recent_users
            ],
            'mysql_connection': app.config['SQLALCHEMY_DATABASE_URI']
        })
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e),
            'mysql_connection': app.config['SQLALCHEMY_DATABASE_URI']
        }), 500

@app.route('/admin/users', methods=['GET'])
def get_users():
    try:
        users = User.query.all()
        return jsonify({
            'status': 'ok',
            'count': len(users),
            'users': [
                {
                    'id': u.id,
                    'username': u.username,
                    'email': u.email,
                    'is_admin': u.is_admin,
                    'created_at': u.created_at.isoformat() if u.created_at else None,
                    'post_count': len(u.posts),
                    'avatar': u.avatar
                }
                for u in users
            ]
        })
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/api/posts', methods=['GET'])
def get_posts():
    try:
        posts = Post.query.order_by(Post.created_at.desc()).all()
        return jsonify({
            'status': 'ok',
            'count': len(posts),
            'posts': [post.to_dict() for post in posts]
        })
    except Exception as e:
        # Si hay error, devolver datos de ejemplo
        return jsonify({
            'status': 'ok',
            'count': 2,
            'posts': [
                {
                    'id': 1,
                    'title': 'NVIDIA RTX 4080',
                    'content': 'Excelente rendimiento en juegos 4K.',
                    'category': 'GPU',
                    'rating': 5,
                    'author': 'admin',
                    'created_at': datetime.utcnow().isoformat()
                },
                {
                    'id': 2,
                    'title': 'AMD Ryzen 7 7800X3D',
                    'content': 'Increíble para gaming.',
                    'category': 'CPU',
                    'rating': 5,
                    'author': 'admin',
                    'created_at': datetime.utcnow().isoformat()
                }
            ]
        })

@app.route('/api/health', methods=['GET'])
def health():
    try:
        # Verificar conexión a MySQL
        db.session.execute('SELECT 1')
        db_status = 'CONNECTED'
        
        # Obtener estadísticas
        stats = {
            'users': User.query.count(),
            'posts': Post.query.count(),
            'comments': Comment.query.count(),
            'likes': Like.query.count()
        }
        
    except Exception as e:
        db_status = f'DISCONNECTED - Error: {str(e)}'
        stats = {}
    
    return jsonify({
        'status': 'OK',
        'service': 'Veredict MySQL Backend',
        'version': '1.0.0',
        'database': db_status,
        'mysql_connection': app.config['SQLALCHEMY_DATABASE_URI'],
        'timestamp': datetime.utcnow().isoformat(),
        'stats': stats,
        'endpoints': [
            '/api/health',
            '/api/posts',
            '/admin/dashboard',
            '/admin/users',
            '/'
        ]
    })

# Ruta para servir archivos estáticos
@app.route('/static/<path:path>')
def serve_static(path):
    return send_from_directory(app.static_folder, path)

# Ruta para servir archivos subidos
@app.route('/uploads/<path:filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

if __name__ == '__main__':
    # Crear carpetas necesarias
    folders = ['static', 'templates', 'uploads/avatars', 'uploads/posts']
    for folder in folders:
        os.makedirs(folder, exist_ok=True)
    
    print("\n" + "=" * 60)
    print("INICIANDO SERVIDOR...")
    print("=" * 60)
    print("\nAccesos rápidos:")
    print("🌐 Página principal: http://localhost:5000")
    print("📊 Panel admin: http://localhost:5000/admin/dashboard")
    print("🔍 Ver posts: http://localhost:5000/api/posts")
    print("💾 phpMyAdmin: http://localhost/phpmyadmin")
    print("\nPresiona Ctrl+C para detener el servidor")
    print("=" * 60 + "\n")
    
    try:
        app.run(debug=True, host='0.0.0.0', port=5000)
    except Exception as e:
        print(f"\n❌ Error al iniciar servidor: {e}")
        print("⚠️  Verifica que:")
        print("   1. XAMPP esté ejecutándose (Apache y MySQL)")
        print("   2. El puerto 5000 no esté en uso")
        print("   3. MySQL esté escuchando en el puerto 3306")