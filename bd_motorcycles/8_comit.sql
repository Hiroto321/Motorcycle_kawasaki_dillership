CREATE FUNCTION public.search_motorcycles(
    p_category_id integer DEFAULT NULL::integer, 
    p_min_price numeric DEFAULT 0, 
    p_max_price numeric DEFAULT 999999, 
    p_year_from integer DEFAULT 2000, 
    p_limit integer DEFAULT 10, 
    p_offset integer DEFAULT 0
) RETURNS TABLE(motorcycle_id integer, model_name character varying, year integer, price numeric, category_name character varying, series_name character varying)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT m.motorcycle_id, m.model_name, m.year, m.price, c.category_name, s.series_name
    FROM motorcycles m
    JOIN categories c ON m.category_id = c.category_id
    JOIN model_series s ON c.series_id = s.series_id
    WHERE (p_category_id IS NULL OR m.category_id = p_category_id)
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
        UPDATE orders SET total_amount = (SELECT COALESCE(SUM(quantity * price_at_order), 0) FROM order_items WHERE order_id = NEW.order_id) WHERE order_id = NEW.order_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE orders SET total_amount = (SELECT COALESCE(SUM(quantity * price_at_order), 0) FROM order_items WHERE order_id = OLD.order_id) WHERE order_id = OLD.order_id;
    END IF;
    RETURN NULL;
END;
$$;
ALTER FUNCTION public.update_order_total() OWNER TO postgres;


CREATE TRIGGER trg_update_total AFTER INSERT OR DELETE OR UPDATE ON public.order_items FOR EACH ROW EXECUTE FUNCTION public.update_order_total();


ALTER TABLE ONLY public.categories ADD CONSTRAINT categories_category_name_key UNIQUE (category_name);
ALTER TABLE ONLY public.categories ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);

ALTER TABLE ONLY public.category_groups ADD CONSTRAINT category_groups_group_name_key UNIQUE (group_name);
ALTER TABLE ONLY public.category_groups ADD CONSTRAINT category_groups_group_slug_key UNIQUE (group_slug);
ALTER TABLE ONLY public.category_groups ADD CONSTRAINT category_groups_pkey PRIMARY KEY (group_id);

ALTER TABLE ONLY public.details ADD CONSTRAINT details_motorcycle_id_key UNIQUE (motorcycle_id);
ALTER TABLE ONLY public.details ADD CONSTRAINT details_pkey PRIMARY KEY (detail_id);

ALTER TABLE ONLY public.model_series ADD CONSTRAINT model_series_pkey PRIMARY KEY (series_id);
ALTER TABLE ONLY public.model_series ADD CONSTRAINT model_series_series_name_key UNIQUE (series_name);
ALTER TABLE ONLY public.model_series ADD CONSTRAINT model_series_series_slug_key UNIQUE (series_slug);

ALTER TABLE ONLY public.motorcycles ADD CONSTRAINT motorcycles_pkey PRIMARY KEY (motorcycle_id);

ALTER TABLE ONLY public.order_items ADD CONSTRAINT order_items_pkey PRIMARY KEY (item_id);

ALTER TABLE ONLY public.orders ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);

ALTER TABLE ONLY public.performance ADD CONSTRAINT performance_motorcycle_id_key UNIQUE (motorcycle_id);
ALTER TABLE ONLY public.performance ADD CONSTRAINT performance_pkey PRIMARY KEY (performance_id);

ALTER TABLE ONLY public.power ADD CONSTRAINT power_motorcycle_id_key UNIQUE (motorcycle_id);
ALTER TABLE ONLY public.power ADD CONSTRAINT power_pkey PRIMARY KEY (power_id);

ALTER TABLE ONLY public.system_notifications ADD CONSTRAINT system_notifications_pkey PRIMARY KEY (notification_id);

ALTER TABLE ONLY public.users ADD CONSTRAINT users_email_key UNIQUE (email);
ALTER TABLE ONLY public.users ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);
ALTER TABLE ONLY public.users ADD CONSTRAINT users_user_name_key UNIQUE (user_name);


