from flask import current_app, send_from_directory
from .utils import save_file

# Ruta para servir imágenes
@main_bp.route('/uploads/<path:filename>')
def uploaded_file(filename):
    return send_from_directory(current_app.config['UPLOAD_FOLDER'], filename)

# Crear post con imagen
@main_bp.route('/posts', methods=['POST'])
def create_post():
    user = current_user()
    if not user:
        return jsonify({'error': 'Debes iniciar sesión'}), 401

    data = request.form
    file = request.files.get('image')
    filename = save_file(file, 'posts') if file else None

    post = Post(
        title=data['title'],
        content=data['content'],
        category=data['category'],
        rating=int(data['rating']),
        author=user
    )

    if filename:
        post.image = filename  # Añadir campo image a Post en models.py

    db.session.add(post)
    db.session.commit()
    return jsonify({'message': 'Post creado exitosamente', 'id': post.id, 'image': filename})
