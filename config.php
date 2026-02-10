<?php
// config/config.php

// Configuración de la aplicación
define('APP_NAME', 'Veredict');
define('APP_VERSION', '1.0.0');
define('BASE_URL', 'http://localhost/veredict'); // Cambiar según tu entorno

// Configuración de seguridad
define('SESSION_TIMEOUT', 3600); // 1 hora en segundos
define('PASSWORD_MIN_LENGTH', 6);

// Configuración de API externas (Gemini AI)
define('GEMINI_API_KEY', ''); // Tu API Key aquí
define('GEMINI_API_URL', 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent');

// Configuración de email (para recuperación de contraseña)
define('SMTP_HOST', 'smtp.gmail.com');
define('SMTP_PORT', 587);
define('SMTP_USER', 'tu_email@gmail.com');
define('SMTP_PASS', 'tu_password');

// Configuración de archivos
define('MAX_FILE_SIZE', 5242880); // 5MB
define('ALLOWED_IMAGE_TYPES', ['jpg', 'jpeg', 'png', 'gif']);

// Funciones de utilidad
function isLoggedIn() {
    return isset($_SESSION['user_id']);
}

function requireLogin() {
    if (!isLoggedIn()) {
        http_response_code(401);
        echo json_encode(['error' => 'No autorizado']);
        exit;
    }
}

function generateToken($length = 32) {
    return bin2hex(random_bytes($length));
}

function validateEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL);
}

function getCurrentDateTime() {
    return date('Y-m-d H:i:s');
}
?>