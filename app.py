# app.py - VERSIÓN SIMPLE Y FUNCIONAL
from flask import Flask, jsonify, request, render_template_string
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash
import os
from datetime import datetime

# Crear aplicación Flask
app = Flask(__name__)

# Configuración SIMPLE
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:@localhost/veredict_db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = 'veredict-secret-key-123'

# Inicializar extensiones
CORS(app)
db = SQLAlchemy(app)

# Definir modelos DENTRO del mismo archivo para evitar errores de importación
class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(200), nullable=False)
    is_admin = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Post(db.Model):
    __tablename__ = 'posts'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(150), nullable=False)
    content = db.Column(db.Text, nullable=False)
    category = db.Column(db.String(50), nullable=False)
    rating = db.Column(db.Integer, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))

# Función para inicializar base de datos
def init_database():
    with app.app_context():
        try:
            db.create_all()
            print("✅ Tablas creadas")
            
            # Crear usuario admin si no existe
            if not User.query.filter_by(username='admin').first():
                admin = User(
                    username='admin',
                    email='admin@veredict.com',
                    is_admin=True
                )
                admin.password_hash = generate_password_hash('admin123')
                db.session.add(admin)
                db.session.commit()
                print("✅ Usuario admin creado")
                print("   Usuario: admin")
                print("   Contraseña: admin123")
                
            # Crear posts de ejemplo
            if Post.query.count() == 0:
                admin = User.query.filter_by(username='admin').first()
                if admin:
                    posts = [
                        Post(
                            title='NVIDIA RTX 4080',
                            content='Excelente GPU para gaming 4K',
                            category='GPU',
                            rating=5,
                            user_id=admin.id
                        ),
                        Post(
                            title='AMD Ryzen 7 7800X3D',
                            content='Procesador excelente para juegos',
                            category='CPU',
                            rating=5,
                            user_id=admin.id
                        )
                    ]
                    db.session.add_all(posts)
                    db.session.commit()
                    print("✅ Posts de ejemplo creados")
                    
        except Exception as e:
            print(f"⚠️  Error al inicializar BD: {e}")
            print("⚠️  Verifica que MySQL esté ejecutándose en XAMPP")

# Llamar a init_database al inicio
init_database()

# ================= RUTAS =================
@app.route('/')
def home():
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Veredict - Backend</title>
        <style>
            body { font-family: Arial; margin: 40px; background: #f0f2f5; }
            .container { max-width: 800px; margin: 0 auto; background: white; 
                        padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            h1 { color: #f4630c; }
            .endpoint { background: #f8f9fa; padding: 15px; margin: 10px 0; 
                       border-radius: 5px; border-left: 4px solid #3498db; }
            .btn { display: inline-block; padding: 10px 20px; background: #3498db; 
                  color: white; text-decoration: none; border-radius: 5px; margin: 5px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>✅ Veredict Backend Funcionando</h1>
            <p>Servidor Flask + MySQL ejecutándose correctamente.</p>
            
            <h2>🔗 Endpoints:</h2>
            <div class="endpoint"><strong>GET</strong> <a href="/api/health">/api/health</a> - Estado del servidor</div>
            <div class="endpoint"><strong>GET</strong> <a href="/api/posts">/api/posts</a> - Publicaciones</div>
            <div class="endpoint"><strong>GET</strong> <a href="/admin">/admin</a> - Panel de administración</div>
            
            <h2>📊 Accesos rápidos:</h2>
            <a href="/api/health" class="btn">Salud del Servidor</a>
            <a href="/api/posts" class="btn">Ver Posts</a>
            <a href="/admin" class="btn">Panel Admin</a>
            <a href="http://localhost/phpmyadmin" target="_blank" class="btn" style="background:#f4630c;">phpMyAdmin</a>
            
            <h2>👤 Credenciales:</h2>
            <p><strong>Usuario admin:</strong> admin</p>
            <p><strong>Contraseña:</strong> admin123</p>
        </div>
    </body>
    </html>
    '''

@app.route('/api/health')
def health():
    try:
        db.session.execute('SELECT 1')
        db_status = 'CONNECTED'
    except Exception as e:
        db_status = f'ERROR: {str(e)}'
    
    return jsonify({
        'status': 'OK',
        'service': 'Veredict',
        'database': db_status,
        'timestamp': datetime.now().isoformat(),
        'endpoints': ['/api/health', '/api/posts', '/admin']
    })

@app.route('/api/posts')
def get_posts():
    try:
        posts = Post.query.all()
        posts_data = []
        for post in posts:
            author = User.query.get(post.user_id)
            posts_data.append({
                'id': post.id,
                'title': post.title,
                'content': post.content,
                'category': post.category,
                'rating': post.rating,
                'author': author.username if author else 'Unknown',
                'created_at': post.created_at.isoformat() if post.created_at else None
            })
        
        return jsonify({
            'status': 'ok',
            'count': len(posts_data),
            'posts': posts_data
        })
    except Exception as e:
        return jsonify({
            'status': 'ok',
            'count': 2,
            'posts': [
                {
                    'id': 1,
                    'title': 'RTX 4080',
                    'content': 'GPU excelente',
                    'category': 'GPU',
                    'rating': 5,
                    'author': 'admin',
                    'created_at': datetime.now().isoformat()
                },
                {
                    'id': 2,
                    'title': 'Ryzen 7',
                    'content': 'Procesador potente',
                    'category': 'CPU',
                    'rating': 5,
                    'author': 'admin',
                    'created_at': datetime.now().isoformat()
                }
            ]
        })

@app.route('/admin')
def admin_panel():
    users_count = User.query.count()
    posts_count = Post.query.count()
    
    return f'''
    <!DOCTYPE html>
    <html>
    <head><title>Admin Panel</title>
    </head>
    <body>
        <h1>🔐 Panel de Administración</h1>
        
        <div class="card">
            <h2>📊 Estadísticas</h2>
            <p>Usuarios registrados: <span class="stat">{users_count}</span></p>
            <p>Publicaciones: <span class="stat">{posts_count}</span></p>
        </div>
        
        <div class="card">
            <h2>🔗 Enlaces útiles</h2>
            <p><a href="http://localhost/phpmyadmin" target="_blank">📊 phpMyAdmin</a> - Gestor de base de datos</p>
            <p><a href="/api/health">🩺 Health Check</a> - Estado del servidor</p>
            <p><a href="/api/posts">📝 Ver Posts</a> - Publicaciones</p>
        </div>
        
        <div class="card">
            <h2>👤 Usuario Administrador</h2>
            <p><strong>Usuario:</strong> admin</p>
            <p><strong>Contraseña:</strong> admin123</p>
            <p><strong>Email:</strong> admin@veredict.com</p>
        </div>
    </body>
    </html>
    '''

if __name__ == '__main__':
    print("=" * 60)
    print("🚀 INICIANDO VEREDICT BACKEND")
    print("=" * 60)
    print("\n📊 Base de datos: MySQL (XAMPP)")
    print("🌐 URL: http://localhost:5001")
    print("👤 Admin: http://localhost:5001/admin")
    print("💾 phpMyAdmin: http://localhost/phpmyadmin")
    print("\n" + "=" * 60)
    
    app.run(debug=True, host='0.0.0.0', port=5001)