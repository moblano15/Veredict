-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS veredict_db;
USE veredict_db;

-- Tabla de usuarios
CREATE TABLE usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre_completo VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    avatar VARCHAR(255) DEFAULT 'default_avatar.png',
    biografia TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultima_conexion TIMESTAMP NULL,
    estado ENUM('activo', 'inactivo', 'suspendido') DEFAULT 'activo',
    rol ENUM('usuario', 'moderador', 'administrador') DEFAULT 'usuario',
    token_verificacion VARCHAR(100),
    email_verificado BOOLEAN DEFAULT FALSE,
    INDEX idx_email (email),
    INDEX idx_fecha_registro (fecha_registro)
);

-- Tabla de categorías de componentes
CREATE TABLE categorias (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    icono VARCHAR(50),
    color VARCHAR(20) DEFAULT '#f4630c',
    orden INT DEFAULT 0,
    activa BOOLEAN DEFAULT TRUE,
    UNIQUE KEY uk_nombre (nombre)
);

-- Tabla de fabricantes
CREATE TABLE fabricantes (
    id_fabricante INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    logo VARCHAR(255),
    descripcion TEXT,
    sitio_web VARCHAR(255),
    pais VARCHAR(50),
    UNIQUE KEY uk_nombre (nombre)
);

-- Tabla de componentes
CREATE TABLE componentes (
    id_componente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    modelo VARCHAR(100),
    id_categoria INT NOT NULL,
    id_fabricante INT,
    especificaciones JSON,
    fecha_lanzamiento DATE,
    precio_estimado DECIMAL(10,2),
    imagen_principal VARCHAR(255),
    promedio_valoracion DECIMAL(3,2) DEFAULT 0.00,
    total_valoraciones INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
    FOREIGN KEY (id_fabricante) REFERENCES fabricantes(id_fabricante),
    INDEX idx_nombre (nombre),
    INDEX idx_categoria (id_categoria),
    INDEX idx_fabricante (id_fabricante)
);

-- Tabla de opiniones (reviews)
CREATE TABLE opiniones (
    id_opinion INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_componente INT NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    contenido TEXT NOT NULL,
    valoracion INT NOT NULL CHECK (valoracion BETWEEN 1 AND 5),
    pros TEXT,
    contras TEXT,
    uso_principal ENUM('gaming', 'trabajo', 'estudio', 'multimedia', 'mixto', 'otro') DEFAULT 'mixto',
    tiempo_uso_meses INT,
    recomendado BOOLEAN DEFAULT TRUE,
    likes INT DEFAULT 0,
    compartidos INT DEFAULT 0,
    estado ENUM('publicado', 'pendiente', 'eliminado') DEFAULT 'publicado',
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_componente) REFERENCES componentes(id_componente),
    INDEX idx_usuario (id_usuario),
    INDEX idx_componente (id_componente),
    INDEX idx_valoracion (valoracion),
    INDEX idx_fecha_publicacion (fecha_publicacion)
);

-- Tabla de comentarios en opiniones
CREATE TABLE comentarios (
    id_comentario INT PRIMARY KEY AUTO_INCREMENT,
    id_opinion INT NOT NULL,
    id_usuario INT NOT NULL,
    contenido TEXT NOT NULL,
    respuesta_a INT NULL,
    likes INT DEFAULT 0,
    estado ENUM('activo', 'eliminado') DEFAULT 'activo',
    fecha_comentario TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_opinion) REFERENCES opiniones(id_opinion),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (respuesta_a) REFERENCES comentarios(id_comentario),
    INDEX idx_opinion (id_opinion),
    INDEX idx_usuario (id_usuario),
    INDEX idx_fecha (fecha_comentario)
);

-- Tabla de likes en opiniones
CREATE TABLE likes_opiniones (
    id_like INT PRIMARY KEY AUTO_INCREMENT,
    id_opinion INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_like TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_opinion) REFERENCES opiniones(id_opinion),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    UNIQUE KEY uk_opinion_usuario (id_opinion, id_usuario),
    INDEX idx_usuario (id_usuario)
);

