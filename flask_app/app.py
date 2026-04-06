from flask import Flask, render_template, request, redirect, url_for, session, jsonify
from functools import wraps
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv('SECRET_KEY', 'dev-secret-key')

# Декоратор для проверки авторизации
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

# Главная страница
@app.route('/')
def index():
    return render_template('index.html')

# Страница входа
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        
        # ВРЕМЕННО: простой вход (потом будет проверка в БД)
        if email and password:
            session['user_id'] = 1
            session['username'] = email.split('@')[0]
            return redirect(url_for('index'))
    
    return render_template('login.html')

# Страница регистрации
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        
        # ВРЕМЕННО: простая регистрация (потом будет запись в БД)
        if username and email and password:
            return redirect(url_for('login'))
    
    return render_template('register.html')

# Выход
@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('index'))

# Профиль пользователя (защищённый роут)
@app.route('/profile')
@login_required
def profile():
    return render_template('profile.html', username=session.get('username'))

if __name__ == '__main__':
    app.run(debug=True, port=5000)