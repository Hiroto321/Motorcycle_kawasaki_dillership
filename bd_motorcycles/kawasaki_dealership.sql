--
-- PostgreSQL database dump
--

\restrict UtGHeETA4FLx36M7paFOZy7SQTvYi2jwGtPeXmT2ysP0n3bn0aDFUzeI2fSQbUJ

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

-- Started on 2026-05-25 18:13:20

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 249 (class 1255 OID 17211)
-- Name: search_motorcycles(integer, numeric, numeric, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- TOC entry 248 (class 1255 OID 17209)
-- Name: update_order_total(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 17005)
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    category_id integer NOT NULL,
    category_name character varying(50) NOT NULL,
    series_id integer
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 17004)
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_category_id_seq OWNER TO postgres;

--
-- TOC entry 4957 (class 0 OID 0)
-- Dependencies: 217
-- Name: categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_category_id_seq OWNED BY public.categories.category_id;


--
-- TOC entry 234 (class 1259 OID 17155)
-- Name: category_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category_groups (
    group_id integer NOT NULL,
    group_name character varying(100) NOT NULL,
    group_slug character varying(50),
    display_order integer DEFAULT 0
);


ALTER TABLE public.category_groups OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 17154)
-- Name: category_groups_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.category_groups_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.category_groups_group_id_seq OWNER TO postgres;

--
-- TOC entry 4960 (class 0 OID 0)
-- Dependencies: 233
-- Name: category_groups_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.category_groups_group_id_seq OWNED BY public.category_groups.group_id;


--
-- TOC entry 222 (class 1259 OID 17053)
-- Name: details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.details (
    detail_id integer NOT NULL,
    motorcycle_id integer NOT NULL,
    frame_type character varying(100),
    rake_trail character varying(50),
    overall_length_in numeric(5,2),
    overall_width_in numeric(5,2),
    overall_height_in numeric(5,2),
    ground_clearance_in numeric(5,2),
    seat_height_in numeric(5,2),
    estimated_dry_weight_lbs numeric(6,2),
    curb_weight_lbs numeric(6,2),
    fuel_capacity_gal numeric(5,2),
    wheelbase_in numeric(6,2),
    special_features character varying(500),
    color_choices character varying(500)
);


ALTER TABLE public.details OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 17052)
-- Name: details_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.details_detail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.details_detail_id_seq OWNER TO postgres;

--
-- TOC entry 4963 (class 0 OID 0)
-- Dependencies: 221
-- Name: details_detail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.details_detail_id_seq OWNED BY public.details.detail_id;


--
-- TOC entry 236 (class 1259 OID 17173)
-- Name: model_series; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.model_series (
    series_id integer NOT NULL,
    series_name character varying(100) NOT NULL,
    group_id integer,
    series_slug character varying(50),
    display_order integer DEFAULT 0
);


ALTER TABLE public.model_series OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 17172)
-- Name: model_series_series_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.model_series_series_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.model_series_series_id_seq OWNER TO postgres;

--
-- TOC entry 4966 (class 0 OID 0)
-- Dependencies: 235
-- Name: model_series_series_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.model_series_series_id_seq OWNED BY public.model_series.series_id;


--
-- TOC entry 220 (class 1259 OID 17014)
-- Name: motorcycles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.motorcycles (
    motorcycle_id integer NOT NULL,
    model_name character varying(100) NOT NULL,
    year integer NOT NULL,
    engine_cc integer,
    price numeric(10,2) NOT NULL,
    image_url text,
    category_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.motorcycles OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17013)
-- Name: motorcycles_motorcycle_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.motorcycles_motorcycle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.motorcycles_motorcycle_id_seq OWNER TO postgres;

--
-- TOC entry 4969 (class 0 OID 0)
-- Dependencies: 219
-- Name: motorcycles_motorcycle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.motorcycles_motorcycle_id_seq OWNED BY public.motorcycles.motorcycle_id;


--
-- TOC entry 230 (class 1259 OID 17120)
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    item_id integer NOT NULL,
    order_id integer,
    motorcycle_id integer,
    quantity integer DEFAULT 1 NOT NULL,
    price_at_order numeric(10,2) NOT NULL,
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 17119)
-- Name: order_items_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_item_id_seq OWNER TO postgres;

--
-- TOC entry 4972 (class 0 OID 0)
-- Dependencies: 229
-- Name: order_items_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_item_id_seq OWNED BY public.order_items.item_id;


--
-- TOC entry 228 (class 1259 OID 17102)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    user_id integer,
    order_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20) DEFAULT 'pending'::character varying,
    delivery_address text,
    total_amount numeric(10,2) DEFAULT 0,
    delivery_cost numeric(10,2) DEFAULT 0,
    CONSTRAINT orders_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'confirmed'::character varying, 'shipped'::character varying, 'delivered'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 17101)
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_order_id_seq OWNER TO postgres;

--
-- TOC entry 4975 (class 0 OID 0)
-- Dependencies: 227
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- TOC entry 226 (class 1259 OID 17085)
-- Name: performance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.performance (
    performance_id integer NOT NULL,
    motorcycle_id integer NOT NULL,
    front_suspension text,
    rear_suspension text,
    front_tire character varying(50),
    rear_tire character varying(50),
    front_brakes text,
    rear_brakes text
);


ALTER TABLE public.performance OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 17084)
-- Name: performance_performance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.performance_performance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.performance_performance_id_seq OWNER TO postgres;

--
-- TOC entry 4978 (class 0 OID 0)
-- Dependencies: 225
-- Name: performance_performance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.performance_performance_id_seq OWNED BY public.performance.performance_id;


--
-- TOC entry 224 (class 1259 OID 17069)
-- Name: power; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.power (
    power_id integer NOT NULL,
    motorcycle_id integer NOT NULL,
    engine_type character varying(200),
    displacement_cc integer,
    bore_x_stroke character varying(50),
    compression_ratio character varying(100),
    maximum_horsepower character varying(50),
    maximum_torque character varying(50),
    fuel_system text,
    ignition character varying(100),
    transmission character varying(200),
    final_drive character varying(50),
    electronic_rider_aids character varying(1000)
);


ALTER TABLE public.power OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17068)
-- Name: power_power_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.power_power_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.power_power_id_seq OWNER TO postgres;

--
-- TOC entry 4981 (class 0 OID 0)
-- Dependencies: 223
-- Name: power_power_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.power_power_id_seq OWNED BY public.power.power_id;


--
-- TOC entry 232 (class 1259 OID 17139)
-- Name: system_notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system_notifications (
    notification_id integer NOT NULL,
    user_id integer,
    event_type character varying(50) NOT NULL,
    title character varying(100) NOT NULL,
    message text NOT NULL,
    payload jsonb,
    is_read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.system_notifications OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 17138)
-- Name: system_notifications_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.system_notifications_notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.system_notifications_notification_id_seq OWNER TO postgres;

--
-- TOC entry 4984 (class 0 OID 0)
-- Dependencies: 231
-- Name: system_notifications_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.system_notifications_notification_id_seq OWNED BY public.system_notifications.notification_id;


--
-- TOC entry 216 (class 1259 OID 16990)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    user_name character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_login timestamp without time zone,
    is_active boolean DEFAULT true,
    role character varying(50) DEFAULT 'user'::character varying NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16989)
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO postgres;

--
-- TOC entry 4987 (class 0 OID 0)
-- Dependencies: 215
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- TOC entry 4691 (class 2604 OID 17008)
-- Name: categories category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN category_id SET DEFAULT nextval('public.categories_category_id_seq'::regclass);


--
-- TOC entry 4707 (class 2604 OID 17158)
-- Name: category_groups group_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_groups ALTER COLUMN group_id SET DEFAULT nextval('public.category_groups_group_id_seq'::regclass);


--
-- TOC entry 4694 (class 2604 OID 17056)
-- Name: details detail_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.details ALTER COLUMN detail_id SET DEFAULT nextval('public.details_detail_id_seq'::regclass);


--
-- TOC entry 4709 (class 2604 OID 17176)
-- Name: model_series series_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.model_series ALTER COLUMN series_id SET DEFAULT nextval('public.model_series_series_id_seq'::regclass);


--
-- TOC entry 4692 (class 2604 OID 17017)
-- Name: motorcycles motorcycle_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.motorcycles ALTER COLUMN motorcycle_id SET DEFAULT nextval('public.motorcycles_motorcycle_id_seq'::regclass);


--
-- TOC entry 4702 (class 2604 OID 17123)
-- Name: order_items item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN item_id SET DEFAULT nextval('public.order_items_item_id_seq'::regclass);


--
-- TOC entry 4697 (class 2604 OID 17105)
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- TOC entry 4696 (class 2604 OID 17088)
-- Name: performance performance_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.performance ALTER COLUMN performance_id SET DEFAULT nextval('public.performance_performance_id_seq'::regclass);


--
-- TOC entry 4695 (class 2604 OID 17072)
-- Name: power power_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.power ALTER COLUMN power_id SET DEFAULT nextval('public.power_power_id_seq'::regclass);


--
-- TOC entry 4704 (class 2604 OID 17142)
-- Name: system_notifications notification_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_notifications ALTER COLUMN notification_id SET DEFAULT nextval('public.system_notifications_notification_id_seq'::regclass);


--
-- TOC entry 4687 (class 2604 OID 16993)
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- TOC entry 4929 (class 0 OID 17005)
-- Dependencies: 218
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (category_id, category_name, series_id) FROM stdin;
1	SPORT	1
2	SUPERSPORT	1
3	HYPERSPORT	1
4	Mini Naked	2
5	Supernaked	2
6	Retro Sport	2
7	Hypernaked	2
9	Adventure/Touring	3
10	Retro Classic	4
11	Cruiser	5
12	Sport Cruiser	6
13	Classic Cruiser	6
14	Bagger Cruiser	6
15	Touring Cruiser	6
16	Adventure	7
17	Off-Road	9
18	Dual-Sport	9
19	Supermoto	9
20	Youth MX	10
21	Full-Size MX	10
22	Full-Size Cross Country	10
24	Dual-Sport-(KLR)	8
\.


--
-- TOC entry 4945 (class 0 OID 17155)
-- Dependencies: 234
-- Data for Name: category_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.category_groups (group_id, group_name, group_slug, display_order) FROM stdin;
1	STREET/TRACK	street-track	1
2	STREET	street	2
3	ADVENTURE / TRAIL / DUAL-SPORT / SUPERMOTO	adventure	3
4	MOTOCROSS / CROSS-COUNTRY	motocross	4
\.


