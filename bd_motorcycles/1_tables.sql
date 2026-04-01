CREATE TABLE public.category_groups (
    group_id integer NOT NULL,
    group_name character varying(100) NOT NULL,
    group_slug character varying(50),
    display_order integer DEFAULT 0
);
ALTER TABLE public.category_groups OWNER TO postgres;

CREATE SEQUENCE public.category_groups_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.category_groups_group_id_seq OWNER TO postgres;
ALTER SEQUENCE public.category_groups_group_id_seq OWNED BY public.category_groups.group_id;

CREATE TABLE public.model_series (
    series_id integer NOT NULL,
    series_name character varying(100) NOT NULL,
    group_id integer,
    series_slug character varying(50),
    display_order integer DEFAULT 0
);
ALTER TABLE public.model_series OWNER TO postgres;

CREATE SEQUENCE public.model_series_series_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.model_series_series_id_seq OWNER TO postgres;
ALTER SEQUENCE public.model_series_series_id_seq OWNED BY public.model_series.series_id;

CREATE TABLE public.categories (
    category_id integer NOT NULL,
    category_name character varying(50) NOT NULL,
    series_id integer
);
ALTER TABLE public.categories OWNER TO postgres;

CREATE SEQUENCE public.categories_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.categories_category_id_seq OWNER TO postgres;
ALTER SEQUENCE public.categories_category_id_seq OWNED BY public.categories.category_id;