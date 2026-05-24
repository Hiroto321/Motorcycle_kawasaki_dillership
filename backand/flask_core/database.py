import psycopg2

def get_db_connection():
    conn = psycopg2.connect(
        host="localhost",
        database="kawasaki_db",
        user="postgres",
        password="789052@Qazfg@@",
        port=5432
    )
    return conn

try:
    conn = get_db_connection()
    print("УРА! Связь с базой установлена!")
    conn.close()
except Exception as e:
    print("Ошибка подключения:", e)