--
-- TOC entry 4933 (class 0 OID 17053)
-- Dependencies: 222
-- Data for Name: details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.details (detail_id, motorcycle_id, frame_type, rake_trail, overall_length_in, overall_width_in, overall_height_in, ground_clearance_in, seat_height_in, estimated_dry_weight_lbs, curb_weight_lbs, fuel_capacity_gal, wheelbase_in, special_features, color_choices) FROM stdin;
1	2	Trellis, high-tensile steel	24.4° / 3.7 in	78.00	27.00	43.50	6.70	30.90	\N	308.70	0.00	53.90	ERGO-FIT, TFT Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP, Battery Temperature-Charge-Remaining Range Indicators	Metallic Bright Silver/Matte Lime Green/Ebony
4	5	Trellis, high-tensile steel	24.5°/3.6 in	78.50	28.70	44.10	5.70	30.90	\N	374.90	3.70	54.10	ERGO-FIT, LCD Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP	Metallic Matte Whitish Silver/Metallic Moondust Gray, Passion Red/Metallic Flat Spark Black/Metallic Matte Dark Gray, Metallic Flat Spark Black/Metallic Spark Black/Metallic Moondust Gray
5	6	Trellis, high-tensile steel	24.5°/3.6 in	78.50	28.70	44.10	5.70	30.90	\N	377.10	3.70	54.10	ERGO-FIT, LCD Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP	Lime Green, Metallic Flat Spark Black/Metallic Spark Black, Metallic Matte Twilight Blue/Candy Persimmon Red, Metallic Yellowish Green/Ebony
6	7	Trellis, high-tensile steel	24.7°/3.6 in	78.50	28.70	46.50	5.70	30.90	\N	381.50	3.70	54.10	ERGO-FIT, Full-color TFT Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP, Kawasaki Intelligent Proximity Activation Start System (KIPASS), USB-C outlet	Lime Green, Metallic Yellowish Green/Ebony, Metallic Matte Twilight Blue/Candy Persimmon Red
7	8	Trellis, high-tensile steel	24.7°/3.6 in	78.50	28.70	46.50	5.70	30.90	\N	381.50	3.70	54.10	ERGO-FIT, Full-color TFT Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP, Kawasaki Intelligent Proximity Activation Start System (KIPASS), USB-C outlet	Metallic Flat Spark Black/Metallic Spark Black/Metallic Moondust Gray, Passion Red/Metallic Flat Spark Black/Metallic Matte Dark Gray
8	9	Trellis, high-tensile steel	24.7°/3.6 in	78.50	28.70	44.10	5.70	30.90	\N	370.40	3.70	54.10	ERGO-FIT, LCD Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP	Lime Green/Ebony/Pearl Blizzard White
9	10	Trellis, high-tensile steel	24.7°/3.6 in	78.50	28.70	46.50	5.70	30.90	\N	381.50	3.70	54.10	ERGO-FIT, Full-color TFT Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP, Kawasaki Intelligent Proximity Activation Start System (KIPASS), USB-C outlet	Lime Green/Ebony/Pearl Blizzard White
10	11	Trellis, high-tensile steel	24.0°/3.9 in	80.90	29.10	45.10	5.10	31.10	\N	425.60	4.00	55.50	Twin LED Headlights	Lime Green, Metallic Flat Spark Black/Metallic Carbon Gray, Metallic Matte Whitish Silver/Metallic Flat Spark Black, Metallic Yellowish Green/Metallic Spark Black
11	12	Trellis, high-tensile steel	24.0°/3.9 in	80.90	29.10	45.10	5.10	31.10	\N	423.40	4.00	55.50	Twin LED Headlights	Candy Steel Furnace Orange/Metallic Spark Black/Metallic Royal Purple, Metallic Matte Old School Green/Metallic Spark Black, Metallic Spark Black/Metallic Flat Spark Black
12	13	Trellis, high-tensile steel	24.0°/3.9 in	80.90	29.10	45.10	5.10	31.10	\N	425.60	4.00	55.50	ERGO-FIT, LCD Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP, KRT Edition Styling	Lime Green/Ebony/Pearl Blizzard White
13	14	Trellis, high-tensile steel	25°/4.1 in	84.40	29.50	44.70	5.10	31.30	\N	502.70	3.70	60.40	e-boost, Idling Stop Function, Regenerative System, TFT Color Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP	Metallic Bright Silver/Metallic Matte Lime Green/Ebony
16	17	Twin-spar aluminum	24.0°/3.9 in	82.70	31.70	46.90	5.30	32.30	\N	518.20	5.00	56.70	4.3" All-digital TFT Instrumentation, All-LED lighting, USB Type-C outlet, Smartphone Connectivity with available Voice Command via RIDEOLOGY THE APP MOTORCYCLE	Metallic Brilliant Golden Black/Metallic Carbon Gray
17	18	Twin-spar aluminum	24.0°/3.9 in	82.70	31.70	46.90	5.30	32.30	\N	518.20	5.00	56.70	4.3" All-digital TFT Instrumentation, All-LED lighting, USB Type-C outlet, Smartphone Connectivity with available Voice Command via RIDEOLOGY THE APP MOTORCYCLE	Metallic Carbon Gray/Metallic Diablo Black
18	19	Twin-spar aluminum	24.0°/3.9 in	82.70	31.70	46.90	5.30	32.30	\N	516.00	5.00	56.70	4.3" All-digital TFT Instrumentation, All-LED lighting, USB Type-C outlet, **Grip heaters**, Smartphone Connectivity with available Voice Command via RIDEOLOGY THE APP MOTORCYCLE	Metallic Deep Blue/Metallic Diablo Black
19	20	Twin-spar aluminum	24.0°/3.9 in	82.70	31.70	46.90	5.30	32.30	\N	516.00	5.00	56.70	4.3" All-digital TFT Instrumentation, All-LED lighting, USB Type-C outlet, Grip heaters, Smartphone Connectivity with available Voice Command via RIDEOLOGY THE APP MOTORCYCLE	Emerald Blazed Green/Metallic Diablo Black
20	21	Trellis, high-tensile steel	23.5°/3.8 in	78.30	30.10	43.70	5.30	31.50	\N	414.50	4.00	54.30	4.3" Full-color TFT Instrumentation, Smartphone Connectivity via RIDEOLOGY THE APP	Metallic Spark Black
21	22	Trellis, high-tensile steel	23.5°/3.8 in	78.30	30.10	43.70	5.30	31.50	\N	414.50	4.00	54.30	4.3" Full-color TFT Instrumentation, Smartphone Connectivity via RIDEOLOGY THE APP	Metallic Spark Black
22	23	Trellis, high-tensile steel	23.5°/3.8 in	78.30	30.10	43.70	5.30	31.50	\N	414.50	4.00	54.30	4.3" Full-color TFT Instrumentation, Smartphone Connectivity via RIDEOLOGY THE APP	Lime Green, Metallic Matte Graphenesteel Gray/Metallic Spark Black, Pearl Robotic White/Metallic Spark Black
23	24	Trellis, high-tensile steel	23.5°/3.8 in	78.30	30.10	43.70	5.30	31.50	\N	414.50	4.00	54.30	4.3" Full-color TFT Instrumentation, Smartphone Connectivity via RIDEOLOGY THE APP	Metallic Matte Whitish Silver/Metallic Flat Spark Black
24	25	Trellis, high-tensile steel	23.5°/3.8 in	78.30	30.10	43.70	5.30	31.50	\N	414.50	4.00	54.30	4.3" Full-color TFT Instrumentation, Smartphone Connectivity via RIDEOLOGY THE APP	Lime Green/Ebony/Pearl Blizzard White
25	26	Aluminum perimeter	23.5°/4.0 in	79.70	28.00	43.30	5.10	32.70	\N	432.20	4.50	55.10	4.3" Full-Color TFT Instrumentation, Smartphone Connectivity via RIDEOLOGY THE APP	Lime Green, Pearl Robotic White/Metallic Spark Black, Metallic Matte Graphenesteel Gray/Metallic Spark Black/Pearl Storm Gray, Metallic Matte Dark Gray/Ebony
26	27	Aluminum perimeter	23.5°/4.0 in	79.70	28.00	43.30	5.10	32.70	\N	432.20	4.50	55.10	4.3" Full-Color TFT Instrumentation, Smartphone Connectivity via RIDEOLOGY THE APP	Pearl Robotic White/Metallic Graphite Gray, Metallic Matte Dark Gray/Ebony
27	28	Aluminum perimeter	23.5°/4.0 in	79.70	28.00	43.30	5.10	32.70	\N	432.20	4.50	55.10	4.3" Full-Color TFT Instrumentation, Smartphone Connectivity via RIDEOLOGY THE APP, KRT Edition Graphics	Lime Green/Ebony/Pearl Blizzard White
28	29	Twin spar, cast aluminum	25.0°/4.1 in	82.10	29.50	46.50	5.10	32.50	\N	458.60	4.50	57.10	5" All-digital TFT color instrumentation, All-LED lighting, Öhlins steering damper, Smartphone Connectivity with available Voice Command and Turn-by-Turn Navigation via RIDEOLOGY THE APP MOTORCYCLE, Aerodynamic Winglets	Lime Green/Blue 24, Metallic Matte Graphenesteel Gray/Metallic Spark Black/Pearl Storm Gray
29	30	Aluminum perimeter	25.0°/4.1 in	82.10	29.50	46.70	5.30	32.90	\N	452.00	4.50	57.10	4.3" Full-Color TFT Instrumentation, Smartphone Connectivity via RIDEOLOGY THE APP, IMU-Enhanced Electronics Package	Metallic Flat Spark Black/Ebony
30	31	Twin spar, cast aluminum	25.0°/4.1 in	82.10	29.50	46.50	5.10	32.50	\N	458.60	4.50	57.10	5" All-digital TFT color instrumentation, All-LED lighting, Öhlins steering damper, Smartphone Connectivity with available Voice Command and Turn-by-Turn Navigation via RIDEOLOGY THE APP MOTORCYCLE, PANKL High-Performance Parts, Limited Production Model	Lime Green
31	32	Aluminum perimeter	25.0°/4.1 in	82.10	29.50	46.70	5.30	32.90	\N	456.40	4.50	57.10	4.3" Full-Color TFT Instrumentation, Smartphone Connectivity via RIDEOLOGY THE APP, Forged Marchesini Wheels, Limited-Production Model	Metallic Matte Graphenesteel Gray
32	33	Aluminum perimeter	25.0°/4.1 in	82.10	29.50	46.70	5.30	32.90	\N	452.00	4.50	57.10	4.3" Full-Color TFT Instrumentation, Smartphone Connectivity via RIDEOLOGY THE APP, KRT Edition Graphics	Lime Green/Ebony/Pearl Blizzard White
33	34	Aluminum monocoque	23.0°/3.7 in	85.40	30.30	46.10	4.90	31.50	\N	593.10	5.80	58.30	4.3" Full-Color TFT Instrumentation, Smartphone Connectivity via RIDEOLOGY THE APP	Metallic Matte Sovereign Red/Metallic Flat Spark Black/Metallic Matte Graphite Gray
34	35	Trellis, high-tensile steel, with swingarm mounting plate	24.7°/4.1 in	85.60	31.10	49.60	5.10	32.90	\N	590.90	5.00	58.30	Supercharged engine, 6.5" Full-color TFT Instrumentation, All-LED lighting including Cornering Lights, KIPASS, Grip heaters, Tire Pressure Monitoring System (TPMS), Smartphone Connectivity via Kawasaki SPIN infotainment app	Metallic Brilliant Golden Black/Metallic Diablo Black
35	36	Trellis, high-tensile steel, with swingarm mounting plate	24.7°/4.1 in	85.60	31.10	49.60	5.10	32.90	\N	590.90	5.00	58.30	Supercharged engine, 6.5" Full-color TFT Instrumentation, All-LED lighting including Cornering Lights, KIPASS, Grip heaters, Tire Pressure Monitoring System (TPMS), Smartphone Connectivity via Kawasaki SPIN infotainment app	Emerald Blazed Green/Metallic Diablo Black/Metallic Matte Graphenesteel Gray
36	37	Trellis, high-tensile steel, with swingarm mounting plate	24.5°/4.1 in	82.10	30.30	44.30	5.10	32.50	\N	524.80	4.50	57.30	Supercharged engine, All-digital TFT color Instrumentation, All-LED lighting, Highly Durable Paint, Smartphone Connectivity via RIDEOLOGY THE APP	Mirror Coated Spark Black
37	38	Trellis, high-tensile steel, with swingarm mounting plate	24.5°/4.1 in	82.10	30.30	44.30	5.10	32.50	\N	524.80	4.50	57.30	Supercharged engine, All-digital TFT color Instrumentation, All-LED lighting, Highly Durable Paint, Smartphone Connectivity via RIDEOLOGY THE APP	Mirror Coated Spark Black
38	39	Trellis, high-tensile steel, with swingarm mounting plate	24.5°/4.1 in	82.10	30.30	44.30	5.10	32.50	\N	524.80	4.50	57.30	Supercharged engine, All-digital TFT color Instrumentation, All-LED lighting, Carbon fiber, Highly Durable Paint, Serial number stamp, Smartphone Connectivity via RIDEOLOGY THE APP	Mirror Coated Matte Spark Black/Candy Flat Blazed Green
39	40	Trellis, high-tensile steel, with swingarm mounting plate	24.5°/4.1 in	82.10	30.30	44.30	5.10	32.50	\N	524.80	4.50	57.30	Supercharged engine, All-digital TFT color Instrumentation, All-LED lighting, Carbon fiber, Highly Durable Paint, Serial number stamp, Smartphone Connectivity via RIDEOLOGY THE APP	Mirror Coated Matte Spark Black/Candy Flat Blazed Green
40	41	Trellis, high-tensile steel, with swingarm mounting plate	25.1°/4.3 in	81.50	33.50	45.70	5.10	32.70	\N	476.30	4.50	57.10	Supercharged engine, Carbon fiber aerodynamic downforce generating devices, Bosch IMU with Kawasaki Dynamic Modeling Software, Highly Durable Paint	Mirror Coated Matte Spark Black
41	42	Trellis, high-tensile steel, with swingarm mounting plate	25.1°/4.3 in	81.50	33.50	45.70	5.10	32.70	\N	476.30	4.50	57.10	Supercharged engine, Carbon fiber aerodynamic downforce generating devices, Bosch IMU with Kawasaki Dynamic Modeling Software, Highly Durable Paint	Mirror Coated Matte Spark Black
42	43	Backbone	26.0°/2.7 in	66.90	29.50	39.60	6.10	31.70	\N	224.80	2.00	46.30	Fuel-injected 125cc engine, LCD screen with Gear Position Indicator	Metallic Yellowish Green, Pearl Robotic White, Cypher Camo Beige
43	44	Backbone	26.0°/2.7 in	66.90	29.50	39.60	6.10	31.70	\N	224.80	2.00	46.30	Fuel-injected 125cc engine, LCD screen with Gear Position Indicator	Pearl Lava Orange, Metallic Matte Old School Green, Cypher Camo Beige
44	45	Trellis, high-tensile steel	24.4° / 3.7 in	78.00	28.70	40.70	6.70	30.90	\N	297.70	\N	53.90	ERGO-FIT, TFT Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP, Battery Temperature-Charge-Remaining Range Indicators, Battery Range: 41 mi (approximate in ROAD Mode w/o e-boost)	Metallic Bright Silver/Matte Lime Green/Ebony
45	46	Trellis, high-tensile steel	24.5°/3.6 in	78.50	31.50	41.50	5.70	30.90	\N	368.20	3.70	54.10	ERGO-FIT, LCD Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP	Metallic Matte Graphenesteel Gray/Metallic Flat Spark Black
46	47	Trellis, high-tensile steel	24.5°/3.6 in	78.50	31.50	41.50	5.70	30.90	\N	366.00	3.70	54.10	ERGO-FIT, LCD Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP	Metallic Spark Black/Metallic Matte Graphenesteel Gray
47	48	Trellis, high-tensile steel	24.5°/3.6 in	78.50	31.50	43.30	5.70	30.90	\N	372.60	3.70	54.10	ERGO-FIT, All-LED lighting, Full-color TFT Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP, USB-C outlet	Pearl Blizzard White/Ebony
48	49	Trellis, high-tensile steel	24.5°/3.6 in	78.50	31.50	43.30	5.70	30.90	\N	370.40	3.70	54.10	ERGO-FIT, All-LED lighting, Full-color TFT Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP, USB-C outlet	Candy Persimmon Red/Metallic Flat Spark Black/Metallic Matte Graphenesteel Gray
49	50	Trellis, high tensile steel	24.0°/3.9 in	80.90	31.70	42.50	5.10	31.70	\N	416.70	4.00	55.50	4.3-in All-digital TFT color Instrumentation, All-LED lighting, Smartphone Connectivity via RIDEOLOGY THE APP MOTORCYCLE, USB Type-C outlet available as an accessory	Metallic Matte Graphenesteel Gray/Metallic Flat Spark Black
50	51	Trellis, high tensile steel	24.0°/3.9 in	80.90	30.10	41.90	5.10	31.10	\N	414.50	4.00	55.50	4.3" All-digital TFT color Instrumentation, Smartphone Connectivity via RIDEOLOGY THE APP	Metallic Spark Black/Green, Metallic Matte Dark Gray/Metallic Spark Black
51	52	Trellis, high-tensile steel	25°/4.1 in	84.40	31.70	42.50	5.10	31.30	\N	498.30	3.70	60.40	e-boost, Idling Stop Function, Regenerative System, TFT Color Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP, WALK MODE (WITH REVERSE)	Metallic Bright Silver/Metallic Matte Lime Green/Ebony
52	53	Trellis, high tensile steel	24.7°/4.3 in	81.30	32.70	43.30	5.70	31.90	\N	469.70	4.50	57.10	5" All-digital TFT color instrumentation, All-LED lighting, ERGO-FIT, Smartphone Connectivity with available Voice Command and Turn-by-Turn Navigation via RIDEOLOGY THE APP MOTORCYCLE, IMU-Enhanced ABS	Metallic Matte Graphenesteel Gray/Metallic Flat Spark Black, Pearl Blizzard White/Ebony
53	54	Trellis, high tensile steel	24.7°/4.3 in	81.30	32.70	43.30	5.70	31.90	\N	467.50	4.50	57.10	5" All-digital TFT color instrumentation, All-LED lighting, ERGO-FIT, Smartphone Connectivity with available Voice Command and Turn-by-Turn Navigation via RIDEOLOGY THE APP MOTORCYCLE	Metallic Spark Black/Metallic Carbon Gray/Ebony, Galaxy Silver/Metallic Spark Black/Phantom Blue
54	55	Trellis, high tensile steel	24.7°/4.3 in	81.30	32.70	44.70	5.70	31.90	\N	471.90	4.50	57.10	5" All-digital TFT color instrumentation, All-LED lighting, USB Type-C outlet, ERGO-FIT, Smartphone Connectivity with available Voice Command and Turn-by-Turn Navigation via RIDEOLOGY THE APP MOTORCYCLE	Metallic Matte Graphenesteel Gray/Metallic Matte Carbon Gray
55	56	Trellis, high tensile steel	24.7°/4.3 in	81.30	32.70	44.70	5.70	31.90	\N	471.90	4.50	57.10	5" All-digital TFT color instrumentation, All-LED lighting, USB Type-C outlet, ERGO-FIT, Smartphone Connectivity with available Voice Command and Turn-by-Turn Navigation via RIDEOLOGY THE APP MOTORCYCLE	Metallic Matte Graphite Gray/Ebony/Metallic Graphite Gray
56	57	Twin-tube, aluminum	24.5°/4.0 in	80.90	32.50	42.70	4.90	32.10	\N	487.30	4.50	56.70	5" All-digital TFT color instrumentation, All-LED lighting, USB-C outlet, Smartphone Connectivity with available Voice Command and Turn-by-Turn Navigation via RIDEOLOGY THE APP MOTORCYCLE, IMU-Equipped Advanced Electronics Package	Metallic Matte Graphenesteel Gray/Metallic Matte Carbon Gray
57	58	Trellis, high tensile steel	24.0°/3.9 in	81.30	31.50	43.90	4.90	31.50	\N	412.30	3.20	55.30	Parallel-Twin engine tuned for low-mid range power, Slim design, Retro styling	Ebony
58	59	Trellis, high tensile steel	24.0°/3.9 in	81.30	31.50	43.90	4.90	31.50	\N	412.30	3.20	55.30	Parallel-Twin engine tuned for low-mid range power, Slim design, and low seat height	Ebony
59	60	Trellis, high tensile steel	25.0°/3.9 in	82.70	32.10	44.70	5.30	31.90	\N	476.30	4.50	57.70	Z1-Inspired Black Ball Edition, All-LED lighting, ERGO-FIT, Smartphone Connectivity with available Voice Command and Turn-by-Turn Navigation via RIDEOLOGY THE APP MOTORCYCLE, IMU-Equipped Advanced Electronics Package	Ebony
60	61	Trellis, high tensile steel	25.0°/3.9 in	82.70	34.10	45.30	5.10	32.90	\N	474.10	4.50	57.90	Authentic retro styling, 4-cylinder engine, All-LED lighting, ERGO-FIT	Candy Tone Red
61	62	Trellis, high tensile steel	25.0°/3.9 in	82.70	33.30	46.90	5.30	32.30	\N	480.70	4.50	57.70	Cafe-Racer Style Front Cowl, Iconic Teardrop Fuel Tank, All-LED lighting, ERGO-FIT, Smartphone Connectivity with available Voice Command and Turn-by-Turn Navigation via RIDEOLOGY THE APP MOTORCYCLE	Ebony
62	63	Trellis, high tensile steel	25.0°/3.9 in	82.70	33.30	46.90	5.10	32.30	\N	476.20	4.50	57.90	Cafe Racer Style Front Cowl, Iconic Teardrop Fuel Tank, All-LED lighting, ERGO-FIT, Smartphone Connectivity with available Voice Command and Turn-by-Turn Navigation via RIDEOLOGY THE APP MOTORCYCLE	Ebony
63	64	Trellis, high tensile steel	25.0°/3.9 in	82.70	32.10	44.70	5.50	32.30	\N	476.30	4.50	57.70	All-LED lighting, USB-C outlet, ERGO-FIT, Smartphone Connectivity with available Voice Command and Turn-by-Turn Navigation via RIDEOLOGY THE APP MOTORCYCLE	Metallic Spark Black
64	65	Trellis, high tensile steel	25.0°/3.9 in	82.70	34.10	45.30	5.10	33.30	\N	474.10	4.50	57.90	High-Grade Öhlins Rear Shock, Authentic Retro Styling	Metallic Graphite Gray/Ebony
65	66	Trellis, high tensile steel	24.9°/4.1 in	82.10	31.90	44.50	5.50	32.70	\N	531.40	5.00	57.30	Supercharged engine, All-digital TFT color Instrumentation, All-LED lighting, Smartphone Connectivity via RIDEOLOGY THE APP	Metallic Matte Graphenesteel Gray/Metallic Matte Carbon Gray
66	67	Trellis, high tensile steel	24.9°/4.1 in	82.10	31.90	44.50	5.50	32.70	\N	531.40	5.00	57.30	Supercharged engine, All-digital TFT color Instrumentation, All-LED lighting, Smartphone Connectivity via RIDEOLOGY THE APP	Metallic Matte Graphenesteel Gray/Ebony/Mirror Coated Black
72	73	Tubular, diamond	24.3°/4.3 in	85.40	33.90	54.70	7.10	32.10	\N	385.90	4.50	57.10	Ninja-derived 296cc Twin-Cylinder Engine, Long-Travel Suspension, ERGO-FIT	Metallic Phantom Silver/Metallic Flat Spark Black
73	74	Tubular, diamond	24.3°/4.3 in	85.40	33.90	54.70	7.10	32.10	\N	385.90	4.50	57.10	Ninja-derived 296cc Twin-Cylinder Engine, Long-Travel Suspension, ERGO-FIT	Candy Lime Green/Metallic Flat Spark Black
74	75	Double pipe diamond frame constructed from high-tensile steel	25°/4.3 in	85.20	33.10	53.50	6.70	33.30	\N	482.90	5.50	55.70	TFT color instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP, Clean-mount hard saddlebag system (KQR mounts), Hand guards for increased wind protection	Metallic Deep Blue/Metallic Spark Black
75	76	Twin-tube, aluminum	27.0°/4.0 in	89.40	37.40	60.20	5.90	33.10	\N	571.10	5.50	59.80	Kawasaki Electronic Control Suspension (KECS), Full-color TFT Instrumentation, All-LED lighting including Cornering Lights, Grip heaters and hand guards, ERGO-FIT, Smartphone Connectivity via RIDEOLOGY THE APP MOTORCYCLE	Metallic Graphite Gray/Metallic Diablo Black
76	77	Semi-double cradle, steel	27.0°/3.7 in	83.60	31.40	42.90	5.90	29.30	\N	315.30	3.10	55.70	4-Stroke Engine, Disc Brakes with ABS	Metallic Matte Dark Green
78	79	Semi-double cradle, steel	27.0°/3.7 in	83.60	31.40	42.90	5.90	29.30	\N	315.20	3.10	55.70	4-Stroke Engine, Disc Brakes with ABS	Metallic Ocean Blue/Ebony
79	80	Double-cradle high tensile steel	26.0°/3.7 in	86.20	31.10	42.30	4.90	31.10	\N	498.30	4.00	57.70	773cc Air-Cooled Vertical-Twin Engine, Authentic W1-Inspired Styling	Pearl Crystal White
80	81	Double-cradle high tensile steel	26.0°/3.7 in	86.20	31.10	42.30	4.90	31.10	\N	498.30	4.00	57.70	773cc Air-Cooled Vertical-Twin Engine, Authentic W1-Inspired Styling	Metallic Brilliant Golden Black/Ebony
81	82	Trellis, high-tensile steel	30.0°/4.8 in	88.60	30.90	43.30	5.90	28.90	\N	388.10	3.40	59.80	ERGO-FIT, Smartphone Connectivity via RIDEOLOGY THE APP MOTORCYCLE	Urban City White, Metallic Flat Spark Black
82	83	Trellis, high-tensile steel	30.0°/4.8 in	88.60	30.90	43.30	5.90	28.90	\N	388.10	3.40	59.80	ERGO-FIT, Smartphone Connectivity via RIDEOLOGY THE APP MOTORCYCLE	Metallic Flat Spark Black, Pearl Sand Khaki
83	84	Trellis, high-tensile steel	30.0°/4.8 in	88.60	30.90	43.30	5.90	28.90	\N	390.30	3.40	59.80	ERGO-FIT, Smartphone Connectivity via RIDEOLOGY THE APP, Headlight Cowl, Waterproof USB-C Outlet	Metallic Imperial Red/Ebony
84	85	Trellis, high-tensile steel	30.0°/4.8 in	88.60	30.90	43.30	5.90	28.90	\N	390.30	3.40	59.80	ERGO-FIT, Smartphone Connectivity via RIDEOLOGY THE APP, Headlight Cowl, Waterproof USB-C Outlet	Phantom Blue/Ebony
85	86	High-tensile steel diamond frame	31°/4.7 in	90.90	34.60	43.30	5.10	27.80	\N	498.30	3.70	62.00	ERGO-FIT	Metallic Graphite Gray/Metallic Spark Black, Metallic Flat Spark Black
86	87	High-tensile steel diamond frame	31°/4.7 in	90.90	34.60	43.30	5.10	27.80	\N	498.30	3.70	62.00	ERGO-FIT	Metallic Matte Graphite Gray/Metallic Matte Carbon Gray, Metallic Flat Spark Black
87	88	High-tensile steel diamond frame	31°/4.7 in	90.90	34.60	44.50	5.10	27.80	\N	502.70	3.70	62.00	ERGO-FIT, Dark-Tinted Wind Deflector, 2-Tone Paint	Candy Plasma Blue/Metallic Ocean Blue
88	89	High-tensile steel diamond frame	31°/4.7 in	90.90	34.60	44.50	5.10	27.80	\N	502.70	3.70	62.00	ERGO-FIT, Dark-Tinted Wind Deflector, 2-Tone Paint	Metallic Moondust Gray/Metallic Spark Black
89	90	Semi-double cradle, high-tensile steel	32°/6.3 in	97.00	39.60	41.90	5.30	26.80	\N	619.60	5.30	64.80	903cc V-Twin Engine, Wide 180mm Rear Tire	Metallic Ocean Blue/Pearl Stardust White
90	91	Semi-double cradle, high-tensile steel	32°/6.3 in	97.00	39.60	41.90	5.30	26.80	\N	619.60	5.30	64.80	903cc V-Twin Engine, Wide 180mm Rear Tire	Metallic Carbon Gray/Phantom Blue
91	92	Semi-double cradle, high-tensile steel	33°/7.2 in	94.70	35.20	44.10	5.50	27.00	\N	610.80	5.30	64.80	Wide Drag Bars, Parallel Slash-Cut Exhaust Pipes	Metallic Spark Black
92	93	Semi-double cradle, high-tensile steel	33°/7.2 in	94.70	35.20	44.10	5.50	27.00	\N	610.80	5.30	64.80	Wide Drag Bars, Parallel Slash-Cut Exhaust Pipes	Candy Fire Red/Ebony
93	94	Semi-double cradle, high-tensile steel	32°/6.3 in	97.00	39.60	58.30	5.30	26.80	\N	657.10	5.30	64.80	Height Adjustable Windscreen, Comfortable Seat with Passenger Backrest	Metallic Graphite Gray/Metallic Spark Black
94	95	Semi-double cradle, high-tensile steel	32°/6.3 in	97.00	39.60	58.30	5.30	26.80	\N	657.10	5.30	64.80	Height Adjustable Windscreen, Comfortable Seat with Passenger Backrest	Metallic Ocean Blue/Metallic Moondust Gray
95	96	Steel, double-cradle with box-section single-tube backbone	30°/7.0 in	98.80	38.20	50.80	5.70	28.70	\N	844.50	5.30	65.60	Stylish Frame-Mounted Fairing, Integrated audio system with SiriusXM and intercom headset compatibility	Metallic Brilliant Golden Black
96	97	Steel, double-cradle with box-section single-tube backbone	30°/7.0 in	98.80	38.20	50.80	5.70	28.70	\N	844.50	5.30	65.60	Stylish Frame-Mounted Fairing, Integrated audio system with SiriusXM and intercom headset compatibility	Metallic Brilliant Golden Black
97	98	Steel, double-cradle with box-section single-tube backbone	30°/7.0 in	100.80	39.20	61.00	5.30	28.70	\N	895.20	5.30	65.60	Integrated Luggage, Integrated audio system with SiriusXM and intercom headset compatibility	Metallic Ocean Blue/Metallic Moondust Gray
98	99	Steel, double-cradle with box-section single-tube backbone	30°/7.0 in	100.80	39.20	61.00	5.30	28.70	\N	895.20	5.30	65.60	Integrated Luggage, Integrated audio system with SiriusXM and intercom headset compatibility	Metallic Graphite Gray/Metallic Carbon Gray
99	101	Trellis, high tensile steel	28.0°/4.1 in	90.60	37.00	55.30	7.30	34.30	\N	425.60	4.20	61.20	LCD instrument panel, LED headlight & taillight, Adjustable windscreen (55.3/53.3 in), Aluminum skid plate, ERGO-FIT, Smartphone Connectivity	Metallic Carbon Gray/Ebony
100	102	Trellis, high tensile steel	28.0°/4.1 in	90.60	38.60	59.40	7.30	34.30	\N	427.80	4.20	61.20	4.3-in All-digital TFT color Instrumentation, All-LED lighting, Tall adjustable windscreen (59.4/57.5 in), Handguards, Larger aluminum skid plate, ERGO-FIT, Smartphone Connectivity	Pearl Blizzard White, Metallic Bluish Green
101	103	Tubular, semi-double cradle	30.0°/4.8 in	89.80	38.20	57.70	8.30	34.30	\N	456.20	6.10	60.60	Large windscreen for increased comfort, LCD instrument panel	Pearl Solar Yellow, Metallic Spark Black
102	104	Tubular, semi-double cradle	30.0°/4.8 in	89.80	38.20	57.70	8.30	34.30	\N	456.20	6.10	60.60	Large windscreen for increased comfort, LCD instrument panel	Metallic Matte Old School Green, Pearl Crystal White/Metallic Carbon Gray
103	105	Tubular, semi-double cradle	29.5°/4.6 in	88.80	38.20	56.30	7.30	32.10	\N	456.20	6.10	59.60	Lower Seat Height (32.1 in), Seat with optimized urethane for improved comfort	Pearl Solar Yellow, Metallic Spark Black
104	106	Tubular, semi-double cradle	29.5°/4.6 in	88.80	38.20	56.30	7.30	32.10	\N	456.20	6.10	59.60	Lower Seat Height (32.1 in), Seat with optimized urethane for improved comfort	Metallic Matte Old School Green, Pearl Crystal White/Metallic Carbon Gray
105	107	Tubular, semi-double cradle	30.0°/4.8 in	89.80	38.20	57.30	8.30	34.30	\N	487.10	6.10	60.60	Factory installed side cases, Fog lamps, LCD instrument panel	Cypher Camo Beige/Metallic Matte Carbon Gray, Metallic Matte Dark Green
106	108	Tubular, semi-double cradle	30.0°/4.8 in	89.80	38.20	57.30	8.30	34.30	\N	487.10	6.10	60.60	Factory installed side cases, Fog lamps, LCD instrument panel	Cypher Camo Beige/Metallic Matte Carbon Gray
107	109	Backbone frame, high-tensile steel	24.8°/2.0 in	61.40	25.60	37.60	8.50	26.80	\N	167.50	1.00	42.30	4-stroke engine with automatic clutch	Lime Green, Bright White
108	110	Backbone frame, high-tensile steel	24.8°/2.0 in	61.40	25.60	37.60	8.50	26.80	\N	167.50	1.00	42.30	4-stroke engine with automatic clutch	Lime Green, Battle Gray
109	111	Backbone frame, high-tensile steel	24.2°/1.9 in	61.40	25.60	39.00	10.40	28.70	\N	167.50	1.00	42.30	Tall seat height and high ground clearance, 4-speed transmission with manual clutch	Lime Green, Bright White
110	112	Backbone frame, high-tensile steel	24.2°/1.9 in	61.40	25.60	39.00	10.40	28.70	\N	167.50	1.00	42.30	Tall seat height and high ground clearance, 4-speed transmission with manual clutch	Lime Green, Battle Gray
111	113	High-tensile steel, box-section perimeter	27.0°/3.3 in	71.70	31.10	41.30	9.30	30.70	\N	205.00	1.50	49.60	5-speed transmission with manual clutch, Uni-Trak rear suspension	Lime Green, Bright White
112	114	High-tensile steel, box-section perimeter	27.0°/3.3 in	71.70	31.10	41.30	9.30	30.70	\N	205.00	1.50	49.60	5-speed transmission with manual clutch, Uni-Trak rear suspension	Lime Green, Battle Gray
113	115	High-tensile steel, box-section perimeter	27.0°/3.8 in	74.60	31.10	42.30	10.00	31.50	\N	209.40	1.50	50.60	Large wheels (19/16 inch), tall seat height, fully adjustable rear suspension with piggyback reservoir	Lime Green, Bright White
114	116	High-tensile steel, box-section perimeter	27.0°/3.8 in	74.60	31.10	42.30	10.00	31.50	\N	209.40	1.50	50.60	Large wheels (19/16 inch), tall seat height, fully adjustable rear suspension with piggyback reservoir	Lime Green, Battle Gray
115	117	High-tensile steel, box-section perimeter	27.0°/4.6 in	78.90	31.10	44.70	12.40	33.90	\N	218.20	1.50	52.40	Full-size wheels (21/18 inch), adjustable long-travel suspension, tall seat height	Lime Green, Bright White
116	118	High-tensile steel, box-section perimeter	27.0°/4.6 in	78.90	31.10	44.70	12.40	33.90	\N	218.20	1.50	52.40	Full-size wheels (21/18 inch), adjustable long-travel suspension, tall seat height	Lime Green, Battle Gray
117	119	High-tensile steel, box-section perimeter	25.4°/4.2 in	80.50	33.30	47.20	11.40	35.60	\N	262.40	2.00	54.10	233cc Fuel-Injected Air-Cooled engine, 6-speed transmission, Uni-Trak rear suspension	Lime Green, Bright White
118	120	High-tensile steel, box-section perimeter	25.4°/4.2 in	80.50	33.30	47.20	11.40	35.60	\N	262.40	2.00	54.10	233cc Fuel-Injected Air-Cooled engine, 6-speed transmission, Uni-Trak rear suspension	Lime Green, Battle Gray
119	121	High-tensile steel, box-section perimeter	24.6°/3.9 in	80.50	33.30	46.70	10.60	34.40	\N	262.40	2.00	53.30	Low seat height (34.4 in), reduced suspension travel	Lime Green, Bright White
120	122	High-tensile steel, box-section perimeter	24.6°/3.9 in	80.50	33.30	46.70	10.60	34.40	\N	262.40	2.00	53.30	Low seat height (34.4 in), reduced suspension travel	Lime Green, Battle Gray
121	123	Semi-double cradle	26.9°/4.3 in	86.60	32.50	49.00	11.80	35.40	\N	286.70	2.10	56.50	292cc liquid-cooled DOHC engine, inverted front fork, 270mm front disc	Lime Green, Bright White
122	124	Semi-double cradle	26.9°/4.3 in	86.60	32.50	49.00	11.80	35.40	\N	286.70	2.10	56.50	292cc liquid-cooled DOHC engine, inverted front fork, 270mm front disc	Lime Green, Battle Gray
123	125	Perimeter, high-tensile steel	24.6°/3.8 in	81.90	33.30	44.90	9.40	33.30	\N	288.90	2.00	53.70	ERGOFIT, LCD Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP MOTORCYCLE	Lime Green, Bright White
124	126	Perimeter, high-tensile steel	24.6°/3.8 in	81.90	33.30	44.90	9.40	33.30	\N	291.10	2.00	53.70	ABS System with ON/OFF function, ERGOFIT, LCD Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP MOTORCYCLE	Lime Green, Bright White
125	127	Perimeter, high-tensile steel	24.6°/3.8 in	81.90	33.30	44.90	9.40	33.30	\N	288.90	2.00	53.70	ERGOFIT, LCD Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP MOTORCYCLE	Lime Green
126	128	Perimeter, high-tensile steel	24.6°/3.8 in	81.90	33.30	44.90	9.40	33.30	\N	291.10	2.00	53.70	ABS System with ON/OFF function, ERGOFIT, LCD Instrumentation with Smartphone Connectivity via RIDEOLOGY THE APP MOTORCYCLE	Lime Green
127	129	High-tensile steel, perimeter	24.4°/3.8 in	81.10	36.20	44.30	8.50	32.50	\N	297.70	2.00	53.30	Aluminum skid plate, Hand guards, ERGO-FIT, Even lower seat height	Whitish Beige
128	130	High-tensile steel, perimeter	24.6°/3.8 in	81.90	36.20	45.30	9.40	33.30	\N	302.10	2.00	53.70	Tubeless Rear Tire, Rear Carrier, Aluminum skid plate, Engine guards, Hand guards, ERGO-FIT	Medium Cloudy Gray
129	131	Tubular, semi-double cradle	26.7°/4.2 in	85.60	32.30	46.70	10.80	35.20	\N	302.10	2.00	56.70	LED Headlight, All-Digital Instrumentation	Lime Green, Bright White, Cypher Camo Beige/Ebony
130	132	Tubular, semi-double cradle	26.7°/4.2 in	86.60	32.30	47.40	10.80	35.20	\N	302.10	2.10	56.70	All-Digital Instrumentation, LED Headlight	Lime Green, Battle Gray
131	133	Perimeter, high-tensile steel	24.9°/3.0 in	80.10	33.30	44.30	8.70	33.10	\N	299.90	2.00	53.70	17-inch Wheels, ERGO-FIT, LCD Instrumentation, Smartphone Connectivity	Neon Green/Ebony
132	134	Perimeter, high-tensile steel	24.9°/3.0 in	80.10	33.30	44.30	8.70	33.10	\N	299.90	2.00	53.70	17-inch Wheels, ERGO-FIT, LCD Instrumentation, Smartphone Connectivity	Battle Gray
133	135	Tubular, semi-double cradle	25.0°/2.8 in	83.30	31.10	44.70	9.30	33.90	\N	304.30	2.00	56.50	43mm inverted cartridge fork, 17-inch wheels	Neon Green/Ebony, Battle Gray/Ebony
134	136	Tubular, semi-double cradle	25.0°/2.8 in	83.30	31.10	44.70	9.30	33.90	\N	304.30	2.10	56.50	43mm inverted cartridge fork, 17-inch wheels	Battle Gray, Phantom Blue
135	137	High-tensile steel semi-double cradle	27.0°/2.4 in	62.60	29.90	37.60	12.00	29.90	\N	126.10	1.00	44.10	64cc 2-stroke liquid-cooled engine, Front and Rear Disc Brakes	Lime Green
136	138	High-tensile steel semi-double cradle	27.0°/2.4 in	62.60	29.90	37.60	12.00	29.90	\N	132.20	1.00	44.10	64cc 2-stroke liquid-cooled engine, Front and Rear Disc Brakes	Lime Green
138	140	Perimeter, high-tensile steel	29.2°/4.1 in	72.20	31.50	43.90	11.60	32.70	\N	168.40	1.32	49.80	ERGO-FIT, KYB 43mm inverted fork, Renthal Fatbar with ODI lock-on grips	Lime Green
139	141	High-tensile steel perimeter design with subframe member	29.0°/3.8 in	72.00	30.10	43.30	11.40	32.70	\N	164.40	1.32	49.80	ERGO-FIT, 6-speed transmission, Efficient cooling performance	Lime Green
140	142	Perimeter, high-tensile steel	29.2°/4.6 in	76.20	31.50	45.90	13.00	34.10	\N	172.40	1.32	51.60	ERGO-FIT, KYB 43mm inverted fork, Large 240mm/220mm Brakes	Lime Green
141	143	Perimeter, high-tensile steel	29.2°/4.6 in	76.20	31.50	45.90	13.00	34.10	\N	172.80	1.32	51.60	ERGO-FIT, KYB 43mm inverted fork, Large 240mm/220mm Brakes	Lime Green
142	144	High-tensile steel perimeter design with subframe member	29.0°/4.3 in	75.60	30.10	45.30	13.00	34.30	\N	169.70	1.32	51.60	ERGO-FIT, 6-speed transmission	Lime Green
143	145	Aluminum perimeter	27.0°/4.6 in	86.20	32.30	49.80	13.40	37.60	\N	240.80	1.64	58.50	Smartphone Connectivity via RIDEOLOGY THE APP KX, ERGO-FIT, ODI Lock-on Grips	Lime Green
144	146	Aluminum perimeter	27.0°/4.7 in	86.20	32.30	49.80	13.40	37.60	\N	240.70	1.64	58.50	Smartphone Connectivity via RIDEOLOGY THE APP KX, ERGO-FIT, ODI Lock-on Grips	Lime Green
145	147	Aluminum perimeter	26.6°/4.5 in	85.80	32.30	50.00	13.60	37.80	\N	248.20	1.64	58.30	Smartphone Connectivity via RIDEOLOGY THE APP KX, ERGO-FIT, Brembo Brake Components, ODI Lock-on Grips	Lime Green
146	148	Aluminum perimeter	26.6°/4.5 in	85.80	32.30	50.00	13.60	37.80	\N	248.20	1.64	58.30	Smartphone Connectivity via RIDEOLOGY THE APP KX, ERGO-FIT, Brembo Brake Components, ODI Lock-on Grips	Lime Green
147	149	Aluminum perimeter	26.6°/4.5 in	86.00	32.30	50.00	13.40	37.60	\N	238.20	1.64	58.50	Xtrig ROCS-TECH Triple Clamp, Pro Circuit Titanium Exhaust, Smartphone Connectivity, ERGO-FIT	Lime Green
148	150	Aluminum perimeter	26.6°/4.5 in	86.00	32.30	50.00	13.40	37.60	\N	248.20	1.64	58.50	Xtrig ROCS-TECH Triple Clamp, Pro Circuit Titanium Exhaust, Smartphone Connectivity via RIDEOLOGY THE APP KX, ERGO-FIT	Lime Green
149	151	Aluminum perimeter	27.8°/4.8 in	85.80	32.30	49.60	13.00	37.20	\N	243.20	1.64	58.50	Smartphone Connectivity via RIDEOLOGY THE APP KX, ERGO-FIT, 18-in Rear Wheel, ODI Lock-on Grips	Lime Green
150	152	Aluminum perimeter	27.5°/4.8 in	85.80	32.30	49.60	13.00	37.20	\N	243.20	1.64	58.50	Smartphone Connectivity via RIDEOLOGY THE APP KX, ERGO-FIT, 18-in Rear Wheel, ODI Lock-on Grips	Lime Green
151	153	Aluminum perimeter	27.0°/4.6 in	85.60	32.10	49.60	13.20	37.40	\N	249.90	1.64	58.30	Smartphone Connectivity via RIDEOLOGY THE APP KX, ERGO-FIT, Brembo Brake Components, 18-in Rear Wheel	Lime Green
152	154	Aluminum perimeter	27.0°/4.6 in	85.60	32.10	49.60	13.20	37.40	\N	249.90	1.64	58.30	Smartphone Connectivity via RIDEOLOGY THE APP KX, ERGO-FIT, Brembo Brake Components, 18-in Rear Wheel	Lime Green
\.