-- Tabla de likes en comentarios
CREATE TABLE likes_comentarios (
    id_like INT PRIMARY KEY AUTO_INCREMENT,
    id_comentario INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_like TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_comentario) REFERENCES comentarios(id_comentario),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    UNIQUE KEY uk_comentario_usuario (id_comentario, id_usuario)
);

-- Tabla de seguimientos (usuarios que siguen a otros usuarios)
CREATE TABLE seguimientos (
    id_seguimiento INT PRIMARY KEY AUTO_INCREMENT,
    id_seguidor INT NOT NULL,
    id_seguido INT NOT NULL,
    fecha_seguimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_seguidor) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_seguido) REFERENCES usuarios(id_usuario),
    UNIQUE KEY uk_seguidor_seguido (id_seguidor, id_seguido),
    INDEX idx_seguidor (id_seguidor),
    INDEX idx_seguido (id_seguido)
);

-- Tabla de favoritos (componentes favoritos de usuarios)
CREATE TABLE favoritos (
    id_favorito INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_componente INT NOT NULL,
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    nota TEXT,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_componente) REFERENCES componentes(id_componente),
    UNIQUE KEY uk_usuario_componente (id_usuario, id_componente),
    INDEX idx_usuario (id_usuario)
);

-- Tabla de búsquedas recientes
CREATE TABLE busquedas_recientes (
    id_busqueda INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    termino_busqueda VARCHAR(255) NOT NULL,
    categoria VARCHAR(50),
    resultados INT DEFAULT 0,
    fecha_busqueda TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    INDEX idx_usuario_fecha (id_usuario, fecha_busqueda)
);

-- Tabla de notificaciones
CREATE TABLE notificaciones (
    id_notificacion INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    tipo ENUM('like_opinion', 'like_comentario', 'comentario', 'respuesta', 'seguimiento', 'sistema') NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    contenido TEXT,
    id_referencia INT, -- Puede ser id_opinion, id_comentario, etc.
    leida BOOLEAN DEFAULT FALSE,
    fecha_notificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    INDEX idx_usuario_leida (id_usuario, leida),
    INDEX idx_fecha (fecha_notificacion)
);

-- Tabla de conversaciones de chat (para el chatbox con AI)
CREATE TABLE conversaciones_ai (
    id_conversacion INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    titulo VARCHAR(200),
    ultimo_mensaje TEXT,
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_ultimo_mensaje TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    INDEX idx_usuario_fecha (id_usuario, fecha_ultimo_mensaje)
);

-- Tabla de mensajes del chat AI
CREATE TABLE mensajes_ai (
    id_mensaje INT PRIMARY KEY AUTO_INCREMENT,
    id_conversacion INT NOT NULL,
    tipo ENUM('usuario', 'ai') NOT NULL,
    contenido TEXT NOT NULL,
    metadata JSON, -- Para almacenar información adicional como componentes mencionados
    fecha_mensaje TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_conversacion) REFERENCES conversaciones_ai(id_conversacion),
    INDEX idx_conversacion_fecha (id_conversacion, fecha_mensaje)
);

-- Tabla de reportes/moderation
CREATE TABLE reportes (
    id_reporte INT PRIMARY KEY AUTO_INCREMENT,
    tipo_recurso ENUM('opinion', 'comentario', 'usuario') NOT NULL,
    id_recurso INT NOT NULL, -- ID de la opinión, comentario o usuario reportado
    id_usuario_reportero INT NOT NULL,
    motivo ENUM('spam', 'contenido_ofensivo', 'informacion_falsa', 'acoso', 'contenido_ilegal', 'otro') NOT NULL,
    descripcion TEXT,
    estado ENUM('pendiente', 'revisado', 'resuelto', 'desestimado') DEFAULT 'pendiente',
    fecha_reporte TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_resolucion TIMESTAMP NULL,
    id_moderador INT NULL,
    accion_tomada TEXT,
    FOREIGN KEY (id_usuario_reportero) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_moderador) REFERENCES usuarios(id_usuario),
    INDEX idx_estado (estado),
    INDEX idx_fecha_reporte (fecha_reporte)
);

