from flask import Flask, render_template, request, redirect, url_for, flash
from flask_cors import CORS
from database import get_db_connection
from werkzeug.security import generate_password_hash, check_password_hash
from motorcycles_api import get_all_motorcycles_with_details, get_hierarchy_data
import os
import jwt
import datetime
from functools import wraps


app = Flask(__name__, 
            static_folder='static', 
            template_folder='templates')
CORS(app)
app.secret_key = os.getenv('FLASK_SECRET_KEY', os.urandom(24))
JWT_SECRET = os.getenv('JWT_SECRET', os.urandom(32).hex())
JWT_ALGORITHM = 'HS256'


def generate_token(user_id, username):
    payload = {
        'user_id': user_id,
        'username': username,
        'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24),
        'iat': datetime.datetime.utcnow()
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        auth_header = request.headers.get('Authorization')
        
        if auth_header and auth_header.startswith('Bearer '):
            token = auth_header.split(' ')[1]
        
        if not token:
            return {'error': 'Токен отсутствует'}, 401
        
        try:
            data = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
            request.current_user = data
        except jwt.ExpiredSignatureError:
            return {'error': 'Токен истёк'}, 401
        except jwt.InvalidTokenError:
            return {'error': 'Неверный токен'}, 401
        
        return f(*args, **kwargs)
    return decorated


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/login')
def login_page():
    return render_template('login.html')


@app.route('/register')
def register_page():
    return render_template('register.html')


@app.route('/motorcycles')
def motorcycles_page():
    return render_template('motorcycles.html')


@app.route('/about')
def about_page():
    return render_template('about.html')


@app.route('/contact')
def contact_page():
    return render_template('contact.html')


@app.route('/cart')
def cart_page():
    return render_template('cart.html')



@app.route('/api/auth/register', methods=['POST'])
def api_register():
    data = request.get_json()
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')
    
    if not all([username, email, password]):
        return {'error': 'Заполните все поля'}, 400
    
    password_hash = generate_password_hash(password)
    
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute(
            "SELECT user_id FROM users WHERE user_name = %s OR email = %s",
            (username, email)
        )
        if cur.fetchone():
            return {'error': 'Пользователь уже существует'}, 400

        cur.execute(
            "INSERT INTO users (user_name, email, password_hash, is_active) VALUES (%s, %s, %s, TRUE)",
            (username, email, password_hash)
        )
        conn.commit()
        return {'message': 'Регистрация успешна', 'username': username}, 201
        
    except Exception as e:
        if conn:
            conn.rollback()
        print("Ошибка регистрации:", e)
        return {'error': 'Ошибка сервера'}, 500
    finally:
        if conn:
            cur.close()
            conn.close()


@app.route('/api/auth/login', methods=['POST'])
def api_login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    
    if not all([username, password]):
        return {'error': 'Введите логин и пароль'}, 400
    
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "SELECT user_id, password_hash, user_name, email FROM users WHERE user_name = %s",
            (username,)
        )
        user = cur.fetchone()
        
        if user and check_password_hash(user[1], password):
            cur.execute(
                "UPDATE users SET last_login = NOW() WHERE user_id = %s",
                (user[0],)
            )
            conn.commit()
            
            # Генерируем JWT
            token = generate_token(user[0], user[2])
            
            return {
                'message': 'Вход выполнен',
                'username': user[2],
                'email': user[3],
                'user_id': user[0],
                'token': token
            }
        else:
            return {'error': 'Неверный логин или пароль'}, 401
            
    except Exception as e:
        print("Ошибка входа:", e)
        return {'error': 'Ошибка сервера'}, 500
    finally:
        if conn:
            cur.close()
            conn.close()


@app.route('/news_events')
def news_events_page():
    return render_template('news_events.html')


@app.route('/owners_manuals')
def owners_manuals_page():
    return render_template('owners_manuals.html')


@app.route('/rider_academy')
def rider_academy_page():
    return render_template('rider_academy.html')


@app.route('/service_centers')
def service_centers_page():
    return render_template('service_centers.html')


@app.route('/under_construction')
def under_construction_page():
    return render_template('under-construction.html')


@app.route('/warranty')
def warranty_page():
    return render_template('warranty.html')


@app.route('/careers')
def careers_page():
    return render_template('careers.html')


@app.route('/faq')
def faq_page():
    return render_template('faq.html')


@app.route('/financing')
def financing_page():
    return render_template('financing.html')


@app.route('/api/motorcycles')
def api_get_motorcycles():
    try:
        motorcycles = get_all_motorcycles_with_details()
        return {'motorcycles': motorcycles, 'total': len(motorcycles)}, 200
    except Exception as e:
        print(f"Error fetching motorcycles: {e}")
        return {'error': 'Failed to fetch motorcycles'}, 500


