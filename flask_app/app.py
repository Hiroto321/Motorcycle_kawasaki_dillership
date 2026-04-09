from flask import Flask, render_template, request, redirect, url_for, session, flash
from database import register_user, login_user, get_user_by_id
from functools import wraps
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)  # ← ИСПРАВЛЕНО: было Flask(name)
app.secret_key = os.getenv('SECRET_KEY', 'dev-secret-key')


# ============================================
# ДЕКОРАТОР ДЛЯ ЗАЩИТЫ РОУТОВ
# ============================================

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            flash('Пожалуйста, войдите в систему', 'warning')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function


# ============================================
# РОУТЫ
# ============================================

@app.route('/')
def index():
    """Главная страница"""
    return render_template('index.html')


@app.route('/register', methods=['GET', 'POST'])
def register():
    """Страница регистрации"""
    if request.method == 'POST':
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        
        if not username or not email or not password:
            flash('Все поля обязательны', 'error')
            return redirect(url_for('register'))
        
        user_id = register_user(username, email, password)
        
        if user_id:
            flash('Регистрация успешна! Добро пожаловать!', 'success')
            # ← Перебрасываем на главную после регистрации
            return redirect(url_for('index'))
        else:
            flash('Ошибка регистрации. Возможно, email уже занят.', 'error')
            return redirect(url_for('register'))
    
    return render_template('register.html')


@app.route('/login', methods=['GET', 'POST'])
def login():
    """Страница входа"""
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        
        user = login_user(email, password)
        
        if user:
            session['user_id'] = user['id']
            session['username'] = user['username']
            
            flash(f'Добро пожаловать, {user["username"]}!', 'success')
            return redirect(url_for('index'))
        else:
            flash('Неверный email или пароль', 'error')
            return redirect(url_for('login'))
    
    return render_template('login.html')


@app.route('/logout')
def logout():
    """Выход из системы"""
    session.clear()
    flash('Вы вышли из системы', 'info')
    return redirect(url_for('index'))


@app.route('/profile')
@login_required
def profile():
    """Страница профиля"""
    user = get_user_by_id(session['user_id'])
    return render_template('profile.html', user=user)


# ============================================
# ЗАПУСК
# ============================================

if __name__ == '__main__':  # ← ИСПРАВЛЕНО: было if name == 'main':
    app.run(debug=True, port=5000)