-- Tabla de estadísticas diarias
CREATE TABLE estadisticas_diarias (
    id_estadistica INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE NOT NULL,
    total_opiniones INT DEFAULT 0,
    total_comentarios INT DEFAULT 0,
    total_usuarios INT DEFAULT 0,
    total_likes INT DEFAULT 0,
    componentes_populares JSON, -- IDs de componentes más valorados
    usuarios_activos JSON, -- IDs de usuarios más activos
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_fecha (fecha)
);

-- Tabla de sesiones de usuario
CREATE TABLE sesiones_usuario (
    id_sesion VARCHAR(100) PRIMARY KEY,
    id_usuario INT NOT NULL,
    token_acceso VARCHAR(255) NOT NULL,
    token_refresh VARCHAR(255),
    dispositivo VARCHAR(100),
    navegador VARCHAR(100),
    ip_address VARCHAR(45),
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP,
    activa BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    INDEX idx_usuario_activa (id_usuario, activa),
    INDEX idx_token (token_acceso)
);

-- Insertar categorías iniciales
INSERT INTO categorias (nombre, descripcion, icono, color, orden) VALUES
('CPU', 'Procesadores (Unidades Centrales de Procesamiento)', 'cpu', '#3498db', 1),
('GPU', 'Tarjetas Gráficas (Unidades de Procesamiento Gráfico)', 'gpu', '#e74c3c', 2),
('RAM', 'Memoria RAM (Memoria de Acceso Aleatorio)', 'ram', '#2ecc71', 3),
('Almacenamiento', 'SSD, HDD, M.2 y otras unidades de almacenamiento', 'storage', '#f39c12', 4),
('Placa Base', 'Motherboards y placas base', 'motherboard', '#9b59b6', 5),
('Fuente de Alimentación', 'Fuentes de poder y PSU', 'psu', '#1abc9c', 6),
('Refrigeración', 'Sistemas de refrigeración líquida y aire', 'cooling', '#34495e', 7),
('Caja/Gabinete', 'Gabinetes y carcasas para PC', 'case', '#7f8c8d', 8),
('Monitor', 'Monitores y pantallas', 'monitor', '#d35400', 9),
('Periféricos', 'Teclados, ratones, auriculares', 'peripherals', '#16a085', 10);

-- Insertar fabricantes populares
INSERT INTO fabricantes (nombre, pais, descripcion) VALUES
('Intel', 'USA', 'Fabricante líder de procesadores y tecnologías de computación'),
('AMD', 'USA', 'Fabricante de procesadores y tarjetas gráficas'),
('NVIDIA', 'USA', 'Fabricante líder de GPUs y tecnologías de IA'),
('ASUS', 'Taiwán', 'Fabricante de placas base, tarjetas gráficas y componentes'),
('MSI', 'Taiwán', 'Fabricante de componentes gaming y placas base'),
('Gigabyte', 'Taiwán', 'Fabricante de componentes y placas base'),
('Corsair', 'USA', 'Fabricante de memorias, fuentes y periféricos gaming'),
('G.Skill', 'Taiwán', 'Fabricante especializado en memoria RAM de alto rendimiento'),
('Samsung', 'Corea del Sur', 'Fabricante de SSDs y componentes de almacenamiento'),
('Seasonic', 'Taiwán', 'Fabricante de fuentes de alimentación de alta calidad'),
('Noctua', 'Austria', 'Fabricante de sistemas de refrigeración por aire'),
('NZXT', 'USA', 'Fabricante de gabinetes y refrigeración líquida'),
('Western Digital', 'USA', 'Fabricante de unidades de almacenamiento'),
('Crucial', 'USA', 'Fabricante de memorias y SSDs'),
('EVGA', 'USA', 'Fabricante de tarjetas gráficas y fuentes de alimentación');

-- Crear usuario admin por defecto (contraseña: Admin123!)
INSERT INTO usuarios (nombre_completo, email, contrasena, avatar, biografia, rol) VALUES
('Administrador Veredict', 'admin@veredict.com', '$2y$10$YourHashedPasswordHere', 'admin_avatar.png', 'Administrador principal de la plataforma Veredict', 'administrador');

