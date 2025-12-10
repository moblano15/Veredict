# run.py
from app import create_app
import os

# Crear carpeta uploads si no existe
os.makedirs(os.path.join(os.path.dirname(__file__), 'uploads/avatars'), exist_ok=True)
os.makedirs(os.path.join(os.path.dirname(__file__), 'uploads/posts'), exist_ok=True)

app = create_app()

if __name__ == '__main__':
    # Debug True para recarga automática al cambiar código
    app.run(debug=True, host='0.0.0.0', port=5000)