--
-- TOC entry 4947 (class 0 OID 17173)
-- Dependencies: 236
-- Data for Name: model_series; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.model_series (series_id, series_name, group_id, series_slug, display_order) FROM stdin;
1	NINJA	1	ninja	1
4	W	2	w	4
5	ELIMINATOR	2	eliminator	5
6	VULCAN	2	vulcan	6
2	Z	2	z	2
3	VERSYS	2	versys	3
7	KLE	3	kle	7
8	KLR	3	klr	8
9	KLX	3	klx	9
10	KX	4	kx	10
\.


--
-- TOC entry 4931 (class 0 OID 17014)
-- Dependencies: 220
-- Data for Name: motorcycles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.motorcycles (motorcycle_id, model_name, year, engine_cc, price, image_url, category_id, created_at) FROM stdin;
2	Ninja e-1	2024	0	7899.00	https://example.com/ninja-e1.jpg	1	2026-04-15 21:48:33.549466
52	Z7 HYBRID ABS	2024	451	12499.00	https://www.kawasaki.com/images/z7-hybrid-2024.jpg	5	2026-04-21 21:34:23.52473
43	Z125 PRO	2026	125	3799.00	https://www.kawasaki.com/images/z125-pro-2026.jpg	4	2026-04-20 19:02:12.103619
44	Z125 PRO	2025	125	3699.00	https://www.kawasaki.com/images/z125-pro-2025.jpg	4	2026-04-21 20:10:03.38044
45	Z e-1 ABS	2024	0	7599.00	https://www.kawasaki.com/images/z-e-1-2024.jpg	5	2026-04-21 20:17:19.416009
46	Z500 ABS	2026	451	5699.00	https://www.kawasaki.com/images/z500-abs-2026.jpg	5	2026-04-21 20:25:10.094944
47	Z500 ABS	2025	451	5599.00	https://www.kawasaki.com/images/z500-abs-2025.jpg	5	2026-04-21 20:33:23.743724
48	Z500 SE ABS	2026	451	6399.00	https://www.kawasaki.com/images/z500-se-abs-2026.jpg	5	2026-04-21 20:41:03.19269
49	Z500 SE ABS	2025	451	6299.00	https://www.kawasaki.com/images/z500-se-abs-2025.jpg	5	2026-04-21 20:47:44.219332
50	Z650 S ABS	2026	649	7699.00	https://www.kawasaki.com/images/z650-s-abs-2026.jpg	5	2026-04-21 21:15:54.221728
51	Z650	2025	649	7749.00	https://www.kawasaki.com/images/z650-2025.jpg	5	2026-04-21 21:24:30.478091
53	Z900 ABS	2026	948	9999.00	https://www.kawasaki.com/images/z900-abs-2026.jpg	5	2026-04-21 21:49:18.920634
54	Z900 ABS	2025	948	9999.00	https://www.kawasaki.com/images/z900-abs-2025.jpg	5	2026-04-21 21:59:55.826647
55	Z900 SE ABS	2026	948	11999.00	https://www.kawasaki.com/images/z900-se-abs-2026.jpg	5	2026-04-21 22:06:13.659982
56	Z900 SE ABS	2025	948	11849.00	https://www.kawasaki.com/images/z900-se-abs-2025.jpg	5	2026-04-21 22:12:25.765906
57	Z1100 SE ABS	2026	1099	14999.00	https://www.kawasaki.com/images/z1100-se-abs-2026.jpg	5	2026-04-21 22:19:34.397065
58	Z650RS ABS	2026	649	8999.00	https://www.kawasaki.com/images/z650rs-abs-2026.jpg	6	2026-04-22 15:50:30.906034
59	Z650RS ABS	2025	649	8899.00	https://www.kawasaki.com/images/z650rs-abs-2025.jpg	6	2026-04-22 15:59:42.640944
60	Z900RS ABS	2026	948	12899.00	https://www.kawasaki.com/images/z900rs-abs-2026.jpg	6	2026-04-22 16:13:02.163821
61	Z900RS ABS	2025	948	12649.00	https://www.kawasaki.com/images/z900rs-abs-2025.jpg	6	2026-04-22 16:19:01.862877
62	Z900RS CAFE ABS	2026	948	13299.00	https://www.kawasaki.com/images/z900rs-cafe-abs-2026.jpg	6	2026-04-22 16:27:43.743582
63	Z900RS CAFE ABS	2025	948	12899.00	https://www.kawasaki.com/images/z900rs-cafe-abs-2025.jpg	6	2026-04-22 16:36:19.274047
64	Z900RS SE ABS	2026	948	14599.00	https://www.kawasaki.com/images/z900rs-se-abs-2026.jpg	6	2026-04-22 16:46:10.308133
65	Z900RS SE ABS	2025	948	14149.00	https://www.kawasaki.com/images/z900rs-se-abs-2025.jpg	6	2026-04-22 16:52:16.960286
66	Z H2 SE ABS	2026	998	21999.00	https://www.kawasaki.com/images/z-h2-se-abs-2026.jpg	7	2026-04-22 16:58:12.608303
67	Z H2 SE ABS	2025	998	21700.00	https://www.kawasaki.com/images/z-h2-se-abs-2025.jpg	7	2026-04-22 17:05:22.843185
73	VERSYS-X 300 ABS	2026	296	5799.00	https://www.kawasaki.com/images/versys-x-300-abs-2026.jpg	9	2026-04-22 19:26:42.026214
74	VERSYS-X 300 ABS	2025	296	5699.00	https://www.kawasaki.com/images/versys-x-300-abs-2025.jpg	9	2026-04-22 19:26:42.026214
75	VERSYS 650 LT ABS	2026	649	10399.00	https://www.kawasaki.com/images/versys-650-lt-abs-2026.jpg	9	2026-04-22 19:26:42.026214
76	VERSYS 1100 SE LT ABS	2025	1099	19499.00	https://www.kawasaki.com/images/versys-1100-se-lt-abs-2025.jpg	9	2026-04-22 19:26:42.026214
77	W230 ABS	2026	233	5699.00	https://www.kawasaki.com/images/w230-abs-2026.jpg	10	2026-04-22 19:57:33.389951
79	W230 ABS	2025	233	5599.00	https://www.kawasaki.com/images/w230-abs-2025.jpg	10	2026-04-22 20:17:27.591866
80	W800 ABS	2026	773	10699.00	https://www.kawasaki.com/images/w800-abs-2026.jpg	10	2026-04-22 20:24:32.491546
81	W800 ABS	2025	773	10399.00	https://www.kawasaki.com/images/w800-abs-2025.jpg	10	2026-04-22 20:31:49.202992
82	ELIMINATOR ABS	2026	451	6799.00	https://www.kawasaki.com/images/eliminator-abs-2026.jpg	11	2026-04-22 20:53:13.861632
83	ELIMINATOR ABS	2025	451	6799.00	https://www.kawasaki.com/images/eliminator-abs-2025.jpg	11	2026-04-22 21:07:19.561638
84	ELIMINATOR SE ABS	2026	451	7099.00	https://www.kawasaki.com/images/eliminator-se-abs-2026.jpg	11	2026-04-22 21:19:51.050861
85	ELIMINATOR SE ABS	2025	451	7099.00	https://www.kawasaki.com/images/eliminator-se-abs-2025.jpg	11	2026-04-22 21:31:21.926231
86	VULCAN S ABS	2026	649	8149.00	https://www.kawasaki.com/images/vulcan-s-abs-2026.jpg	12	2026-04-23 17:54:01.395976
87	VULCAN S ABS	2025	649	7899.00	https://www.kawasaki.com/images/vulcan-s-abs-2025.jpg	12	2026-04-23 18:03:09.683829
88	VULCAN S CAFE ABS	2026	649	8749.00	https://www.kawasaki.com/images/vulcan-s-cafe-abs-2026.jpg	12	2026-04-23 18:15:59.814283
89	VULCAN S CAFE ABS	2025	649	8499.00	https://www.kawasaki.com/images/vulcan-s-cafe-abs-2025.jpg	12	2026-04-23 18:32:35.760804
90	VULCAN 900 CLASSIC	2026	903	9599.00	https://www.kawasaki.com/images/vulcan-900-classic-2026.jpg	13	2026-04-23 18:58:47.118258
91	VULCAN 900 CLASSIC	2025	903	9399.00	https://www.kawasaki.com/images/vulcan-900-classic-2025.jpg	13	2026-04-23 19:05:25.36904
92	VULCAN 900 CUSTOM	2026	903	9999.00	https://www.kawasaki.com/images/vulcan-900-custom-2026.jpg	13	2026-04-23 19:11:46.680218
93	VULCAN 900 CUSTOM	2025	903	9899.00	https://www.kawasaki.com/images/vulcan-900-custom-2025.jpg	13	2026-04-23 19:22:18.523279
94	VULCAN 900 CLASSIC LT	2026	903	10599.00	https://www.kawasaki.com/images/vulcan-900-classic-lt-2026.jpg	13	2026-04-23 19:28:00.246437
95	VULCAN 900 CLASSIC LT	2025	903	10399.00	https://www.kawasaki.com/images/vulcan-900-classic-lt-2025.jpg	13	2026-04-23 19:37:52.042256
96	VULCAN 1700 VAQUERO ABS	2026	1700	19999.00	https://www.kawasaki.com/images/vulcan-1700-vaquero-abs-2026.jpg	14	2026-04-23 19:47:13.733537
97	VULCAN 1700 VAQUERO ABS	2025	1700	19499.00	https://www.kawasaki.com/images/vulcan-1700-vaquero-abs-2025.jpg	14	2026-04-23 19:54:43.506182
98	VULCAN 1700 VOYAGER ABS	2025	1700	20199.00	https://www.kawasaki.com/images/vulcan-1700-voyager-abs-2025.jpg	15	2026-04-23 20:05:04.484731
99	VULCAN 1700 VOYAGER ABS	2024	1700	19799.00	https://www.kawasaki.com/images/vulcan-1700-voyager-abs-2024.jpg	15	2026-04-23 20:13:21.384195
101	KLE 500 ABS	2026	451	6599.00	https://www.kawasaki.com/images/kle-500-abs-2026.jpg	16	2026-04-26 17:44:02.02155
102	KLE 500 SE ABS	2026	451	7499.00	https://www.kawasaki.com/images/kle-500-se-abs-2026.jpg	16	2026-04-26 17:52:23.485095
109	KLX 110R	2026	112	2999.00	https://www.kawasaki.com/images/klx-110r-2026.jpg	17	2026-04-27 16:13:55.897292
110	KLX 110R	2025	112	2899.00	https://www.kawasaki.com/images/klx-110r-2025.jpg	17	2026-04-27 16:20:50.477351
111	KLX 110R L	2026	112	3199.00	https://www.kawasaki.com/images/klx-110r-l-2026.jpg	17	2026-04-27 16:25:55.142894
112	KLX 110R L	2025	112	3099.00	https://www.kawasaki.com/images/klx-110r-l-2025.jpg	17	2026-04-27 16:33:13.841188
113	KLX 140R	2026	144	3799.00	https://www.kawasaki.com/images/klx-140r-2026.jpg	17	2026-04-27 16:47:02.758784
114	KLX 140R	2025	144	3699.00	https://www.kawasaki.com/images/klx-140r-2025.jpg	17	2026-04-27 16:53:59.173625
115	KLX 140R L	2026	144	4099.00	https://www.kawasaki.com/images/klx-140r-l-2026.jpg	17	2026-04-27 17:02:44.161356
116	KLX 140R L	2025	144	3999.00	https://www.kawasaki.com/images/klx-140r-l-2025.jpg	17	2026-04-27 17:14:45.590729
117	KLX 140R F	2026	144	4449.00	https://www.kawasaki.com/images/klx-140r-f-2026.jpg	17	2026-04-27 17:28:07.230216
118	KLX 140R F	2025	144	4299.00	https://www.kawasaki.com/images/klx-140r-f-2025.jpg	17	2026-04-27 17:39:30.043609
119	KLX 230R	2026	233	4999.00	https://www.kawasaki.com/images/klx-230r-2026.jpg	17	2026-04-27 17:51:15.148322
120	KLX 230R	2025	233	4999.00	https://www.kawasaki.com/images/klx-230r-2025.jpg	17	2026-04-27 17:58:15.697991
121	KLX 230R S	2026	233	4999.00	https://www.kawasaki.com/images/klx-230r-s-2026.jpg	17	2026-04-27 18:05:14.606683
122	KLX 230R S	2025	233	4999.00	https://www.kawasaki.com/images/klx-230r-s-2025.jpg	17	2026-04-27 18:11:37.079858
123	KLX 300R	2026	292	5749.00	https://www.kawasaki.com/images/klx-300r-2026.jpg	17	2026-04-27 18:18:38.286871
124	KLX 300R	2025	292	5549.00	https://www.kawasaki.com/images/klx-300r-2025.jpg	17	2026-04-27 18:23:56.15446
125	KLX 230 S	2026	233	5199.00	https://www.kawasaki.com/images/klx-230s-2026.jpg	18	2026-04-27 19:22:34.823066
126	KLX 230 S ABS	2026	233	5499.00	https://www.kawasaki.com/images/klx-230s-abs-2026.jpg	18	2026-04-27 19:22:34.823066
127	KLX 230 S	2025	233	4999.00	https://www.kawasaki.com/images/klx-230s-2025.jpg	18	2026-04-27 19:28:20.320591
128	KLX 230 S ABS	2025	233	5299.00	https://www.kawasaki.com/images/klx-230s-abs-2025.jpg	18	2026-04-27 19:28:20.320591
129	KLX 230 Sherpa S ABS	2026	233	5899.00	https://www.kawasaki.com/images/klx-230-sherpa-s-abs-2026.jpg	18	2026-04-27 19:34:25.297958
130	KLX 230 DF ABS	2026	233	5999.00	https://www.kawasaki.com/images/klx-230-df-abs-2026.jpg	18	2026-04-27 19:41:06.109924
131	KLX 300	2026	292	5649.00	https://www.kawasaki.com/images/klx-300-2026.jpg	18	2026-04-27 19:57:28.38322
132	KLX 300	2025	292	5449.00	https://www.kawasaki.com/images/klx-300-2025.jpg	18	2026-04-27 20:53:33.271107
133	KLX 230SM ABS	2026	233	5799.00	https://www.kawasaki.com/images/klx-230sm-abs-2026.jpg	19	2026-04-27 21:08:05.105304
134	KLX 230SM ABS	2025	233	5599.00	https://www.kawasaki.com/images/klx-230sm-abs-2025.jpg	19	2026-04-27 21:14:08.779344
135	KLX 300SM	2026	292	6049.00	https://www.kawasaki.com/images/klx-300sm-2026.jpg	19	2026-04-27 21:20:01.687298
136	KLX 300SM	2025	292	5849.00	https://www.kawasaki.com/images/klx-300sm-2025.jpg	19	2026-04-27 21:27:33.647297
137	KX 65	2026	64	4249.00	https://www.kawasaki.com/images/kx-65-2026.jpg	20	2026-04-28 13:33:50.543089
138	KX 65	2025	64	4249.00	https://www.kawasaki.com/images/kx-65-2025.jpg	20	2026-04-28 13:43:28.04829
140	KX 85	2026	84	4999.00	https://www.kawasaki.com/images/kx-85-2026.jpg	20	2026-04-28 13:55:27.399395
141	KX 85	2025	84	4949.00	https://www.kawasaki.com/images/kx-85-2025.jpg	20	2026-04-28 14:02:22.146155
142	KX 85 L	2026	84	5199.00	https://www.kawasaki.com/images/kx-85-l-2026.jpg	20	2026-04-28 14:07:16.022119
143	KX 112	2026	112	5749.00	https://www.kawasaki.com/images/kx-112-2026.jpg	20	2026-04-28 14:18:23.479428
144	KX 112	2025	112	5649.00	https://www.kawasaki.com/images/kx-112-2025.jpg	20	2026-04-28 14:27:05.104499
145	KX 250	2026	249	9099.00	https://www.kawasaki.com/images/kx-250-2026.jpg	21	2026-04-28 14:46:38.44881
146	KX 250	2025	249	8999.00	https://www.kawasaki.com/images/kx-250-2025.jpg	21	2026-04-28 14:55:06.082547
147	KX 450	2026	449	10599.00	https://www.kawasaki.com/images/kx-450-2026.jpg	21	2026-04-28 15:00:56.389111
148	KX 450	2025	449	10499.00	https://www.kawasaki.com/images/kx-450-2025.jpg	21	2026-04-28 15:07:39.976702
149	KX 450SR	2026	449	13699.00	https://www.kawasaki.com/images/kx-450sr-2026.jpg	21	2026-04-28 15:12:18.426262
150	KX 450SR	2025	449	13599.00	https://www.kawasaki.com/images/kx-450sr-2025.jpg	21	2026-04-28 15:16:56.071382
151	KX 250X	2026	249	9199.00	https://www.kawasaki.com/images/kx-250x-2026.jpg	22	2026-04-28 16:06:47.502973
152	KX 250X	2025	249	9099.00	https://www.kawasaki.com/images/kx-250x-2025.jpg	22	2026-04-28 16:12:49.92738
153	KX 450X	2026	449	10799.00	https://www.kawasaki.com/images/kx-450x-2026.jpg	22	2026-04-28 16:18:42.427481
154	KX 450X	2025	449	10699.00	https://www.kawasaki.com/images/kx-450x-2025.jpg	22	2026-04-28 16:27:45.598645
5	Ninja 500	2025	451	5299.00	https://www.kawasaki.com/images/ninja-500-2025-silver.jpg	1	2026-04-15 23:09:53.658103
6	Ninja 500	2026	451	5399.00	https://www.kawasaki.com/images/ninja-500-2026-lime.jpg	1	2026-04-16 00:11:06.593525
7	Ninja 500 SE ABS	2026	451	6499.00	https://www.kawasaki.com/images/ninja-500-se-abs-2026.jpg	1	2026-04-16 20:05:28.058761
8	Ninja 500 SE ABS	2025	451	6399.00	https://www.kawasaki.com/images/ninja-500-se-abs-2025-black.jpg	1	2026-04-16 20:23:49.993814
9	Ninja 500 KRT Edition	2025	451	5499.00	https://www.kawasaki.com/images/ninja-500-krt-2025.jpg	1	2026-04-16 20:37:28.640454
10	Ninja 500 SE KRT Edition ABS	2025	451	6399.00	https://www.kawasaki.com/images/ninja-650-krt-2025.jpg	1	2026-04-16 21:10:13.093823
11	Ninja 650	2026	649	7599.00	https://www.kawasaki.com/images/ninja-650-2026.jpg	1	2026-04-18 18:48:31.856158
12	Ninja 650	2025	649	7399.00	https://www.kawasaki.com/images/ninja-650-2025-orange.jpg	1	2026-04-18 19:05:19.62091
13	Ninja 650 KRT Edition ABS	2025	649	7999.00	https://www.kawasaki.com/images/ninja-650-krt-2025.jpg	1	2026-04-18 19:22:15.624458
14	Ninja 7 Hybrid ABS	2024	451	12499.00	https://www.kawasaki.com/images/ninja-7-hybrid-2024.jpg	1	2026-04-18 19:44:00.104087
21	Ninja ZX-4R ABS	2026	399	9299.00	https://www.kawasaki.com/images/ninja-zx-4r-2026.jpg	2	2026-04-19 15:59:12.838969
22	Ninja ZX-4R ABS	2025	399	8999.00	https://www.kawasaki.com/images/ninja-zx-4r-2025.jpg	2	2026-04-19 16:12:14.919396
23	Ninja ZX-4RR ABS	2026	399	9999.00	https://www.kawasaki.com/images/ninja-zx-4rr-2026.jpg	2	2026-04-19 16:21:24.410634
24	Ninja ZX-4RR ABS	2025	399	9699.00	https://www.kawasaki.com/images/ninja-zx-4rr-2025.jpg	2	2026-04-19 16:29:13.977817
25	Ninja ZX-4RR KRT Edition ABS	2025	399	9699.00	https://www.kawasaki.com/images/ninja-zx-4rr-krt-2025.jpg	2	2026-04-19 16:39:17.392805
26	Ninja ZX-6R	2026	636	11599.00	https://www.kawasaki.com/images/ninja-zx-6r-2026.jpg	2	2026-04-19 19:21:04.750753
27	Ninja ZX-6R	2025	636	11399.00	https://www.kawasaki.com/images/ninja-zx-6r-2025.jpg	2	2026-04-19 19:34:56.622851
28	Ninja ZX-6R KRT Edition	2025	636	11399.00	https://www.kawasaki.com/images/ninja-zx-6r-krt-2025.jpg	2	2026-04-19 19:53:45.10195
29	Ninja ZX-10R	2026	998	16999.00	https://www.kawasaki.com/images/ninja-zx-10r-2026.jpg	3	2026-04-19 20:08:24.790878
30	Ninja ZX-10R	2025	998	16999.00	https://www.kawasaki.com/images/ninja-zx-10r-2025.jpg	3	2026-04-19 20:18:49.34091
31	Ninja ZX-10RR ABS	2026	998	29999.00	https://www.kawasaki.com/images/ninja-zx-10rr-2026.jpg	3	2026-04-19 20:31:03.968015
32	Ninja ZX-10RR ABS	2025	998	29999.00	https://www.kawasaki.com/images/ninja-zx-10rr-2025.jpg	3	2026-04-19 20:50:45.439695
33	Ninja ZX-10R KRT Edition	2025	998	16999.00	https://www.kawasaki.com/images/ninja-zx-10r-krt-2025.jpg	3	2026-04-19 21:01:20.301644
34	Ninja ZX-14R ABS	2025	1441	17599.00	https://www.kawasaki.com/images/ninja-zx-14r-2025.jpg	3	2026-04-19 21:11:12.14697
35	Ninja H2 SX SE ABS	2026	998	29999.00	https://www.kawasaki.com/images/ninja-h2-sx-se-2026.jpg	3	2026-04-20 13:45:33.096855
36	Ninja H2 SX SE ABS	2025	998	29100.00	https://www.kawasaki.com/images/ninja-h2-sx-se-2025.jpg	3	2026-04-20 13:51:33.456343
37	Ninja H2 ABS	2026	998	34400.00	https://www.kawasaki.com/images/ninja-h2-2026.jpg	3	2026-04-20 14:15:59.732541
38	Ninja H2 ABS	2025	998	32700.00	https://www.kawasaki.com/images/ninja-h2-2025.jpg	3	2026-04-20 14:30:53.033507
39	Ninja H2 Carbon ABS	2026	998	38100.00	https://www.kawasaki.com/images/ninja-h2-carbon-2026.jpg	3	2026-04-20 14:38:43.201844
40	Ninja H2 Carbon ABS	2025	998	36200.00	https://www.kawasaki.com/images/ninja-h2-carbon-2025.jpg	3	2026-04-20 14:50:25.10366
41	Ninja H2R ABS	2026	998	62100.00	https://www.kawasaki.com/images/ninja-h2r-2026.jpg	3	2026-04-20 15:01:15.971333
42	Ninja H2R ABS	2025	998	59100.00	https://www.kawasaki.com/images/ninja-h2r-2025.jpg	3	2026-04-20 15:06:29.779537
17	Ninja 1100SX ABS	2026	1099	13999.00	https://www.kawasaki.com/images/ninja-1100sx-2026.jpg	9	2026-04-18 20:54:54.614824
18	Ninja 1100SX ABS	2025	1099	13699.00	https://www.kawasaki.com/images/ninja-1100sx-2025.jpg	9	2026-04-18 21:21:36.72614
19	Ninja 1100SX SE ABS	2026	1099	15799.00	https://www.kawasaki.com/images/ninja-1100sx-se-2026.jpg	9	2026-04-18 21:40:39.589633
20	Ninja 1100SX SE ABS	2025	1099	15399.00	https://www.kawasaki.com/images/ninja-1100sx-se-2025.jpg	9	2026-04-18 21:54:29.080073
103	KLR 650	2026	652	6999.00	https://www.kawasaki.com/images/klr-650-2026.jpg	24	2026-04-26 20:42:54.99079
104	KLR 650	2025	652	6899.00	https://www.kawasaki.com/images/klr-650-2025.jpg	24	2026-04-26 20:57:26.294935
105	KLR 650 S	2026	652	6999.00	https://www.kawasaki.com/images/klr-650-s-2026.jpg	24	2026-04-26 21:22:59.761672
106	KLR 650 S	2025	652	6899.00	https://www.kawasaki.com/images/klr-650-s-2025.jpg	24	2026-04-26 21:33:26.609327
107	KLR 650 ADVENTURE ABS	2026	652	8199.00	https://www.kawasaki.com/images/klr-650-adventure-abs-2026.jpg	24	2026-04-26 21:41:51.52487
108	KLR 650 ADVENTURE ABS	2025	652	8099.00	https://www.kawasaki.com/images/klr-650-adventure-abs-2025.jpg	24	2026-04-26 21:51:53.665812
\.