-- Crear vistas útiles
CREATE VIEW vista_opiniones_detalladas AS
SELECT 
    o.id_opinion,
    o.titulo,
    o.contenido,
    o.valoracion,
    o.likes,
    o.fecha_publicacion,
    u.id_usuario,
    u.nombre_completo,
    u.avatar as avatar_usuario,
    c.id_componente,
    c.nombre as nombre_componente,
    cat.nombre as categoria,
    fab.nombre as fabricante
FROM opiniones o
JOIN usuarios u ON o.id_usuario = u.id_usuario
JOIN componentes c ON o.id_componente = c.id_componente
JOIN categorias cat ON c.id_categoria = cat.id_categoria
LEFT JOIN fabricantes fab ON c.id_fabricante = fab.id_fabricante
WHERE o.estado = 'publicado';

CREATE VIEW vista_componentes_populares AS
SELECT 
    c.id_componente,
    c.nombre,
    c.modelo,
    cat.nombre as categoria,
    fab.nombre as fabricante,
    c.promedio_valoracion,
    c.total_valoraciones,
    COUNT(o.id_opinion) as total_opiniones,
    SUM(o.likes) as total_likes
FROM componentes c
JOIN categorias cat ON c.id_categoria = cat.id_categoria
LEFT JOIN fabricantes fab ON c.id_fabricante = fab.id_fabricante
LEFT JOIN opiniones o ON c.id_componente = o.id_componente
WHERE c.activo = TRUE AND o.estado = 'publicado'
GROUP BY c.id_componente
ORDER BY c.promedio_valoracion DESC, total_opiniones DESC;

-- Triggers para mantener estadísticas actualizadas
DELIMITER $$

CREATE TRIGGER after_opinion_insert
AFTER INSERT ON opiniones
FOR EACH ROW
BEGIN
    -- Actualizar promedio de valoración del componente
    UPDATE componentes 
    SET 
        promedio_valoracion = (
            SELECT AVG(valoracion) 
            FROM opiniones 
            WHERE id_componente = NEW.id_componente 
            AND estado = 'publicado'
        ),
        total_valoraciones = (
            SELECT COUNT(*) 
            FROM opiniones 
            WHERE id_componente = NEW.id_componente 
            AND estado = 'publicado'
        )
    WHERE id_componente = NEW.id_componente;
    
    -- Incrementar contador de opiniones del usuario
    UPDATE usuarios 
    SET biografia = JSON_SET(
        IFNULL(biografia, '{}'), 
        '$.total_opiniones', 
        COALESCE(JSON_EXTRACT(biografia, '$.total_opiniones'), 0) + 1
    )
    WHERE id_usuario = NEW.id_usuario;
END$$

CREATE TRIGGER after_like_opinion_insert
AFTER INSERT ON likes_opiniones
FOR EACH ROW
BEGIN
    -- Incrementar contador de likes en la opinión
    UPDATE opiniones 
    SET likes = likes + 1 
    WHERE id_opinion = NEW.id_opinion;
    
    -- Crear notificación para el dueño de la opinión
    INSERT INTO notificaciones (id_usuario, tipo, titulo, contenido, id_referencia)
    SELECT 
        o.id_usuario,
        'like_opinion',
        'Nuevo like en tu opinión',
        CONCAT('A ', u.nombre_completo, ' le gustó tu opinión sobre ', c.nombre),
        NEW.id_opinion
    FROM opiniones o
    JOIN usuarios u ON NEW.id_usuario = u.id_usuario
    JOIN componentes c ON o.id_componente = c.id_componente
    WHERE o.id_opinion = NEW.id_opinion;
END$$

