from database import get_db_connection

def get_all_motorcycles_with_details():
    conn = get_db_connection()
    cur = conn.cursor()
    
    query = """
    SELECT 
        m.motorcycle_id, m.model_name, m.year, m.price, m.image_url, m.created_at,
        c.category_id, c.category_name,
        ms.series_id, ms.series_name, ms.series_slug,
        cg.group_id, cg.group_name, cg.group_slug,
        p.engine_type, p.displacement_cc, p.maximum_horsepower, p.maximum_torque, p.transmission,
        d.seat_height_in, d.fuel_capacity_gal, d.curb_weight_lbs
    FROM motorcycles m
    LEFT JOIN categories c ON m.category_id = c.category_id
    LEFT JOIN model_series ms ON c.series_id = ms.series_id
    LEFT JOIN category_groups cg ON ms.group_id = cg.group_id
    LEFT JOIN power p ON m.motorcycle_id = p.motorcycle_id
    LEFT JOIN details d ON m.motorcycle_id = d.motorcycle_id
    ORDER BY cg.display_order, ms.display_order, c.category_name, m.year DESC
    """
    
    cur.execute(query)
    rows = cur.fetchall()
    
    motorcycles = []
    for row in rows:
        motorcycles.append({
            'id': row[0], 'name': row[1], 'year': row[2], 'price': float(row[3]) if row[3] else None,
            'image': row[4],
            'category': {'id': row[6], 'name': row[7]},
            'series': {'id': row[8], 'name': row[9], 'slug': row[10]},
            'group': {'id': row[11], 'name': row[12], 'slug': row[13]},
            'specs': {
                'engine_type': row[14], 'displacement_cc': row[15], 'horsepower': row[16],
                'torque': row[17], 'transmission': row[18], 'seat_height': row[19],
                'fuel_capacity': row[20], 'weight': row[21]
            }
        })
    
    cur.close()
    conn.close()
    return motorcycles


def get_hierarchy_data():
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute("SELECT group_id, group_name, group_slug FROM category_groups ORDER BY display_order")
    groups = [{'id': r[0], 'name': r[1], 'slug': r[2]} for r in cur.fetchall()]
    
    cur.execute("SELECT series_id, series_name, series_slug, group_id FROM model_series ORDER BY display_order")
    series = [{'id': r[0], 'name': r[1], 'slug': r[2], 'group_id': r[3]} for r in cur.fetchall()]

    cur.execute("SELECT category_id, category_name, series_id FROM categories")
    categories = [{'id': r[0], 'name': r[1], 'series_id': r[2]} for r in cur.fetchall()]
    
    cur.close()
    conn.close()
    
    return {'groups': groups, 'series': series, 'categories': categories}