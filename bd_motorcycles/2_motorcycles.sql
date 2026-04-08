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

CREATE SEQUENCE public.motorcycles_motorcycle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.motorcycles_motorcycle_id_seq OWNER TO postgres;
ALTER SEQUENCE public.motorcycles_motorcycle_id_seq OWNED BY public.motorcycles.motorcycle_id;

ALTER TABLE ONLY public.motorcycles 
    ALTER COLUMN motorcycle_id SET DEFAULT nextval('public.motorcycles_motorcycle_id_seq'::regclass);


ALTER TABLE ONLY public.motorcycles
    ADD CONSTRAINT motorcycles_pkey PRIMARY KEY (motorcycle_id);

ALTER TABLE ONLY public.motorcycles
    ADD CONSTRAINT motorcycles_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(category_id);