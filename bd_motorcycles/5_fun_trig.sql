CREATE FUNCTION public.search_motorcycles(p_category_id integer DEFAULT NULL::integer, p_min_price numeric DEFAULT 0, p_max_price numeric DEFAULT 999999, p_year_from integer DEFAULT 2000, p_limit integer DEFAULT 10, p_offset integer DEFAULT 0) RETURNS TABLE(motorcycle_id integer, model_name character varying, year integer, price numeric, category_name character varying, series_name character varying)
LANGUAGE plpgsql
AS $$
BEGIN
RETURN QUERY
SELECT
m.motorcycle_id,
m.model_name,
m.year,
m.price,
c.category_name,
s.series_name
FROM motorcycles m
JOIN categories c ON m.category_id = c.category_id
JOIN model_series s ON c.series_id = s.series_id
WHERE
(p_category_id IS NULL OR m.category_id = p_category_id)
AND m.price BETWEEN p_min_price AND p_max_price
AND m.year >= p_year_from
ORDER BY m.year DESC, m.price ASC
LIMIT p_limit OFFSET p_offset;
END;
$$;

ALTER FUNCTION public.search_motorcycles(p_category_id integer, p_min_price numeric, p_max_price numeric, p_year_from integer, p_limit integer, p_offset integer) OWNER TO postgres;

CREATE FUNCTION public.update_order_total() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
UPDATE orders
SET total_amount = (
SELECT COALESCE(SUM(quantity * price_at_order), 0)
FROM order_items
WHERE order_id = NEW.order_id
)
WHERE order_id = NEW.order_id;
ELSIF TG_OP = 'DELETE' THEN
UPDATE orders
SET total_amount = (
SELECT COALESCE(SUM(quantity * price_at_order), 0)
FROM order_items
WHERE order_id = OLD.order_id
)
WHERE order_id = OLD.order_id;
END IF;
RETURN NULL;
END;
$$;

ALTER FUNCTION public.update_order_total() OWNER TO postgres;

CREATE TRIGGER trg_update_total AFTER INSERT OR DELETE OR UPDATE ON public.order_items FOR EACH ROW EXECUTE FUNCTION public.update_order_total();