ALTER TABLE ONLY public.categories ADD CONSTRAINT categories_series_id_fkey FOREIGN KEY (series_id) REFERENCES public.model_series(series_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.model_series ADD CONSTRAINT model_series_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.category_groups(group_id) ON DELETE SET NULL;
ALTER TABLE ONLY public.motorcycles ADD CONSTRAINT motorcycles_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(category_id);

ALTER TABLE ONLY public.details ADD CONSTRAINT details_motorcycle_id_fkey FOREIGN KEY (motorcycle_id) REFERENCES public.motorcycles(motorcycle_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.performance ADD CONSTRAINT performance_motorcycle_id_fkey FOREIGN KEY (motorcycle_id) REFERENCES public.motorcycles(motorcycle_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.power ADD CONSTRAINT power_motorcycle_id_fkey FOREIGN KEY (motorcycle_id) REFERENCES public.motorcycles(motorcycle_id) ON DELETE CASCADE;

ALTER TABLE ONLY public.orders ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;

ALTER TABLE ONLY public.order_items ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.order_items ADD CONSTRAINT order_items_motorcycle_id_fkey FOREIGN KEY (motorcycle_id) REFERENCES public.motorcycles(motorcycle_id) ON DELETE RESTRICT;

ALTER TABLE ONLY public.system_notifications ADD CONSTRAINT system_notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE SET NULL;


GRANT USAGE ON SCHEMA public TO app_user;
GRANT USAGE ON SCHEMA public TO readonly_user;
GRANT USAGE ON SCHEMA public TO admin_user;

GRANT ALL ON FUNCTION public.search_motorcycles(p_category_id integer, p_min_price numeric, p_max_price numeric, p_year_from integer, p_limit integer, p_offset integer) TO app_user;
GRANT ALL ON FUNCTION public.search_motorcycles(p_category_id integer, p_min_price numeric, p_max_price numeric, p_year_from integer, p_limit integer, p_offset integer) TO readonly_user;
GRANT ALL ON FUNCTION public.search_motorcycles(p_category_id integer, p_min_price numeric, p_max_price numeric, p_year_from integer, p_limit integer, p_offset integer) TO admin_user;
GRANT ALL ON FUNCTION public.update_order_total() TO app_user;
GRANT ALL ON FUNCTION public.update_order_total() TO readonly_user;
GRANT ALL ON FUNCTION public.update_order_total() TO admin_user;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.categories TO app_user; GRANT SELECT ON TABLE public.categories TO readonly_user; GRANT ALL ON TABLE public.categories TO admin_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.category_groups TO app_user; GRANT SELECT ON TABLE public.category_groups TO readonly_user; GRANT ALL ON TABLE public.category_groups TO admin_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.details TO app_user; GRANT SELECT ON TABLE public.details TO readonly_user; GRANT ALL ON TABLE public.details TO admin_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.model_series TO app_user; GRANT SELECT ON TABLE public.model_series TO readonly_user; GRANT ALL ON TABLE public.model_series TO admin_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.motorcycles TO app_user; GRANT SELECT ON TABLE public.motorcycles TO readonly_user; GRANT ALL ON TABLE public.motorcycles TO admin_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.order_items TO app_user; GRANT SELECT ON TABLE public.order_items TO readonly_user; GRANT ALL ON TABLE public.order_items TO admin_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.orders TO app_user; GRANT SELECT ON TABLE public.orders TO readonly_user; GRANT ALL ON TABLE public.orders TO admin_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.performance TO app_user; GRANT SELECT ON TABLE public.performance TO readonly_user; GRANT ALL ON TABLE public.performance TO admin_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.power TO app_user; GRANT SELECT ON TABLE public.power TO readonly_user; GRANT ALL ON TABLE public.power TO admin_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.system_notifications TO app_user; GRANT SELECT ON TABLE public.system_notifications TO readonly_user; GRANT ALL ON TABLE public.system_notifications TO admin_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.users TO app_user; GRANT SELECT ON TABLE public.users TO readonly_user; GRANT ALL ON TABLE public.users TO admin_user;


GRANT SELECT,USAGE ON SEQUENCE public.categories_category_id_seq TO app_user; GRANT ALL ON SEQUENCE public.categories_category_id_seq TO admin_user;
GRANT SELECT,USAGE ON SEQUENCE public.category_groups_group_id_seq TO app_user; GRANT ALL ON SEQUENCE public.category_groups_group_id_seq TO admin_user;
GRANT SELECT,USAGE ON SEQUENCE public.details_detail_id_seq TO app_user; GRANT ALL ON SEQUENCE public.details_detail_id_seq TO admin_user;
GRANT SELECT,USAGE ON SEQUENCE public.model_series_series_id_seq TO app_user; GRANT ALL ON SEQUENCE public.model_series_series_id_seq TO admin_user;
GRANT SELECT,USAGE ON SEQUENCE public.motorcycles_motorcycle_id_seq TO app_user; GRANT ALL ON SEQUENCE public.motorcycles_motorcycle_id_seq TO admin_user;
GRANT SELECT,USAGE ON SEQUENCE public.order_items_item_id_seq TO app_user; GRANT ALL ON SEQUENCE public.order_items_item_id_seq TO admin_user;
GRANT SELECT,USAGE ON SEQUENCE public.orders_order_id_seq TO app_user; GRANT ALL ON SEQUENCE public.orders_order_id_seq TO admin_user;
GRANT SELECT,USAGE ON SEQUENCE public.performance_performance_id_seq TO app_user; GRANT ALL ON SEQUENCE public.performance_performance_id_seq TO admin_user;
GRANT SELECT,USAGE ON SEQUENCE public.power_power_id_seq TO app_user; GRANT ALL ON SEQUENCE public.power_power_id_seq TO admin_user;
GRANT SELECT,USAGE ON SEQUENCE public.system_notifications_notification_id_seq TO app_user; GRANT ALL ON SEQUENCE public.system_notifications_notification_id_seq TO admin_user;
GRANT SELECT,USAGE ON SEQUENCE public.users_user_id_seq TO app_user; GRANT ALL ON SEQUENCE public.users_user_id_seq TO admin_user;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO readonly_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO admin_user;