@app.route('/api/motorcycles/list')
def api_get_motorcycles_paginated():
    try:
        group = request.args.get('group', '')
        series = request.args.get('series', '')
        category = request.args.get('category', '')
        search = request.args.get('search', '').lower()
        sort_by = request.args.get('sort', 'name')
        sort_order = request.args.get('order', 'asc')
        page = int(request.args.get('page', 1))
        per_page = int(request.args.get('per_page', 12))
        
        motorcycles = get_all_motorcycles_with_details()
        
        if group:
            motorcycles = [m for m in motorcycles if m['group']['slug'].lower() == group.lower()]
        if series:
            motorcycles = [m for m in motorcycles if m['series']['name'].lower() == series.lower()]
        if category:
            motorcycles = [m for m in motorcycles if m['category']['name'].lower() == category.lower()]
        if search:
            motorcycles = [m for m in motorcycles if search in m['name'].lower()]
        
        reverse = sort_order == 'desc'
        if sort_by == 'price':
            motorcycles.sort(key=lambda x: x['price'] or 0, reverse=reverse)
        elif sort_by == 'year':
            motorcycles.sort(key=lambda x: x['year'] or 0, reverse=reverse)
        else:
            motorcycles.sort(key=lambda x: x['name'], reverse=reverse)
        
        total = len(motorcycles)
        start = (page - 1) * per_page
        end = start + per_page
        paginated = motorcycles[start:end]
        
        return {
            'motorcycles': paginated,
            'total': total,
            'page': page,
            'per_page': per_page,
            'pages': (total + per_page - 1) // per_page
        }, 200
        
    except Exception as e:
        print(f"Error: {e}")
        return {'error': 'Failed to fetch motorcycles'}, 500


@app.route('/api/motorcycles/hierarchy')
def api_get_hierarchy():
    try:
        return get_hierarchy_data(), 200
    except Exception as e:
        print(f"Error fetching hierarchy: {e}")
        return {'error': 'Failed to fetch hierarchy'}, 500


@app.route('/api/motorcycles/filtered')
def api_get_filtered_motorcycles():
    try:
        group_slug = request.args.get('group', '')
        series_slug = request.args.get('series', '')
        category_name = request.args.get('category', '')
        search = request.args.get('search', '').lower()
        sort = request.args.get('sort', 'name-asc')
        page = int(request.args.get('page', 1))
        per_page = 12
        
        motorcycles = get_all_motorcycles_with_details()
        
        if group_slug:
            motorcycles = [m for m in motorcycles if m['group']['slug'] == group_slug]
        if series_slug:
            motorcycles = [m for m in motorcycles if m['series']['slug'] == series_slug]
        if category_name:
            motorcycles = [m for m in motorcycles if m['category']['name'].lower() == category_name.lower()]
        if search:
            motorcycles = [m for m in motorcycles if search in m['name'].lower()]
        
        sort_key, sort_order = sort.split('-')
        reverse = sort_order == 'desc'
        if sort_key == 'price':
            motorcycles.sort(key=lambda x: x['price'] or 0, reverse=reverse)
        elif sort_key == 'year':
            motorcycles.sort(key=lambda x: x['year'] or 0, reverse=reverse)
        else:
            motorcycles.sort(key=lambda x: x['name'], reverse=reverse)
        
        total = len(motorcycles)
        start = (page - 1) * per_page
        paginated = motorcycles[start:start + per_page]
        
        return {
            'motorcycles': paginated,
            'total': total,
            'page': page,
            'pages': (total + per_page - 1) // per_page
        }, 200
        
    except Exception as e:
        print(f"Error: {e}")
        return {'error': 'Failed to filter motorcycles'}, 500
    
@app.route('/acc')
def acc_page():
    """Страница профиля пользователя"""
    token = None
    auth_header = request.headers.get('Authorization')
    
    # Пробуем получить токен из заголовка или cookies
    if auth_header and auth_header.startswith('Bearer '):
        token = auth_header.split(' ')[1]
    else:
        token = request.cookies.get('jwt_token')
    
    if not token:
        # Если нет токена - редирект на login
        return redirect(url_for('login_page'))
    
    try:
        data = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        return render_template('acc.html',
                             username=data['username'],
                             user_id=data['user_id'])
    except jwt.ExpiredSignatureError:
        # Токен истёк - редирект на login
        return redirect(url_for('login_page'))
    except jwt.InvalidTokenError:
        # Неверный токен - редирект на login
        return redirect(url_for('login_page'))


@app.route('/api/auth/logout', methods=['POST'])
def api_logout():
    """API: выход из системы (клиент удаляет токен)"""
    return {'message': 'Выход выполнен успешно'}, 200


@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404


@app.errorhandler(500)
def internal_server_error(e):
    """Обработка ошибки 500 - внутренняя ошибка сервера"""
    return render_template('500.html'), 500


@app.route('/trigger-500')
def trigger_500():
    """Принудительная ошибка 500"""
    return 1/0


if __name__ == '__main__':
    port = int(os.getenv('FLASK_PORT', 5000))
    app.run(debug=False, port=port)