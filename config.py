# config.py
import os

class Config:
    # MySQL para XAMPP (puerto 3306, sin contraseña por defecto)
    SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://root:@localhost/veredict_db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SECRET_KEY = 'clave-secreta-veredict-2024'
    
    # Carpetas de uploads
    UPLOAD_FOLDER = 'uploads'
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}