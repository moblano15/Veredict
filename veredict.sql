-- ===========================================
-- BASE DE DATOS VEREDICT - RED SOCIAL DE HARDWARE
-- ===========================================
-- Versión: 1.0
-- Creado: 2025
-- ============================================

-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS veredict_db;
USE veredict_db;

-- ===========================================
-- TABLA: Usuarios
-- ===========================================
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500) DEFAULT 'https://i.pravatar.cc/100',
    bio TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_login TIMESTAMP NULL,
    estado ENUM('activo', 'inactivo', 'suspendido') DEFAULT 'activo',
    rol ENUM('usuario', 'moderador', 'administrador') DEFAULT 'usuario',
    reputacion INT DEFAULT 0,
    total_posts INT DEFAULT 0,
    total_likes_recibidos INT DEFAULT 0,
    total_seguidores INT DEFAULT 0,
    INDEX idx_email (email),
    INDEX idx_fecha_registro (fecha_registro)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- TABLA: Categorías de componentes
-- ===========================================
CREATE TABLE IF NOT EXISTS categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    slug VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    icono VARCHAR(100),
    color_hex VARCHAR(7) DEFAULT '#f4630c',
    orden INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    INDEX idx_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- TABLA: Marcas de componentes
-- ===========================================
CREATE TABLE IF NOT EXISTS marcas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    logo_url VARCHAR(500),
    descripcion TEXT,
    sitio_web VARCHAR(200),
    fecha_fundacion YEAR,
    pais_origen VARCHAR(100),
    INDEX idx_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- TABLA: Componentes
