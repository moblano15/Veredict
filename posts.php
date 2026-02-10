<?php
// api/posts.php
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

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        if (isset($_GET['id'])) {
            getPost($db, $_GET['id']);
        } else if (isset($_GET['user_id'])) {
            getUserPosts($db, $_GET['user_id']);
        } else if (isset($_GET['category'])) {
            getPostsByCategory($db, $_GET['category']);
        } else if (isset($_GET['search'])) {
            searchPosts($db, $_GET['search'], $_GET['category'] ?? 'all');
        } else {
            getAllPosts($db, $_GET['limit'] ?? 20);
        }
        break;
        
    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        createPost($db, $data);
        break;
        
    case 'PUT':
        $data = json_decode(file_get_contents('php://input'), true);
        updatePost($db, $_GET['id'], $data);
        break;
        
    case 'DELETE':
        deletePost($db, $_GET['id']);
        break;
        
    default:
        http_response_code(405);
        echo json_encode(['error' => 'Método no permitido']);
}

// Obtener todas las publicaciones
function getAllPosts($db, $limit = 20) {
    try {
        $query = "SELECT p.*, u.nombre as usuario_nombre, u.avatar_url as usuario_avatar, 
                  c.nombre as categoria_nombre, c.icono as categoria_icono
                  FROM publicaciones p
                  JOIN usuarios u ON p.usuario_id = u.id
                  JOIN categorias c ON p.categoria_id = c.id
                  ORDER BY p.fecha_publicacion DESC
                  LIMIT :limit";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        
        $posts = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Obtener comentarios para cada publicación
        foreach ($posts as &$post) {
            $post['comentarios'] = getComments($db, $post['id']);
        }
        
        echo json_encode($posts);
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Error al obtener publicaciones: ' . $e->getMessage()]);
    }
}

// Crear nueva publicación
function createPost($db, $data) {
    if (!isset($_SESSION['user_id'])) {
        http_response_code(401);
        echo json_encode(['error' => 'No autorizado']);
        return;
    }
    
    $required = ['componente', 'categoria_id', 'titulo', 'contenido', 'valoracion'];
    
    foreach ($required as $field) {
        if (!isset($data[$field]) || empty($data[$field])) {
            http_response_code(400);
            echo json_encode(['error' => "Campo {$field} es requerido"]);
            return;
        }
    }
    
    try {
        $query = "INSERT INTO publicaciones 
                  (usuario_id, categoria_id, componente, titulo, contenido, valoracion) 
                  VALUES (:usuario_id, :categoria_id, :componente, :titulo, :contenido, :valoracion)";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':usuario_id', $_SESSION['user_id']);
        $stmt->bindParam(':categoria_id', $data['categoria_id']);
        $stmt->bindParam(':componente', $data['componente']);
        $stmt->bindParam(':titulo', $data['titulo']);
        $stmt->bindParam(':contenido', $data['contenido']);
        $stmt->bindParam(':valoracion', $data['valoracion']);
        
        if ($stmt->execute()) {
            // Actualizar contador de posts del usuario
            $updateQuery = "UPDATE usuarios SET posts_count = posts_count + 1 WHERE id = :usuario_id";
            $updateStmt = $db->prepare($updateQuery);
            $updateStmt->bindParam(':usuario_id', $_SESSION['user_id']);
            $updateStmt->execute();
            
            $post_id = $db->lastInsertId();
            echo json_encode([
                'success' => true,
                'message' => 'Publicación creada exitosamente',
                'post_id' => $post_id
            ]);
        }
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Error al crear publicación: ' . $e->getMessage()]);
    }
}

// Obtener comentarios de una publicación
function getComments($db, $post_id) {
    try {
        $query = "SELECT c.*, u.nombre as usuario_nombre, u.avatar_url as usuario_avatar
                  FROM comentarios c
                  JOIN usuarios u ON c.usuario_id = u.id
                  WHERE c.publicacion_id = :post_id
                  ORDER BY c.fecha_comentario ASC";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':post_id', $post_id);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch(PDOException $e) {
        return [];
    }
}
?>