from fastapi import APIRouter, Request, HTTPException
from datetime import datetime, timedelta
import jwt
import json
from passlib.context import CryptContext
from database import get_db_connection

router = APIRouter()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
SECRET_KEY = "your_secret_key"
ALGORITHM = "HS256"

def create_access_token(data: dict):
    expire = datetime.utcnow() + timedelta(minutes=30)
    to_encode = data.copy()
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

@router.post("/api/auth/login")
async def login(request: Request):
    body = await request.json()
    username = body.get("username")
    password = body.get("password")

    if not username or not password:
        raise HTTPException(status_code=400, detail="Заполните все поля")

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        "SELECT user_id, password_hash, user_name FROM users WHERE user_name = %s",
        (username,)
    )
    user = cur.fetchone()
    cur.close()
    conn.close()

    if not user or not pwd_context.verify(password, user[1]):
        raise HTTPException(status_code=401, detail="Неверный логин или пароль")

    token = create_access_token({"sub": user[2], "user_id": user[0]})
    return {
        "access_token": token,
        "token_type": "bearer",
        "username": user[2]
    }

@router.post("/api/auth/register")
async def register(request: Request):
    body = await request.json()
    username = body.get("username")
    email = body.get("email")
    password = body.get("password")

    if not all([username, email, password]):
        raise HTTPException(status_code=400, detail="Заполните все поля")

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        "SELECT user_id FROM users WHERE user_name = %s OR email = %s",
        (username, email)
    )
    if cur.fetchone():
        cur.close()
        conn.close()
        raise HTTPException(status_code=400, detail="Пользователь уже существует")

    password_hash = pwd_context.hash(password)
    cur.execute(
        "INSERT INTO users (user_name, email, password_hash, is_active) VALUES (%s, %s, %s, TRUE)",
        (username, email, password_hash)
    )
    conn.commit()
    cur.close()
    conn.close()
    return {"message": "Регистрация успешна", "username": username}