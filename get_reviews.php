<?php
require_once 'config.php';

$conn = getDBConnection();
$sql = "SELECT r.*, u.name as usuario_nombre 
        FROM reviews r 
        JOIN users u ON r.usuario_id = u.id 
        ORDER BY r.fecha DESC 
        LIMIT 10";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        echo '
        <div class="post-card" data-post-id="'.$row['id'].'">
            <div class="post-header">
                <div class="post-avatar">
                    <img src="https://via.placeholder.com/40" alt="Usuario">
                </div>
                <div>
                    <div class="post-user">'.$row['usuario_nombre'].'</div>
                    <div class="post-time">'.date('d/m/Y H:i', strtotime($row['fecha'])).'</div>
                </div>
            </div>
            <div class="post-content">
                <span class="component-tag">'.strtoupper($row['categoria']).'</span>
                <h3>'.$row['titulo'].'</h3>
                <div class="rating">'.str_repeat('★', $row['valoracion']).str_repeat('☆', 5-$row['valoracion']).'</div>
                <p>'.$row['review'].'</p>
            </div>
            <div class="post-actions">
                <div class="post-action" data-action="like">
                    <i>👍</i> <span class="like-count">0</span>
                </div>
                <div class="post-action" data-action="comment">
                    <i>💬</i> <span>Comentar</span>
                </div>
            </div>
        </div>';
    }
} else {
    echo '<p>No hay opiniones todavía. ¡Sé el primero en publicar!</p>';
}

$conn->close();
?>