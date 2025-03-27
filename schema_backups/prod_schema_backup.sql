--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8
-- Dumped by pg_dump version 17.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: prod; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA prod;


ALTER SCHEMA prod OWNER TO pg_database_owner;

--
-- Name: SCHEMA prod; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA prod IS 'Nesters Prod Schema';


--
-- Name: get_nearby_apartments(uuid, double precision, integer, integer, double precision, double precision); Type: FUNCTION; Schema: prod; Owner: postgres
--

CREATE FUNCTION prod.get_nearby_apartments(uid uuid, range_km double precision DEFAULT 100, offset_value integer DEFAULT 0, page_limit integer DEFAULT 10, source_latitude double precision DEFAULT 100, source_longitude double precision DEFAULT 100) RETURNS TABLE(id bigint, apartment_description text, rent real, photos json, amenities_available json, is_available boolean, user_id uuid, start_date bigint, end_date bigint, beds smallint, baths smallint, created_at timestamp with time zone, address text, distance_m double precision, latitude double precision, longitude double precision, location gis.geometry, apartment_likes json)
    LANGUAGE plpgsql
    AS $$
DECLARE 
    search_location gis.geography;
BEGIN -- If source_latitude and source_longitude are provided, convert them to gis.geography

    IF source_latitude IS NOT NULL
    AND source_longitude IS NOT NULL THEN search_location := gis.ST_SetSRID(
        gis.ST_MakePoint(source_longitude, source_latitude),
        4326
    );
    ELSE -- Otherwise, get the university location for the given user_id
        SELECT
            u.location INTO search_location
        FROM
            prod.user_details AS ud
            INNER JOIN const.universities AS u ON ud.college = u.title
        WHERE
            ud.id = uid;
    END IF;

-- Return nearby apartments with like information
RETURN QUERY
SELECT
    a.id AS id,
    a.apartment_description,
    a.rent,
    a.photos,
    a.amenities_available,
    a.is_available,
    a.user_id,
    a.start_date,
    a.end_date,
    a.beds,
    a.baths,
    a.created_at,
    a.address,
    gis.ST_Distance(a.location :: gis.geography, search_location) AS distance_m,
    gis.ST_Y(a.location :: gis.geometry) AS latitude,
    gis.ST_X(a.location :: gis.geometry) AS longitude,
    a.location :: gis.geometry,
    -- Include like information as JSON
    json_build_object(
        'is_liked',
        COALESCE(al.is_liked, false)
    ) AS apartment_likes
FROM
    prod.apartments AS a -- Left join with apartment_likes to get like status for this user
    LEFT JOIN prod.apartment_likes AS al ON a.id = al.apartment_id
    AND al.user_id = uid
WHERE
    -- Filter by distance
    gis.ST_DWithin(
        a.location :: gis.geography,
        search_location,
        range_km * 1000
    ) -- Exclude apartments created by the calling user
    AND a.user_id != uid
ORDER BY
    distance_m OFFSET offset_value
LIMIT
    page_limit;

END;
$$;


ALTER FUNCTION prod.get_nearby_apartments(uid uuid, range_km double precision, offset_value integer, page_limit integer, source_latitude double precision, source_longitude double precision) OWNER TO postgres;

--
-- Name: get_nearby_marketplaces(uuid, double precision, integer, integer, double precision, double precision); Type: FUNCTION; Schema: prod; Owner: postgres
--

