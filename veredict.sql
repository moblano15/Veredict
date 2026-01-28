-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS veredict_db;
USE veredict_db;

-- Tabla de usuarios
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    avatar VARCHAR(255) DEFAULT 'https://i.pravatar.cc/40?img=1',
    bio TEXT,
    posts INT DEFAULT 0,
    likes_recibidos INT DEFAULT 0,
    seguidores INT DEFAULT 0,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de categorías
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT
);

-- Insertar categorías por defecto
INSERT INTO categorias (nombre, descripcion) VALUES
('cpu', 'Procesadores (CPU)'),
('gpu', 'Tarjetas Gráficas (GPU)'),
('ram', 'Memoria RAM'),
('refrigeracion', 'Refrigeración Líquida'),
('alimentacion', 'Fuente de Alimentación'),
('motherboard', 'Placa Base'),
('storage', 'Almacenamiento'),
('cooling', 'Refrigeración'),
('psu', 'Fuente de Alimentación'),
('case', 'Caja/Gabinete');

-- Tabla de publicaciones
CREATE TABLE publicaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    categoria_id INT NOT NULL,
    componente VARCHAR(100) NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    contenido TEXT NOT NULL,
    valoracion INT CHECK (valoracion >= 1 AND valoracion <= 5),
    likes INT DEFAULT 0,
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE CASCADE
);

-- Tabla de comentarios
CREATE TABLE comentarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    publicacion_id INT NOT NULL,
    usuario_id INT NOT NULL,
    contenido TEXT NOT NULL,
    fecha_comentario TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (publicacion_id) REFERENCES publicaciones(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Tabla de likes (para controlar que un usuario solo pueda dar like una vez)
CREATE TABLE likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    publicacion_id INT NOT NULL,
    usuario_id INT NOT NULL,
    fecha_like TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_like (publicacion_id, usuario_id),
    FOREIGN KEY (publicacion_id) REFERENCES publicaciones(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Tabla de seguidores
CREATE TABLE seguidores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    seguidor_id INT NOT NULL, -- el que sigue
    seguido_id INT NOT NULL, -- el que es seguido
    fecha_seguimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_seguimiento (seguidor_id, seguido_id),
    FOREIGN KEY (seguidor_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (seguido_id) REFERENCES usuarios(id) ON DELETE CASCADE
);