-- ===========================================
CREATE TABLE IF NOT EXISTS componentes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    slug VARCHAR(200) NOT NULL UNIQUE,
    categoria_id INT NOT NULL,
    marca_id INT NOT NULL,
    modelo VARCHAR(100),
    descripcion TEXT,
    especificaciones JSON,
    imagen_url VARCHAR(500),
    precio_estimado DECIMAL(10,2),
    fecha_lanzamiento DATE,
    peso_kg DECIMAL(5,2),
    dimensiones VARCHAR(100),
    consumo_watts INT,
    promedio_valoracion DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE RESTRICT,
    FOREIGN KEY (marca_id) REFERENCES marcas(id) ON DELETE RESTRICT,
    INDEX idx_slug (slug),
    INDEX idx_categoria (categoria_id),
    INDEX idx_marca (marca_id),
    INDEX idx_nombre (nombre),
    FULLTEXT idx_busqueda (nombre, modelo, descripcion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- TABLA: Posts/Opiniones
-- ===========================================
CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    componente_id INT NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    contenido TEXT NOT NULL,
    valoracion INT CHECK (valoracion BETWEEN 1 AND 5),
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    estado ENUM('publicado', 'borrador', 'eliminado') DEFAULT 'publicado',
    total_likes INT DEFAULT 0,
    total_comentarios INT DEFAULT 0,
    total_compartidos INT DEFAULT 0,
    ip_address VARCHAR(45),
    user_agent TEXT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (componente_id) REFERENCES componentes(id) ON DELETE RESTRICT,
    INDEX idx_usuario (usuario_id),
    INDEX idx_componente (componente_id),
    INDEX idx_fecha_publicacion (fecha_publicacion),
    INDEX idx_valoracion (valoracion),
    FULLTEXT idx_busqueda_contenido (titulo, contenido)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- TABLA: Comentarios
-- ===========================================
CREATE TABLE IF NOT EXISTS comentarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    usuario_id INT NOT NULL,
    contenido TEXT NOT NULL,
    fecha_comentario TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    estado ENUM('activo', 'eliminado') DEFAULT 'activo',
    likes INT DEFAULT 0,
    respuesta_id INT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (respuesta_id) REFERENCES comentarios(id) ON DELETE CASCADE,
    INDEX idx_post (post_id),
    INDEX idx_usuario (usuario_id),
    INDEX idx_fecha (fecha_comentario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- TABLA: Likes en posts
-- ===========================================
CREATE TABLE IF NOT EXISTS post_likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    usuario_id INT NOT NULL,
    fecha_like TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo ENUM('like', 'dislike') DEFAULT 'like',
    UNIQUE KEY unique_post_usuario (post_id, usuario_id),
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_post (post_id),
    INDEX idx_usuario (usuario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- TABLA: Likes en comentarios
-- ===========================================
CREATE TABLE IF NOT EXISTS comentario_likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    comentario_id INT NOT NULL,
    usuario_id INT NOT NULL,
    fecha_like TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_comentario_usuario (comentario_id, usuario_id),
    FOREIGN KEY (comentario_id) REFERENCES comentarios(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- TABLA: Seguidores
-- ===========================================
CREATE TABLE IF NOT EXISTS seguidores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    seguidor_id INT NOT NULL,
    seguido_id INT NOT NULL,
    fecha_seguimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notificaciones_activadas BOOLEAN DEFAULT TRUE,
    UNIQUE KEY unique_seguimiento (seguidor_id, seguido_id),
    FOREIGN KEY (seguidor_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (seguido_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_seguidor (seguidor_id),
    INDEX idx_seguido (seguido_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- TABLA: Notificaciones
-- ===========================================
CREATE TABLE IF NOT EXISTS notificaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    tipo ENUM('like_post', 'like_comentario', 'comentario', 'respuesta', 'seguimiento', 'sistema') NOT NULL,
    mensaje TEXT NOT NULL,
    enlace VARCHAR(500),
    leido BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_leido TIMESTAMP NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_usuario (usuario_id),
    INDEX idx_leido (leido),
    INDEX idx_fecha (fecha_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- TABLA: Chat AI (Historial de conversaciones)
-- ===========================================
CREATE TABLE IF NOT EXISTS chat_ai (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NULL,
    session_id VARCHAR(100) NOT NULL,
    mensaje_usuario TEXT NOT NULL,
    mensaje_ai TEXT NOT NULL,
    contexto JSON,
    tokens_usados INT,
    fecha_conversacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    model_used VARCHAR(50) DEFAULT 'gemini-pro',
    ip_address VARCHAR(45),
    INDEX idx_usuario (usuario_id),
    INDEX idx_session (session_id),
    INDEX idx_fecha (fecha_conversacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- TABLA: Configuración de AI
-- ===========================================
CREATE TABLE IF NOT EXISTS ai_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    api_key_encrypted TEXT NOT NULL,
    model_name VARCHAR(50) DEFAULT 'gemini-pro',
    max_tokens INT DEFAULT 300,
    temperature DECIMAL(3,2) DEFAULT 0.7,
    activo BOOLEAN DEFAULT TRUE,
    ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- TABLA: Favoritos de usuarios
-- ===========================================
CREATE TABLE IF NOT EXISTS favoritos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    componente_id INT NOT NULL,
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notas TEXT,
    UNIQUE KEY unique_favorito (usuario_id, componente_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (componente_id) REFERENCES componentes(id) ON DELETE CASCADE,
    INDEX idx_usuario (usuario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- TABLA: Builds de PC (Configuraciones)
-- ===========================================
CREATE TABLE IF NOT EXISTS builds (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    presupuesto DECIMAL(10,2),
    uso_principal ENUM('gaming', 'trabajo', 'streaming', 'edicion', 'oficina', 'otros') DEFAULT 'gaming',
    es_publico BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    total_likes INT DEFAULT 0,
    total_vistas INT DEFAULT 0,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_usuario (usuario_id),
    INDEX idx_fecha (fecha_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- TABLA: Componentes en Builds
-- ===========================================
CREATE TABLE IF NOT EXISTS build_componentes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    build_id INT NOT NULL,
    componente_id INT NOT NULL,
    tipo ENUM('cpu', 'gpu', 'ram', 'motherboard', 'storage', 'psu', 'case', 'cooling', 'otros') NOT NULL,
    precio_pagado DECIMAL(10,2),
    notas TEXT,
    orden INT DEFAULT 0,
    FOREIGN KEY (build_id) REFERENCES builds(id) ON DELETE CASCADE,
    FOREIGN KEY (componente_id) REFERENCES componentes(id) ON DELETE RESTRICT,
    UNIQUE KEY unique_build_componente (build_id, componente_id),
    INDEX idx_build (build_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- TABLA: Logs de actividad
-- ===========================================
CREATE TABLE IF NOT EXISTS actividad_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NULL,
    accion VARCHAR(100) NOT NULL,
    detalles TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    fecha_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_usuario (usuario_id),
    INDEX idx_accion (accion),
    INDEX idx_fecha (fecha_log)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- TABLA: Reportes/Moderación
-- ===========================================
CREATE TABLE IF NOT EXISTS reportes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reportador_id INT NOT NULL,
    tipo ENUM('post', 'comentario', 'usuario', 'componente') NOT NULL,
    elemento_id INT NOT NULL,
    motivo ENUM('spam', 'inapropiado', 'informacion_erronea', 'acoso', 'otros') NOT NULL,
    descripcion TEXT,
    estado ENUM('pendiente', 'revisado', 'resuelto', 'descartado') DEFAULT 'pendiente',
    fecha_reporte TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_resolucion TIMESTAMP NULL,
    moderador_id INT NULL,
    resolucion TEXT,
    FOREIGN KEY (reportador_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (moderador_id) REFERENCES usuarios(id) ON DELETE SET NULL,
    INDEX idx_estado (estado),
    INDEX idx_fecha (fecha_reporte)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- INSERTS INICIALES (DATOS DE EJEMPLO)
-- ===========================================

-- Insertar categorías
INSERT INTO categorias (nombre, slug, descripcion, icono, color_hex, orden) VALUES
('CPU/Procesador', 'cpu', 'Procesadores centrales', '🖥️', '#3498db', 1),
('GPU/Tarjeta Gráfica', 'gpu', 'Tarjetas gráficas', '🎮', '#e74c3c', 2),
('RAM/Memoria', 'ram', 'Memoria RAM', '💾', '#9b59b6', 3),
('Placa Base', 'motherboard', 'Placas madre', '🔌', '#2ecc71', 4),
('Almacenamiento', 'storage', 'Discos duros y SSDs', '💿', '#f39c12', 5),
('Refrigeración', 'cooling', 'Sistemas de refrigeración', '❄️', '#1abc9c', 6),
('Fuente de Alimentación', 'psu', 'Fuentes de poder', '⚡', '#e67e22', 7),
('Caja/Gabinete', 'case', 'Gabinetes para PC', '📦', '#95a5a6', 8);

-- Insertar marcas populares
INSERT INTO marcas (nombre, slug, descripcion, pais_origen) VALUES
('AMD', 'amd', 'Advanced Micro Devices', 'EE.UU.'),
('Intel', 'intel', 'Intel Corporation', 'EE.UU.'),
('NVIDIA', 'nvidia', 'NVIDIA Corporation', 'EE.UU.'),
('ASUS', 'asus', 'ASUSTeK Computer Inc.', 'Taiwán'),
('MSI', 'msi', 'Micro-Star International', 'Taiwán'),
('Gigabyte', 'gigabyte', 'Gigabyte Technology', 'Taiwán'),
('Corsair', 'corsair', 'Corsair Components', 'EE.UU.'),
('Kingston', 'kingston', 'Kingston Technology', 'EE.UU.'),
('Samsung', 'samsung', 'Samsung Electronics', 'Corea del Sur'),
('Seasonic', 'seasonic', 'Seasonic Electronics', 'Taiwán'),
('NZXT', 'nzxt', 'NZXT Inc.', 'EE.UU.'),
('G.Skill', 'gskill', 'G.Skill International', 'Taiwán');

-- Insertar componentes de ejemplo
INSERT INTO componentes (nombre, slug, categoria_id, marca_id, modelo, descripcion, precio_estimado, especificaciones) VALUES
('AMD Ryzen 7 7800X3D', 'amd-ryzen-7-7800x3d', 1, 1, '7800X3D', 'Procesador gaming con tecnología 3D V-Cache', 449.99, '{"nucleos": 8, "hilos": 16, "frecuencia_base": "4.2 GHz", "frecuencia_max": "5.0 GHz", "cache": "96MB", "tdp": "120W", "socket": "AM5"}'),
('Intel Core i9-14900K', 'intel-core-i9-14900k', 1, 2, '14900K', 'Procesador de alto rendimiento para gaming y productividad', 589.99, '{"nucleos": 24, "hilos": 32, "frecuencia_base": "3.2 GHz", "frecuencia_max": "6.0 GHz", "cache": "36MB", "tdp": "125W", "socket": "LGA1700"}'),
('NVIDIA RTX 4090', 'nvidia-rtx-4090', 2, 3, 'RTX 4090', 'Tarjeta gráfica flagship para 4K gaming', 1599.99, '{"vram": "24GB GDDR6X", "bus": "384-bit", "cuda_cores": 16384, "frecuencia": "2235 MHz", "consumo": "450W", "conectores": "3x 8-pin"}'),
('AMD Radeon RX 7900 XTX', 'amd-radeon-rx-7900-xtx', 2, 1, 'RX 7900 XTX', 'Tarjeta gráfica de alta gama AMD', 999.99, '{"vram": "24GB GDDR6", "bus": "384-bit", "stream_processors": 6144, "frecuencia": "2300 MHz", "consumo": "355W", "conectores": "2x 8-pin"}'),
('Corsair Vengeance RGB 32GB', 'corsair-vengeance-rgb-32gb', 3, 7, 'CMH32GX5M2B6000C30', 'Kit de memoria RAM DDR5 RGB', 129.99, '{"capacidad": "32GB", "velocidad": "6000 MHz", "latencia": "CL30", "voltaje": "1.35V", "formato": "DIMM"}'),
('G.Skill Trident Z5 RGB 64GB', 'gskill-trident-z5-rgb-64gb', 3, 12, 'F5-6400J3239G32GX2-TZ5RK', 'Kit de memoria RAM DDR5 de alta velocidad', 249.99, '{"capacidad": "64GB", "velocidad": "6400 MHz", "latencia": "CL32", "voltaje": "1.4V", "formato": "DIMM"}'),
('Samsung 990 Pro 2TB', 'samsung-990-pro-2tb', 5, 9, 'MZ-V9P2T0BW', 'SSD NVMe PCIe 4.0 de alto rendimiento', 179.99, '{"capacidad": "2TB", "interface": "PCIe 4.0", "lectura": "7450 MB/s", "escritura": "6900 MB/s", "formato": "M.2 2280"}'),
('Corsair iCUE H150i Elite', 'corsair-icue-h150i-elite', 6, 7, 'CW-9060061-WW', 'Refrigeración líquida AIO 360mm', 199.99, '{"tamaño": "360mm", "ruido": "10-36 dBA", "rgb": true, "software": "iCUE", "compatibilidad": "Intel/AMD"}'),
('Seasonic Prime TX-1000', 'seasonic-prime-tx-1000', 7, 10, 'PRIME-TX-1000', 'Fuente de alimentación 80 Plus Titanium', 299.99, '{"potencia": "1000W", "certificacion": "80 Plus Titanium", "modular": "Completo", "ventilador": "135mm", "garantia": "12 años"}');

-- Insertar usuario administrador (contraseña: Admin123!)
INSERT INTO usuarios (nombre, email, password_hash, avatar_url, bio, rol, reputacion) VALUES
('Administrador Veredict', 'admin@veredict.com', '$2y$10$YourHashedPasswordHere', 'https://i.pravatar.cc/100?img=60', 'Administrador principal de Veredict', 'administrador', 1000);

-- ===========================================
-- VISTAS ÚTILES
-- ===========================================

-- Vista para posts con información completa
CREATE VIEW vista_posts_completos AS
SELECT 
    p.id,
    p.titulo,
    p.contenido,
    p.valoracion,
    p.fecha_publicacion,
    p.total_likes,
    p.total_comentarios,
    u.nombre AS usuario_nombre,
    u.avatar_url AS usuario_avatar,
    u.reputacion AS usuario_reputacion,
    c.nombre AS componente_nombre,
    c.slug AS componente_slug,
    cat.nombre AS categoria_nombre,
    cat.color_hex AS categoria_color,
    m.nombre AS marca_nombre
FROM posts p
JOIN usuarios u ON p.usuario_id = u.id
JOIN componentes c ON p.componente_id = c.id
JOIN categorias cat ON c.categoria_id = cat.id
JOIN marcas m ON c.marca_id = m.id
WHERE p.estado = 'publicado';

-- Vista para estadísticas de usuarios
CREATE VIEW vista_estadisticas_usuarios AS
SELECT 
    u.id,
    u.nombre,
    u.email,
    u.fecha_registro,
    u.reputacion,
    COUNT(DISTINCT p.id) AS total_posts,
    COUNT(DISTINCT l.id) AS total_likes_dados,
    COALESCE(SUM(p.total_likes), 0) AS total_likes_recibidos,
    COUNT(DISTINCT s.seguido_id) AS total_seguidos,
    COUNT(DISTINCT f.seguidor_id) AS total_seguidores
FROM usuarios u
LEFT JOIN posts p ON u.id = p.usuario_id AND p.estado = 'publicado'
LEFT JOIN post_likes l ON u.id = l.usuario_id
LEFT JOIN seguidores s ON u.id = s.seguidor_id
LEFT JOIN seguidores f ON u.id = f.seguido_id
GROUP BY u.id;

-- Vista para componentes mejor valorados
CREATE VIEW vista_componentes_top AS
SELECT 
    c.id,
    c.nombre,
    c.slug,
    cat.nombre AS categoria,
    m.nombre AS marca,
    COUNT(p.id) AS total_reviews,
    AVG(p.valoracion) AS promedio_valoracion,
    SUM(p.total_likes) AS total_likes
FROM componentes c
JOIN categorias cat ON c.categoria_id = cat.id
JOIN marcas m ON c.marca_id = m.id
LEFT JOIN posts p ON c.id = p.componente_id AND p.estado = 'publicado'
GROUP BY c.id
HAVING total_reviews >= 1
ORDER BY promedio_valoracion DESC;

-- ===========================================
-- PROCEDIMIENTOS ALMACENADOS
-- ===========================================

-- Procedimiento para crear un nuevo post
DELIMITER //
CREATE PROCEDURE crear_post(
    IN p_usuario_id INT,
    IN p_componente_id INT,
    IN p_titulo VARCHAR(200),
    IN p_contenido TEXT,
    IN p_valoracion INT,
    IN p_ip_address VARCHAR(45)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Insertar el post
    INSERT INTO posts (usuario_id, componente_id, titulo, contenido, valoracion, ip_address)
    VALUES (p_usuario_id, p_componente_id, p_titulo, p_contenido, p_valoracion, p_ip_address);
    
    -- Actualizar estadísticas del usuario
    UPDATE usuarios 
    SET total_posts = total_posts + 1 
    WHERE id = p_usuario_id;
    
    -- Actualizar estadísticas del componente
    UPDATE componentes c
    SET 
        total_reviews = total_reviews + 1,
        promedio_valoracion = (
            SELECT AVG(valoracion) 
            FROM posts 
            WHERE componente_id = p_componente_id AND estado = 'publicado'
        )
    WHERE c.id = p_componente_id;
    
    COMMIT;
END //
DELIMITER ;

-- Procedimiento para dar like a un post
DELIMITER //
CREATE PROCEDURE dar_like_post(
    IN p_post_id INT,
    IN p_usuario_id INT
)
BEGIN
    DECLARE v_like_existe INT;
    
    -- Verificar si ya existe el like
    SELECT COUNT(*) INTO v_like_existe 
    FROM post_likes 
    WHERE post_id = p_post_id AND usuario_id = p_usuario_id;
    
    IF v_like_existe = 0 THEN
        -- Insertar like
        INSERT INTO post_likes (post_id, usuario_id) 
        VALUES (p_post_id, p_usuario_id);
        
        -- Actualizar contador en posts
        UPDATE posts 
        SET total_likes = total_likes + 1 
        WHERE id = p_post_id;
        
        -- Actualizar estadísticas del usuario que recibe el like
        UPDATE usuarios u
        JOIN posts p ON p.usuario_id = u.id
        SET u.total_likes_recibidos = u.total_likes_recibidos + 1
        WHERE p.id = p_post_id;
        
        -- Crear notificación
        INSERT INTO notificaciones (usuario_id, tipo, mensaje, enlace)
        SELECT 
            p.usuario_id,
            'like_post',
            CONCAT((SELECT nombre FROM usuarios WHERE id = p_usuario_id), ' le dio like a tu post'),
            CONCAT('/post/', p_post_id)
        FROM posts p
        WHERE p.id = p_post_id AND p.usuario_id != p_usuario_id;
    END IF;
END //
DELIMITER ;

-- Procedimiento para seguir a un usuario
DELIMITER //
CREATE PROCEDURE seguir_usuario(
    IN p_seguidor_id INT,
    IN p_seguido_id INT
)
BEGIN
    DECLARE v_seguimiento_existe INT;
    
    -- Verificar que no sea el mismo usuario
    IF p_seguidor_id = p_seguido_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No puedes seguirte a ti mismo';
    END IF;
    
    -- Verificar si ya existe el seguimiento
    SELECT COUNT(*) INTO v_seguimiento_existe 
    FROM seguidores 
    WHERE seguidor_id = p_seguidor_id AND seguido_id = p_seguido_id;
    
    IF v_seguimiento_existe = 0 THEN
        -- Insertar seguimiento
        INSERT INTO seguidores (seguidor_id, seguido_id) 
        VALUES (p_seguidor_id, p_seguido_id);
        
        -- Actualizar contadores de seguidores
        UPDATE usuarios 
        SET total_seguidores = total_seguidores + 1 
        WHERE id = p_seguido_id;
        
        -- Crear notificación
        INSERT INTO notificaciones (usuario_id, tipo, mensaje, enlace)
        VALUES (
            p_seguido_id,
            'seguimiento',
            CONCAT((SELECT nombre FROM usuarios WHERE id = p_seguidor_id), ' comenzó a seguirte'),
            CONCAT('/perfil/', p_seguidor_id)
        );
    END IF;
END //
DELIMITER ;

-- ===========================================
-- TRIGGERS
-- ===========================================

-- Trigger para actualizar reputación cuando se crea un post
DELIMITER //
CREATE TRIGGER after_post_insert
AFTER INSERT ON posts
FOR EACH ROW
BEGIN
    DECLARE puntos_reputacion INT;
    
    -- Calcular puntos según valoración
    SET puntos_reputacion = CASE 
        WHEN NEW.valoracion = 5 THEN 10
        WHEN NEW.valoracion = 4 THEN 7
        WHEN NEW.valoracion = 3 THEN 5
        WHEN NEW.valoracion = 2 THEN 3
        WHEN NEW.valoracion = 1 THEN 1
        ELSE 5
    END;
    
    -- Actualizar reputación del usuario
    UPDATE usuarios 
    SET reputacion = reputacion + puntos_reputacion
    WHERE id = NEW.usuario_id;
    
    -- Registrar actividad
    INSERT INTO actividad_logs (usuario_id, accion, detalles)
    VALUES (NEW.usuario_id, 'post_creado', CONCAT('Post ID: ', NEW.id));
END //
DELIMITER ;

-- Trigger para cuando se elimina un post
DELIMITER //
CREATE TRIGGER before_post_delete
BEFORE DELETE ON posts
FOR EACH ROW
BEGIN
    -- Actualizar contador de posts del usuario
    UPDATE usuarios 
    SET total_posts = total_posts - 1 
    WHERE id = OLD.usuario_id;
    
    -- Actualizar estadísticas del componente
    UPDATE componentes c
    SET 
        total_reviews = GREATEST(0, total_reviews - 1),
        promedio_valoracion = (
            SELECT COALESCE(AVG(valoracion), 0)
            FROM posts 
            WHERE componente_id = OLD.componente_id 
            AND estado = 'publicado'
            AND id != OLD.id
        )
    WHERE c.id = OLD.componente_id;
END //
DELIMITER ;

-- Trigger para cuando se recibe un like
DELIMITER //
CREATE TRIGGER after_like_insert
AFTER INSERT ON post_likes
FOR EACH ROW
BEGIN
    -- Actualizar reputación del usuario dueño del post
    UPDATE usuarios u
    JOIN posts p ON p.usuario_id = u.id
    SET u.reputacion = u.reputacion + 2
    WHERE p.id = NEW.post_id;
    
    -- Registrar actividad
    INSERT INTO actividad_logs (usuario_id, accion, detalles)
    VALUES (NEW.usuario_id, 'like_dado', CONCAT('Post ID: ', NEW.post_id));
END //
DELIMITER ;

-- ===========================================
-- FUNCIONES
-- ===========================================

-- Función para calcular edad de un post en días
DELIMITER //
CREATE FUNCTION edad_post_dias(post_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE edad INT;
    SELECT DATEDIFF(NOW(), fecha_publicacion) INTO edad
    FROM posts WHERE id = post_id;
    RETURN edad;
END //
DELIMITER ;

-- Función para obtener nivel de usuario basado en reputación
DELIMITER //
CREATE FUNCTION nivel_usuario(reputacion INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    RETURN CASE
        WHEN reputacion >= 10000 THEN 'Leyenda'
        WHEN reputacion >= 5000 THEN 'Experto'
        WHEN reputacion >= 1000 THEN 'Avanzado'
        WHEN reputacion >= 500 THEN 'Intermedio'
        WHEN reputacion >= 100 THEN 'Principiante'
        ELSE 'Novato'
    END;
END //
DELIMITER ;