--
-- TOC entry 4941 (class 0 OID 17120)
-- Dependencies: 230
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (item_id, order_id, motorcycle_id, quantity, price_at_order) FROM stdin;
\.


--
-- TOC entry 4939 (class 0 OID 17102)
-- Dependencies: 228
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (order_id, user_id, order_date, status, delivery_address, total_amount, delivery_cost) FROM stdin;
\.


--
-- TOC entry 4937 (class 0 OID 17085)
-- Dependencies: 226
-- Data for Name: performance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.performance (performance_id, motorcycle_id, front_suspension, rear_suspension, front_tire, rear_tire, front_brakes, rear_brakes) FROM stdin;
1	2	41mm telescopic front fork/4.7 in	Bottom-Link Uni-Trak with single gas-charged shock, adjustable spring preload/5.2 in	100/80-17M/C 52S	130/70-17M/C 62S	Single 290mm disc with dual-piston caliper	Single 220mm disc with dual-piston caliper
3	5	41mm hydraulic telescopic fork/4.7 in	Horizontal back-link with adjustable spring preload/5.1 in	110/70-17	150/60-17	Single 310mm semi-floating disc with 2-piston calipers (and ABS)	Single 220mm disc with single-piston caliper (and ABS)
4	6	41mm hydraulic telescopic fork/4.7 in	Horizontal back-link with adjustable spring preload/5.1 in	110/70-17	150/60-17	Single 310mm semi-floating disc with 2-piston calipers (and ABS)	Single 220mm disc with single-piston caliper (and ABS)
5	7	41mm hydraulic telescopic fork/4.7 in	Horizontal back-link with adjustable spring preload/5.1 in	110/70-17	150/60-17	Single 310mm semi-floating disc with 2-piston calipers and ABS	Single 220mm disc with single-piston caliper and ABS
6	8	41mm hydraulic telescopic fork/4.7 in	Horizontal back-link with adjustable spring preload/5.1 in	110/70-17	150/60-17	Single 310mm semi-floating disc with 2-piston calipers and ABS	Single 220mm disc with single-piston caliper and ABS
7	9	41mm hydraulic telescopic fork/4.7 in	Horizontal back-link with adjustable spring preload/5.1 in	110/70-17	150/60-17	Single 310mm semi-floating disc with 2-piston calipers	Single 220mm disc with single-piston caliper
8	10	41mm hydraulic telescopic fork/4.7 in	Horizontal back-link with adjustable spring preload/5.1 in	110/70-17	150/60-17	Single 310mm semi-floating disc with 2-piston calipers and ABS	Single 220mm disc with single-piston caliper and ABS
9	11	41mm hydraulic telescopic fork/4.9 in	Horizontal back-link with adjustable spring preload/5.1 in	120/70 x 17	160/60 x 17	Dual 300mm petal-type discs and 2-piston calipers (and ABS)	Single 220mm petal-type disc and single-piston caliper (and ABS)
10	12	41mm hydraulic telescopic fork/4.9 in	Horizontal back-link with adjustable spring preload/5.1 in	120/70 x 17	160/60 x 17	Dual 300mm petal-type discs and 2-piston calipers (and ABS)	Single 220mm petal-type disc and single-piston caliper (and ABS)
11	13	41mm hydraulic telescopic fork/4.9 in	Horizontal back-link with adjustable spring preload/5.1 in	120/70 x 17	160/60 x 17	Dual 300mm petal-type discs and 2-piston calipers and ABS	Single 220mm petal-type disc and single-piston caliper and ABS
12	14	41mm telescopic fork/4.7 in	Bottom-Link Uni-Trak with single gas-charged shock, adjustable spring preload/4.5 in	120/70-17	160/60-17	Dual 300mm discs with 2-piston calipers and ABS	Single 220mm disc with single-piston caliper and ABS
13	17	41mm inverted telescopic Showa fork with compression and rebound damping, adjustable spring preload/4.7 in	Horizontal back-link, gas-charged rear shock with rebound damping, remotely adjustable spring preload/5.6 in	120/70-17	190/50-17	Dual 300mm discs with radial-mount 4-piston monobloc calipers, Kawasaki Intelligent anti-lock Brake System (KIBS)	Single 260mm disc with single-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS)
14	18	41mm inverted telescopic Showa fork with compression and rebound damping, adjustable spring preload/4.7 in	Horizontal back-link, gas-charged rear shock with rebound damping, remotely adjustable spring preload/5.6 in	120/70-17	190/50-17	Dual 300mm discs with radial-mount 4-piston monobloc calipers, Kawasaki Intelligent anti-lock Brake System (KIBS)	Single 260mm disc with single-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS)
15	19	41mm inverted telescopic Showa fork with compression and rebound damping, adjustable spring preload/4.7 in	Horizontal back-link, **Öhlins S46** gas-charged rear shock with rebound damping, remotely adjustable spring preload/5.6 in	120/70-17	190/50-17	Dual 300mm discs with radial-mount 4-piston **Brembo M4.32** monobloc calipers, Kawasaki Intelligent anti-lock Brake System (KIBS)	Single 260mm disc with single-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS)
16	20	41mm inverted telescopic Showa fork with compression and rebound damping, adjustable spring preload/4.7 in	Horizontal back-link, Öhlins S46 gas-charged rear shock with rebound damping, remotely adjustable spring preload/5.6 in	120/70-17	190/50-17	Dual 300mm discs with radial-mount 4-piston Brembo M4.32 monobloc calipers, Kawasaki Intelligent anti-lock Brake System (KIBS)	Single 260mm disc with single-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS)
17	21	37mm inverted Showa fork with SFF-BP internals/4.7 in	Horizontal back-link, Showa shock w/ adjustable spring preload/4.4 in	120/70-17	160/60-17	Dual 290mm semi-floating discs with radial-mount 4-piston monobloc caliper and ABS	Single 220mm disc with single-piston caliper and ABS
18	22	37mm inverted Showa fork with SFF-BP internals/4.7 in	Horizontal back-link, Showa shock w/ adjustable spring preload/4.4 in	120/70-17	160/60-17	Dual 290mm semi-floating discs with radial-mount 4-piston monobloc caliper and ABS	Single 220mm disc with single-piston caliper and ABS
19	23	37mm inverted Showa fork with SFF-BP internals and spring preload adjustability/4.7 in	Horizontal back-link, Showa BFRC lite gas-charged shock w/ piggyback reservoir, adjustable compression, rebound and spring preload/4.9 in	120/70-17	160/60-17	Dual 290mm semi-floating discs with radial-mount 4-piston monobloc caliper and ABS	Single 220mm disc with single-piston caliper and ABS
20	24	37mm inverted Showa fork with SFF-BP internals and spring preload adjustability/4.7 in	Horizontal back-link, Showa BFRC lite gas-charged shock w/ piggyback reservoir, adjustable compression, rebound and spring preload/4.9 in	120/70-17	160/60-17	Dual 290mm semi-floating discs with radial-mount 4-piston monobloc caliper and ABS	Single 220mm disc with single-piston caliper and ABS
21	25	37mm inverted Showa fork with SFF-BP internals and spring preload adjustability/4.7 in	Horizontal back-link, Showa BFRC lite gas-charged shock w/ piggyback reservoir, adjustable compression, rebound and spring preload/4.9 in	120/70-17	160/60-17	Dual 290mm semi-floating discs with radial-mount 4-piston monobloc caliper and ABS	Single 220mm disc with single-piston caliper and ABS
34	38	43mm inverted Kayaba AOS-II fork with adjustable rebound and compression damping, spring preload adjustability and top-out springs/4.7 in	Uni-Trak, Ohlins TTX36 gas-charged shock with piggyback reservoir, 24-way compression and rebound damping adjustability, 15-way spring preload adjustability, and top-outspring/5.3 in	120/70-17	200/55-17	Dual 330mm semi-floating discs with dual radial-mount, opposed 4-piston Brembo Stylema calipers, Kawasaki Intelligent anti-lock Brake System (KIBS)	Single 250mm disc with opposed 2-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS)
22	26	41mm inverted fork Showa Separate Function Big Piston Fork (SFF-BP) with rebound and compression damping and spring preload adjustability, and top-out springs/4.7 in	Bottom-link Uni-Trak with single shock, stepless compression damping adjustment, stepless adjustable rebound damping, fully adjustable spring preload/5.9 in	120/70 ZR17	180/55 ZR17	Dual semi-floating 310mm discs with dual radial-mounted, monobloc, opposed 4-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only)	Single 220mm petal discs with single-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only)
23	27	41mm inverted fork Showa Separate Function Big Piston Fork (SFF-BP) with rebound and compression damping and spring preload adjustability, and top-out springs/4.7 in	Bottom-link Uni-Trak with single shock, stepless compression damping adjustment, stepless adjustable rebound damping, fully adjustable spring preload/5.9 in	120/70 ZR17	180/55 ZR17	Dual semi-floating 310mm discs with dual radial-mounted, monobloc, opposed 4-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only)	Single 220mm petal discs with single-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only)
24	28	41mm inverted fork Showa Separate Function Big Piston Fork (SFF-BP) with rebound and compression damping and spring preload adjustability, and top-out springs/4.7 in	Bottom-link Uni-Trak with single shock, stepless compression damping adjustment, stepless adjustable rebound damping, fully adjustable spring preload/5.9 in	120/70 ZR17	180/55 ZR17	Dual semi-floating 310mm discs with dual radial-mounted, monobloc, opposed 4-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only)	Single 220mm petal discs with single-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only)
25	29	43mm inverted Showa Balance Free Fork (BFF) with external compression chamber, rebound and compression damping, spring preload adjustability/4.7 in	Horizontal back-link with Showa Balance Free Rear Cushion (BFRC) lite gas-charged shock with piggyback reservoir, rebound and compression damping, spring preload adjustability/4.2 in	120/70 ZR17	190/55 ZR17	Dual 330mm semi-floating Brembo discs with radial-mount 4-piston Brembo M50 monobloc calipers (and ABS)	Single 220mm disc with aluminum single-piston caliper (and ABS)
26	30	43mm inverted Showa Balance Free Fork (BFF), adjustable stepless rebound and compression damping, spring preload adjustability/4.7 in	Horizontal back-link with Showa Balance Free Rear Cushion (BFRC) lite shock, stepless, dual-range (low-/high-speed) compression damping, stepless rebound damping, fully adjustable spring preload/4.5 in	120/70 ZR17	190/55 ZR17	Brembo dual semi-floating 330mm discs with dual radial mounted monobloc 4-piston calipers, Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only)	Single 220mm disc with aluminum single-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only)
27	31	43mm inverted Showa Balance Free Fork (BFF) with external compression chamber, rebound and compression damping, spring preload adjustability/4.7 in	Horizontal back-link with Showa Balance Free Rear Cushion (BFRC) lite gas-charged shock with piggyback reservoir, rebound and compression damping, spring preload adjustability/4.2 in	120/70 ZR17	190/55 ZR17	Dual 330mm semi-floating Brembo discs with radial-mount 4-piston Brembo M50 monobloc calipers (and ABS)	Single 220mm disc with aluminum single-piston caliper (and ABS)
28	32	43mm inverted Showa Balance Free Fork (BFF), adjustable stepless rebound and compression damping, spring preload adjustability/4.7 in	Horizontal back-link with Showa Balance Free Rear Cushion (BFRC) lite shock, stepless, dual-range (low-/high-speed) compression damping, stepless rebound damping, fully adjustable spring preload/4.5 in	120/70 ZR17	190/55 ZR17	Brembo dual semi-floating 330mm discs with dual radial mounted monobloc 4-piston calipers, Kawasaki Intelligent anti-lock Brake System (KIBS)	Single 220mm disc with aluminum single-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS)
29	33	43mm inverted Showa Balance Free Fork (BFF), adjustable stepless rebound and compression damping, spring preload adjustability/4.7 in	Horizontal back-link with Showa Balance Free Rear Cushion (BFRC) lite shock, stepless, dual-range (low-/high-speed) compression damping, stepless rebound damping, fully adjustable spring preload/4.5 in	120/70 ZR17	190/55 ZR17	Brembo dual semi-floating 330mm discs with dual radial mounted monobloc 4-piston calipers, Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only)	Single 220mm disc with aluminum single-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only)
30	34	43mm inverted cartridge fork with adjustable preload, 18-way compression and 15-way rebound damping adjustment/4.6 in	Bottom-link Uni-Trak and gas-charged shock with adjustable preload, stepless rebound and compression damping adjustments, adjustable ride height/4.9 in	120/70-17	190/50-R17	Dual 310mm semi-floating Brembo discs with dual radial-mounted Brembo 4-piston M50 monobloc calipers and ABS	Single 250mm disc with twin-piston caliper and ABS
31	35	43mm inverted Showa fork with KECS-controlled rebound and compression damping, manual spring preload adjustability and top-out springs/4.7 in	Uni-Trak, Showa BFRC lite gas-charged shock with piggyback reservoir, KECS-controlled compression and rebound damping electronically-adjustable spring preload/5.5 inspiring/5.3 in	120/70-17	190/55-17	Dual 320mm semi-floating discs with dual radial-mount, opposed 4-piston Brembo Stylema calipers, Kawasaki Intelligent anti-lock Brake System (KIBS)	Single 250mm disc with opposed 2-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS)
32	36	43mm inverted Showa fork with KECS-controlled rebound and compression damping, manual spring preload adjustability and top-out springs/4.7 in	Uni-Trak, Showa BFRC lite gas-charged shock with piggyback reservoir, KECS-controlled compression and rebound damping electronically-adjustable spring preload/5.5 inspiring/5.3 in	120/70-17	190/55-17	Dual 320mm semi-floating discs with dual radial-mount, opposed 4-piston Brembo Stylema calipers, Kawasaki Intelligent anti-lock Brake System (KIBS)	Single 250mm disc with opposed 2-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS)
33	37	43mm inverted Kayaba AOS-II fork with adjustable rebound and compression damping, spring preload adjustability and top-out springs/4.7 in	Uni-Trak, Ohlins TTX36 gas-charged shock with piggyback reservoir, 24-way compression and rebound damping adjustability, 15-way spring preload adjustability, and top-outspring/5.3 in	120/70-17	200/55-17	Dual 330mm semi-floating discs with dual radial-mount, opposed 4-piston Brembo Stylema calipers, Kawasaki Intelligent anti-lock Brake System (KIBS)	Single 250mm disc with opposed 2-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS)
57	61	41mm inverted telescopic fork with (13-way) adjustable compression and rebound (11-way) damping, spring preload (15-turn)/4.7 in	Horizontal back-link swingarm with stepless adjustable rebound damping and spring preload/5.5 in	120/70-17	180/55-17	Dual 300mm discs with four-piston calipers and ABS	Single 250mm disc with single-piston caliper and ABS
35	39	43mm inverted Kayaba AOS-II fork with adjustable rebound and compression damping, spring preload adjustability and top-out springs/4.7 in	Uni-Trak, Ohlins TTX36 gas-charged shock with piggyback reservoir, 24-way compression and rebound damping adjustability, 15-way spring preload adjustability, and top-outspring/5.3 in	120/70-17	200/55-17	Dual 330mm semi-floating discs with dual radial-mount, opposed 4-piston Brembo Stylema calipers, Kawasaki Intelligent anti-lock Brake System (KIBS)	Single 250mm disc with opposed 2-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS)
36	40	43mm inverted Kayaba AOS-II fork with adjustable rebound and compression damping, spring preload adjustability and top-out springs/4.7 in	Uni-Trak, Ohlins TTX36 gas-charged shock with piggyback reservoir, 24-way compression and rebound damping adjustability, 15-way spring preload adjustability, and top-outspring/5.3 in	120/70-17	200/55-17	Dual 330mm semi-floating discs with dual radial-mount, opposed 4-piston Brembo Stylema calipers, Kawasaki Intelligent anti-lock Brake System (KIBS)	Single 250mm disc with opposed 2-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS)
37	41	43mm inverted Kayaba AOS-II fork with adjustable rebound and compression damping, spring preload adjustability and top-out springs/4.7 in	Uni-Trak, Ohlins TTX36 gas-charged shock with piggyback reservoir, 30-way compression and rebound damping adjustability, 16-way spring preload adjustability, and top-outspring/5.3 in	120/60-17 V01R slick	190/65-17 V01R slick	Dual 330mm semi-floating discs with dual radial-mount, opposed 4-piston Brembo M50 Monobloc calipers, Kawasaki Intelligent anti-lock Brake System (KIBS)	Single 250mm disc with opposed 2-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS)
38	42	43mm inverted Kayaba AOS-II fork with adjustable rebound and compression damping, spring preload adjustability and top-out springs/4.7 in	Uni-Trak, Ohlins TTX36 gas-charged shock with piggyback reservoir, 30-way compression and rebound damping adjustability, 16-way spring preload adjustability, and top-outspring/5.3 in	120/60-17 V01F slick	190/65-17 V01R slick	Dual 330mm semi-floating discs with dual radial-mount, opposed 4-piston Brembo M50 Monobloc calipers, Kawasaki Intelligent anti-lock Brake System (KIBS)	Single 250mm disc with opposed 2-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS)
39	43	30mm telescopic fork/3.9 in	Swingarm, single shock/4.1 in	100/90-12	120/70-12	Single 200mm petal-style disc	Single 184mm petal-style disc
40	44	30mm telescopic fork/3.9 in	Swingarm, single shock/4.1 in	100/90-12	120/70-12	Single 200mm petal-style disc	Single 184mm petal-style disc
41	45	41mm telescopic front fork	Bottom-Link Uni-Trak with single gas-charged shock, adjustable spring preload/5.2 in	100/80-17M/C 52S	130/70-17M/C 62S	Single 290mm disc with dual-piston caliper	Single 220mm disc with dual-piston caliper
42	46	41mm hydraulic telescopic fork/4.7 in	Horizontal back-link with adjustable spring preload/5.1 in	110/70-17	150/60-17	Single 310mm semi-floating disc with 2-piston calipers and ABS	Single 220mm disc with single-piston caliper and ABS
43	47	41mm hydraulic telescopic fork/4.7 in	Horizontal back-link with adjustable spring preload/5.1 in	110/70-17	150/60-17	Single 310mm semi-floating disc with 2-piston calipers and ABS	Single 220mm disc with single-piston caliper and ABS
44	48	41mm hydraulic telescopic fork/4.7 in	Horizontal back-link with adjustable spring preload/5.1 in	110/70-17	150/60-17	Single 310mm semi-floating disc with 2-piston calipers and ABS	Single 220mm disc with single-piston caliper and ABS
45	49	41mm hydraulic telescopic fork/4.7 in	Horizontal back-link with adjustable spring preload/5.1 in	110/70-17	150/60-17	Single 310mm semi-floating disc with 2-piston calipers and ABS	Single 220mm disc with single-piston caliper and ABS
46	50	41mm inverted telescopic fork/4.9 in	Horizontal back-link with adjustable preload, swingarm/5.1 in	120/70-17	160/60-17	Dual 300mm petal-style discs with two-piston calipers (and ABS)	Single 220mm petal-style disc (and ABS)
47	51	41mm telescopic fork/4.9 in	Horizontal back-link with adjustable preload, swingarm/5.1 in	120/70-17	160/60-17	Dual 300mm petal-style discs with two-piston calipers (and ABS)	Single 220mm petal-style disc (and ABS)
48	52	41mm telescopic fork/4.7 in	Bottom-Link Uni-Trak with single gas-charged shock, adjustable spring preload/4.5 in	120/70-17	160/60-17	Dual 300mm discs with 2-piston calipers and ABS	Single 220mm disc with single-piston caliper and ABS
49	53	41mm inverted telescopic fork with rebound damping and spring preload adjustability/4.7 in	Horizontal back-link, gas-charged rear shock with rebound damping and spring preload adjustability/5.5 in	120/70-17	180/55-17	Dual 300mm semi-floating discs with radial-mount 4-piston calipers and ABS	Single 250mm disc with single-piston caliper and ABS
50	54	41mm inverted telescopic fork with rebound damping and spring preload adjustability/4.7 in	Horizontal back-link, gas-charged rear shock with rebound damping and spring preload adjustability/5.5 in	120/70-17	180/55-17	Dual 300mm semi-floating discs with radial-mount 4-piston calipers and ABS	Single 250mm disc with single-piston caliper and ABS
51	55	41mm inverted telescopic fork with compression and rebound damping and spring preload adjustability/4.7 in	Horizontal back-link, Öhlins S46 gas-charged rear shock with rebound damping and spring preload adjustability/5.5 in	120/70-17	180/55-17	Dual 300mm semi-floating discs with radial-mount 4-piston Brembo M4.32 monobloc calipers and ABS	Single 250mm disc with single-piston caliper and ABS
52	56	41mm inverted telescopic fork with compression and rebound damping and spring preload adjustability/4.7 in	Horizontal back-link, Öhlins S46 gas-charged rear shock with rebound damping and spring preload adjustability/5.5 in	120/70-17	180/55-17	Dual 300mm semi-floating discs with radial-mount 4-piston Brembo M4.32 monobloc calipers and ABS	Single 250mm disc with single-piston caliper and ABS
53	57	41mm inverted telescopic fork with compression and rebound damping and spring preload adjustability/4.7 in	Horizontal back-link, Öhlins S46 gas-charged rear shock with rebound damping and remote spring preload adjustability/5.4 in	120/70-17	190/50-17	Dual 300mm semi-floating discs with radial-mount 4-piston Brembo M4.32 monobloc calipers and ABS	Single 250mm disc with single-piston caliper and ABS
54	58	41mm telescopic fork/4.9 in	Horizontal back-link with adjustable preload, swingarm/5.1 in	120/70-17	160/60-17	Dual 300mm petal-style discs with two-piston calipers and ABS	Single 220mm petal-style disc and ABS
55	59	41mm telescopic fork/4.9 in	Horizontal back-link with adjustable preload, swingarm/5.1 in	120/70-17	160/60-17	Dual 300mm petal-style discs with two-piston calipers and ABS	Single 220mm petal-style disc and ABS
56	60	41mm inverted telescopic fork with (12-way) adjustable compression and rebound (10-way) damping, spring preload (15-turn)/4.7 in	Horizontal back-link swingarm with stepless adjustable rebound damping and spring preload/5.5 in	120/70-17	180/55-17	Dual 300mm discs with four-piston calipers and ABS	Single 250mm disc with single-piston caliper and ABS
58	62	41mm inverted telescopic fork with (12-way) adjustable compression and rebound (10-way) damping, spring preload (15-turn)/4.7 in	Horizontal back-link swingarm with stepless adjustable rebound damping and spring preload/5.5 in	120/70-17	180/55-17	Dual 300mm discs with four-piston calipers and ABS	Single 250mm disc with single-piston caliper and ABS
59	63	41mm inverted telescopic fork with (13-way) adjustable compression and rebound (11-way) damping, spring preload (15-turn)/4.7 in	Horizontal back-link swingarm with stepless adjustable rebound damping and spring preload/5.5 in	120/70-17	180/55-17	Dual 300mm discs with four-piston calipers and ABS	Single 250mm disc with single-piston caliper and ABS
60	64	41mm inverted telescopic fork with (12-way) adjustable compression and rebound (10-way) damping, spring preload (15-turn)/4.7	Horizontal back-link swingarm, Öhlins S46 shock with 30-position adjustable rebound damping and stepless spring preload adjustability/5.5 in	120/70-17	180/55-17	Dual 300mm discs with Brembo M4.32 monobloc four-piston calipers and ABS	Single 250mm disc with single-piston caliper and ABS
61	65	41mm inverted telescopic fork with (13-way) adjustable compression and rebound (11-way) damping, spring preload (15-turn)/4.7	Horizontal back-link swingarm, Öhlins S46 shock with 30-position adjustable rebound damping and stepless spring preload adjustability/5.5 in	120/70-17	180/55-17	Dual 300mm discs with Brembo M4.32 monobloc four-piston calipers and ABS	Single 250mm disc with single-piston caliper and ABS
62	66	43mm Showa SFF-BP inverted fork with KECS-controlled rebound and compression damping, manual spring preload adjustability/4.7 in	Uni-Trak, Showa gas-charged shock with KECS-controlled compression and rebound damping, manual spring preload adjustability/5.3 in	120/70-17	190/55-17	Dual 320mm discs with radial-mount Brembo M4.32 Calipers, Kawasaki Intelligent anti-lock Brake System (KIBS)	Single 260mm disc with single-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS)
63	67	43mm Showa SFF-BP inverted fork with KECS-controlled rebound and compression damping, manual spring preload adjustability/4.7 in	Uni-Trak, Showa gas-charged shock with KECS-controlled compression and rebound damping, manual spring preload adjustability/5.3 in	120/70-17	190/55-17	Dual 320mm discs with radial-mount Brembo M4.32 Calipers, Kawasaki Intelligent anti-lock Brake System (KIBS)	Single 260mm disc with single-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS)
68	73	41mm telescopic fork/5.1 in	Uni-Trak swingarm with 5-way spring preload adjustment/5.8 in	100/90-19	130/80-17	Single 290mm disc, ABS	Single 220mm disc, ABS
69	74	41mm telescopic fork/5.1 in	Uni-Trak swingarm with 5-way spring preload adjustment/5.8 in	100/90-19	130/80-17	Single 290mm disc, ABS	Single 220mm disc, ABS
70	75	41mm telescopic fork with stepless adjustable rebound and spring preload/5.9 in	Single offset laydown shock with remote adjustable spring preload/5.7 in	120/70 ZR-17	160/60 ZR-17	Dual 300mm petal-style discs with 2-piston calipers, ABS	Single 250mm petal-style disc with single-piston caliper, ABS
71	76	43mm inverted Showa fork with KECS-controlled rebound and compression damping, manual spring preload adjustability and top-out springs/5.9 in	Horizontal back-link, Showa BFRC Lite gas-charged shock with piggyback reservoir, KECS-controlled compression and rebound damping electronically-adjustable spring preload/5.9 in	120/70-17	180/55-17	Dual 310mm petal discs with radial-mount 4-piston monobloc calipers, Kawasaki Intelligent anti-lock Brake System (KIBS)	Single 260mm petal disc with single-piston caliper, Kawasaki Intelligent anti-lock Brake System (KIBS)
72	77	37mm telescopic fork/4.6 in	Twin shocks with spring preload adjustability/3.7 in	90/90-18	110/90-17	Single 265mm disc with 2-piston calipers, ABS	Single 220mm disc with 1-piston caliper, ABS
73	79	37mm telescopic fork/4.6 in	Twin shocks with spring preload adjustability/3.7 in	90/90-18	110/90-17	Single 265mm disc with 2-piston calipers, ABS	Single 220mm disc with 1-piston caliper, ABS
74	80	41mm telescopic fork/5.1 in	Twin shocks with spring preload adjustability/4.2 in	100/90-19	130/80-18	Single 320mm disc with 2-piston calipers, ABS	Single 270mm disc with 2-piston caliper, ABS
75	81	41mm telescopic fork/5.1 in	Twin shocks with spring preload adjustability/4.2 in	100/90-19	130/80-18	Single 320mm disc with 2-piston calipers, ABS	Single 270mm disc with 2-piston caliper, ABS
76	82	41mm telescopic fork/4.7 in	Twin shocks/3.1 in	130/70-18	150/80-16	Single 310mm disc with twin-piston caliper (and ABS)	Single 220mm disc with single-piston caliper (and ABS)
77	83	41mm telescopic fork/4.7 in	Twin shocks/3.1 in	130/70-18	150/80-16	Single 310mm disc with twin-piston caliper (and ABS)	Single 220mm disc with single-piston caliper (and ABS)
78	84	41mm telescopic fork/4.7 in	Twin shocks/3.1 in	130/70-18	150/80-16	Single 310mm disc with twin-piston caliper, and ABS	Single 220mm disc with single-piston caliper, and ABS
79	85	41mm telescopic fork/4.7 in	Twin shocks/3.1 in	130/70-18	150/80-16	Single 310mm disc with twin-piston caliper, and ABS	Single 220mm disc with single-piston caliper, and ABS
80	86	41mm telescopic fork/5.1 in	Lay-down offset rear shock with linkage and adjustable preload/3.2 in	120/70-18	160/60-17	Single 300mm disc with twin-piston caliper (and ABS)	Single 250mm disc with single-piston caliper (and ABS)
81	87	41mm telescopic fork/5.1 in	Lay-down offset rear shock with linkage and adjustable preload/3.2 in	120/70-18	160/60-17	Single 300mm disc with twin-piston caliper (and ABS)	Single 250mm disc with single-piston caliper (and ABS)
82	88	41mm telescopic fork/5.1 in	Lay-down offset rear shock with linkage and adjustable preload/3.2 in	120/70-18	160/60-17	Single 300mm disc with twin-piston caliper, ABS	Single 250mm disc with single-piston caliper, ABS
83	89	41mm telescopic fork/5.1 in	Lay-down offset rear shock with linkage and adjustable preload/3.2 in	120/70-18	160/60-17	Single 300mm disc with twin-piston caliper, ABS	Single 250mm disc with single-piston caliper, ABS
84	90	41mm Showa telescopic fork/5.9 in	Uni-Trak swingarm, 7-way adjustable spring preload/4.1 in	130/90-16	180/70-15	Single 300mm hydraulic disc	Single 270mm hydraulic disc
85	91	41mm Showa telescopic fork/5.9 in	Uni-Trak swingarm, 7-way adjustable spring preload/4.1 in	130/90-16	180/70-15	Single 300mm hydraulic disc	Single 270mm hydraulic disc
86	92	41mm Showa telescopic fork/5.9 in	Uni-Trak swingarm, 7-way adjustable spring preload/4.1 in	80/90-21	180/70-15	Single 300mm hydraulic disc	Single 270mm hydraulic disc
87	93	41mm Showa telescopic fork/5.9 in	Uni-Trak swingarm, 7-way adjustable spring preload/4.1 in	80/90-21	180/70-15	Single 300mm hydraulic disc	Single 270mm hydraulic disc
88	94	41mm Showa telescopic fork/5.9 in	Uni-Trak swingarm, 7-way adjustable spring preload/4.1 in	130/90-16	180/70-15	Single 300mm hydraulic disc	Single 270mm hydraulic disc
89	95	41mm Showa telescopic fork/5.9 in	Uni-Trak swingarm, 7-way adjustable spring preload/4.1 in	130/90-16	180/70-15	Single 300mm hydraulic disc	Single 270mm hydraulic disc
90	96	45mm Showa telescopic fork/5.5 in	Swingarm with twin air-assisted shocks, with 4-way adjustable rebound damping/3.1 in	130/90-16	170/70-16	Dual 300mm discs, dual four-piston calipers, K-ACT ABS	Single 300mm disc, twin-piston caliper, K-ACT ABS
91	97	45mm Showa telescopic fork/5.5 in	Swingarm with twin air-assisted shocks, with 4-way adjustable rebound damping/3.1 in	130/90-16	170/70-16	Dual 300mm discs, dual four-piston calipers, K-ACT ABS	Single 300mm disc, twin-piston caliper, K-ACT ABS
92	98	45mm Showa telescopic fork/5.5 in	Swingarm with twin air-assisted shocks, with 4-way adjustable rebound damping/3.1 in	130/90-16	170/70-16	Dual 300mm discs, dual four-piston calipers, K-ACT ABS	Single 300mm disc, twin-piston caliper, K-ACT ABS
93	99	45mm Showa telescopic fork/5.5 in	Swingarm with twin air-assisted shocks, with 4-way adjustable rebound damping/3.1 in	130/90-16	170/70-16	Dual 300mm discs, dual four-piston calipers, K-ACT ABS	Single 300mm disc, twin-piston caliper, K-ACT ABS
94	101	43mm inverted telescopic fork/8.3 in	Bottom-link Uni-Trak with adjustable spring preload/7.7 in	90/90-21	140/70-17	Single 300mm disc with 2-piston caliper and ABS	Single 230mm disc with 2-piston caliper and ABS
95	102	43mm inverted telescopic fork/8.3 in	Bottom-link Uni-Trak with adjustable spring preload/7.7 in	90/90-21	140/70-17	Single 300mm disc with 2-piston caliper and ABS	Single 230mm disc with 2-piston caliper and ABS
96	103	41mm telescopic fork/ 7.9 in	Uni-Trak single shock with adjustable rebound damping and adjustable spring preload/8.0 in	90/90-21	130/80-17	Single 300mm disc with 2-piston calipers	Single 240mm disc with single-piston caliper
97	104	41mm telescopic fork/ 7.9 in	Uni-Trak single shock with adjustable rebound damping and adjustable spring preload/8.0 in	90/90-21	130/80-17	Single 300mm disc with 2-piston calipers	Single 240mm disc with single-piston caliper
98	105	41mm telescopic fork/ 6.7 in	Uni-Trak single shock with adjustable rebound damping and adjustable spring preload/7.0 in	90/90-21	130/80-17	Single 300mm disc with 2-piston calipers	Single 240mm disc with single-piston caliper
99	106	41mm telescopic fork/ 6.7 in	Uni-Trak single shock with adjustable rebound damping and adjustable spring preload/7.0 in	90/90-21	130/80-17	Single 300mm disc with 2-piston calipers	Single 240mm disc with single-piston caliper
100	107	41mm telescopic fork/ 7.9 in	Uni-Trak single shock with adjustable rebound damping and adjustable spring preload/8.0 in	90/90-21	130/80-17	Single 300mm disc with 2-piston calipers (and ABS)	Single 240mm disc with single-piston caliper (and ABS)
101	108	41mm telescopic fork/ 7.9 in	Uni-Trak single shock with adjustable rebound damping and adjustable spring preload/8.0 in	90/90-21	130/80-17	Single 300mm disc with 2-piston calipers (and ABS)	Single 240mm disc with single-piston caliper (and ABS)
102	109	30mm hydraulic telescopic fork/4.3 in	Swingarm with single hydraulic shock/4.3 in	2.50 x 14	3.00 x 12	90mm mechanical drum, cable actuated	110mm mechanical drum, rod actuated
103	110	30mm hydraulic telescopic fork/4.3 in	Swingarm with single hydraulic shock/4.3 in	2.50 x 14	3.00 x 12	90mm mechanical drum, cable actuated	110mm mechanical drum, rod actuated
104	111	30mm hydraulic telescopic fork/5.5 in	Swingarm with single hydraulic shock/5.2 in	2.50 x 14	3.00 x 12	90mm mechanical drum, cable actuated	110mm mechanical drum, rod actuated
105	112	30mm hydraulic telescopic fork/5.5 in	Swingarm with single hydraulic shock/5.2 in	2.50 x 14	3.00 x 12	90mm mechanical drum, cable actuated	110mm mechanical drum, rod actuated
106	113	33mm telescopic fork/7.1 in	Uni-Trak linkage system and single shock with 5-way preload adjustability/7.1 in	70/100-17	90/100-14	Single 220mm petal disc with a dual-piston caliper	Single 186mm petal disc with single-piston caliper
107	114	33mm telescopic fork/7.1 in	Uni-Trak linkage system and single shock with 5-way preload adjustability/7.1 in	70/100-17	90/100-14	Single 220mm petal disc with a dual-piston caliper	Single 186mm petal disc with single-piston caliper
108	115	33mm telescopic fork/7.1 in	Uni-Trak linkage system and single shock with piggyback reservoir, fully adjustable preload and 22-way rebound damping/7.1 in	70/100-19	90/100-16	Single 220mm petal disc with a dual-piston caliper	Single 186mm petal disc with single-piston caliper
109	116	33mm telescopic fork/7.1 in	Uni-Trak linkage system and single shock with piggyback reservoir, fully adjustable preload and 22-way rebound damping/7.1 in	70/100-19	90/100-16	Single 220mm petal disc with a dual-piston caliper	Single 186mm petal disc with single-piston caliper
110	117	33mm telescopic fork/7.5 in	Uni-Trak linkage system and single shock with piggyback reservoir, 20-way rebound damping and threaded preload adjustability/7.9 in	2.75 x 21	4.10 x 18	Single 220mm petal disc with a dual-piston caliper	Single 186mm petal disc with single-piston caliper
111	118	33mm telescopic fork/7.5 in	Uni-Trak linkage system and single shock with piggyback reservoir, 20-way rebound damping and threaded preload adjustability/7.9 in	2.75 x 21	4.10 x 18	Single 220mm petal disc with a dual-piston caliper	Single 186mm petal disc with single-piston caliper
112	119	37mm telescopic fork/9.8 in	Uni-Trak linkage system and single shock with adjustable spring preload/9.8 in	80/100-21	100/100-18	Single 240mm petal disc with a dual-piston caliper	Single 220mm petal disc with single-piston caliper
113	120	37mm telescopic fork/9.8 in	Uni-Trak linkage system and single shock with adjustable spring preload/9.8 in	80/100-21	100/100-18	Single 240mm petal disc with a dual-piston caliper	Single 220mm petal disc with single-piston caliper
114	121	37mm telescopic fork/8.7 in	Uni-Trak linkage system and single shock with adjustable spring preload/8.8 in	80/100-21	100/100-18	Single 240mm petal disc with a dual-piston caliper	Single 220mm petal disc with single-piston caliper
115	122	37mm telescopic fork/8.7 in	Uni-Trak linkage system and single shock with adjustable spring preload/8.8 in	80/100-21	100/100-18	Single 240mm petal disc with a dual-piston caliper	Single 220mm petal disc with single-piston caliper
116	123	43mm inverted telescopic fork with adjustable compression damping/11.2 in	Uni-Trak gas charged shock with piggyback reservoir with adjustable compression, rebound damping and spring preload/11.2 in	3.0 x 21	4.6 x 18	Single 270mm petal disc with a dual-piston caliper	Single 240mm petal disc with single-piston caliper
117	124	43mm inverted telescopic fork with adjustable compression damping/11.2 in	Uni-Trak gas charged shock with piggyback reservoir with adjustable compression, rebound damping and spring preload/11.2 in	3.0 x 21	4.6 x 18	Single 270mm petal disc with a dual-piston caliper	Single 240mm petal disc with single-piston caliper
118	125	37mm telescopic fork/7.9 in	Uni-Trak linkage system and single shock with adjustable spring preload/8.8 in	2.75 x 21	4.10 x 18	Single 240mm petal disc with a dual-piston caliper	Single 220mm petal disc with single-piston caliper
119	126	37mm telescopic fork/7.9 in	Uni-Trak linkage system and single shock with adjustable spring preload/8.8 in	2.75 x 21	4.10 x 18	Single 265mm petal disc with a dual-piston caliper (and ABS)	Single 220mm petal disc with single-piston caliper (and ABS)
120	127	37mm telescopic fork/7.9 in	Uni-Trak linkage system and single shock with adjustable spring preload/8.8 in	2.75 x 21	4.10 x 18	Single 240mm petal disc with a dual-piston caliper	Single 220mm petal disc with single-piston caliper
121	128	37mm telescopic fork/7.9 in	Uni-Trak linkage system and single shock with adjustable spring preload/8.8 in	2.75 x 21	4.10 x 18	Single 265mm petal disc with a dual-piston caliper (and ABS)	Single 220mm petal disc with single-piston caliper (and ABS)
122	129	37mm telescopic fork/6.2 in	Uni-Trak linkage system and single shock with adjustable spring preload/6.6 in	2.75 x 21	4.10 x 18	Single 265mm petal disc with a dual-piston caliper	Single 220mm petal disc with single-piston caliper
123	130	37mm telescopic fork/7.9 in	Uni-Trak linkage system and single shock with adjustable spring preload/8.8 in	2.75 x 21	4.10 x 18	Single 265mm petal disc with a dual-piston caliper	Single 220mm petal disc with single-piston caliper
124	131	43mm inverted telescopic fork with adjustable compression damping/10.0 in	Uni-Trak gas charged shock with piggyback reservoir with adjustable compression, rebound damping and spring preload/9.1 in	3.0 x 21	4.6 x 18	Single 250mm petal disc with a dual-piston caliper	Single 240mm petal disc with single-piston caliper
125	132	43mm inverted telescopic fork with adjustable compression damping/10.0 in	Uni-Trak gas charged shock with piggyback reservoir with adjustable compression, rebound damping and spring preload/9.1 in	3.0 x 21	4.6 x 18	Single 250mm petal disc with a dual-piston caliper	Single 240mm petal disc with single-piston caliper
126	133	37mm telescopic fork/7.4 in	Uni-Trak linkage system and single shock with adjustable spring preload/8.8 in	110/70-17	120/70-17	Single 300mm petal disc with a dual-piston caliper and ABS	Single 220mm petal disc with single-piston caliper and ABS
127	134	37mm telescopic fork/7.4 in	Uni-Trak linkage system and single shock with adjustable spring preload/8.8 in	110/70-17	120/70-17	Single 300mm petal disc with a dual-piston caliper and ABS	Single 220mm petal disc with single-piston caliper and ABS
128	135	43mm inverted cartridge fork with adjustable compression damping/9.1 in	Uni-Trak gas charged shock with piggyback reservoir with adjustable rebound damping and spring preload/8.1 in	110/70-17	130/70-17	Single 300mm petal disc with a dual-piston caliper	Single 240mm petal disc with single-piston caliper
129	136	43mm inverted cartridge fork with adjustable compression damping/9.1 in	Uni-Trak gas charged shock with piggyback reservoir with adjustable rebound damping and spring preload/8.1 in	110/70-17	130/70-17	Single 300mm petal disc with a dual-piston caliper	Single 240mm petal disc with single-piston caliper
130	137	33mm leading axle telescopic fork with 4-way rebound damping/8.3 in	Uni-Trak single shock system with stepless 3-turns rebound damping and fully adjustable spring preload/9.4 in	60/100-14	80/100-12	Single 180mm disc with single-piston caliper	Single 180mm disc with single-piston caliper
131	138	33mm leading axle telescopic fork with 4-way rebound damping/8.3 in	Uni-Trak single shock system with stepless 3-turns rebound damping and fully adjustable spring preload/9.4 in	60/100-14	80/100-12	Single 180mm disc with single-piston caliper	Single 180mm disc with single-piston caliper
132	140	43mm inverted fork with adjustable compression and rebound damping/10.8 in	Uni-Trak single shock with adjustable dual-range (high-low-speed) compression and rebound damping, plus adjustable spring preload/10.8 in	70/100-17	90/100-14	Single 240mm petal disc with dual-piston caliper	Single 220mm petal disc with single-piston caliper
133	141	36mm inverted telescopic cartridge fork with 20-way compression damping/10.8 in	Uni-Trak single shock system with 24-way compression and 21-way rebound damping, plus adjustable spring preload/10.8 in	70/100-17	90/100-14	Single 220mm petal disc with dual-piston caliper	Single 184mm petal disc with single-piston caliper
134	142	43mm inverted fork with adjustable compression and rebound damping/10.8 in	Uni-Trak single shock with adjustable dual-range (high-low-speed) compression and rebound damping, plus adjustable spring preload/12.0 in	70/100-19	90/100-16	Single 240mm petal disc with dual-piston caliper	Single 220mm petal disc with single-piston caliper
135	143	43mm inverted fork with adjustable compression and rebound damping/10.8 in	Uni-Trak single shock with adjustable dual-range (high-low-speed) compression and rebound damping, plus adjustable spring preload/12.0 in	70/100-19	90/100-16	Single 240mm petal disc with dual-piston caliper	Single 220mm petal disc with single-piston caliper
136	144	36mm inverted telescopic cartridge fork with 20-way compression damping/10.8 in	Uni-Trak gas charged shock with piggyback reservoir with 24-way compression and 21-way rebound damping plus adjustable spring preload/10.8 in	70/100-19	90/100-16	Single 220mm petal disc with dual-piston caliper	Single 184mm petal disc with single-piston caliper
137	145	49mm Showa inverted telescopic coil-spring fork with 16-way compression and rebound damping/12.0 in	Uni-Trak with dual-range (4 turns high speed/19-way low-speed) compression damping, 22-way rebound damping and adjustable preload/12.1 in	80/100-21	110/90-19	Single semi-floating 270mm Braking petal disc with dual-piston caliper	Single 240mm Braking petal disc with single-piston caliper
138	146	49mm Showa inverted telescopic coil-spring fork with 23-way compression damping and 20-way rebound damping /12.0 in	Uni-Trak with dual-range (2.25 turns high speed/21-way low-speed) compression damping, 38-way rebound damping and adjustable preload/12.1 in	80/100-21	110/90-19	Single semi-floating 270mm Braking petal disc with dual-piston caliper	Single 240mm Braking petal disc with single-piston caliper
139	147	49mm Showa inverted telescopic coil-spring fork with 21-way adjustable compression and 22-way adjustable rebound damping/12.0 in	Uni-Trak gas charged shock with piggyback reservoir with adjustable dual-range compression damping (19-way low speed and 4.25 turn stepless high speed), 23-way adjustable rebound damping and stepless adjustable preload/12.1 in	80/100-21	120/80-19	Single semi-floating 270mm Braking/Sunstar petal disc with Brembo master cylinder and dual-piston caliper	Single 240mm Braking/Sunstar petal disc with single-piston caliper
140	148	49mm Showa inverted telescopic coil-spring fork with 21-way adjustable compression and 22-way adjustable rebound damping/12.0 in	Uni-Trak gas charged shock with piggyback reservoir with adjustable dual-range compression damping (19-way low speed and 4.25 turn stepless high speed), 23-way adjustable rebound damping and stepless adjustable preload/12.1 in	80/100-21	120/80-19	Single semi-floating 270mm Braking/Sunstar petal disc with Brembo master cylinder and dual-piston caliper	Single 240mm Braking/Sunstar petal disc with single-piston caliper
141	149	49mm Showa inverted telescopic coil-spring fork with 21-way adjustable compression and 22-way adjustable rebound damping/12.0 in	Uni-Trak gas charged shock with piggyback reservoir with adjustable dual-range compression damping (19-way low speed and 4.25 turn stepless high speed), 23-way adjustable rebound damping and stepless adjustable preload/12.1 in	80/100-21	120/80-19	Single semi-floating 270mm Braking/Sunstar petal disc with Brembo master cylinder and dual-piston caliper	Single 240mm Braking/Sunstar petal disc with single-piston caliper
142	150	49mm Showa inverted telescopic coil-spring fork with 21-way adjustable compression and 22-way adjustable rebound damping/12.0 in	Uni-Trak gas charged shock with piggyback reservoir with adjustable dual-range compression damping (19-way low speed and 4.25 turn stepless high speed), 23-way adjustable rebound damping and stepless adjustable preload/12.1 in	80/100-21	120/80-19	Single semi-floating 270mm Braking/Sunstar petal disc with Brembo master cylinder and dual-piston caliper	Single 240mm Braking/Sunstar petal disc with single-piston caliper
143	151	49mm Showa inverted telescopic coil-spring fork with 16-way compression and rebound damping /12.0 in	Uni-Trak with dual-range (4 turns high speed/19-way low-speed) compression damping, 22-way rebound damping and adjustable preload/12.1 in	80/100-21	110/100-18	Single semi-floating 270mm Braking petal disc with dual-piston caliper	Single 240mm Braking petal disc with single-piston caliper
144	152	49mm Showa inverted telescopic coil-spring fork with 23-way compression damping and 20-way rebound damping /12.0 in	Uni-Trak with dual-range (2.25 turns high speed/21-way low-speed) compression damping, 38-way rebound damping and adjustable preload/12.1 in	80/100-21	110/100-18	Single semi-floating 270mm Braking petal disc with dual-piston caliper	Single 240mm Braking petal disc with single-piston caliper
145	153	49mm Showa inverted telescopic coil-spring fork with 21-way adjustable compression and 22-way adjustable rebound damping/12.0 in	Uni-Trak gas charged shock with piggyback reservoir with adjustable dual-range compression damping (19-way low speed and 4.25 turn stepless high speed), 23-way adjustable rebound damping and stepless adjustable preload/12.1 in	80/100-21	120/80-18	Single semi-floating 270mm Braking/Sunstar petal disc with Brembo master cylinder and dual-piston caliper	Single 240mm Braking/Sunstar petal disc with single-piston caliper
146	154	49mm Showa inverted telescopic coil-spring fork with 21-way adjustable compression and 22-way adjustable rebound damping/12.0 in	Uni-Trak gas charged shock with piggyback reservoir with adjustable dual-range compression damping (19-way low speed and 4.25 turn stepless high speed), 23-way adjustable rebound damping and stepless adjustable preload/12.1 in	80/100-21	120/80-18	Single semi-floating 270mm Braking/Sunstar petal disc with Brembo master cylinder and dual-piston caliper	Single 240mm Braking/Sunstar petal disc with single-piston caliper
\.