CREATE FUNCTION prod.get_nearby_marketplaces(uid uuid, range_km double precision DEFAULT 100, offset_value integer DEFAULT 0, page_limit integer DEFAULT 10, source_latitude double precision DEFAULT 100, source_longitude double precision DEFAULT 100) RETURNS TABLE(id bigint, name text, category json, description text, price integer, photos json, link json, period json, is_available boolean, user_id uuid, created_at bigint, address text, distance_m double precision, latitude double precision, longitude double precision, marketplaces_likes json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    search_location gis.geography;
BEGIN
    -- Convert source coordinates to geography if provided
    IF source_latitude IS NOT NULL AND source_longitude IS NOT NULL THEN
        search_location := gis.ST_SetSRID(
            gis.ST_MakePoint(source_longitude, source_latitude), 4326
        );
    ELSE
        -- Get university location for the given user_id if no source coordinates provided
        SELECT u.location INTO search_location
        FROM prod.user_details AS ud
        INNER JOIN const.universities AS u ON ud.college = u.title
        WHERE ud.id = uid;
    END IF;

    -- Return nearby marketplaces with like information
    RETURN QUERY
    SELECT
        m.id AS id,
        m.name,
        m.category,
        m.description,
        m.price,
        m.photos,
        m.link,
        m.period,
        m.is_available,
        m.user_id,
        m.created_at,
        m.address,
        gis.ST_Distance(m.location::gis.geography, search_location) AS distance_m,
        gis.ST_Y(m.location::gis.geometry) AS latitude,
        gis.ST_X(m.location::gis.geometry) AS longitude,
        json_build_object(
            'is_liked', COALESCE(ml.is_liked, false)
        ) AS marketplaces_likes
    FROM prod.marketplaces AS m
    LEFT JOIN prod.marketplaces_likes AS ml ON 
        m.id = ml.marketplace_id AND 
        ml.user_id = uid
    WHERE 
        gis.ST_DWithin(m.location::gis.geography, search_location, range_km * 1000) AND
        m.user_id != uid  -- Exclude marketplaces created by the calling user
    ORDER BY distance_m
    OFFSET offset_value LIMIT page_limit;
END;
$$;


ALTER FUNCTION prod.get_nearby_marketplaces(uid uuid, range_km double precision, offset_value integer, page_limit integer, source_latitude double precision, source_longitude double precision) OWNER TO postgres;

--
-- Name: get_nearby_sublets(uuid, double precision, integer, integer, double precision, double precision); Type: FUNCTION; Schema: prod; Owner: postgres
--

CREATE FUNCTION prod.get_nearby_sublets(uid uuid, range_km double precision DEFAULT 100, offset_value integer DEFAULT 0, page_limit integer DEFAULT 10, source_latitude double precision DEFAULT 100, source_longitude double precision DEFAULT 100) RETURNS TABLE(sublet_id bigint, room_description text, roommate_description text, roommate_gender_pref text, rent real, photos json, amenities_available json, room_type text, is_available boolean, user_id uuid, start_date bigint, end_date bigint, beds smallint, baths smallint, created_at timestamp with time zone, address text, distance_m double precision, latitude double precision, longitude double precision, location gis.geography, sublet_likes json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    university_location gis.geography;
    search_location gis.geography;
BEGIN
    -- If source_latitude and source_longitude are provided, convert them to gis.geography
    IF source_latitude IS NOT NULL AND source_longitude IS NOT NULL THEN
        search_location := gis.ST_SetSRID(gis.ST_MakePoint(source_longitude, source_latitude), 4326);
    ELSE
        -- Otherwise, get the university location for the given user_id
        SELECT u.location INTO university_location
        FROM prod.user_details AS ud
        INNER JOIN const.universities AS u ON ud.college = u.title
        WHERE ud.id = uid;
        search_location := university_location;
    END IF;

    -- Return nearby sublets based on the search location with pagination and distance
    RETURN QUERY
    SELECT
        s.id AS sublet_id,
        s.room_description,
        s.roommate_description,
        s.roommate_gender_pref,
        s.rent,
        s.photos,
        s.amenities_available,
        s.room_type,
        s.is_available,
        s.user_id,
        s.start_date,
        s.end_date,
        s.beds,
        s.baths,
        s.created_at,
        s.address,
        gis.ST_Distance(s.location::gis.geography, search_location) AS distance_m,
        gis.ST_Y(s.location::gis.geometry) AS latitude,
        gis.ST_X(s.location::gis.geometry) AS longitude,
        s.location::gis.geography,
        -- Add sublet_likes JSON with is_liked status
        json_build_object(
            'is_liked', COALESCE(sl.is_liked, false)
        ) AS sublet_likes
    FROM prod.sublets AS s
    -- Left join with sublet_likes to check if current user has liked the sublet
    LEFT JOIN prod.sublet_likes AS sl ON s.id = sl.sublet_id AND sl.user_id = uid
    WHERE gis.ST_DWithin(s.location::gis.geography, search_location, range_km * 1000)
    -- Exclude sublets created by the calling user
    AND s.user_id != uid
    ORDER BY distance_m
    OFFSET offset_value LIMIT page_limit;
END;
$$;


ALTER FUNCTION prod.get_nearby_sublets(uid uuid, range_km double precision, offset_value integer, page_limit integer, source_latitude double precision, source_longitude double precision) OWNER TO postgres;

--
-- Name: get_users(uuid, text, integer, integer); Type: FUNCTION; Schema: prod; Owner: postgres
--

CREATE FUNCTION prod.get_users(exclude_user uuid, target_college text, offset_value integer DEFAULT 0, page_limit integer DEFAULT 10) RETURNS TABLE(id uuid, full_name text, profile_image text, selected_course_name text, college text, city text, state text, country text, work_experience smallint, intake_period text, intake_year smallint, has_roommate_found boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    (
        -- Get users from the same college first, excluding the specified user
        SELECT
            u.id,
            u.full_name,
            u.profile_image,
            u.selected_course_name,
            u.college,
            u.city,
            u.state,
            u.country,
            u.work_experience,
            u.intake_period,
            u.intake_year,
            u.has_roommate_found
        FROM prod.user_details u
        WHERE 
            u.college = target_college AND
            u.id != exclude_user
        ORDER BY 
            u.intake_year DESC, 
            u.intake_period DESC
        LIMIT page_limit 
        OFFSET offset_value * page_limit
    )
    UNION ALL
    (
        -- Get users from other colleges after the same college users are exhausted
        SELECT
            u.id,
            u.full_name,
            u.profile_image,
            u.selected_course_name,
            u.college,
            u.city,
            u.state,
            u.country,
            u.work_experience,
            u.intake_period,
            u.intake_year,
            u.has_roommate_found
        FROM prod.user_details u
        WHERE 
            u.college != target_college AND
            u.id != exclude_user
        ORDER BY 
            u.intake_year DESC, 
            u.intake_period DESC
        LIMIT page_limit 
        OFFSET offset_value * page_limit
    );
END;
$$;


ALTER FUNCTION prod.get_users(exclude_user uuid, target_college text, offset_value integer, page_limit integer) OWNER TO postgres;

--
-- Name: search_marketplace_items(text, uuid, double precision, double precision, double precision); Type: FUNCTION; Schema: prod; Owner: postgres
--

CREATE FUNCTION prod.search_marketplace_items(search_query text, uid uuid, source_latitude double precision DEFAULT 100, source_longitude double precision DEFAULT 100, range_km double precision DEFAULT 100) RETURNS TABLE(id bigint, name text, category json, description text, price integer, photos json, link json, period json, is_available boolean, user_id uuid, created_at bigint, address text, distance_m double precision, latitude double precision, longitude double precision, match_by text)
    LANGUAGE plpgsql
    AS $$ 
DECLARE 
    search_location gis.geography;
BEGIN -- Convert source coordinates to geography if provided
IF source_latitude IS NOT NULL
AND source_longitude IS NOT NULL THEN search_location := gis.ST_SetSRID(
    gis.ST_MakePoint(source_longitude, source_latitude),
    4326
);

ELSE -- Get university location for the given user_id if no source coordinates provided
SELECT
    u.location INTO search_location
FROM
    prod.user_details AS ud
    INNER JOIN const.universities AS u ON ud.college = u.title
WHERE
    ud.id = uid;

END IF;

RETURN QUERY
SELECT
    m.id AS id,
    m.name,
    m.category,
    m.description,
    m.price,
    m.photos,
    m.link,
    m.period,
    m.is_available,
    m.user_id,
    m.created_at,
    m.address,
    gis.ST_Distance(m.location :: gis.geography, search_location) AS distance_m,
    gis.ST_Y(m.location :: gis.geometry) AS latitude,
    gis.ST_X(m.location :: gis.geometry) AS longitude,
    CASE
        WHEN m.name ILIKE '%' || search_query || '%' THEN 'name'
        WHEN m.description ILIKE '%' || search_query || '%' THEN 'description'
        WHEN m.category ->> 'name' ILIKE '%' || search_query || '%' THEN 'category'
        WHEN m.address ILIKE '%' || search_query || '%' THEN 'address'
        ELSE 'unknown'
    END AS match_by
FROM
    prod.marketplaces AS m
WHERE
    gis.ST_DWithin(
        m.location :: gis.geography,
        search_location,
        range_km * 1000
    )
    AND (
        m.name ILIKE '%' || search_query || '%'
        OR m.description ILIKE '%' || search_query || '%'
        OR m.category ->> 'name' ILIKE '%' || search_query || '%'
        OR m.address ILIKE '%' || search_query || '%'
    )
    AND m.user_id != uid -- Exclude items posted by the current user
ORDER BY
    distance_m;

END;
$$;


ALTER FUNCTION prod.search_marketplace_items(search_query text, uid uuid, source_latitude double precision, source_longitude double precision, range_km double precision) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: apartment_likes; Type: TABLE; Schema: prod; Owner: postgres
--

CREATE TABLE prod.apartment_likes (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id uuid NOT NULL,
    apartment_id bigint NOT NULL,
    is_liked boolean DEFAULT false NOT NULL
);


ALTER TABLE prod.apartment_likes OWNER TO postgres;

--
-- Name: apartment_likes_id_seq; Type: SEQUENCE; Schema: prod; Owner: postgres
--

ALTER TABLE prod.apartment_likes ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME prod.apartment_likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: apartments; Type: TABLE; Schema: prod; Owner: postgres
--

CREATE TABLE prod.apartments (
    id bigint NOT NULL,
    apartment_description text,
    rent real,
    photos json,
    amenities_available json,
    is_available boolean,
    user_id uuid,
    start_date bigint,
    beds smallint,
    baths smallint,
    created_at timestamp with time zone DEFAULT now(),
    end_date bigint,
    location gis.geography(Point,4326),
    address text DEFAULT ''::text NOT NULL
);


ALTER TABLE prod.apartments OWNER TO postgres;

--
-- Name: marketplaces; Type: TABLE; Schema: prod; Owner: postgres
--

CREATE TABLE prod.marketplaces (
    id bigint NOT NULL,
    created_at bigint NOT NULL,
    name text,
    category json,
    description text,
    photos json,
    price integer,
    link json,
    period json,
    is_available boolean,
    user_id uuid,
    location gis.geography(Point,4326),
    address text DEFAULT ''::text NOT NULL
);


ALTER TABLE prod.marketplaces OWNER TO postgres;

--
-- Name: TABLE marketplaces; Type: COMMENT; Schema: prod; Owner: postgres
--

COMMENT ON TABLE prod.marketplaces IS 'Place to sell products from student to student';


--
-- Name: market_place_id_seq; Type: SEQUENCE; Schema: prod; Owner: postgres
--

ALTER TABLE prod.marketplaces ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME prod.market_place_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: marketplaces_likes; Type: TABLE; Schema: prod; Owner: postgres
--

CREATE TABLE prod.marketplaces_likes (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id uuid DEFAULT gen_random_uuid(),
    marketplace_id bigint NOT NULL,
    is_liked boolean DEFAULT false NOT NULL
);


ALTER TABLE prod.marketplaces_likes OWNER TO postgres;

--
-- Name: marketplace_likes_id_seq; Type: SEQUENCE; Schema: prod; Owner: postgres
--

ALTER TABLE prod.marketplaces_likes ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME prod.marketplace_likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sublet_likes; Type: TABLE; Schema: prod; Owner: postgres
--

CREATE TABLE prod.sublet_likes (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id uuid NOT NULL,
    sublet_id bigint NOT NULL,
    is_liked boolean DEFAULT false NOT NULL
);


ALTER TABLE prod.sublet_likes OWNER TO postgres;

--
-- Name: sublet_likes_id_seq; Type: SEQUENCE; Schema: prod; Owner: postgres
--

ALTER TABLE prod.sublet_likes ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME prod.sublet_likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sublets; Type: TABLE; Schema: prod; Owner: postgres
--

CREATE TABLE prod.sublets (
    id bigint NOT NULL,
    room_description text,
    roommate_description text,
    roommate_gender_pref text,
    rent real,
    photos json,
    amenities_available json,
    room_type text,
    is_available boolean,
    user_id uuid,
    start_date bigint,
    end_date bigint,
    beds smallint,
    baths smallint,
    created_at timestamp with time zone DEFAULT now(),
    location gis.geography(Point,4326),
    address text DEFAULT ''::text NOT NULL
);


ALTER TABLE prod.sublets OWNER TO postgres;

--
-- Name: TABLE sublets; Type: COMMENT; Schema: prod; Owner: postgres
--

COMMENT ON TABLE prod.sublets IS 'Table containing all the sublets post request data';


--
-- Name: user_details; Type: TABLE; Schema: prod; Owner: postgres
--

CREATE TABLE prod.user_details (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text) NOT NULL,
    full_name text DEFAULT ''::text,
    email text DEFAULT ''::text,
    phone text,
    profile_image text DEFAULT ''::text,
    city text DEFAULT ''::text,
    selected_course_name text DEFAULT ''::text,
    gender character varying,
    college text DEFAULT ''::text NOT NULL,
    undergrad_college_name text DEFAULT ''::text,
    birth_date timestamp without time zone,
    person_type character varying,
    prefs json,
    primary_lang text,
    other_lang text,
    work_experience smallint,
    smoking_habit character varying,
    habits json,
    hobbies text,
    drinking_habit character varying DEFAULT ''::character varying,
    food_habit text,
    cooking_skill text,
    cleanliness_habit character varying,
    state text,
    bio text,
    room_type text,
    flatmates_gender_prefs text,
    country text,
    user_deleted boolean DEFAULT false,
    user_deleted_date timestamp with time zone,
    intake_period text,
    intake_year smallint,
    has_roommate_found boolean DEFAULT false,
    user_data_completed boolean DEFAULT false
);


ALTER TABLE prod.user_details OWNER TO postgres;

--
-- Name: TABLE user_details; Type: COMMENT; Schema: prod; Owner: postgres
--

COMMENT ON TABLE prod.user_details IS 'Table that contains all the user details';


--
-- Data for Name: apartment_likes; Type: TABLE DATA; Schema: prod; Owner: postgres
--

COPY prod.apartment_likes (id, created_at, user_id, apartment_id, is_liked) FROM stdin;
\.


--
-- Data for Name: apartments; Type: TABLE DATA; Schema: prod; Owner: postgres
--

COPY prod.apartments (id, apartment_description, rent, photos, amenities_available, is_available, user_id, start_date, beds, baths, created_at, end_date, location, address) FROM stdin;
1740614096938	bsbs	85	["https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/apartments/25f247de-78b8-4ebc-91ac-1451302dc9ff/1740614096938/image_2025-02-26%2018:56:31.673176.jpg"]	{"has_dryer":false,"has_washing_machine":false,"has_dishwasher":false,"has_parking":false,"has_gym":false,"has_pool":false,"has_balcony":false,"has_patio":false,"has_AC":false,"has_gas":false,"has_heater":false,"has_furnished":false,"has_semi_furnished":false,"extra_amenities":[]}	t	25f247de-78b8-4ebc-91ac-1451302dc9ff	1740546000000	1	1	2025-02-26 23:56:35.929723+00	\N	0101000020E6100000A4B041156D7C52C0436DC08CCE564440	Brooklyn, NY, USA
1740614219929	bsns	54545	["https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/apartments/25f247de-78b8-4ebc-91ac-1451302dc9ff/1740614219929/image_2025-02-26%2018:57:24.204145.jpg","https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/apartments/25f247de-78b8-4ebc-91ac-1451302dc9ff/1740614219929/image_2025-02-26%2018:57:27.039872.jpg"]	{"has_dryer":false,"has_washing_machine":false,"has_dishwasher":true,"has_parking":false,"has_gym":true,"has_pool":false,"has_balcony":false,"has_patio":false,"has_AC":false,"has_gas":true,"has_heater":false,"has_furnished":false,"has_semi_furnished":false,"extra_amenities":[]}	t	25f247de-78b8-4ebc-91ac-1451302dc9ff	1740546000000	1	2	2025-02-26 23:57:30.597953+00	\N	0101000020E61000005F556243DC7E52C0057756C15E624440	Manhattan, New York, NY, USA
1740624271509	hajsjsj	508	["https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/apartments/58d807e4-5272-419f-b59a-b3219a7835fe/1740624271509/image_2025-02-26%2021:45:47.894718.jpg","https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/apartments/58d807e4-5272-419f-b59a-b3219a7835fe/1740624271509/image_2025-02-26%2021:45:50.661140.jpg"]	{"has_dryer":true,"has_washing_machine":false,"has_dishwasher":true,"has_parking":true,"has_gym":true,"has_pool":true,"has_balcony":false,"has_patio":true,"has_AC":true,"has_gas":true,"has_heater":false,"has_furnished":false,"has_semi_furnished":false,"extra_amenities":[]}	t	58d807e4-5272-419f-b59a-b3219a7835fe	1740546000000	2	3	2025-02-27 02:45:54.070649+00	\N	0101000020E6100000A4B041156D7C52C0436DC08CCE564440	Brooklyn, NY, USA
\.


--
-- Data for Name: marketplaces; Type: TABLE DATA; Schema: prod; Owner: postgres
--

COPY prod.marketplaces (id, created_at, name, category, description, photos, price, link, period, is_available, user_id, location, address) FROM stdin;
1740614282825	1740614316886	dell computer	{"id":1,"name":"Amazon Devices"}	nsn	["https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/marketplaces/25f247de-78b8-4ebc-91ac-1451302dc9ff/1740614282825/image_2025-02-26%2018:58:57.489533.jpg"]	84	{}	{"period_till":1740718800000,"period_from":1740546000000}	t	25f247de-78b8-4ebc-91ac-1451302dc9ff	0101000020E6100000A4B041156D7C52C0436DC08CCE564440	Brooklyn, NY, USA
\.


--
-- Data for Name: marketplaces_likes; Type: TABLE DATA; Schema: prod; Owner: postgres
--

COPY prod.marketplaces_likes (id, created_at, user_id, marketplace_id, is_liked) FROM stdin;
\.


--
-- Data for Name: sublet_likes; Type: TABLE DATA; Schema: prod; Owner: postgres
--

COPY prod.sublet_likes (id, created_at, user_id, sublet_id, is_liked) FROM stdin;
1	2025-03-26 19:36:07.721901+00	25f247de-78b8-4ebc-91ac-1451302dc9ff	1740614038771	t
\.


--
-- Data for Name: sublets; Type: TABLE DATA; Schema: prod; Owner: postgres
--

COPY prod.sublets (id, room_description, roommate_description, roommate_gender_pref, rent, photos, amenities_available, room_type, is_available, user_id, start_date, end_date, beds, baths, created_at, location, address) FROM stdin;
1740613945426	hshshshh	nsnsns	Male	200	["https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/sublets/25f247de-78b8-4ebc-91ac-1451302dc9ff/1740613945426/image_2025-02-26%2018:53:04.314106.jpg","https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/sublets/25f247de-78b8-4ebc-91ac-1451302dc9ff/1740613945426/image_2025-02-26%2018:53:06.976760.jpg","https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/sublets/25f247de-78b8-4ebc-91ac-1451302dc9ff/1740613945426/image_2025-02-26%2018:53:09.844094.jpg"]	{"has_dryer":true,"has_washing_machine":false,"has_dishwasher":false,"has_parking":true,"has_gym":true,"has_pool":true,"has_balcony":false,"has_patio":false,"has_AC":true,"has_gas":true,"has_heater":false,"has_furnished":false,"has_semi_furnished":false,"extra_amenities":[]}	Private	t	25f247de-78b8-4ebc-91ac-1451302dc9ff	1740546000000	1740546000000	1	2	2025-02-26 23:53:14.087419+00	0101000020E6100000A4B041156D7C52C0436DC08CCE564440	Brooklyn, NY, USA
1740614038771	ndns	bsbsn	Female	2330	["https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/sublets/25f247de-78b8-4ebc-91ac-1451302dc9ff/1740614038771/image_2025-02-26%2018:54:49.276933.jpg"]	{"has_dryer":false,"has_washing_machine":false,"has_dishwasher":false,"has_parking":false,"has_gym":false,"has_pool":false,"has_balcony":true,"has_patio":true,"has_AC":true,"has_gas":false,"has_heater":false,"has_furnished":false,"has_semi_furnished":false,"extra_amenities":[]}	Shared	t	25f247de-78b8-4ebc-91ac-1451302dc9ff	1740546000000	1740718800000	2	3	2025-02-26 23:54:52.491963+00	0101000020E61000005F556243DC7E52C0057756C15E624440	Manhattan, New York, NY, USA
1740622552873	bsbsn	bsnsjjs	Male	58	["https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/sublets/25f247de-78b8-4ebc-91ac-1451302dc9ff/1740622552873/image_2025-02-26%2021:17:20.587799.jpg"]	{"has_dryer":false,"has_washing_machine":false,"has_dishwasher":true,"has_parking":true,"has_gym":true,"has_pool":true,"has_balcony":false,"has_patio":false,"has_AC":false,"has_gas":true,"has_heater":false,"has_furnished":false,"has_semi_furnished":false,"extra_amenities":[]}	Shared	t	25f247de-78b8-4ebc-91ac-1451302dc9ff	1740546000000	1740718800000	2	3	2025-02-27 02:17:23.824649+00	0101000020E6100000A4B041156D7C52C0436DC08CCE564440	Brooklyn, NY, USA
1740623479339	jdjsj	jsjsjjnznzn	Male	2000	["https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/sublets/58d807e4-5272-419f-b59a-b3219a7835fe/1740623479339/image_2025-02-26%2021:32:36.429710.jpg","https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/sublets/58d807e4-5272-419f-b59a-b3219a7835fe/1740623479339/image_2025-02-26%2021:32:39.298920.jpg"]	{"has_dryer":true,"has_washing_machine":false,"has_dishwasher":false,"has_parking":true,"has_gym":true,"has_pool":true,"has_balcony":false,"has_patio":true,"has_AC":true,"has_gas":true,"has_heater":false,"has_furnished":false,"has_semi_furnished":false,"extra_amenities":[]}	Private	t	58d807e4-5272-419f-b59a-b3219a7835fe	1740546000000	1740718800000	3	2	2025-02-27 02:32:42.790066+00	0101000020E6100000A4B041156D7C52C0436DC08CCE564440	Brooklyn, NY, USA
\.


--
-- Data for Name: user_details; Type: TABLE DATA; Schema: prod; Owner: postgres
--

COPY prod.user_details (id, created_at, full_name, email, phone, profile_image, city, selected_course_name, gender, college, undergrad_college_name, birth_date, person_type, prefs, primary_lang, other_lang, work_experience, smoking_habit, habits, hobbies, drinking_habit, food_habit, cooking_skill, cleanliness_habit, state, bio, room_type, flatmates_gender_prefs, country, user_deleted, user_deleted_date, intake_period, intake_year, has_roommate_found, user_data_completed) FROM stdin;
58d807e4-5272-419f-b59a-b3219a7835fe	2025-02-27 00:04:09.022977+00	Shreyash Dhamane	shreyashb.dhamane0@gmail.com	\N	https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/profile_images/58d807e4-5272-419f-b59a-b3219a7835fe/profile_image_1740614628831.jpg	Brooklyn Park	Applied Data Science	\N	Harvard University	C	2025-02-26 00:00:00	Ambivert	\N	Afar	Afrikaans	5	Occasional	\N	cgh	Occasional	Vegetarian	Intermediate	Very Clean	Minnesota	vh	Private	Mix	United States	f	\N	Summer	2024	t	f
6bf907e7-ed36-4183-9d03-0f50043d92bf	2025-02-21 12:49:38.942777+00	Pratik Pujari	pratikpujari1000@gmail.com	\N	https://lh3.googleusercontent.com/a/ACg8ocLK_WfLajmgRz4AO3vck3rbp0hih9FWllZWwOramG8N6D1yeDHi=s96-c	Mumbai	Applied Computer Science	\N	Yale University		2002-12-06 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N		\N	\N	\N	Maharashtra	\N	\N	\N	India	f	\N	Fall	2024	f	f
3ca375fd-4460-4c8d-9d09-7b18fe70d2fe	2025-02-27 02:03:58.877497+00	Shreyash Dhamane	sd5971@nyu.edu	\N	https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/profile_images/3ca375fd-4460-4c8d-9d09-7b18fe70d2fe/profile_image_1740621817568.jpg	Brooklyn Park	Applied Mechanics	\N	Princeton University		2025-02-26 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N		\N	\N	\N	Minnesota	\N	\N	\N	United States	f	\N	Summer	2024	f	f
45f45c8c-db0c-409b-a1a2-bf07df81ca0b	2025-02-27 02:05:29.539526+00	Shreyash Dhamane	dhamaneshreyash0@gmail.com	\N	https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/profile_images/45f45c8c-db0c-409b-a1a2-bf07df81ca0b/profile_image_1740621886308.jpg	New York	Applied Physics	\N	New York University (NYU)		2025-02-26 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N		\N	\N	\N	New York	\N	\N	\N	United States	f	\N	Winter	2024	f	f
ae5a1954-82fc-4b2d-9b64-7ea076344bf6	2025-02-27 02:07:15.244691+00	Shreyash Dhamane	dhamaneshreyash3701@gmail.com	\N	https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/profile_images/ae5a1954-82fc-4b2d-9b64-7ea076344bf6/profile_image_1740622004030.jpg	Mumbai	Applied Linguistics	\N	New York University (NYU)		2025-02-26 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N		\N	\N	\N	Maharashtra	\N	\N	\N	India	f	\N	Summer	2024	f	f
25f247de-78b8-4ebc-91ac-1451302dc9ff	2025-02-26 23:50:51.934994+00	Shreyash Tech	shreyashdhamane22032001@gmail.com	\N	https://ellkdthdiuqbbbilufmq.supabase.co/storage/v1/object/public/profile_images/25f247de-78b8-4ebc-91ac-1451302dc9ff/profile_image_1740613832205.jpg	Brookline	Applied Mechanics	\N	Harvard University	Hshshs	2025-02-26 00:00:00	Ambivert	\N	Afar	Afrikaans	0	Rarely	\N	bsnsbsh	Rarely	Pescatarian	Intermediate	Very Clean	Massachusetts	bxn\n	Private	Female	United States	f	\N	Fall	2024	t	f
\.


--
-- Name: apartment_likes_id_seq; Type: SEQUENCE SET; Schema: prod; Owner: postgres
--

SELECT pg_catalog.setval('prod.apartment_likes_id_seq', 1, false);


--
-- Name: market_place_id_seq; Type: SEQUENCE SET; Schema: prod; Owner: postgres
--

SELECT pg_catalog.setval('prod.market_place_id_seq', 1, false);


--
-- Name: marketplace_likes_id_seq; Type: SEQUENCE SET; Schema: prod; Owner: postgres
--

SELECT pg_catalog.setval('prod.marketplace_likes_id_seq', 1, false);


--
-- Name: sublet_likes_id_seq; Type: SEQUENCE SET; Schema: prod; Owner: postgres
--

SELECT pg_catalog.setval('prod.sublet_likes_id_seq', 1, true);


--
-- Name: apartment_likes apartment_likes_pkey; Type: CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.apartment_likes
    ADD CONSTRAINT apartment_likes_pkey PRIMARY KEY (id);


--
-- Name: apartment_likes apartment_likes_sublet_id_key; Type: CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.apartment_likes
    ADD CONSTRAINT apartment_likes_sublet_id_key UNIQUE (apartment_id);


--
-- Name: apartments apartments_pkey; Type: CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.apartments
    ADD CONSTRAINT apartments_pkey PRIMARY KEY (id);


--
-- Name: marketplaces market_place_pkey; Type: CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.marketplaces
    ADD CONSTRAINT market_place_pkey PRIMARY KEY (id);


--
-- Name: marketplaces_likes marketplace_likes_pkey; Type: CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.marketplaces_likes
    ADD CONSTRAINT marketplace_likes_pkey PRIMARY KEY (id);


--
-- Name: marketplaces_likes marketplaces_likes_marketplace_id_key; Type: CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.marketplaces_likes
    ADD CONSTRAINT marketplaces_likes_marketplace_id_key UNIQUE (marketplace_id);


--
-- Name: sublet_likes sublet_likes_pkey; Type: CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.sublet_likes
    ADD CONSTRAINT sublet_likes_pkey PRIMARY KEY (id);


--
-- Name: sublet_likes sublet_likes_sublet_id_key; Type: CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.sublet_likes
    ADD CONSTRAINT sublet_likes_sublet_id_key UNIQUE (sublet_id);


--
-- Name: sublets sublets_pkey; Type: CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.sublets
    ADD CONSTRAINT sublets_pkey PRIMARY KEY (id);


--
-- Name: user_details user_details_pkey; Type: CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.user_details
    ADD CONSTRAINT user_details_pkey PRIMARY KEY (id);


--
-- Name: apartments_location_idx; Type: INDEX; Schema: prod; Owner: postgres
--

CREATE INDEX apartments_location_idx ON prod.apartments USING gist (location);


--
-- Name: marketplaces_location_idx; Type: INDEX; Schema: prod; Owner: postgres
--

CREATE INDEX marketplaces_location_idx ON prod.marketplaces USING gist (location);


--
-- Name: sublets_location_idx; Type: INDEX; Schema: prod; Owner: postgres
--

CREATE INDEX sublets_location_idx ON prod.sublets USING gist (location);


--
-- Name: apartment_likes apartment_likes_apartment_id_fkey; Type: FK CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.apartment_likes
    ADD CONSTRAINT apartment_likes_apartment_id_fkey FOREIGN KEY (apartment_id) REFERENCES prod.apartments(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: apartment_likes apartment_likes_user_id_fkey; Type: FK CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.apartment_likes
    ADD CONSTRAINT apartment_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES prod.user_details(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: marketplaces_likes marketplaces_likes_marketplace_id_fkey; Type: FK CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.marketplaces_likes
    ADD CONSTRAINT marketplaces_likes_marketplace_id_fkey FOREIGN KEY (marketplace_id) REFERENCES prod.marketplaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: marketplaces_likes marketplaces_likes_user_id_fkey; Type: FK CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.marketplaces_likes
    ADD CONSTRAINT marketplaces_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES prod.user_details(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sublet_likes sublet_likes_sublet_id_fkey; Type: FK CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.sublet_likes
    ADD CONSTRAINT sublet_likes_sublet_id_fkey FOREIGN KEY (sublet_id) REFERENCES prod.sublets(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sublet_likes sublet_likes_user_id_fkey; Type: FK CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.sublet_likes
    ADD CONSTRAINT sublet_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES prod.user_details(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_details user_details_college_fkey; Type: FK CONSTRAINT; Schema: prod; Owner: postgres
--

ALTER TABLE ONLY prod.user_details
    ADD CONSTRAINT user_details_college_fkey FOREIGN KEY (college) REFERENCES const.universities(title) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: user_details  Insert User Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY " Insert User Policy" ON prod.user_details FOR INSERT TO authenticated, service_role WITH CHECK ((( SELECT auth.uid() AS uid) = id));


--
-- Name: apartment_likes Apartment Likes Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Apartment Likes Policy" ON prod.apartment_likes TO authenticated, service_role USING (true);


--
-- Name: apartments Delete Apartment Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Delete Apartment Policy" ON prod.apartments FOR DELETE TO authenticated, service_role USING ((( SELECT auth.uid() AS uid) = user_id));


--
-- Name: marketplaces Delete Marketplaces Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Delete Marketplaces Policy" ON prod.marketplaces FOR DELETE TO authenticated, service_role USING ((( SELECT auth.uid() AS uid) = user_id));


--
-- Name: sublets Delete Sublet Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Delete Sublet Policy" ON prod.sublets FOR DELETE TO authenticated, service_role USING ((( SELECT auth.uid() AS uid) = user_id));


--
-- Name: user_details Delete User Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Delete User Policy" ON prod.user_details FOR DELETE TO authenticated, service_role USING ((( SELECT auth.uid() AS uid) = id));


--
-- Name: marketplaces Enable insert for users based on user_id; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Enable insert for users based on user_id" ON prod.marketplaces FOR INSERT TO authenticated, service_role WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));


--
-- Name: apartments Insert Apartment Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Insert Apartment Policy" ON prod.apartments FOR INSERT TO authenticated, service_role WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));


--
-- Name: sublets Insert Sublet Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Insert Sublet Policy" ON prod.sublets FOR INSERT TO authenticated, service_role WITH CHECK (true);


--
-- Name: marketplaces_likes Marketplace Likes Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Marketplace Likes Policy" ON prod.marketplaces_likes TO authenticated, service_role USING (true);


--
-- Name: apartments Select Apartment Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Select Apartment Policy" ON prod.apartments FOR SELECT TO authenticated, service_role USING (true);


--
-- Name: marketplaces Select Marketplace Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Select Marketplace Policy" ON prod.marketplaces FOR SELECT TO authenticated, service_role USING (true);


--
-- Name: sublets Select Sublet Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Select Sublet Policy" ON prod.sublets FOR SELECT TO authenticated, service_role USING (true);


--
-- Name: user_details Select User Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Select User Policy" ON prod.user_details FOR SELECT USING (true);


--
-- Name: sublet_likes Sublet Likes Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Sublet Likes Policy" ON prod.sublet_likes TO authenticated, service_role USING (true);


--
-- Name: apartments Update Apartment Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Update Apartment Policy" ON prod.apartments FOR UPDATE TO authenticated, service_role USING ((( SELECT auth.uid() AS uid) = user_id)) WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));


--
-- Name: marketplaces Update Marketplaces Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Update Marketplaces Policy" ON prod.marketplaces FOR UPDATE TO authenticated, service_role USING ((( SELECT auth.uid() AS uid) = user_id)) WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));


--
-- Name: sublets Update Sublet Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Update Sublet Policy" ON prod.sublets FOR UPDATE TO authenticated, service_role USING ((( SELECT auth.uid() AS uid) = user_id)) WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));


--
-- Name: user_details Update User Policy; Type: POLICY; Schema: prod; Owner: postgres
--

CREATE POLICY "Update User Policy" ON prod.user_details FOR UPDATE TO authenticated, service_role USING ((( SELECT auth.uid() AS uid) = id));


--
-- Name: apartment_likes; Type: ROW SECURITY; Schema: prod; Owner: postgres
--

ALTER TABLE prod.apartment_likes ENABLE ROW LEVEL SECURITY;

--
-- Name: apartments; Type: ROW SECURITY; Schema: prod; Owner: postgres
--

ALTER TABLE prod.apartments ENABLE ROW LEVEL SECURITY;

--
-- Name: marketplaces; Type: ROW SECURITY; Schema: prod; Owner: postgres
--

ALTER TABLE prod.marketplaces ENABLE ROW LEVEL SECURITY;

--
-- Name: marketplaces_likes; Type: ROW SECURITY; Schema: prod; Owner: postgres
--

ALTER TABLE prod.marketplaces_likes ENABLE ROW LEVEL SECURITY;

--
-- Name: sublet_likes; Type: ROW SECURITY; Schema: prod; Owner: postgres
--

ALTER TABLE prod.sublet_likes ENABLE ROW LEVEL SECURITY;

--
-- Name: sublets; Type: ROW SECURITY; Schema: prod; Owner: postgres
--

ALTER TABLE prod.sublets ENABLE ROW LEVEL SECURITY;

--
-- Name: user_details; Type: ROW SECURITY; Schema: prod; Owner: postgres
--

ALTER TABLE prod.user_details ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA prod; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA prod TO postgres;
GRANT USAGE ON SCHEMA prod TO anon;
GRANT USAGE ON SCHEMA prod TO authenticated;
GRANT USAGE ON SCHEMA prod TO service_role;


--
-- Name: FUNCTION get_nearby_apartments(uid uuid, range_km double precision, offset_value integer, page_limit integer, source_latitude double precision, source_longitude double precision); Type: ACL; Schema: prod; Owner: postgres
--

GRANT ALL ON FUNCTION prod.get_nearby_apartments(uid uuid, range_km double precision, offset_value integer, page_limit integer, source_latitude double precision, source_longitude double precision) TO authenticated;
GRANT ALL ON FUNCTION prod.get_nearby_apartments(uid uuid, range_km double precision, offset_value integer, page_limit integer, source_latitude double precision, source_longitude double precision) TO service_role;


--
-- Name: FUNCTION get_nearby_marketplaces(uid uuid, range_km double precision, offset_value integer, page_limit integer, source_latitude double precision, source_longitude double precision); Type: ACL; Schema: prod; Owner: postgres
--

GRANT ALL ON FUNCTION prod.get_nearby_marketplaces(uid uuid, range_km double precision, offset_value integer, page_limit integer, source_latitude double precision, source_longitude double precision) TO authenticated;
GRANT ALL ON FUNCTION prod.get_nearby_marketplaces(uid uuid, range_km double precision, offset_value integer, page_limit integer, source_latitude double precision, source_longitude double precision) TO service_role;


--
-- Name: FUNCTION get_nearby_sublets(uid uuid, range_km double precision, offset_value integer, page_limit integer, source_latitude double precision, source_longitude double precision); Type: ACL; Schema: prod; Owner: postgres
--

GRANT ALL ON FUNCTION prod.get_nearby_sublets(uid uuid, range_km double precision, offset_value integer, page_limit integer, source_latitude double precision, source_longitude double precision) TO authenticated;
GRANT ALL ON FUNCTION prod.get_nearby_sublets(uid uuid, range_km double precision, offset_value integer, page_limit integer, source_latitude double precision, source_longitude double precision) TO service_role;


--
-- Name: FUNCTION get_users(exclude_user uuid, target_college text, offset_value integer, page_limit integer); Type: ACL; Schema: prod; Owner: postgres
--

GRANT ALL ON FUNCTION prod.get_users(exclude_user uuid, target_college text, offset_value integer, page_limit integer) TO authenticated;
GRANT ALL ON FUNCTION prod.get_users(exclude_user uuid, target_college text, offset_value integer, page_limit integer) TO service_role;


--
-- Name: FUNCTION search_marketplace_items(search_query text, uid uuid, source_latitude double precision, source_longitude double precision, range_km double precision); Type: ACL; Schema: prod; Owner: postgres
--

GRANT ALL ON FUNCTION prod.search_marketplace_items(search_query text, uid uuid, source_latitude double precision, source_longitude double precision, range_km double precision) TO authenticated;
GRANT ALL ON FUNCTION prod.search_marketplace_items(search_query text, uid uuid, source_latitude double precision, source_longitude double precision, range_km double precision) TO service_role;


--
-- Name: TABLE apartment_likes; Type: ACL; Schema: prod; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE prod.apartment_likes TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE prod.apartment_likes TO service_role;


--
-- Name: SEQUENCE apartment_likes_id_seq; Type: ACL; Schema: prod; Owner: postgres
--

GRANT ALL ON SEQUENCE prod.apartment_likes_id_seq TO authenticated;
GRANT ALL ON SEQUENCE prod.apartment_likes_id_seq TO service_role;


--
-- Name: TABLE apartments; Type: ACL; Schema: prod; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE prod.apartments TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE prod.apartments TO service_role;


--
-- Name: TABLE marketplaces; Type: ACL; Schema: prod; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE prod.marketplaces TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE prod.marketplaces TO service_role;


--
-- Name: SEQUENCE market_place_id_seq; Type: ACL; Schema: prod; Owner: postgres
--

GRANT ALL ON SEQUENCE prod.market_place_id_seq TO authenticated;
GRANT ALL ON SEQUENCE prod.market_place_id_seq TO service_role;


--
-- Name: TABLE marketplaces_likes; Type: ACL; Schema: prod; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE prod.marketplaces_likes TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE prod.marketplaces_likes TO service_role;


--
-- Name: SEQUENCE marketplace_likes_id_seq; Type: ACL; Schema: prod; Owner: postgres
--

GRANT ALL ON SEQUENCE prod.marketplace_likes_id_seq TO authenticated;
GRANT ALL ON SEQUENCE prod.marketplace_likes_id_seq TO service_role;


--
-- Name: TABLE sublet_likes; Type: ACL; Schema: prod; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE prod.sublet_likes TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE prod.sublet_likes TO service_role;


--
-- Name: SEQUENCE sublet_likes_id_seq; Type: ACL; Schema: prod; Owner: postgres
--

GRANT ALL ON SEQUENCE prod.sublet_likes_id_seq TO authenticated;
GRANT ALL ON SEQUENCE prod.sublet_likes_id_seq TO service_role;


--
-- Name: TABLE sublets; Type: ACL; Schema: prod; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE prod.sublets TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE prod.sublets TO service_role;


--
-- Name: TABLE user_details; Type: ACL; Schema: prod; Owner: postgres
--

GRANT SELECT ON TABLE prod.user_details TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE prod.user_details TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE prod.user_details TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: prod; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA prod GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA prod GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA prod GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- PostgreSQL database dump complete
--

