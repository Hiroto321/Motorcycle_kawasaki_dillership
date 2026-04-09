import psycopg2
from werkzeug.security import generate_password_hash, check_password_hash
import os
from dotenv import load_dotenv

load_dotenv()

# ============================================
# КОНФИГУРАЦИЯ ПОДКЛЮЧЕНИЯ К БД (Neon)
# ============================================

DB_CONFIG = {
    'dbname': os.getenv('DB_NAME', 'neondb'),
    'user': os.getenv('DB_USER', 'neondb_owner'),
    'password': os.getenv('DB_PASSWORD'),
    'host': os.getenv('DB_HOST'),
    'port': os.getenv('DB_PORT', '5432'),
    'sslmode': 'require'
}


def get_connection():
    """Создает подключение к базе данных"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("✅ Подключение к БД успешно!")
        return conn
    except Exception as e:
        print(f"❌ Ошибка подключения к БД: {e}")
        return None


def register_user(username, email, password):
    """Регистрирует нового пользователя"""
    try:
        password_hash = generate_password_hash(password)
        
        conn = get_connection()
        if not conn:
            return None
        
        cursor = conn.cursor()
        
        cursor.execute("""
            INSERT INTO users (user_name, email, password_hash)
            VALUES (%s, %s, %s)
            RETURNING user_id
        """, (username, email, password_hash))
        
        user_id = cursor.fetchone()[0]
        conn.commit()
        cursor.close()
        conn.close()
        
        print(f"✅ Пользователь {username} зарегистрирован с ID: {user_id}")
        return user_id
        
    except psycopg2.IntegrityError as e:
        print(f"❌ Пользователь с таким email или username уже существует!")
        return None
    except Exception as e:
        print(f"❌ Ошибка регистрации: {e}")
        return None


def login_user(email, password):
    """Проверяет логин и пароль"""
    try:
        conn = get_connection()
        if not conn:
            return None
        
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT user_id, user_name, email, password_hash, is_active, created_at, last_login
            FROM users 
            WHERE email = %s AND is_active = TRUE
        """, (email,))
        
        user = cursor.fetchone()
        cursor.close()
        conn.close()
        
        if user and check_password_hash(user[3], password):
            conn = get_connection()
            cursor = conn.cursor()
            cursor.execute("""
                UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE user_id = %s
            """, (user[0],))
            conn.commit()
            cursor.close()
            conn.close()
            
            return {
                'id': user[0],
                'username': user[1],
                'email': user[2],
                'is_active': user[4],
                'created_at': user[5],
                'last_login': user[6]
            }
        
        return None
        
    except Exception as e:
        print(f"❌ Ошибка входа: {e}")
        return None


def get_user_by_id(user_id):
    """Получает пользователя по ID"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT user_id, user_name, email, created_at, last_login, is_active
            FROM users 
            WHERE user_id = %s
        """, (user_id,))
        
        user = cursor.fetchone()
        cursor.close()
        conn.close()
        
        if user:
            return {
                'id': user[0],
                'username': user[1],
                'email': user[2],
                'created_at': user[3],
                'last_login': user[4],
                'is_active': user[5]
            }
        
        return None
        
    except Exception as e:
        print(f"❌ Ошибка получения пользователя: {e}")
        return None