CREATE TRIGGER after_comentario_insert
AFTER INSERT ON comentarios
FOR EACH ROW
BEGIN
    -- Crear notificación para el dueño de la opinión
    INSERT INTO notificaciones (id_usuario, tipo, titulo, contenido, id_referencia)
    SELECT 
        o.id_usuario,
        'comentario',
        'Nuevo comentario en tu opinión',
        CONCAT(u.nombre_completo, ' comentó en tu opinión'),
        NEW.id_opinion
    FROM opiniones o
    JOIN usuarios u ON NEW.id_usuario = u.id_usuario
    WHERE o.id_opinion = NEW.id_opinion
    AND o.id_usuario != NEW.id_usuario; -- No notificar si es el mismo usuario
    
    -- Si es respuesta a otro comentario, notificar también al dueño del comentario
    IF NEW.respuesta_a IS NOT NULL THEN
        INSERT INTO notificaciones (id_usuario, tipo, titulo, contenido, id_referencia)
        SELECT 
            c.id_usuario,
            'respuesta',
            'Respondieron a tu comentario',
            CONCAT(u.nombre_completo, ' respondió a tu comentario'),
            NEW.id_opinion
        FROM comentarios c
        JOIN usuarios u ON NEW.id_usuario = u.id_usuario
        WHERE c.id_comentario = NEW.respuesta_a
        AND c.id_usuario != NEW.id_usuario;
    END IF;
END$$

DELIMITER ;

-- Procedimiento almacenado para obtener recomendaciones
DELIMITER $$

CREATE PROCEDURE obtener_recomendaciones_usuario(IN p_id_usuario INT)
BEGIN
    -- Componentes similares a los que el usuario ha valorado positivamente
    SELECT DISTINCT c.*, cat.nombre as categoria, fab.nombre as fabricante
    FROM componentes c
    JOIN categorias cat ON c.id_categoria = cat.id_categoria
    LEFT JOIN fabricantes fab ON c.id_fabricante = fab.id_fabricante
    WHERE c.id_componente IN (
        SELECT o2.id_componente
        FROM opiniones o1
        JOIN opiniones o2 ON o1.id_componente != o2.id_componente 
            AND o1.id_usuario = p_id_usuario 
            AND o1.valoracion >= 4
        WHERE o2.valoracion >= 4
        GROUP BY o2.id_componente
        HAVING COUNT(*) >= 2
    )
    AND c.activo = TRUE
    ORDER BY c.promedio_valoracion DESC
    LIMIT 10;
END$$

CREATE PROCEDURE generar_estadisticas_diarias()
BEGIN
    DECLARE v_fecha DATE;
    SET v_fecha = CURDATE();
    
    INSERT INTO estadisticas_diarias (fecha, total_opiniones, total_comentarios, total_usuarios, total_likes, componentes_populares, usuarios_activos)
    SELECT 
        v_fecha,
        COUNT(DISTINCT o.id_opinion) as total_opiniones,
        COUNT(DISTINCT com.id_comentario) as total_comentarios,
        COUNT(DISTINCT u.id_usuario) as total_usuarios,
        COUNT(DISTINCT l.id_like) as total_likes,
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'id_componente', c.id_componente,
                'nombre', c.nombre,
                'total_opiniones', COUNT(DISTINCT o.id_opinion)
            )
        ) as componentes_populares,
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'id_usuario', u.id_usuario,
                'nombre', u.nombre_completo,
                'actividad', COUNT(DISTINCT o.id_opinion) + COUNT(DISTINCT com.id_comentario)
            )
        ) as usuarios_activos
    FROM usuarios u
    LEFT JOIN opiniones o ON u.id_usuario = o.id_usuario AND DATE(o.fecha_publicacion) = v_fecha
    LEFT JOIN comentarios com ON u.id_usuario = com.id_usuario AND DATE(com.fecha_comentario) = v_fecha
    LEFT JOIN likes_opiniones l ON u.id_usuario = l.id_usuario AND DATE(l.fecha_like) = v_fecha
    LEFT JOIN componentes c ON o.id_componente = c.id_componente
    GROUP BY v_fecha
    ON DUPLICATE KEY UPDATE
        total_opiniones = VALUES(total_opiniones),
        total_comentarios = VALUES(total_comentarios),
        total_usuarios = VALUES(total_usuarios),
        total_likes = VALUES(total_likes),
        componentes_populares = VALUES(componentes_populares),
        usuarios_activos = VALUES(usuarios_activos);
END$$

DELIMITER ;