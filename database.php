<?php
// config/database.php

class Database {
    private $host = 'localhost';
    private $db_name = 'veredict_db';
    private $username = 'root'; // Cambiar según tu configuración
    private $password = '1230'; // Cambiar según tu configuración
    private $conn;
    
    public function getConnection() {
        $this->conn = null;
        
        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name,
                $this->username,
                $this->password
            );
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->conn->exec("set names utf8");
        } catch(PDOException $exception) {
            error_log("Error de conexión: " . $exception->getMessage());
            return null;
        }
        
        return $this->conn;
    }
    
    public function closeConnection() {
        $this->conn = null;
    }
}
?>