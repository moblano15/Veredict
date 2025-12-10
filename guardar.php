<?php
// guardar.php - Maneja el guardado de reviews en la base de datos

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Recibir datos del formulario
    $producto = $_POST['producto'];
    $categoria = $_POST['categoria'];
    $valoracion = $_POST['valoracion'];
    $review = $_POST['review'];
    $usuario = $_POST['usuario'];
    
    // Validar datos (aquí deberías agregar más validaciones)
    if (empty($producto) || empty($review)) {
        echo "Error: Todos los campos son obligatorios";
        exit;
    }
    
    // Conectar a la base de datos (ejemplo con MySQLi)
    $servername = "localhost";
    $username = "tu_usuario";
    $password = "tu_contraseña";
    $dbname = "veredict";
    
    $conn = new mysqli($servername, $username, $password, $dbname);
    
    if ($conn->connect_error) {
        die("Conexión fallida: " . $conn->connect_error);
    }
    
    // Preparar y ejecutar la consulta
    $stmt = $conn->prepare("INSERT INTO reviews (producto, categoria, valoracion, review, usuario, fecha) VALUES (?, ?, ?, ?, ?, NOW())");
    $stmt->bind_param("ssiss", $producto, $categoria, $valoracion, $review, $usuario);
    
    if ($stmt->execute()) {
        echo "Review guardado exitosamente";
    } else {
        echo "Error al guardar el review: " . $stmt->error;
    }
    
    $stmt->close();
    $conn->close();
} else {
    echo "Método no permitido";
}
?>