# init_database.py
import pymysql
from werkzeug.security import generate_password_hash

def init_mysql_database():
    try:
        # Conectar a MySQL (sin especificar base de datos)
        connection = pymysql.connect(
            host='localhost',
            user='root',
            password='1230',
            charset='utf8mb4'
        )
        
        with connection.cursor() as cursor:
            # Crear base de datos si no existe
            cursor.execute("CREATE DATABASE IF NOT EXISTS veredict_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
            print("✅ Base de datos 'veredict_db' creada")
            
            # Usar la base de datos
            cursor.execute("USE veredict_db")
            
            # Crear tabla de usuarios
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    username VARCHAR(80) UNIQUE NOT NULL,
                    email VARCHAR(120) UNIQUE NOT NULL,
                    password_hash VARCHAR(255) NOT NULL,
                    avatar VARCHAR(200) DEFAULT 'default-avatar.png',
                    is_admin BOOLEAN DEFAULT FALSE,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
            """)
            
            # Crear usuario admin
            admin_password = generate_password_hash('admin123')
            cursor.execute("""
                INSERT IGNORE INTO users (username, email, password_hash, is_admin)
                VALUES (%s, %s, %s, TRUE)
            """, ('admin', 'admin@veredict.com', admin_password))
            
            # Crear otras tablas
            tables = [
                """
                CREATE TABLE IF NOT EXISTS posts (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    title VARCHAR(150) NOT NULL,
                    content TEXT NOT NULL,
                    category VARCHAR(50) NOT NULL,
                    rating INT NOT NULL,
                    image VARCHAR(200),
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    user_id INT NOT NULL,
                    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
                """,
                """
                CREATE TABLE IF NOT EXISTS comments (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    content TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    user_id INT NOT NULL,
                    post_id INT NOT NULL,
                    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
                """,
                """
                CREATE TABLE IF NOT EXISTS likes (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    user_id INT NOT NULL,
                    post_id INT NOT NULL,
                    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
                    UNIQUE KEY unique_user_post_like (user_id, post_id)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
                """
            ]
            
            for table_sql in tables:
                cursor.execute(table_sql)
            
            connection.commit()
            
            print("✅ Todas las tablas creadas correctamente")
            print("\n📊 Credenciales de administración:")
            print("   👤 Usuario: admin")
            print("   🔑 Contraseña: admin123")
            print("   📧 Email: admin@veredict.com")
            print("\n🌐 phpMyAdmin: http://localhost/phpmyadmin")
            
    except pymysql.err.OperationalError as e:
        print(f"❌ Error de conexión a MySQL: {e}")
        print("\n⚠️  Solución:")
        print("   1. Abre XAMPP Control Panel")
        print("   2. Inicia Apache y MySQL")
        print("   3. Intenta nuevamente")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == '__main__':
    print("=" * 50)
    print("INICIALIZADOR DE BASE DE DATOS MYSQL")
    print("=" * 50)
    init_mysql_database()