--
-- TOC entry 4935 (class 0 OID 17069)
-- Dependencies: 224
-- Data for Name: power; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.power (power_id, motorcycle_id, engine_type, displacement_cc, bore_x_stroke, compression_ratio, maximum_horsepower, maximum_torque, fuel_system, ignition, transmission, final_drive, electronic_rider_aids) FROM stdin;
1	2	Air-cooled, interior permanent magnet synchronous motor	0	\N	\N	9.0 kW / 2,600-4,000 min-1	29.7 lb-ft @ 500 rpm	Lithium-ion battery pack (x2) - 50.4 V 30 Ah	Electric Motor	Single reduction gear	Chain	WALK Mode (with Reverse), Anti-lock Brake System (ABS)
3	5	4-stroke, Parallel Twin, DOHC, liquid-cooled	451	70.0 x 58.6mm	11.3:1	51.0 hp @ 10,000 rpm	31.7 lb-ft @ 7,500 rpm	DFI with dual 32mm throttle bodies	TCBI with Digital Advance	6-speed	Sealed chain	Economical Riding Indicator, Anti-lock Brake System (ABS only)
4	6	4-stroke, Parallel Twin, DOHC, liquid-cooled	451	70.0 x 58.6mm	11.3:1	51.0 hp @ 10,000 rpm	31.7 lb-ft @ 7,500 rpm	DFI with dual 32mm throttle bodies	TCBI with Digital Advance	6-speed	Sealed chain	Economical Riding Indicator, Anti-lock Brake System (ABS only)
5	7	4-stroke, Parallel Twin, DOHC, liquid-cooled	451	70.0 x 58.6mm	11.3:1	51.0 hp @ 10,000 rpm	31.7 lb-ft @ 7,500 rpm	DFI with dual 32mm throttle bodies	TCBI with Digital Advance	6-speed	Sealed chain	Economical Riding Indicator, Anti-lock Brake System (ABS)
6	8	4-stroke, Parallel Twin, DOHC, liquid-cooled	451	70.0 x 58.6mm	11.3:1	51.0 hp @ 10,000 rpm	31.7 lb-ft @ 7,500 rpm	DFI with dual 32mm throttle bodies	TCBI with Digital Advance	6-speed	Sealed chain	Economical Riding Indicator, Anti-lock Brake System (ABS)
7	9	4-stroke, Parallel Twin, DOHC, liquid-cooled	451	70.0 x 58.6mm	11.3:1	51.0 hp @ 10,000 rpm	31.7 lb-ft @ 7,500 rpm	DFI with dual 32mm throttle bodies	TCBI with Digital Advance	6-speed	Sealed chain	Economical Riding Indicator
8	10	4-stroke, Parallel Twin, DOHC, liquid-cooled	451	70.0 x 58.6mm	11.3:1	51.0 hp @ 10,000 rpm	31.7 lb-ft @ 7,500 rpm	DFI with dual 32mm throttle bodies	TCBI with Digital Advance	6-speed	Sealed chain	Economical Riding Indicator, Anti-lock Brake System (ABS)
9	11	4-stroke, parallel twin, DOHC, 8-valve, liquid cooled	649	83.0 x 60.0mm	10.8:1	67.0 hp @ 8,000 rpm	48.5 lb-ft @ 6,700 rpm	DFI with dual 36mm Keihin throttle bodies	TCBI with Electronic Advance	6-speed	Sealed chain	Kawasaki Traction Control (KTRC), Anti-lock Brake System (ABS only)
10	12	4-stroke, parallel twin, DOHC, 8-valve, liquid cooled	649	83.0 x 60.0mm	10.8:1	67.0 hp @ 8,000 rpm	48.5 lb-ft @ 6,700 rpm	DFI with dual 36mm Keihin throttle bodies	TCBI with Electronic Advance	6-speed	Sealed chain	Kawasaki Traction Control (KTRC), Anti-lock Brake System (ABS only)
11	13	4-stroke, parallel twin, DOHC, 8-valve, liquid cooled	649	83.0 x 60.0mm	10.8:1	67.0 hp @ 8,000 rpm	48.5 lb-ft @ 6,700 rpm	DFI with dual 36mm Keihin throttle bodies	TCBI with electronic advance	6-speed	Sealed chain	Kawasaki Traction Control (KTRC), Anti-lock Brake System (ABS only)
12	14	4-stroke, Parallel Twin, DOHC, liquid-cooled (Hybrid)	451	70.0 x 58.6mm	11.7:1	\N	44.2 lb-ft @ 2,800 rpm	EFI with dual 36mm throttle bodies	TCBI	6-speed Automated Manual	Chain	Automatic Launch Position Finder (ALPF) in MT, WALK Mode (with Reverse), Anti-lock Brake System (ABS)
13	17	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	1099	77.0 x 59.0mm	11.8:1	134.0 hp @ 9,000 rpm	83.2 lb-ft @ 7,600 rpm	DFI with 38mm Electronic Throttle Valves	TCBI with Digital Advance	6-speed, return shift with wet multi-disc manual Assist & Slipper Clutch	Sealed chain	Economical Riding Indicator, Electronic Cruise Control, KTRC, KIBS, ABS, Power Modes, KCMF, KQS, IMU-Enhanced Chassis Orientation Awareness
14	18	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	1099	77.0 x 59.0mm	11.8:1	134.0 hp @ 9,000 rpm	83.2 lb-ft @ 7,600 rpm	DFI with 38mm Electronic Throttle Valves	TCBI with Digital Advance	6-speed, return shift with wet multi-disc manual Assist & Slipper Clutch	Sealed chain	Economical Riding Indicator, Electronic Cruise Control, KTRC, KIBS, ABS, Power Modes, KCMF, KQS, IMU-Enhanced Chassis Orientation Awareness
15	19	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	1099	77.0 x 59.0mm	11.8:1	134.0 hp @ 9,000 rpm	83.2 lb-ft @ 7,600 rpm	DFI with 38mm Electronic Throttle Valves	TCBI with Digital Advance	6-speed, return shift with wet multi-disc manual Assist & Slipper Clutch	Sealed chain	Economical Riding Indicator, Electronic Cruise Control, KTRC, KIBS, ABS, Power Modes, KCMF, KQS, IMU-Enhanced Chassis Orientation Awareness
16	20	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	1099	77.0 x 59.0mm	11.8:1	134.0 hp @ 9,000 rpm	83.2 lb-ft @ 7,600 rpm	DFI with 38mm Electronic Throttle Valves	TCBI with Digital Advance	6-speed, return shift with wet multi-disc manual Assist & Slipper Clutch	Sealed chain	Economical Riding Indicator, Electronic Cruise Control, KTRC, KIBS, ABS, Power Modes, KCMF, KQS, IMU-Enhanced Chassis Orientation Awareness
17	21	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	399	57.0 x 39.1mm	12.3:1	56.0 hp @ 11,500 rpm	26.5 lb-ft @ 11,000 rpm	DFI with 34mm throttle valves (4)	TCBI with Digital Advance	6-speed, return shift	Chain	Economical Riding Indicator, Kawasaki Traction Control (KTRC) (3-mode), Power Modes, Anti-lock Brake System (ABS)
18	22	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	399	57.0 x 39.1mm	12.3:1	56.0 hp @ 11,500 rpm	26.5 lb-ft @ 11,000 rpm	DFI with 34mm throttle valves (4)	TCBI with Digital Advance	6-speed, return shift	Chain	Economical Riding Indicator, Kawasaki TRaction Control (KTRC) (3-mode), Power Modes, Anti-lock Brake System (ABS)
19	23	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	399	57.0 x 39.1mm	12.3:1	56.0 hp @ 11,500 rpm	26.5 lb-ft @ 11,000 rpm	DFI with 34mm throttle valves (4)	TCBI with Digital Advance	6-speed, return shift	Chain	Economical Riding Indicator, Kawasaki Traction Control (KTRC) (3-mode), Kawasaki Quick Shifter (KQS) (dual direction), Power Modes, Anti-lock Brake System (ABS)
20	24	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	399	57.0 x 39.1mm	12.3:1	56.0 hp @ 11,500 rpm	26.5 lb-ft @ 11,000 rpm	DFI with 34mm throttle valves (4)	TCBI with Digital Advance	6-speed, return shift	Chain	Economical Riding Indicator, Kawasaki Traction Control (KTRC) (3-mode), Kawasaki Quick Shifter (KQS) (dual direction), Power Modes, Anti-lock Brake System (ABS)
21	25	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	399	57.0 x 39.1mm	12.3:1	56.0 hp @ 11,500 rpm	26.5 lb-ft @ 11,000 rpm	DFI with 34mm throttle valves (4)	TCBI with Digital Advance	6-speed, return shift	Chain	Economical Riding Indicator, Kawasaki TRaction Control (KTRC) (3-mode), Kawasaki Quick Shifter (KQS) (dual direction), Power Modes, Anti-lock Brake System (ABS)
22	26	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	636	67.0 x 45.1mm	12.9:1	127.0 hp @ 13,000 rpm	52.1 lb-ft @ 10,800 rpm	DFI with 38mm Keihin throttle bodies (4) and oval sub-throttles	TCBI with electronic advance	6-speed, return shift	Sealed chain	Kawasaki Traction Control (KTRC), Power Modes (Full/Low), Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only), Kawasaki Quick Shifter (KQS) (upshift only)
54	58	4-stroke, 2-cylinder, DOHC, liquid-cooled	649	83.0 x 60.0mm	10.8:1	67.0 hp @ 8,000 rpm	48.5 lb-ft @ 6,700 rpm	DFI with Keihin 36mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Kawasaki Traction Control (KTRC - 3 Modes), Anti-lock Brake System (ABS)
23	27	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	636	67.0 x 45.1mm	12.9:1	127.0 hp @ 13,000 rpm	52.1 lb-ft @ 10,800 rpm	DFI with 38mm Keihin throttle bodies (4) and oval sub-throttles	TCBI with electronic advance	6-speed, return shift	Sealed chain	Kawasaki Traction Control (KTRC), Power Modes (Full/Low), Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only), Kawasaki Quick Shifter (KQS) (upshift only)
24	28	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	636	67.0 x 45.1mm	12.9:1	127.0 hp @ 13,000 rpm	52.1 lb-ft @ 10,800 rpm	DFI with 38mm Keihin throttle bodies (4) and oval sub-throttles	TCBI with electronic advance	6-speed, return shift	Sealed chain	Kawasaki Traction Control (KTRC), Power Modes (Full/Low), Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only), Kawasaki Quick Shifter (KQS) (upshift only)
25	29	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	998	76.0 x 55.0mm	13.0:1	190.0 hp @ 11,500 rpm	82.5 lb-ft @ 11,300 rpm	DFI with 47mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Electronic Cruise Control, Kawasaki Launch Control Mode (KLCM), Sport-Kawasaki TRaction Control (S-KTRC), Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only), Anti-lock Brake System (ABS) (ABS only), Power Modes, Kawasaki Cornering Management Function (KCMF), Kawasaki Engine Brake Control, Kawasaki Quick Shifter (KQS), IMU-Enhanced Chassis Orientation Awareness
26	30	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	998	76.0 x 55.0mm	13.0:1	196.0 hp @ 11,500 rpm	83.9 lb-ft @ 11,300 rpm	DFI, 47mm throttle bodies	TCBI with electronic advance	6-speed	Sealed chain	Öhlins Electronic Steering Damper, Electronic Cruise Control, Kawasaki Launch Control Mode (KLCM), Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only), Sport-Kawasaki TRaction Control (S-KTRC), Kawasaki Engine Braking Control, Kawasaki Quick Shifter (KQS) (upshift & downshift), Kawasaki Corner Management Function (KCMF)
27	31	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	998	76.0 x 55.0mm	13.0:1	190.0 hp @ 11,500 rpm	82.5 lb-ft @ 11,300 rpm	DFI with 47mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Electronic Cruise Control, Kawasaki Launch Control Mode (KLCM), Sport-Kawasaki TRaction Control (S-KTRC), Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only), Anti-lock Brake System (ABS) (ABS only), Power Modes, Kawasaki Cornering Management Function (KCMF), Kawasaki Engine Brake Control, Kawasaki Quick Shifter (KQS), IMU-Enhanced Chassis Orientation Awareness
28	32	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	998	76.0 x 55.0mm	13.0:1	188.0 hp @ 11,500 rpm	81.7 lb-ft @ 11,500 rpm	DFI, 47mm throttle bodies and Variable Air Intake System (VAI)	TCBI with digital advance	6-speed, return shift	Sealed chain	Öhlins Electronic Steering Damper, Kawasaki Launch Control Mode (KLCM), Kawasaki Intelligent anti-lock Brake System (KIBS), Sport-Kawasaki TRaction Control (S-KTRC), Kawasaki Engine Braking Control, Kawasaki Quick Shifter (KQS) (upshift & downshift), Kawasaki Corner Management Function (KCMF), Power Modes (Full/Mid/Low)
29	33	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	998	76.0 x 55.0mm	13.0:1	196.0 hp @ 11,500 rpm	83.9 lb-ft @ 11,300 rpm	DFI, 47mm throttle bodies	TCBI with electronic advance	6-speed	Sealed chain	Öhlins Electronic Steering Damper, Electronic Cruise Control, Kawasaki Launch Control Mode (KLCM), Kawasaki Intelligent anti-lock Brake System (KIBS) (ABS only), Sport-Kawasaki TRaction Control (S-KTRC), Kawasaki Engine Braking Control, Kawasaki Quick Shifter (KQS) (upshift & downshift), Kawasaki Corner Management Function (KCMF)
30	34	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	1441	84.0 x 65.0mm	12.3:1	197.0 hp @ 10,000 rpm	116.5 lb-ft @ 7,500 rpm	DFI with 44mm Mikuni throttle bodies (4)	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Kawasaki Traction Control (KTRC) (3-mode), Power Modes, Anti-lock Brake System (ABS)
31	35	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled, Supercharged	998	76.0 x 55.0mm	11.2:1	207.0 hp @ 10,000 rpm	101.0 lb-ft @ 8,500 rpm	DFI with 40mm throttle bodies (4); Kawasaki Supercharger	TCBI with Digital Advance	6-speed, return shift, dog-ring	Sealed chain	Economical Riding Indicator, ARAS: Forward Collision Warning (FCW), Blind-Spot Detection (BSD), Adaptive Cruise Control (ACC), Vehicle Hold Assist (VHA), KECS (Electronic Suspension), Power Modes, KTRC, KLCM, KIBS, ABS, KEBC, KQS (dual direction), IMU-Enhanced Chassis Orientation Awareness
32	36	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled, Supercharged	998	76.0 x 55.0mm	11.2:1	207.0 hp @ 10,000 rpm	101.0 lb-ft @ 8,500 rpm	DFI with 40mm throttle bodies (4); Kawasaki Supercharger	TCBI with Digital Advance	6-speed, return shift, dog-ring	Sealed chain	Economical Riding Indicator, ARAS: Forward Collision Warning (FCW), Blind-Spot Detection (BSD), Adaptive Cruise Control (ACC), Vehicle Hold Assist (VHA), KECS (Electronic Suspension), Power Modes, KTRC, KLCM, KIBS, ABS, KEBC, KQS (dual direction), IMU-Enhanced Chassis Orientation Awareness
33	37	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled, Supercharged	998	76.0 x 55.0mm	8.5:1	240 hp @ 11,500 rpm	104.9 lb-ft @ 11,000 rpm	DFI with 50mm throttle bodies (4) with dual injection; Kawasaki Supercharger	TCBI with Digital Advance	6-speed, return shift, dog-ring	Sealed chain	Economical Riding Indicator, Kawasaki Cornering Management Function (KCMF), Kawasaki Traction Control (KTRC), Kawasaki Launch Control Mode (KLCM), IMU-Enhanced Chassis Orientation Awareness, Kawasaki Intelligent anti-lock Brake System (KIBS), Kawasaki Engine Brake Control (KEBC), Kawasaki Quick Shifter (KQS) (upshift & downshift), Ohlins Electronic Steering Damper
34	38	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled, Supercharged	998	76.0 x 55.0mm	8.5:1	240 hp @ 11,500 rpm	104.9 lb-ft @ 11,000 rpm	DFI with 50mm throttle bodies (4) with dual injection; Kawasaki Supercharger	TCBI with Digital Advance	6-speed, return shift, dog-ring	Sealed chain	Economical Riding Indicator, Kawasaki Cornering Management Function (KCMF), Kawasaki Traction Control (KTRC), Kawasaki Launch Control Mode (KLCM), IMU-Enhanced Chassis Orientation Awareness, Kawasaki Intelligent anti-lock Brake System (KIBS), Kawasaki Engine Brake Control (KEBC), Kawasaki Quick Shifter (KQS) (upshift & downshift), Ohlins Electronic Steering Damper
35	39	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled, Supercharged	998	76.0 x 55.0mm	8.5:1	240 hp @ 11,500 rpm	104.9 lb-ft @ 11,000 rpm	DFI with 50mm throttle bodies (4) with dual injection; Kawasaki Supercharger	TCBI with Digital Advance	6-speed, return shift, dog-ring	Sealed chain	Economical Riding Indicator, Kawasaki Cornering Management Function (KCMF), Kawasaki Traction Control (KTRC), Kawasaki Launch Control Mode (KLCM), IMU-Enhanced Chassis Orientation Awareness, Kawasaki Intelligent anti-lock Brake System (KIBS), Kawasaki Engine Brake Control (KEBC), Kawasaki Quick Shifter (KQS) (upshift & downshift), Ohlins Electronic Steering Damper
55	59	4-stroke, 2-cylinder, DOHC, liquid-cooled	649	83.0 x 60.0mm	10.8:1	67.0 hp @ 8,000 rpm	48.5 lb-ft @ 6,700 rpm	DFI with Keihin 36mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Kawasaki Traction Control (KTRC - 3 Modes), Anti-lock Brake System (ABS)
36	40	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled, Supercharged	998	76.0 x 55.0mm	8.5:1	240 hp @ 11,500 rpm	104.9 lb-ft @ 11,000 rpm	DFI with 50mm throttle bodies (4) with dual injection; Kawasaki Supercharger	TCBI with Digital Advance	6-speed, return shift, dog-ring	Sealed chain	Economical Riding Indicator, Kawasaki Cornering Management Function (KCMF), Kawasaki Traction Control (KTRC), Kawasaki Launch Control Mode (KLCM), IMU-Enhanced Chassis Orientation Awareness, Kawasaki Intelligent anti-lock Brake System (KIBS), Kawasaki Engine Brake Control (KEBC), Kawasaki Quick Shifter (KQS) (upshift & downshift), Ohlins Electronic Steering Damper
37	41	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled, Supercharged	998	76.0 x 55.0mm	8.3:1	322 hp @ 14,000 rpm	121.5 lb-ft @ 12,500 rpm	DFI with 50mm throttle bodies (4) with dual injection; Kawasaki Supercharger	TCBI with Digital Advance	6-speed, return shift, dog-ring	Sealed chain	Economical Riding Indicator, Kawasaki Cornering Management Function (KCMF), Kawasaki Traction Control (KTRC), Kawasaki Launch Control Mode (KLCM), IMU-Enhanced Chassis Orientation Awareness, Kawasaki Intelligent anti-lock Brake System (KIBS), Kawasaki Engine Brake Control (KEBC), Kawasaki Quick Shifter (KQS) (upshift & downshift), Ohlins Electronic Steering Damper
38	42	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled, Supercharged	998	76.0 x 55.0mm	8.3:1	322 hp @ 14,000 rpm	121.5 lb-ft @ 12,500 rpm	DFI with 50mm throttle bodies (4) with dual injection; Kawasaki Supercharger	TCBI with Digital Advance	6-speed, return shift, dog-ring	Sealed chain	Economical Riding Indicator, Kawasaki Cornering Management Function (KCMF), Kawasaki Traction Control (KTRC), Kawasaki Launch Control Mode (KLCM), IMU-Enhanced Chassis Orientation Awareness, Kawasaki Intelligent anti-lock Brake System (KIBS), Kawasaki Engine Brake Control (KEBC), Kawasaki Quick Shifter (KQS) (upshift & downshift), Ohlins Electronic Steering Damper
39	43	4-stroke, 1 cylinder, SOHC, 2-valve, air-cooled	125	56.0 x 50.6mm	9.8:1	10.0 hp @ 8,000 rpm	7.1 lb-ft @ 6,000 rpm	DFI with 24mm throttle bodies	TCBI with Electronic Advance	4-speed, return shift	Sealed chain	LCD screen with Gear Position Indicator
40	44	4-stroke, 1 cylinder, SOHC, 2-valve, air-cooled	125	56.0 x 50.6mm	9.8:1	10.0 hp @ 8,000 rpm	7.1 lb-ft @ 6,000 rpm	DFI with 24mm throttle bodies	TCBI with Electronic Advance	4-speed, return shift	Sealed chain	LCD screen with Gear Position Indicator
41	45	Air-cooled, interior permanent magnet synchronous motor	0	\N	\N	9.0 kW / 2,600-4,000 min-1	29.7 lb-ft @ 500 rpm	\N	\N	Single reduction gear	Chain	WALK Mode (with Reverse), Anti-lock Brake System (ABS)
42	46	4-stroke, Parallel Twin, DOHC, liquid-cooled	451	70.0 x 58.6mm	11.3:1	51.0 hp @ 10,000 rpm	31.7 lb-ft @ 7,500 rpm	DFI with dual 32mm throttle bodies	TCBI with Electronic Advance	6-speed	Sealed chain	Economical Riding Indicator, Anti-lock Brake System (ABS)
43	47	4-stroke, Parallel Twin, DOHC, liquid-cooled	451	70.0 x 58.6mm	11.3:1	51.0 hp @ 10,000 rpm	31.7 lb-ft @ 7,500 rpm	DFI with dual 32mm throttle bodies	TCBI with Electronic Advance	6-speed	Sealed chain	Economical Riding Indicator, Anti-lock Brake System (ABS)
44	48	4-stroke, Parallel Twin, DOHC, liquid-cooled	451	70.0 x 58.6mm	11.3:1	51.0 hp @ 10,000 rpm	31.7 lb-ft @ 7,500 rpm	DFI with dual 32mm throttle bodies	TCBI with Electronic Advance	6-speed	Sealed chain	Economical Riding Indicator, Anti-lock Brake System (ABS)
45	49	4-stroke, Parallel Twin, DOHC, liquid-cooled	451	70.0 x 58.6mm	11.3:1	51.0 hp @ 10,000 rpm	31.7 lb-ft @ 7,500 rpm	DFI with dual 32mm throttle bodies	TCBI with Electronic Advance	6-speed	Sealed chain	Economical Riding Indicator, Anti-lock Brake System (ABS)
46	50	4-stroke, 2-cylinder, DOHC, liquid-cooled	649	83.0 x 60.0mm	10.8:1	67.0 hp @ 8,000 rpm	47.2 lb-ft @ 6,700 rpm	DFI with Keihin 36mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Kawasaki Traction Control (KTRC), Anti-lock Brake System (ABS), Kawasaki Quick Shifter (KQS) available as an accessory
47	51	4-stroke, 2-cylinder, DOHC, liquid-cooled	649	83.0 x 60.0mm	10.8:1	67.0 hp @ 8,000 rpm	48.5 lb-ft @ 6,700 rpm	DFI with Keihin 36mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Kawasaki Traction Control (KTRC - 3 Modes), Anti-lock Brake System (ABS)
48	52	4-stroke, Parallel Twin, DOHC, liquid-cooled + Liquid-cooled, interior permanent magnet synchronous motor	451	70.0 x 58.6mm	11.7:1	Hybrid System (Engine + Motor)	44.2 lb-ft @ 2,800 rpm	EFI with dual 36mm throttle bodies	TCBI	6-speed Automated Manual	Chain	Automatic Launch Position Finder (ALPF) in MT, WALK Mode (with Reverse), Anti-lock Brake System (ABS), 3 Modes (SPORT-HYBRID/ ECO-HYBRID/EV) plus e-boost
49	53	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	948	73.4 x 56.0mm	11.8:1	123.0 hp @ 9,500 rpm	73.1 lb-ft @ 7,700 rpm	DFI with 36mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Electronic Cruise Control, Kawasaki Traction Control (KTRC), Anti-lock Brake System (ABS), Power Modes, Kawasaki Cornering Management Function (KCMF), Kawasaki Quick Shifter (KQS), IMU-Enhanced Chassis Orientation Awareness
50	54	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	948	73.4 x 56.0mm	11.8:1	123.0 hp @ 9,500 rpm	73.1 lb-ft @ 7,700 rpm	DFI with 36mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Electronic Cruise Control, Kawasaki Traction Control (KTRC), Anti-lock Brake System (ABS), Power Modes, Kawasaki Cornering Management Function (KCMF), Kawasaki Quick Shifter (KQS), IMU-Enhanced Chassis Orientation Awareness
51	55	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	948	73.4 x 56.0mm	11.8:1	123.0 hp @ 9,500 rpm	73.1 lb-ft @ 7,700 rpm	DFI with 36mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Electronic Cruise Control, Kawasaki Traction Control (KTRC), Anti-lock Brake System (ABS), Power Modes, Kawasaki Cornering Management Function (KCMF), Kawasaki Quick Shifter (KQS), IMU-Enhanced Chassis Orientation Awareness
52	56	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	948	73.4 x 56.0mm	11.8:1	123.0 hp @ 9,500 rpm	73.1 lb-ft @ 7,700 rpm	DFI with 36mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Electronic Cruise Control, Kawasaki Traction Control (KTRC), Anti-lock Brake System (ABS), Power Modes, Kawasaki Cornering Management Function (KCMF), Kawasaki Quick Shifter (KQS), IMU-Enhanced Chassis Orientation Awareness
53	57	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled	1099	77.0 x 59.0mm	11.8:1	134.0 hp @ 9,000 rpm	83.3 lb-ft @ 7,600 rpm	DFI with 38mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Electronic Cruise Control, Kawasaki Traction Control (KTRC), Kawasaki Intelligent anti-lock Brake System (KIBS), Anti-lock Brake System (ABS), Power Modes, Kawasaki Cornering Management Function (KCMF), Kawasaki Quick Shifter (KQS), IMU-Enhanced Chassis Orientation Awareness
56	60	4-stroke, 4-cylinder, DOHC, 16-valve, liquid-cooled	948	73.4 x 56.0mm	11.8:1	115.0 hp @ 9,300 rpm	73.0 lb-ft @ 7,700 rpm	DFI with 36mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Electronic Cruise Control, Kawasaki Traction Control (KTRC), Anti-lock Brake System (ABS), Power Modes, Kawasaki Cornering Management Function (KCMF), Kawasaki Quick Shifter (KQS), IMU-Enhanced Chassis Orientation Awareness
57	61	4-stroke, 4-cylinder, DOHC, 16-valve, liquid-cooled	948	73.4 x 56.0mm	10.8:1	110.0 hp @ 8,500 rpm	72.3 lb-ft @ 6,500 rpm	DFI with Keihin 36mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Kawasaki Traction Control (KTRC - 3 Modes), Anti-lock Brake System (ABS)
58	62	4-stroke, 4-cylinder, DOHC, 16-valve, liquid-cooled	948	73.4 x 56.0mm	11.8:1	115.0 hp @ 9,300 rpm	73.0 lb-ft @ 7,700 rpm	DFI with 36mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Electronic Cruise Control, Kawasaki Traction Control (KTRC), Anti-lock Brake System (ABS), Power Modes, Kawasaki Cornering Management Function (KCMF), Kawasaki Quick Shifter (KQS), IMU-Enhanced Chassis Orientation Awareness
59	63	4-stroke, 4-cylinder, DOHC, 16-valve, liquid-cooled	948	73.4 x 56.0mm	10.8:1	110.0 hp @ 8,500 rpm	72.3 lb-ft @ 6,500 rpm	DFI with Keihin 36mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Kawasaki Traction Control (KTRC - 3 Modes), Anti-lock Brake System (ABS)
60	64	4-stroke, 4-cylinder, DOHC, 16-valve, liquid-cooled	948	73.4 x 56.0mm	11.8:1	115.0 hp @ 9,300 rpm	73.0 lb-ft @ 7,700 rpm	DFI with 36mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Electronic Cruise Control, Kawasaki TRaction Control (KTRC), Anti-lock Brake System (ABS), Power Modes, Kawasaki Cornering Management Function (KCMF), Kawasaki Quick Shifter (KQS), IMU-Enhanced Chassis Orientation Awareness
61	65	4-stroke, 4-cylinder, DOHC, 16-valve, liquid-cooled	948	73.4 x 56.0mm	10.8:1	110.0 hp @ 8,500 rpm	72.3 lb-ft @ 6,500 rpm	DFI with Keihin 36mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Kawasaki TRaction Control (KTRC - 3 Modes), Anti-lock Brake System (ABS)
62	66	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled, supercharged	998	76.0 x 55.0mm	11.2:1	197.0 hp @ 10,500 rpm	101.0 lb-ft @ 8,500 rpm	DFI with 40mm throttle bodies; Kawasaki Supercharger	TCBI with Digital Advance	6-speed, return shift, dog-ring	Sealed chain	Economical Riding Indicator, Kawasaki Electronic Control Suspension (KECS) with Showa Skyhook Technology, Kawasaki Cornering Management Function (KCMF), Power Modes, Kawasaki Launch Control Mode (KLCM), Kawasaki Traction Control (KTRC), Kawasaki Engine Brake Control (KEBC), Kawasaki Intelligent anti-lock Brake System (KIBS), Anti-lock Brake System (ABS), Kawasaki Quick Shifter (KQS) (upshift & downshift), Electronic Cruise Control, IMU-Enhanced Chassis Orientation Awareness
63	67	4-stroke, in-line 4-cylinder, DOHC, 16-valve, liquid-cooled, supercharged	998	76.0 x 55.0mm	11.2:1	197.0 hp @ 10,500 rpm	101.0 lb-ft @ 8,500 rpm	DFI with 40mm throttle bodies; Kawasaki Supercharger	TCBI with Digital Advance	6-speed, return shift, dog-ring	Sealed chain	Economical Riding Indicator, Kawasaki Electronic Control Suspension (KECS) with Showa Skyhook Technology, Kawasaki Cornering Management Function (KCMF), Power Modes, Kawasaki Launch Control Mode (KLCM), Kawasaki Traction Control (KTRC), Kawasaki Engine Brake Control (KEBC), Kawasaki Intelligent anti-lock Brake System (KIBS), Anti-lock Brake System (ABS), Kawasaki Quick Shifter (KQS) (upshift & downshift), Electronic Cruise Control, IMU-Enhanced Chassis Orientation Awareness
68	73	4-stroke, 2-cylinder, DOHC, liquid-cooled	296	62.0 x 49.0mm	10.6:1	39.0 hp @ 11,500 rpm	19.2 lb-ft @ 10,000 rpm	DFI with 32mm throttle bodies (2)	TCBI with Digital Advance	6-speed, return shift with wet multi-disc manual clutch	Chain	Economical Riding Indicator, Anti-lock Brake System (ABS)
69	74	4-stroke, 2-cylinder, DOHC, liquid-cooled	296	62.0 x 49.0mm	10.6:1	39.0 hp @ 11,500 rpm	19.2 lb-ft @ 10,000 rpm	DFI with 32mm throttle bodies (2)	TCBI with Digital Advance	6-speed, return shift with wet multi-disc manual clutch	Chain	Economical Riding Indicator, Anti-lock Brake System (ABS)
70	75	4-stroke, 2-cylinder, DOHC, 8 valves, liquid-cooled	649	83.0 x 60.0mm	10.8:1	66.0 hp @ 8,500 rpm	45.0 lb-ft @ 7,000 rpm	DFI with 38mm Keihin throttle bodies (2)	TCBI with Electronic Advance	6-speed with positive neutral finder	Sealed chain	Kawasaki Traction Control (KTRC), Anti-lock Brake System (ABS), Economical Riding Indicator
71	76	4-stroke, in-line 4-cylinder, DOHC, liquid-cooled	1099	77.0 x 59.0mm	11.8:1	133.0 hp @ 9,000 rpm	82.5 lb-ft @ 7,600 rpm	DFI with 38mm throttle bodies (4)	TCBI with Electronic Advance	6-speed, return shift with wet multi-disc manual Assist & Slipper Clutch	Chain	Economical Riding Indicator, Electronic Cruise Control, Kawasaki Traction Control (KTRC), Kawasaki Electronic Control Suspension (KECS), Kawasaki Intelligent anti-lock Brake System (KIBS), Anti-lock Brake System (ABS), Power Modes, Kawasaki Cornering Management Function (KCMF), Kawasaki Quick Shifter (KQS), IMU-Enhanced Chassis Orientation Awareness
72	77	4-stroke, single-cylinder, SOHC, 2 valves, air-cooled	233	67.0 x 66.0mm	9.0:1	17 hp @ 7,000 rpm	14.0 lb-ft @ 5,800 rpm	DFI with 32mm throttle body	TCBI with Digital Advance	6-speed, return shift	Sealed chain	Anti-lock Brake System
73	79	4-stroke, single-cylinder, SOHC, 2 valves, air-cooled	233	67.0 x 66.0mm	9.0:1	17 hp @ 7,000 rpm	14.0 lb-ft @ 5,800 rpm	DFI with 32mm throttle body	TCBI with Digital Advance	6-speed, return shift	Sealed chain	Anti-lock Brake System
74	80	4-stroke, Parallel Twin, SOHC, 4 valves, air-cooled	773	77.0 x 83.0mm	8.4:1	51 hp @ 6,500 rpm	46.5 lb-ft @ 4,800 rpm	DFI with 34mm throttle bodies (2)	TCBI with Digital Advance	5-speed, return shift	Sealed chain	Anti-lock Brake System
75	81	4-stroke, Parallel Twin, SOHC, 4 valves, air-cooled	773	77.0 x 83.0mm	8.4:1	51 hp @ 6,500 rpm	46.4 lb-ft @ 4,800 rpm	DFI with 34mm throttle bodies (2)	TCBI with Digital Advance	5-speed, return shift	Sealed chain	Anti-lock Brake System
76	82	4-stroke, 2-cylinder, DOHC, liquid-cooled	451	70.0 x 58.6mm	11.3:1	51 hp @ 10,000 rpm	31.7 lb-ft @ 7,500 rpm	DFI with 32mm throttle bodies	TCBI w/ Digital Advance	6-speed, return shift	Sealed chain	Anti-lock Brake System (ABS only)
77	83	4-stroke, 2-cylinder, DOHC, liquid-cooled	451	70.0 x 58.6mm	11.3:1	51 hp @ 10,000 rpm	31.7 lb-ft @ 7,500 rpm	DFI with 32mm throttle bodies	TCBI w/ Digital Advance	6-speed, return shift	Sealed chain	Anti-lock Brake System (ABS only)
78	84	4-stroke, 2-cylinder, DOHC, liquid-cooled	451	70.0 x 58.6mm	11.3:1	51 hp @ 10,000 rpm	31.7 lb-ft @ 7,500 rpm	DFI with 32mm throttle bodies	TCBI w/ Digital Advance	6-speed, return shift	Sealed chain	Anti-lock Brake System
79	85	4-stroke, 2-cylinder, DOHC, liquid-cooled	451	70.0 x 58.6mm	11.3:1	51 hp @ 10,000 rpm	31.7 lb-ft @ 7,500 rpm	DFI with 32mm throttle bodies	TCBI w/ Digital Advance	6-speed, return shift	Sealed chain	Anti-lock Brake System
80	86	4-stroke, 2-cylinder, DOHC, liquid-cooled	649	83.0 x 60.0mm	10.8:1	60 hp @ 7,500 rpm	46.5 lb-ft @ 6,600 rpm	DFI with 38mm throttle bodies (2), with sub-throttle valves	TCBI with Electronic Advance	6-speed with positive neutral finder	Sealed chain	Economical Riding Indicator, Anti-lock Brake System (ABS)
81	87	4-stroke, 2-cylinder, DOHC, liquid-cooled	649	83.0 x 60.0mm	10.8:1	60 hp @ 7,500 rpm	46.3 lb-ft @ 6,600 rpm	DFI with 38mm throttle bodies (2), with sub-throttle valves	TCBI with Electronic Advance	6-speed with positive neutral finder	Sealed chain	Economical Riding Indicator, Anti-lock Brake System (ABS)
82	88	4-stroke, 2-cylinder, DOHC, liquid-cooled	649	83.0 x 60.0mm	10.8:1	60 hp @ 7,500 rpm	46.5 lb-ft @ 6,600 rpm	DFI with 38mm throttle bodies (2), with sub-throttle valves	TCBI with Electronic Advance	6-speed with positive neutral finder	Sealed chain	Economical Riding Indicator, Anti-lock Brake System (ABS)
83	89	4-stroke, 2-cylinder, DOHC, liquid-cooled	649	83.0 x 60.0mm	10.8:1	60 hp @ 7,500 rpm	46.3 lb-ft @ 6,600 rpm	DFI with 38mm throttle bodies (2), with sub-throttle valves	TCBI with Electronic Advance	6-speed with positive neutral finder	Sealed chain	Economical Riding Indicator, Anti-lock Brake System (ABS)
84	90	4-stroke, 55-degree V-twin, liquid-cooled	903	88.0 x 74.2mm	9.5:1	51 hp @ 5,500 rpm	58.3 lb-ft @ 3,500 rpm	DFI with 34mm throttle bodies (2), with sub-throttle valves	TCBI with Electronic Advance	5-speed with positive neutral finder	Kevlar-reinforced belt	
85	91	4-stroke, 55-degree V-twin, liquid-cooled	903	88.0 x 74.2mm	9.5:1	51 hp @ 5,500 rpm	58.2 lb-ft @ 3,500 rpm	DFI with 34mm throttle bodies (2), with sub-throttle valves	TCBI with Electronic Advance	5-speed with positive neutral finder	Kevlar-reinforced belt	
86	92	4-stroke, 55-degree V-twin, liquid-cooled	903	88.0 x 74.2mm	9.5:1	51 hp @ 5,500 rpm	58.3 lb-ft @ 3,500 rpm	DFI with 34mm throttle bodies (2), with sub-throttle valves	TCBI with Electronic Advance	5-speed with positive neutral finder	Kevlar-reinforced belt	
87	93	4-stroke, 55-degree V-twin, liquid-cooled	903	88.0 x 74.2mm	9.5:1	51 hp @ 5,500 rpm	58.2 lb-ft @ 3,500 rpm	DFI with 34mm throttle bodies (2), with sub-throttle valves	TCBI with Electronic Advance	5-speed with positive neutral finder	Kevlar-reinforced belt	
88	94	4-stroke, 55-degree V-twin, liquid-cooled	903	88.0 x 74.2mm	9.5:1	51 hp @ 5,500 rpm	58.3 lb-ft @ 3,500 rpm	DFI with 34mm throttle bodies (2), with sub-throttle valves	TCBI with Electronic Advance	5-speed with positive neutral finder	Kevlar-reinforced belt	
89	95	4-stroke, 55-degree V-twin, liquid-cooled	903	88.0 x 74.2mm	9.5:1	51 hp @ 5,500 rpm	58.2 lb-ft @ 3,500 rpm	DFI with 34mm throttle bodies (2), with sub-throttle valves	TCBI with Electronic Advance	5-speed with positive neutral finder	Kevlar-reinforced belt	
90	96	4-stroke, 52-degree V-twin, liquid-cooled	1700	102.0 x 104.0mm	9.5:1	82 hp @ 5,000 rpm	107.6 lb-ft @ 2,750 rpm	DFI with 42mm throttle bodies (2)	TCBI with Electronic Advance	6-speed with overdrive and positive neutral finder	Carbon fiber-reinforced belt	Electronic Cruise Control, Kawasaki Advanced Coactive-Braking Technology (K-ACT) ABS
91	97	4-stroke, 52-degree V-twin, liquid-cooled	1700	102.0 x 104.0mm	9.5:1	82 hp @ 5,000 rpm	107.6 lb-ft @ 2,750 rpm	DFI with 42mm throttle bodies (2)	TCBI with Electronic Advance	6-speed with overdrive and positive neutral finder	Carbon fiber-reinforced belt	Electronic Cruise Control, Kawasaki Advanced Coactive-Braking Technology (K-ACT) ABS
92	98	4-stroke, 52-degree V-twin, liquid-cooled	1700	102.0 x 104.0mm	9.5:1	82 hp @ 5,000 rpm	107.6 lb-ft @ 2,750 rpm	DFI with 42mm throttle bodies (2)	TCBI with Electronic Advance	6-speed with overdrive and positive neutral finder	Carbon fiber-reinforced belt	Electronic Cruise Control, Kawasaki Advanced Coactive-Braking Technology (K-ACT) ABS
93	99	4-stroke, 52-degree V-twin, liquid-cooled	1700	102.0 x 104.0mm	9.5:1	82 hp @ 5,000 rpm	107.6 lb-ft @ 2,750 rpm	DFI with 42mm throttle bodies (2)	TCBI with Electronic Advance	6-speed with overdrive and positive neutral finder	Carbon fiber-reinforced belt	Electronic Cruise Control, Kawasaki Advanced Coactive-Braking Technology (K-ACT) ABS
94	101	4-stroke, Parallel Twin, DOHC, liquid-cooled	451	70.0 x 58.6mm	11.3:1	51 hp @ 10,000 rpm	31.7 lb-ft @ 7,500 rpm	DFI with 32mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Selectable On/Off Anti-lock Brake System (ABS)
95	102	4-stroke, Parallel Twin, DOHC, liquid-cooled	451	70.0 x 58.6mm	11.3:1	51 hp @ 10,000 rpm	31.7 lb-ft @ 7,500 rpm	DFI with 32mm throttle bodies	TCBI with Electronic Advance	6-speed, return shift	Sealed chain	Economical Riding Indicator, Selectable On/Off Anti-lock Brake System (ABS)
96	103	4-stroke, single cylinder, DOHC, liquid-cooled	652	100.0 x 83.0mm	9.8:1	40 hp @ 6,000 rpm	39.1 lb-ft @ 4,500 rpm	DFI with 40mm throttle body	CDI	5-speed, return shift with wet multi-disc manual clutch	Sealed chain	Anti-lock Brake System (ABS)
97	104	4-stroke, single cylinder, DOHC, liquid-cooled	652	100.0 x 83.0mm	9.8:1	40 hp @ 6,000 rpm	39.1 lb-ft @ 4,500 rpm	DFI with 40mm throttle body	CDI	5-speed, return shift with wet multi-disc manual clutch	Sealed chain	Anti-lock Brake System (ABS)
98	105	4-stroke, single cylinder, DOHC, liquid-cooled	652	100.0 x 83.0mm	9.8:1	40 hp @ 6,000 rpm	39.1 lb-ft @ 4,500 rpm	DFI with 40mm throttle body	CDI	5-speed, return shift with wet multi-disc manual clutch	Sealed chain	Anti-lock Brake System (ABS)
99	106	4-stroke, single cylinder, DOHC, liquid-cooled	652	100.0 x 83.0mm	9.8:1	40 hp @ 6,000 rpm	39.1 lb-ft @ 4,500 rpm	DFI with 40mm throttle body	CDI	5-speed, return shift with wet multi-disc manual clutch	Sealed chain	Anti-lock Brake System (ABS)
100	107	4-stroke, single cylinder, DOHC, liquid-cooled	652	100.0 x 83.0mm	9.8:1	40 hp @ 6,000 rpm	39.1 lb-ft @ 4,500 rpm	DFI with 40mm throttle body	CDI	5-speed, return shift with wet multi-disc manual clutch	Sealed chain	Anti-lock Brake System (ABS)
101	108	4-stroke, single cylinder, DOHC, liquid-cooled	652	100.0 x 83.0mm	9.8:1	40 hp @ 6,000 rpm	39.1 lb-ft @ 4,500 rpm	DFI with 40mm throttle body	CDI	5-speed, return shift with wet multi-disc manual clutch	Sealed chain	Anti-lock Brake System (ABS)
102	109	4-stroke, single-cylinder, SOHC, air-cooled	112	53.0 x 50.6mm	9.5:1	\N	\N	Keihin PB18 carburetor and screw type throttle limiter on grip housing	DC-CDI	4-speed, return shift, automatic centrifugal and wet, multi-disc clutch	Chain	\N
103	110	4-stroke, single-cylinder, SOHC, air-cooled	112	53.0 x 50.6mm	9.5:1	\N	\N	Keihin PB18 carburetor and screw type throttle limiter on grip housing	DC-CDI	4-speed, return shift, automatic centrifugal and wet, multi-disc clutch	Chain	\N
104	111	4-stroke, single-cylinder, SOHC, air-cooled	112	53.0 x 50.6mm	9.5:1	\N	\N	Keihin PB18 carburetor and screw type throttle limiter on grip housing	DC-CDI	4-speed, return shift, wet multi-disc manual clutch	Chain	\N
105	112	4-stroke, single-cylinder, SOHC, air-cooled	112	53.0 x 50.6mm	9.5:1	\N	\N	Keihin PB18 carburetor and screw type throttle limiter on grip housing	DC-CDI	4-speed, return shift, wet multi-disc manual clutch	Chain	\N
106	113	4-stroke, single-cylinder, SOHC, air-cooled	144	58.0 x 54.4mm	9.5:1	\N	\N	Keihin PB20 carburetor	Digital DC-CDI	5-speed, return shift, with wet multi-disc manual clutch	Chain	\N
107	114	4-stroke, single-cylinder, SOHC, air-cooled	144	58.0 x 54.4mm	9.5:1	\N	\N	Keihin PB20 carburetor	Digital DC-CDI	5-speed, return shift, with wet multi-disc manual clutch	Chain	\N
108	115	4-stroke, single-cylinder, SOHC, air-cooled	144	58.0 x 54.4mm	9.5:1	\N	\N	Keihin PB20 carburetor	Digital DC-CDI	5-speed, return shift, with wet multi-disc manual clutch	Chain	\N
109	116	4-stroke, single-cylinder, SOHC, air-cooled	144	58.0 x 54.4mm	9.5:1	\N	\N	Keihin PB20 carburetor	Digital DC-CDI	5-speed, return shift, with wet multi-disc manual clutch	Chain	\N
110	117	4-stroke, single-cylinder, SOHC, air-cooled	144	58.0 x 54.4mm	9.5:1	\N	\N	Keihin PB20 carburetor	Digital DC-CDI	5-speed, return shift, with wet multi-disc manual clutch	Chain	\N
111	118	4-stroke, single-cylinder, SOHC, air-cooled	144	58.0 x 54.4mm	9.5:1	\N	\N	Keihin PB20 carburetor	Digital DC-CDI	5-speed, return shift, with wet multi-disc manual clutch	Chain	\N
112	119	4-stroke, single-cylinder, SOHC, air-cooled	233	67.0 x 66.0mm	9.4:1	\N	\N	DFI with 32mm Keihin throttle body	TCBI with electronic advance	6-speed, return shift with wet multi-disc manual clutch	Chain	\N
113	120	4-stroke, single-cylinder, SOHC, air-cooled	233	67.0 x 66.0mm	9.4:1	\N	\N	DFI with 32mm Keihin throttle body	TCBI with electronic advance	6-speed, return shift with wet multi-disc manual clutch	Chain	\N
114	121	4-stroke, single-cylinder, SOHC, air-cooled	233	67.0 x 66.0mm	9.4:1	\N	\N	DFI with 32mm Keihin throttle body	TCBI with electronic advance	6-speed, return shift with wet multi-disc manual clutch	Chain	\N
115	122	4-stroke, single-cylinder, SOHC, air-cooled	233	67.0 x 66.0mm	9.4:1	\N	\N	DFI with 32mm Keihin throttle body	TCBI with electronic advance	6-speed, return shift with wet multi-disc manual clutch	Chain	\N
116	123	4-stroke, single-cylinder, DOHC, liquid-cooled	292	78.0 x 61.2mm	11.0:1	\N	\N	DFI with 34mm Keihin throttle body	TCBI with electronic advance	6-speed, return shift with wet multi-disc manual clutch	Chain	\N
117	124	4-stroke, single-cylinder, DOHC, liquid-cooled	292	78.0 x 61.2mm	11.0:1	\N	\N	DFI with 34mm Keihin throttle body	TCBI with electronic advance	6-speed, return shift with wet multi-disc manual clutch	Chain	\N
118	125	4-stroke single, SOHC, air-cooled	233	67.0 x 66.0mm	9.4:1	17 hp @ 8,000 rpm	13.0 lb-ft @ 6,400 rpm	DFI with 32mm throttle body	TCBI with Electronic Advance	6-speed	Sealed chain	\N
119	126	4-stroke single, SOHC, air-cooled	233	67.0 x 66.0mm	9.4:1	17 hp @ 8,000 rpm	13.0 lb-ft @ 6,400 rpm	DFI with 32mm throttle body	TCBI with Electronic Advance	6-speed	Sealed chain	Anti-lock Brake System (ABS)
120	127	4-stroke single, SOHC, air-cooled	233	67.0 x 66.0mm	9.4:1	\N	13.0 lb-ft @ 6,400 rpm	DFI with 32mm throttle body	TCBI with Electronic Advance	6-speed	Sealed chain	\N
121	128	4-stroke single, SOHC, air-cooled	233	67.0 x 66.0mm	9.4:1	\N	13.0 lb-ft @ 6,400 rpm	DFI with 32mm throttle body	TCBI with Electronic Advance	6-speed	Sealed chain	Anti-lock Brake System (ABS)
122	129	4-stroke single, SOHC, air-cooled	233	67.0 x 66.0mm	9.4:1	17.0 hp @ 8,000 rpm	13.3 lb-ft @ 6,400 rpm	DFI with 32mm throttle body	TCBI with Electronic Advance	6-speed	Sealed chain	Anti-lock Brake System (ABS)
123	130	4-stroke single, SOHC, air-cooled	233	67.0 x 66.0mm	9.4:1	17.0 hp @ 8,000 rpm	13.3 lb-ft @ 6,400 rpm	DFI with 32mm throttle body	TCBI with Electronic Advance	6-speed	Sealed chain	Anti-lock Brake System (ABS)
124	131	4-stroke, single-cylinder, DOHC, liquid-cooled	292	78.0 x 61.2mm	11.1:1	25.0 hp @ 8,000 rpm	17.7 lb-ft @ 7,000 rpm	DFI with 34mm Keihin throttle body	CDI	6-speed, return shift with wet multi-disc manual clutch	Chain	\N
125	132	4-stroke, single-cylinder, DOHC, liquid-cooled	292	78.0 x 61.2mm	11.1:1	\N	18.1 lb-ft @ 7,000 rpm	DFI with 34mm Keihin throttle body	CDI	6-speed, return shift with wet multi-disc manual clutch	Chain	\N
126	133	4-stroke single, SOHC, air-cooled	233	67.0 x 66.0mm	9.4:1	17 hp @ 8,000 rpm	13.0 lb-ft @ 6,400 rpm	DFI with 32mm throttle body	TCBI with Electronic Advance	6-speed	Sealed chain	Anti-lock Brake System (ABS)
127	134	4-stroke single, SOHC, air-cooled	233	67.0 x 66.0mm	9.4:1	\N	13.0 lb-ft @ 6,400 rpm	DFI with 32mm throttle body	TCBI with Electronic Advance	6-speed	Sealed chain	Anti-lock Brake System (ABS)
128	135	4-stroke, single-cylinder, DOHC, liquid-cooled	292	78.0 x 61.2mm	11.1:1	25.0 hp @ 8,000 rpm	17.7 lb-ft @ 7,000 rpm	DFI with 34mm Keihin throttle body	CDI	6-speed, return shift with wet multi-disc manual clutch	Chain	\N
129	136	4-stroke, single-cylinder, DOHC, liquid-cooled	292	78.0 x 61.2mm	11.1:1	\N	18.1 lb-ft @ 7,000 rpm	DFI with 34mm Keihin throttle body	CDI	6-speed, return shift with wet multi-disc manual clutch	Chain	\N
130	137	2-stroke, single-cylinder, liquid-cooled	64	44.5 x 41.6mm	8.4:1	\N	\N	24mm Mikuni carburetor	CDI with digital advance	6-speed, return shift, with wet multi-disc manual clutch	Chain	\N
131	138	2-stroke, single-cylinder, liquid-cooled	64	44.5 x 41.6mm	8.4:1	\N	\N	24mm Mikuni carburetor	CDI with digital advance	6-speed, return shift, with wet multi-disc manual clutch	Chain	\N
132	140	2-stroke, single-cylinder with exhaust power valve (KIPS), liquid-cooled	84	48.5 x 45.8mm	10.9:1 (low speed) / 9.0:1 (high speed)	\N	\N	28mm Keihin carburetor	CDI with digital advance	6-speed, return shift, with wet multi-disc manual clutch	Chain	\N
133	141	2-stroke, single-cylinder with exhaust power valve (KIPS), liquid-cooled	84	48.5 x 45.8mm	10.9:1 (low speed) / 9.0:1 (high speed)	\N	\N	28mm Keihin carburetor	CDI with digital advance	6-speed, return shift, with wet multi-disc manual clutch	Chain	\N
134	142	2-stroke, single-cylinder with exhaust power valve (KIPS), liquid-cooled	84	48.5 x 45.8mm	10.9:1 (low speed) / 9.0:1 (high speed)	\N	\N	28mm Keihin carburetor	CDI with digital advance	6-speed, return shift, with wet multi-disc manual clutch	Chain	\N
135	143	2-stroke, single-cylinder with exhaust power valve (KIPS), liquid-cooled	112	52.5 x 51.6mm	9.9:1 (low speed) / 8.6:1 (high speed)	\N	\N	28mm Keihin carburetor	CDI with digital advance	6-speed, return shift, with wet multi-disc manual clutch	Chain	\N
136	144	2-stroke, single-cylinder with exhaust power valve (KIPS), liquid-cooled	112	52.5 x 51.6mm	9.9:1 (low speed) / 8.6:1 (high speed)	\N	\N	28mm Keihin carburetor	CDI with digital advance	6-speed, return shift, with wet multi-disc manual clutch	Chain	\N
137	145	4-stroke, single-cylinder, DOHC, liquid-cooled	249	78.0 x 52.2mm	14.1:1	\N	\N	DFI with 44mm Keihin throttle body and dual injectors	Digital CDI with handlebar-controlled power modes	5-speed, return shift, with wet multi-disc manual clutch and hydraulic clutch actuation	Chain	Power Modes, Kawasaki TRaction Control (KTRC), Launch Control Mode
138	146	4-stroke, single-cylinder, DOHC, liquid-cooled	249	78.0 x 52.2mm	14.0:1	\N	\N	DFI with 44mm Keihin throttle body and dual injectors	Digital CDI with handlebar-controlled power modes	5-speed, return shift, with wet multi-disc manual clutch and hydraulic clutch actuation	Chain	Power Modes, Kawasaki TRaction Control (KTRC), Launch Control Mode
139	147	4-stroke, single-cylinder, DOHC, liquid-cooled	449	96.0 x 62.1mm	12.5:1	\N	\N	DFI with 44mm Keihin throttle body	Digital CDI with handlebar-controlled power modes	5-speed, return shift, with wet multi-disc manual clutch and hydraulic clutch actuation	Chain	Power Modes, Kawasaki TRaction Control (KTRC), Launch Control Mode
140	148	4-stroke, single-cylinder, DOHC, liquid-cooled	449	96.0 x 62.1mm	12.5:1	\N	\N	DFI with 44mm Keihin throttle body	Digital CDI with handlebar-controlled power modes	5-speed, return shift, with wet multi-disc manual clutch and hydraulic clutch actuation	Chain	Power Modes, Kawasaki TRaction Control (KTRC), Launch Control Mode
141	149	4-stroke, single-cylinder, DOHC, liquid-cooled	449	96.0 x 62.1mm	12.5:1	\N	\N	DFI with 44mm Keihin throttle body	Digital CDI with handlebar-controlled power modes	5-speed, return shift, with wet multi-disc manual clutch and hydraulic clutch actuation	Chain	Power Modes, Kawasaki TRaction Control (KTRC), Launch Control Mode
142	150	4-stroke, single-cylinder, DOHC, liquid-cooled	449	96.0 x 62.1mm	12.5:1	\N	\N	DFI with 44mm Keihin throttle body	Digital CDI with handlebar-controlled power modes	5-speed, return shift, with wet multi-disc manual clutch and hydraulic clutch actuation	Chain	Power Modes, Kawasaki TRaction Control (KTRC), Launch Control Mode
143	151	4-stroke, single-cylinder, DOHC, liquid-cooled	249	78.0 x 52.2mm	14.0:1	\N	\N	DFI with 44mm Keihin throttle body and dual injectors	Digital CDI with handlebar-controlled power modes	5-speed, return shift, with wet multi-disc manual clutch and hydraulic clutch actuation	Chain	Power Modes, Kawasaki TRaction Control (KTRC), Launch Control Mode
144	152	4-stroke, single-cylinder, DOHC, liquid-cooled	249	78.0 x 52.2mm	14.0:1	\N	\N	DFI with 44mm Keihin throttle body and dual injectors	Digital CDI with handlebar-controlled power modes	5-speed, return shift, with wet multi-disc manual clutch and hydraulic clutch actuation	Chain	Power Modes, Kawasaki TRaction Control (KTRC), Launch Control Mode
145	153	4-stroke, single-cylinder, DOHC, liquid-cooled	449	96.0 x 62.1mm	12.5:1	\N	\N	DFI with 44mm Keihin throttle body	Digital CDI with handlebar-controlled power modes	5-speed, return shift, with wet multi-disc manual clutch and hydraulic clutch actuation	Chain	Power Modes, Kawasaki TRaction Control (KTRC), Launch Control Mode
146	154	4-stroke, single-cylinder, DOHC, liquid-cooled	449	96.0 x 62.1mm	12.5:1	\N	\N	DFI with 44mm Keihin throttle body	Digital CDI with handlebar-controlled power modes	5-speed, return shift, with wet multi-disc manual clutch and hydraulic clutch actuation	Chain	Power Modes, Kawasaki TRaction Control (KTRC), Launch Control Mode
\.


