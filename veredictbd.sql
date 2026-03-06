-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS veredict_db;
USE veredict_db;

-- =============================================
-- TABLA DE USUARIOS
-- =============================================
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    avatar VARCHAR(255),
    bio TEXT,
    posts INT DEFAULT 0,
    likes_recibidos INT DEFAULT 0,
    seguidores INT DEFAULT 0,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP NULL,
    activo BOOLEAN DEFAULT TRUE,
    rol ENUM('usuario', 'moderador', 'admin') DEFAULT 'usuario'
);

-- =============================================
-- TABLA DE CATEGORÍAS
-- =============================================
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255),
    icono VARCHAR(50)
);

-- Insertar categorías principales
INSERT INTO categorias (nombre, descripcion, icono) VALUES
('cpu', 'Procesadores y CPUs', 'cpu'),
('gpu', 'Tarjetas gráficas', 'gpu'),
('ram', 'Memoria RAM', 'ram'),
('motherboard', 'Placas base', 'motherboard'),
('storage', 'Almacenamiento', 'storage'),
('refrigeracion', 'Refrigeración', 'cooling'),
('alimentacion', 'Fuentes de alimentación', 'psu'),
('case', 'Cajas y gabinetes', 'case');

-- =============================================
-- TABLA DE PUBLICACIONES (OPINIONES)
-- =============================================
CREATE TABLE publicaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    componente VARCHAR(200) NOT NULL,
    categoria_id INT NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    contenido TEXT NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    likes INT DEFAULT 0,
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE CASCADE,
    INDEX idx_usuario (usuario_id),
    INDEX idx_categoria (categoria_id),
    FULLTEXT INDEX idx_busqueda (titulo, contenido, componente)
);

-- =============================================
-- TABLA DE COMENTARIOS
-- =============================================
CREATE TABLE comentarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    publicacion_id INT NOT NULL,
    usuario_id INT NOT NULL,
    contenido TEXT NOT NULL,
    fecha_comentario TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (publicacion_id) REFERENCES publicaciones(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_publicacion (publicacion_id)
);

-- =============================================
-- TABLA DE LIKES
-- =============================================
CREATE TABLE likes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    publicacion_id INT NOT NULL,
    usuario_id INT NOT NULL,
    fecha_like TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (publicacion_id) REFERENCES publicaciones(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    UNIQUE KEY unique_like (publicacion_id, usuario_id)
);

-- =============================================
-- TABLA DE SEGUIDORES
-- =============================================
CREATE TABLE seguidores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    seguidor_id INT NOT NULL,
    seguido_id INT NOT NULL,
    fecha_seguimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (seguidor_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (seguido_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    UNIQUE KEY unique_seguimiento (seguidor_id, seguido_id),
    CHECK (seguidor_id != seguido_id)
);

-- =============================================
-- TABLA DE PRODUCTOS (TIENDA)
-- =============================================
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    categoria_id INT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    descripcion TEXT,
    imagen VARCHAR(500),
    stock INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE CASCADE,
    INDEX idx_categoria_producto (categoria_id)
);

-- =============================================
-- TABLA DE ENLACES DE COMPRA
-- =============================================
CREATE TABLE enlaces_compra (
    id INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT NOT NULL,
    tienda VARCHAR(100) NOT NULL,
    url VARCHAR(500) NOT NULL,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE
);

-- =============================================
-- TABLA DE VALORACIONES DE PRODUCTOS
-- =============================================
CREATE TABLE valoraciones_productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT NOT NULL,
    usuario_id INT NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comentario TEXT,
    fecha_valoracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    UNIQUE KEY unique_valoracion (producto_id, usuario_id)
);

-- =============================================
-- TABLA DE CARRITO DE COMPRAS
-- =============================================
CREATE TABLE carrito (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT DEFAULT 1,
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
    UNIQUE KEY unique_carrito (usuario_id, producto_id)
);

-- =============================================
-- TABLA DE PEDIDOS
-- =============================================
CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    numero_pedido VARCHAR(20) UNIQUE NOT NULL,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10, 2) NOT NULL,
    envio DECIMAL(10, 2) DEFAULT 9.99,
    impuestos DECIMAL(10, 2) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    direccion_envio TEXT NOT NULL,
    metodo_pago ENUM('tarjeta', 'paypal', 'transferencia') NOT NULL,
    estado ENUM('pendiente', 'procesando', 'enviado', 'entregado', 'cancelado') DEFAULT 'pendiente',
    notas TEXT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_numero_pedido (numero_pedido)
);

