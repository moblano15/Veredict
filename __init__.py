# app/__init__.py
from flask import Flask
from ..app.config import Config
from .database import db
from ..app.auth import auth_bp
from ..app.routes import main_bp

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    # Inicializar la base de datos
    db.init_app(app)

    # Registrar Blueprints
    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(main_bp, url_prefix='/api')

    with app.app_context():
        db.create_all()  # Crear tablas si no existen

    return app