--
-- TOC entry 4943 (class 0 OID 17139)
-- Dependencies: 232
-- Data for Name: system_notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.system_notifications (notification_id, user_id, event_type, title, message, payload, is_read, created_at) FROM stdin;
\.


--
-- TOC entry 4927 (class 0 OID 16990)
-- Dependencies: 216
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, user_name, email, password_hash, created_at, last_login, is_active, role) FROM stdin;
\.


--
-- TOC entry 4989 (class 0 OID 0)
-- Dependencies: 217
-- Name: categories_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_category_id_seq', 24, true);


--
-- TOC entry 4990 (class 0 OID 0)
-- Dependencies: 233
-- Name: category_groups_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.category_groups_group_id_seq', 4, true);


--
-- TOC entry 4991 (class 0 OID 0)
-- Dependencies: 221
-- Name: details_detail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.details_detail_id_seq', 152, true);


--
-- TOC entry 4992 (class 0 OID 0)
-- Dependencies: 235
-- Name: model_series_series_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.model_series_series_id_seq', 10, true);


--
-- TOC entry 4993 (class 0 OID 0)
-- Dependencies: 219
-- Name: motorcycles_motorcycle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.motorcycles_motorcycle_id_seq', 154, true);


--
-- TOC entry 4994 (class 0 OID 0)
-- Dependencies: 229
-- Name: order_items_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_item_id_seq', 2, true);


