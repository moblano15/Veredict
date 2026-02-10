<?php
// api/users.php
require_once '../config/database.php';
session_start();
header('Content-Type: application/json');

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    http_response_code(500);
    echo json_encode(['error' => 'Error de conexión a la base de datos']);
    exit;
}

// Función para limpiar datos
function sanitize($data) {
    return htmlspecialchars(strip_tags(trim($data)));
}

// Verificar método HTTP
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (isset($data['action'])) {
            switch ($data['action']) {
                case 'login':
                    login($db, $data);
                    break;
                case 'register':
                    register($db, $data);
                    break;
                case 'logout':
                    logout();
                    break;
                case 'update_profile':
                    updateProfile($db, $data);
                    break;
                default:
                    http_response_code(400);
                    echo json_encode(['error' => 'Acción no válida']);
            }
        }
        break;
        
    case 'GET':
        if (isset($_GET['id'])) {
            getUser($db, $_GET['id']);
        } else {
            http_response_code(400);
            echo json_encode(['error' => 'ID de usuario requerido']);
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(['error' => 'Método no permitido']);
}

// Función de login
function login($db, $data) {
    if (!isset($data['email']) || !isset($data['password'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Email y contraseña requeridos']);
        return;
    }
    
    $email = sanitize($data['email']);
    $password = $data['password'];
    
    try {
        $query = "SELECT * FROM usuarios WHERE email = :email AND is_active = 1";
        $stmt = $db->prepare($query);
        $stmt->bindParam(':email', $email);
        $stmt->execute();
        
        if ($stmt->rowCount() > 0) {
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // Verificar contraseña (en producción usa password_verify)
            if ($user['password_hash'] === md5($password)) { // Cambia esto por password_verify
                // Actualizar último login
                $updateQuery = "UPDATE usuarios SET ultimo_login = NOW() WHERE id = :id";
                $updateStmt = $db->prepare($updateQuery);
                $updateStmt->bindParam(':id', $user['id']);
                $updateStmt->execute();
                
                // No devolver el hash de la contraseña
                unset($user['password_hash']);
                unset($user['reset_token']);
                
                $_SESSION['user_id'] = $user['id'];
                $_SESSION['user_email'] = $user['email'];
                $_SESSION['user_name'] = $user['nombre'];
                
                echo json_encode([
                    'success' => true,
                    'message' => 'Login exitoso',
                    'user' => $user
                ]);
            } else {
                http_response_code(401);
                echo json_encode(['error' => 'Credenciales incorrectas']);
            }
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Usuario no encontrado']);
        }
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Error en el servidor: ' . $e->getMessage()]);
    }
}

// Función de registro
function register($db, $data) {
    $required = ['nombre', 'email', 'password', 'confirm_password'];
    
    foreach ($required as $field) {
        if (!isset($data[$field]) || empty($data[$field])) {
            http_response_code(400);
            echo json_encode(['error' => 'Todos los campos son requeridos']);
            return;
        }
    }
    
    if ($data['password'] !== $data['confirm_password']) {
        http_response_code(400);
        echo json_encode(['error' => 'Las contraseñas no coinciden']);
        return;
    }
    
    if (strlen($data['password']) < 6) {
        http_response_code(400);
        echo json_encode(['error' => 'La contraseña debe tener al menos 6 caracteres']);
        return;
    }
    
    $nombre = sanitize($data['nombre']);
    $email = sanitize($data['email']);
    $password_hash = md5($data['password']); // En producción usa password_hash
    
    try {
        // Verificar si el email ya existe
        $checkQuery = "SELECT id FROM usuarios WHERE email = :email";
        $checkStmt = $db->prepare($checkQuery);
        $checkStmt->bindParam(':email', $email);
        $checkStmt->execute();
        
        if ($checkStmt->rowCount() > 0) {
            http_response_code(409);
            echo json_encode(['error' => 'El email ya está registrado']);
            return;
        }
        
        // Generar avatar aleatorio
        $random_img = rand(1, 70);
        $avatar_url = "https://i.pravatar.cc/40?img={$random_img}";
        $bio = "Nuevo usuario de Veredict. ¡Estoy emocionado de compartir mis opiniones sobre hardware!";
        
        $query = "INSERT INTO usuarios (nombre, email, password_hash, avatar_url, bio) 
                  VALUES (:nombre, :email, :password_hash, :avatar_url, :bio)";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':nombre', $nombre);
        $stmt->bindParam(':email', $email);
        $stmt->bindParam(':password_hash', $password_hash);
        $stmt->bindParam(':avatar_url', $avatar_url);
        $stmt->bindParam(':bio', $bio);
        
        if ($stmt->execute()) {
            $user_id = $db->lastInsertId();
            
            // Obtener usuario creado
            $userQuery = "SELECT id, nombre, email, avatar_url, bio, posts_count, 
                          likes_received, followers_count, fecha_registro 
                          FROM usuarios WHERE id = :id";
            $userStmt = $db->prepare($userQuery);
            $userStmt->bindParam(':id', $user_id);
            $userStmt->execute();
            $user = $userStmt->fetch(PDO::FETCH_ASSOC);
            
            $_SESSION['user_id'] = $user['id'];
            $_SESSION['user_email'] = $user['email'];
            $_SESSION['user_name'] = $user['nombre'];
            
            echo json_encode([
                'success' => true,
                'message' => 'Usuario registrado exitosamente',
                'user' => $user
            ]);
        }
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Error al registrar usuario: ' . $e->getMessage()]);
    }
}

// Función logout
function logout() {
    session_destroy();
    echo json_encode(['success' => true, 'message' => 'Sesión cerrada']);
}

// Obtener información de usuario
function getUser($db, $user_id) {
    try {
        $query = "SELECT id, nombre, email, avatar_url, bio, posts_count, 
                  likes_received, followers_count, fecha_registro 
                  FROM usuarios WHERE id = :id AND is_active = 1";
        $stmt = $db->prepare($query);
        $stmt->bindParam(':id', $user_id);
        $stmt->execute();
        
        if ($stmt->rowCount() > 0) {
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            echo json_encode($user);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Usuario no encontrado']);
        }
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Error en el servidor: ' . $e->getMessage()]);
    }
}

// Actualizar perfil
function updateProfile($db, $data) {
    if (!isset($_SESSION['user_id'])) {
        http_response_code(401);
        echo json_encode(['error' => 'No autorizado']);
        return;
    }
    
    $user_id = $_SESSION['user_id'];
    $updates = [];
    $params = [];
    
    if (isset($data['nombre'])) {
        $updates[] = "nombre = :nombre";
        $params[':nombre'] = sanitize($data['nombre']);
    }
    
    if (isset($data['bio'])) {
        $updates[] = "bio = :bio";
        $params[':bio'] = sanitize($data['bio']);
    }
    
    if (isset($data['avatar_url'])) {
        $updates[] = "avatar_url = :avatar_url";
        $params[':avatar_url'] = sanitize($data['avatar_url']);
    }
    
    if (empty($updates)) {
        http_response_code(400);
        echo json_encode(['error' => 'No hay datos para actualizar']);
        return;
    }
    
    try {
        $query = "UPDATE usuarios SET " . implode(', ', $updates) . " WHERE id = :id";
        $params[':id'] = $user_id;
        
        $stmt = $db->prepare($query);
        $stmt->execute($params);
        
        echo json_encode([
            'success' => true,
            'message' => 'Perfil actualizado exitosamente'
        ]);
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Error al actualizar perfil: ' . $e->getMessage()]);
    }
}
?>