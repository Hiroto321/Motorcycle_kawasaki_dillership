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