--
-- TOC entry 4995 (class 0 OID 0)
-- Dependencies: 227
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 2, true);


--
-- TOC entry 4996 (class 0 OID 0)
-- Dependencies: 225
-- Name: performance_performance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.performance_performance_id_seq', 146, true);


--
-- TOC entry 4997 (class 0 OID 0)
-- Dependencies: 223
-- Name: power_power_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.power_power_id_seq', 146, true);


--
-- TOC entry 4998 (class 0 OID 0)
-- Dependencies: 231
-- Name: system_notifications_notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.system_notifications_notification_id_seq', 1, false);


--
-- TOC entry 4999 (class 0 OID 0)
-- Dependencies: 215
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 3, true);


--
-- TOC entry 4722 (class 2606 OID 17012)
-- Name: categories categories_category_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_category_name_key UNIQUE (category_name);


--
-- TOC entry 4724 (class 2606 OID 17010)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- TOC entry 4760 (class 2606 OID 17163)
-- Name: category_groups category_groups_group_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_groups
    ADD CONSTRAINT category_groups_group_name_key UNIQUE (group_name);


--
-- TOC entry 4762 (class 2606 OID 17165)
-- Name: category_groups category_groups_group_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_groups
    ADD CONSTRAINT category_groups_group_slug_key UNIQUE (group_slug);


