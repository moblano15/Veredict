from .utils import save_file

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.form
    file = request.files.get('avatar')
    filename = save_file(file, 'avatars') if file else 'default-avatar.png'

    if User.query.filter_by(username=data['username']).first():
        return jsonify({'error': 'Usuario ya existe'}), 400

    user = User(username=data['username'], email=data['email'], avatar=filename)
    user.set_password(data['password'])
    db.session.add(user)
    db.session.commit()
    return jsonify({'message': 'Usuario registrado exitosamente', 'avatar': filename})
