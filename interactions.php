<?php
// api/interactions.php
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
    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (isset($data['action'])) {
            switch ($data['action']) {
                case 'comment':
                    addComment($db, $data);
                    break;
                case 'like':
                    toggleLike($db, $data);
                    break;
                default:
                    http_response_code(400);
                    echo json_encode(['error' => 'Acción no válida']);
            }
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(['error' => 'Método no permitido']);
}

// Añadir comentario
function addComment($db, $data) {
    if (!isset($_SESSION['user_id'])) {
        http_response_code(401);
        echo json_encode(['error' => 'No autorizado']);
        return;
    }
    
    if (!isset($data['post_id']) || !isset($data['content'])) {
        http_response_code(400);
        echo json_encode(['error' => 'ID de publicación y contenido requeridos']);
        return;
    }
    
    try {
        // Insertar comentario
        $query = "INSERT INTO comentarios (publicacion_id, usuario_id, contenido) 
                  VALUES (:post_id, :user_id, :content)";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':post_id', $data['post_id']);
        $stmt->bindParam(':user_id', $_SESSION['user_id']);
        $stmt->bindParam(':content', $data['content']);
        
        if ($stmt->execute()) {
            // Actualizar contador de comentarios
            $updateQuery = "UPDATE publicaciones SET comentarios_count = comentarios_count + 1 
                           WHERE id = :post_id";
            $updateStmt = $db->prepare($updateQuery);
            $updateStmt->bindParam(':post_id', $data['post_id']);
            $updateStmt->execute();
            
            echo json_encode([
                'success' => true,
                'message' => 'Comentario añadido'
            ]);
        }
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Error al añadir comentario: ' . $e->getMessage()]);
    }
}

// Dar/quitar like
function toggleLike($db, $data) {
    if (!isset($_SESSION['user_id'])) {
        http_response_code(401);
        echo json_encode(['error' => 'No autorizado']);
        return;
    }
    
    if (!isset($data['post_id'])) {
        http_response_code(400);
        echo json_encode(['error' => 'ID de publicación requerido']);
        return;
    }
    
    try {
        // Verificar si ya existe like
        $checkQuery = "SELECT id FROM likes WHERE publicacion_id = :post_id AND usuario_id = :user_id";
        $checkStmt = $db->prepare($checkQuery);
        $checkStmt->bindParam(':post_id', $data['post_id']);
        $checkStmt->bindParam(':user_id', $_SESSION['user_id']);
        $checkStmt->execute();
        
        if ($checkStmt->rowCount() > 0) {
            // Quitar like
            $deleteQuery = "DELETE FROM likes WHERE publicacion_id = :post_id AND usuario_id = :user_id";
            $deleteStmt = $db->prepare($deleteQuery);
            $deleteStmt->bindParam(':post_id', $data['post_id']);
            $deleteStmt->bindParam(':user_id', $_SESSION['user_id']);
            $deleteStmt->execute();
            
            // Actualizar contador
            $updateQuery = "UPDATE publicaciones SET likes_count = likes_count - 1 WHERE id = :post_id";
            $updateStmt = $db->prepare($updateQuery);
            $updateStmt->bindParam(':post_id', $data['post_id']);
            $updateStmt->execute();
            
            echo json_encode([
                'success' => true,
                'liked' => false,
                'message' => 'Like removido'
            ]);
        } else {
            // Dar like
            $insertQuery = "INSERT INTO likes (publicacion_id, usuario_id) VALUES (:post_id, :user_id)";
            $insertStmt = $db->prepare($insertQuery);
            $insertStmt->bindParam(':post_id', $data['post_id']);
            $insertStmt->bindParam(':user_id', $_SESSION['user_id']);
            $insertStmt->execute();
            
            // Actualizar contador
            $updateQuery = "UPDATE publicaciones SET likes_count = likes_count + 1 WHERE id = :post_id";
            $updateStmt = $db->prepare($updateQuery);
            $updateStmt->bindParam(':post_id', $data['post_id']);
            $updateStmt->execute();
            
            echo json_encode([
                'success' => true,
                'liked' => true,
                'message' => 'Like añadido'
            ]);
        }
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Error al gestionar like: ' . $e->getMessage()]);
    }
}
?>