--
-- TOC entry 4764 (class 2606 OID 17161)
-- Name: category_groups category_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_groups
    ADD CONSTRAINT category_groups_pkey PRIMARY KEY (group_id);


--
-- TOC entry 4734 (class 2606 OID 17062)
-- Name: details details_motorcycle_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.details
    ADD CONSTRAINT details_motorcycle_id_key UNIQUE (motorcycle_id);


--
-- TOC entry 4736 (class 2606 OID 17060)
-- Name: details details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.details
    ADD CONSTRAINT details_pkey PRIMARY KEY (detail_id);


--
-- TOC entry 4767 (class 2606 OID 17179)
-- Name: model_series model_series_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.model_series
    ADD CONSTRAINT model_series_pkey PRIMARY KEY (series_id);


--
-- TOC entry 4769 (class 2606 OID 17181)
-- Name: model_series model_series_series_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.model_series
    ADD CONSTRAINT model_series_series_name_key UNIQUE (series_name);


--
-- TOC entry 4771 (class 2606 OID 17183)
-- Name: model_series model_series_series_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.model_series
    ADD CONSTRAINT model_series_series_slug_key UNIQUE (series_slug);


--
-- TOC entry 4732 (class 2606 OID 17022)
-- Name: motorcycles motorcycles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.motorcycles
    ADD CONSTRAINT motorcycles_pkey PRIMARY KEY (motorcycle_id);


--
-- TOC entry 4753 (class 2606 OID 17127)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (item_id);


--
-- TOC entry 4749 (class 2606 OID 17113)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- TOC entry 4742 (class 2606 OID 17094)
-- Name: performance performance_motorcycle_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.performance
    ADD CONSTRAINT performance_motorcycle_id_key UNIQUE (motorcycle_id);


--
-- TOC entry 4744 (class 2606 OID 17092)
-- Name: performance performance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.performance
    ADD CONSTRAINT performance_pkey PRIMARY KEY (performance_id);


--
-- TOC entry 4738 (class 2606 OID 17078)
-- Name: power power_motorcycle_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.power
    ADD CONSTRAINT power_motorcycle_id_key UNIQUE (motorcycle_id);


--
-- TOC entry 4740 (class 2606 OID 17076)
-- Name: power power_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.power
    ADD CONSTRAINT power_pkey PRIMARY KEY (power_id);


--
-- TOC entry 4758 (class 2606 OID 17148)
-- Name: system_notifications system_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_notifications
    ADD CONSTRAINT system_notifications_pkey PRIMARY KEY (notification_id);


--
-- TOC entry 4716 (class 2606 OID 17003)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4718 (class 2606 OID 16999)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 4720 (class 2606 OID 17001)
-- Name: users users_user_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_name_key UNIQUE (user_name);


--
-- TOC entry 4725 (class 1259 OID 17217)
-- Name: idx_categories_series; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_categories_series ON public.categories USING btree (series_id);


--
-- TOC entry 4765 (class 1259 OID 17218)
-- Name: idx_model_series_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_model_series_group ON public.model_series USING btree (group_id);


--
-- TOC entry 4726 (class 1259 OID 17212)
-- Name: idx_motorcycles_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_motorcycles_category ON public.motorcycles USING btree (category_id);


--
-- TOC entry 4727 (class 1259 OID 17215)
-- Name: idx_motorcycles_model_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_motorcycles_model_name ON public.motorcycles USING btree (model_name);


--
-- TOC entry 4728 (class 1259 OID 17213)
-- Name: idx_motorcycles_price; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_motorcycles_price ON public.motorcycles USING btree (price);


--
-- TOC entry 4729 (class 1259 OID 17216)
-- Name: idx_motorcycles_price_year; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_motorcycles_price_year ON public.motorcycles USING btree (price, year);


--
-- TOC entry 4730 (class 1259 OID 17214)
-- Name: idx_motorcycles_year; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_motorcycles_year ON public.motorcycles USING btree (year);


--
-- TOC entry 4754 (class 1259 OID 17228)
-- Name: idx_notifications_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_created_at ON public.system_notifications USING btree (created_at);


--
-- TOC entry 4755 (class 1259 OID 17227)
-- Name: idx_notifications_is_read; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_is_read ON public.system_notifications USING btree (is_read);


--
-- TOC entry 4756 (class 1259 OID 17226)
-- Name: idx_notifications_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_user_id ON public.system_notifications USING btree (user_id);


--
-- TOC entry 4750 (class 1259 OID 17225)
-- Name: idx_order_items_motorcycle_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_items_motorcycle_id ON public.order_items USING btree (motorcycle_id);


--
-- TOC entry 4751 (class 1259 OID 17224)
-- Name: idx_order_items_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_items_order_id ON public.order_items USING btree (order_id);


--
-- TOC entry 4745 (class 1259 OID 17223)
-- Name: idx_orders_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_date ON public.orders USING btree (order_date);


--
-- TOC entry 4746 (class 1259 OID 17222)
-- Name: idx_orders_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_status ON public.orders USING btree (status);


--
-- TOC entry 4747 (class 1259 OID 17221)
-- Name: idx_orders_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_user_id ON public.orders USING btree (user_id);


--
-- TOC entry 4713 (class 1259 OID 17219)
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_users_email ON public.users USING btree (email);


--
-- TOC entry 4714 (class 1259 OID 17220)
-- Name: idx_users_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_users_username ON public.users USING btree (user_name);


--
-- TOC entry 4782 (class 2620 OID 17210)
-- Name: order_items trg_update_total; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_total AFTER INSERT OR DELETE OR UPDATE ON public.order_items FOR EACH ROW EXECUTE FUNCTION public.update_order_total();


--
-- TOC entry 4772 (class 2606 OID 17189)
-- Name: categories categories_series_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_series_id_fkey FOREIGN KEY (series_id) REFERENCES public.model_series(series_id) ON DELETE CASCADE;


--
-- TOC entry 4774 (class 2606 OID 17063)
-- Name: details details_motorcycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.details
    ADD CONSTRAINT details_motorcycle_id_fkey FOREIGN KEY (motorcycle_id) REFERENCES public.motorcycles(motorcycle_id) ON DELETE CASCADE;


--
-- TOC entry 4781 (class 2606 OID 17184)
-- Name: model_series model_series_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.model_series
    ADD CONSTRAINT model_series_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.category_groups(group_id) ON DELETE SET NULL;


--
-- TOC entry 4773 (class 2606 OID 17023)
-- Name: motorcycles motorcycles_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.motorcycles
    ADD CONSTRAINT motorcycles_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(category_id);


--
-- TOC entry 4778 (class 2606 OID 17133)
-- Name: order_items order_items_motorcycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_motorcycle_id_fkey FOREIGN KEY (motorcycle_id) REFERENCES public.motorcycles(motorcycle_id) ON DELETE RESTRICT;


--
-- TOC entry 4779 (class 2606 OID 17128)
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- TOC entry 4777 (class 2606 OID 17114)
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 4776 (class 2606 OID 17095)
-- Name: performance performance_motorcycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.performance
    ADD CONSTRAINT performance_motorcycle_id_fkey FOREIGN KEY (motorcycle_id) REFERENCES public.motorcycles(motorcycle_id) ON DELETE CASCADE;


--
-- TOC entry 4775 (class 2606 OID 17079)
-- Name: power power_motorcycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.power
    ADD CONSTRAINT power_motorcycle_id_fkey FOREIGN KEY (motorcycle_id) REFERENCES public.motorcycles(motorcycle_id) ON DELETE CASCADE;


--
-- TOC entry 4780 (class 2606 OID 17149)
-- Name: system_notifications system_notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_notifications
    ADD CONSTRAINT system_notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE SET NULL;


--
-- TOC entry 4953 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO app_user;
GRANT USAGE ON SCHEMA public TO readonly_user;
GRANT USAGE ON SCHEMA public TO admin_user;


--
-- TOC entry 4954 (class 0 OID 0)
-- Dependencies: 249
-- Name: FUNCTION search_motorcycles(p_category_id integer, p_min_price numeric, p_max_price numeric, p_year_from integer, p_limit integer, p_offset integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.search_motorcycles(p_category_id integer, p_min_price numeric, p_max_price numeric, p_year_from integer, p_limit integer, p_offset integer) TO app_user;
GRANT ALL ON FUNCTION public.search_motorcycles(p_category_id integer, p_min_price numeric, p_max_price numeric, p_year_from integer, p_limit integer, p_offset integer) TO readonly_user;
GRANT ALL ON FUNCTION public.search_motorcycles(p_category_id integer, p_min_price numeric, p_max_price numeric, p_year_from integer, p_limit integer, p_offset integer) TO admin_user;


--
-- TOC entry 4955 (class 0 OID 0)
-- Dependencies: 248
-- Name: FUNCTION update_order_total(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_order_total() TO app_user;
GRANT ALL ON FUNCTION public.update_order_total() TO readonly_user;
GRANT ALL ON FUNCTION public.update_order_total() TO admin_user;


--
-- TOC entry 4956 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE categories; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.categories TO app_user;
GRANT SELECT ON TABLE public.categories TO readonly_user;
GRANT ALL ON TABLE public.categories TO admin_user;


--
-- TOC entry 4958 (class 0 OID 0)
-- Dependencies: 217
-- Name: SEQUENCE categories_category_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.categories_category_id_seq TO app_user;
GRANT ALL ON SEQUENCE public.categories_category_id_seq TO admin_user;


--
-- TOC entry 4959 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE category_groups; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.category_groups TO app_user;
GRANT SELECT ON TABLE public.category_groups TO readonly_user;
GRANT ALL ON TABLE public.category_groups TO admin_user;


--
-- TOC entry 4961 (class 0 OID 0)
-- Dependencies: 233
-- Name: SEQUENCE category_groups_group_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.category_groups_group_id_seq TO app_user;
GRANT ALL ON SEQUENCE public.category_groups_group_id_seq TO admin_user;


--
-- TOC entry 4962 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.details TO app_user;
GRANT SELECT ON TABLE public.details TO readonly_user;
GRANT ALL ON TABLE public.details TO admin_user;


--
-- TOC entry 4964 (class 0 OID 0)
-- Dependencies: 221
-- Name: SEQUENCE details_detail_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.details_detail_id_seq TO app_user;
GRANT ALL ON SEQUENCE public.details_detail_id_seq TO admin_user;


--
-- TOC entry 4965 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE model_series; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.model_series TO app_user;
GRANT SELECT ON TABLE public.model_series TO readonly_user;
GRANT ALL ON TABLE public.model_series TO admin_user;


--
-- TOC entry 4967 (class 0 OID 0)
-- Dependencies: 235
-- Name: SEQUENCE model_series_series_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.model_series_series_id_seq TO app_user;
GRANT ALL ON SEQUENCE public.model_series_series_id_seq TO admin_user;


--
-- TOC entry 4968 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE motorcycles; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.motorcycles TO app_user;
GRANT SELECT ON TABLE public.motorcycles TO readonly_user;
GRANT ALL ON TABLE public.motorcycles TO admin_user;


--
-- TOC entry 4970 (class 0 OID 0)
-- Dependencies: 219
-- Name: SEQUENCE motorcycles_motorcycle_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.motorcycles_motorcycle_id_seq TO app_user;
GRANT ALL ON SEQUENCE public.motorcycles_motorcycle_id_seq TO admin_user;


--
-- TOC entry 4971 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE order_items; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.order_items TO app_user;
GRANT SELECT ON TABLE public.order_items TO readonly_user;
GRANT ALL ON TABLE public.order_items TO admin_user;


--
-- TOC entry 4973 (class 0 OID 0)
-- Dependencies: 229
-- Name: SEQUENCE order_items_item_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.order_items_item_id_seq TO app_user;
GRANT ALL ON SEQUENCE public.order_items_item_id_seq TO admin_user;


--
-- TOC entry 4974 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE orders; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.orders TO app_user;
GRANT SELECT ON TABLE public.orders TO readonly_user;
GRANT ALL ON TABLE public.orders TO admin_user;


--
-- TOC entry 4976 (class 0 OID 0)
-- Dependencies: 227
-- Name: SEQUENCE orders_order_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.orders_order_id_seq TO app_user;
GRANT ALL ON SEQUENCE public.orders_order_id_seq TO admin_user;


--
-- TOC entry 4977 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE performance; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.performance TO app_user;
GRANT SELECT ON TABLE public.performance TO readonly_user;
GRANT ALL ON TABLE public.performance TO admin_user;


--
-- TOC entry 4979 (class 0 OID 0)
-- Dependencies: 225
-- Name: SEQUENCE performance_performance_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.performance_performance_id_seq TO app_user;
GRANT ALL ON SEQUENCE public.performance_performance_id_seq TO admin_user;


--
-- TOC entry 4980 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE power; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.power TO app_user;
GRANT SELECT ON TABLE public.power TO readonly_user;
GRANT ALL ON TABLE public.power TO admin_user;


--
-- TOC entry 4982 (class 0 OID 0)
-- Dependencies: 223
-- Name: SEQUENCE power_power_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.power_power_id_seq TO app_user;
GRANT ALL ON SEQUENCE public.power_power_id_seq TO admin_user;


--
-- TOC entry 4983 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE system_notifications; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.system_notifications TO app_user;
GRANT SELECT ON TABLE public.system_notifications TO readonly_user;
GRANT ALL ON TABLE public.system_notifications TO admin_user;


--
-- TOC entry 4985 (class 0 OID 0)
-- Dependencies: 231
-- Name: SEQUENCE system_notifications_notification_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.system_notifications_notification_id_seq TO app_user;
GRANT ALL ON SEQUENCE public.system_notifications_notification_id_seq TO admin_user;


--
-- TOC entry 4986 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.users TO app_user;
GRANT SELECT ON TABLE public.users TO readonly_user;
GRANT ALL ON TABLE public.users TO admin_user;


--
-- TOC entry 4988 (class 0 OID 0)
-- Dependencies: 215
-- Name: SEQUENCE users_user_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.users_user_id_seq TO app_user;
GRANT ALL ON SEQUENCE public.users_user_id_seq TO admin_user;


--
-- TOC entry 2090 (class 826 OID 17232)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO readonly_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO admin_user;


-- Completed on 2026-05-25 18:13:21

--
-- PostgreSQL database dump complete
--

\unrestrict UtGHeETA4FLx36M7paFOZy7SQTvYi2jwGtPeXmT2ysP0n3bn0aDFUzeI2fSQbUJ

