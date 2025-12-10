# init_mysql.py
import mysql.connector
from werkzeug.security import generate_password_hash

def create_database():
    try:
        # Conexión a MySQL (sin especificar base de datos)
        conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password="1230"  # Contraseña vacía por defecto en XAMPP
        )
        
        cursor = conn.cursor()
        
        # Crear base de datos
        cursor.execute("CREATE DATABASE IF NOT EXISTS veredict_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
        print("✅ Base de datos 'veredict_db' creada/existe")
        
        # Usar la base de datos
        cursor.execute("USE veredict_db")
        
        # Crear usuario admin
        admin_password = generate_password_hash("admin123")
        
        # Verificar si la tabla users existe
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
        
        # Insertar usuario admin si no existe
        cursor.execute("SELECT id FROM users WHERE username = 'admin'")
        if not cursor.fetchone():
            cursor.execute("""
                INSERT INTO users (username, email, password_hash, is_admin)
                VALUES (%s, %s, %s, TRUE)
            """, ('admin', 'admin@veredict.com', admin_password))
            print("✅ Usuario admin creado:")
            print("   Usuario: admin")
            print("   Email: admin@veredict.com")
            print("   Contraseña: admin123")
        
        # Crear otras tablas
        tables = [
            """
            CREATE TABLE IF NOT EXISTS posts (
                id INT AUTO_INCREMENT PRIMARY KEY,
                title VARCHAR(150) NOT NULL,
                content TEXT NOT NULL,
                category VARCHAR(50) NOT NULL,
                rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
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
        
        conn.commit()
        print("✅ Todas las tablas creadas correctamente")
        
        # Mostrar información
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        print("\n📊 Tablas en la base de datos:")
        for table in tables:
            print(f"   - {table[0]}")
        
        cursor.close()
        conn.close()
        
    except mysql.connector.Error as err:
        print(f"❌ Error MySQL: {err}")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    print("=" * 50)
    print("INICIALIZADOR DE BASE DE DATOS MYSQL")
    print("=" * 50)
    create_database()