-- =============================================
-- TABLA DE DETALLES DE PEDIDO
-- =============================================
CREATE TABLE detalles_pedido (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE
);

-- =============================================
-- TABLA DE NOTIFICACIONES
-- =============================================
CREATE TABLE notificaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    tipo ENUM('like', 'comentario', 'seguidor', 'sistema') NOT NULL,
    mensaje TEXT NOT NULL,
    leido BOOLEAN DEFAULT FALSE,
    fecha_notificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_usuario_notificacion (usuario_id, leido)
);

-- =============================================
-- INSERTAR DATOS DE EJEMPLO
-- =============================================

-- Usuarios de ejemplo
INSERT INTO usuarios (nombre, email, password, avatar, bio, posts, likes_recibidos, seguidores) VALUES
('Carlos Rodríguez', 'carlos@veredict.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'https://i.pravatar.cc/150?img=1', 'Entusiasta del hardware y gaming', 3, 45, 342),
('Ana Martínez', 'ana@veredict.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'https://i.pravatar.cc/150?img=2', 'Reviewer de componentes PC', 2, 32, 527),
('Miguel Torres', 'miguel@veredict.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'https://i.pravatar.cc/150?img=3', 'Gamer y streamer', 1, 28, 156);

-- Publicaciones de ejemplo
INSERT INTO publicaciones (usuario_id, componente, categoria_id, titulo, contenido, rating, likes) VALUES
(1, 'AMD Ryzen 7 7800X3D', 1, 'AMD Ryzen 7 7800X3D - Bestia para gaming', 'Increíble procesador para gaming. La tecnología 3D V-Cache hace maravillas en juegos que dependen mucho de la caché.', 5, 45),
(1, 'Intel Core i9-14900K', 1, 'Intel Core i9-14900K - Potencia extrema', 'Rendimiento brutal en aplicaciones de productividad y gaming. Necesita refrigeración líquida de alta gama.', 4, 32),
(2, 'NVIDIA RTX 4090', 2, 'NVIDIA RTX 4090 - Monstruo de rendimiento', 'La mejor tarjeta gráfica del mercado. Maneja cualquier juego en 4K con tasas de refresco altísimas.', 5, 67);

-- Comentarios de ejemplo
INSERT INTO comentarios (publicacion_id, usuario_id, contenido) VALUES
(1, 2, '¡Totalmente de acuerdo! Lo tengo desde hace 2 meses y es increíble para gaming.'),
(1, 3, '¿Qué refrigerador estás usando? Estoy pensando en comprarlo.'),
(3, 2, '¡Envidia sana! ¿Qué fuente de alimentación usas?');

-- Likes de ejemplo
INSERT INTO likes (publicacion_id, usuario_id) VALUES
(1, 2), (1, 3), (2, 1), (3, 1), (3, 2);

-- Productos de ejemplo
INSERT INTO productos (nombre, categoria_id, precio, descripcion, imagen, stock) VALUES
('AMD Ryzen 7 7800X3D', 1, 338.25, 'Procesador para gaming con tecnología 3D V-Cache, 8 núcleos, 16 hilos', 'https://www.coolmod.com/images/product/large/PROD-032811_1.jpg', 50),
('Intel Core i9-14900K', 1, 460.90, 'Procesador de alto rendimiento para gaming y productividad, 24 núcleos', 'https://m.media-amazon.com/images/I/61qV6qUYqpL.jpg', 30),
('NVIDIA RTX 4090', 2, 2399.00, 'Tarjeta gráfica más potente del mercado para gaming 4K y Ray Tracing', 'https://thumb.pccomponentes.com/w-530-530/articles/1058/10589923/1624-gigabyte-geforce-rtx-4090-gaming-oc-24gb-gddr6x.jpg', 15),
('Corsair Vengeance RGB 32GB 6000MHz', 3, 469.80, 'Memoria RAM DDR5 con iluminación RGB, CL30, optimizada para AMD', 'https://assets.corsair.com/image/upload/c_pad,q_auto,h_1024,w_1024,f_auto/products/Memory/vengeance-rgb-amd-ddr5-blk-config/Gallery/Vengeance-RGB-DDR5-2UP-32GB-GRAY_03.webp', 100);

-- Enlaces de compra
INSERT INTO enlaces_compra (producto_id, tienda, url) VALUES
(1, 'Amazon', 'https://www.amazon.com/AMD-Ryzen-7800X3D-procesador-escritorio/dp/B0BTZB7F88/'),
(1, 'Newegg', 'https://www.newegg.com/amd-ryzen-7-7800x3d-ryzen-7-7000-series/p/N82E16819113793'),
(2, 'Amazon', 'https://www.amazon.es/Intel-BX8071514900K-Core-i9-14900K/dp/B0CHBJGFBC/'),
(2, 'Newegg', 'https://www.newegg.com/intel-core-i9-14th-gen-core-i9-14900k/p/N82E16819118462');

-- =============================================
-- VISTAS ÚTILES
-- =============================================

-- Vista de publicaciones con información completa
CREATE VIEW v_publicaciones_completas AS
SELECT 
    p.id,
    p.componente,
    p.titulo,
    p.contenido,
    p.rating,
    p.likes,
    p.fecha_publicacion,
    u.id as usuario_id,
    u.nombre as usuario_nombre,
    u.avatar as usuario_avatar,
    c.id as categoria_id,
    c.nombre as categoria_nombre,
    (SELECT COUNT(*) FROM comentarios WHERE publicacion_id = p.id) as total_comentarios
FROM publicaciones p
JOIN usuarios u ON p.usuario_id = u.id
JOIN categorias c ON p.categoria_id = c.id
WHERE p.activo = TRUE;

-- Vista de productos con valoración promedio
CREATE VIEW v_productos_con_valoracion AS
SELECT 
    p.*,
    c.nombre as categoria_nombre,
    COALESCE(AVG(v.rating), 0) as rating_promedio,
    COUNT(DISTINCT v.id) as total_valoraciones
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN valoraciones_productos v ON p.id = v.producto_id
WHERE p.activo = TRUE
GROUP BY p.id;

-- =============================================
-- PROCEDIMIENTOS ALMACENADOS
-- =============================================

-- Procedimiento para dar like a una publicación
DELIMITER //
CREATE PROCEDURE sp_dar_like(
    IN p_publicacion_id INT,
    IN p_usuario_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Insertar el like
    INSERT INTO likes (publicacion_id, usuario_id) 
    VALUES (p_publicacion_id, p_usuario_id);
    
    -- Actualizar contador de likes en la publicación
    UPDATE publicaciones 
    SET likes = likes + 1 
    WHERE id = p_publicacion_id;
    
    -- Actualizar contador de likes recibidos del usuario
    UPDATE usuarios u
    JOIN publicaciones p ON p.usuario_id = u.id
    SET u.likes_recibidos = u.likes_recibidos + 1
    WHERE p.id = p_publicacion_id;
    
    COMMIT;
END //
DELIMITER ;

-- Procedimiento para quitar like
DELIMITER //
CREATE PROCEDURE sp_quitar_like(
    IN p_publicacion_id INT,
    IN p_usuario_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Eliminar el like
    DELETE FROM likes 
    WHERE publicacion_id = p_publicacion_id 
    AND usuario_id = p_usuario_id;
    
    -- Actualizar contador de likes en la publicación
    UPDATE publicaciones 
    SET likes = likes - 1 
    WHERE id = p_publicacion_id;
    
    -- Actualizar contador de likes recibidos del usuario
    UPDATE usuarios u
    JOIN publicaciones p ON p.usuario_id = u.id
    SET u.likes_recibidos = u.likes_recibidos - 1
    WHERE p.id = p_publicacion_id;
    
    COMMIT;
END //
DELIMITER ;

-- =============================================
-- TRIGGERS
-- =============================================

-- Trigger para actualizar contador de posts al crear publicación
DELIMITER //
CREATE TRIGGER after_publicacion_insert
AFTER INSERT ON publicaciones
FOR EACH ROW
BEGIN
    UPDATE usuarios 
    SET posts = posts + 1 
    WHERE id = NEW.usuario_id;
END //
DELIMITER ;

-- Trigger para crear notificación al recibir like
DELIMITER //
CREATE TRIGGER after_like_insert
AFTER INSERT ON likes
FOR EACH ROW
BEGIN
    DECLARE v_autor_id INT;
    DECLARE v_autor_nombre VARCHAR(100);
    
    -- Obtener el autor de la publicación
    SELECT usuario_id INTO v_autor_id 
    FROM publicaciones 
    WHERE id = NEW.publicacion_id;
    
    -- Obtener nombre de quien dio like
    SELECT nombre INTO v_autor_nombre 
    FROM usuarios 
    WHERE id = NEW.usuario_id;
    
    -- Crear notificación si no es el mismo usuario
    IF v_autor_id != NEW.usuario_id THEN
        INSERT INTO notificaciones (usuario_id, tipo, mensaje)
        VALUES (v_autor_id, 'like', CONCAT(v_autor_nombre, ' le ha dado like a tu publicación'));
    END IF;
END //
DELIMITER ;
