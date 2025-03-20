CREATE OR REPLACE FUNCTION get_nearby_sublets(
    uid UUID,
    range_km DOUBLE PRECISION DEFAULT 100,
    offset_value INTEGER DEFAULT 0,
    page_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
    sublet_id BIGINT,
    room_description TEXT,
    roommate_description TEXT,
    roommate_gender_pref TEXT,
    rent REAL,
    photos JSON,
    amenities_available JSON,
    room_type TEXT,
    is_available BOOLEAN,
    user_id UUID,
    start_date BIGINT,
    end_date BIGINT,
    beds SMALLINT,
    baths SMALLINT,
    created_at TIMESTAMP WITH TIME ZONE,
    address TEXT,
    distance_m DOUBLE PRECISION
) AS $$
DECLARE
    university_location gis.geography;
BEGIN
    -- Get the university location for the given user_id
    SELECT u.location INTO university_location
    FROM public.user_details AS ud
    INNER JOIN const.universities AS u ON ud.college = u.title
    WHERE ud.id = uid;

    -- Return nearby sublets based on the university location with pagination and distance
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
        gis.ST_Distance(s.location::gis.geography, university_location) AS distance_m
    FROM public.sublets AS s
    WHERE gis.ST_DWithin(s.location::gis.geography, university_location, range_km * 1000) -- Convert km to meters
    ORDER BY distance_m
    OFFSET offset_value LIMIT page_limit;
END;
$$ LANGUAGE plpgsql;

-- Example usage
SELECT * FROM get_nearby_sublets('25f247de-78b8-4ebc-91ac-1451302dc9ff', 1000);
SELECT * FROM get_nearby_sublets(
    '25f247de-78b8-4ebc-91ac-1451302dc9ff', 
    1000000, 
    0, 
    10, 
    -74.01069425046444,
     40.64151070303465
);

CREATE OR REPLACE FUNCTION get_nearby_apartments(
    uid UUID,
    range_km DOUBLE PRECISION DEFAULT 100,
    offset_value INTEGER DEFAULT 0,
    page_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
    id BIGINT,
    apartment_description TEXT,
    rent REAL,
    photos JSON,
    amenities_available JSON,
    is_available BOOLEAN,
    user_id UUID,
    start_date BIGINT,
    end_date BIGINT,
    beds SMALLINT,
    baths SMALLINT,
    created_at TIMESTAMP WITH TIME ZONE,
    address TEXT,
    distance_m DOUBLE PRECISION
) AS $$
DECLARE
    university_location gis.geography;
BEGIN
    -- Get the university location for the given user_id
    SELECT u.location INTO university_location
    FROM public.user_details AS ud
    INNER JOIN const.universities AS u ON ud.college = u.title
    WHERE ud.id = uid;

    -- Return nearby apartments based on the university location with pagination and distance
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
        gis.ST_Distance(a.location::gis.geography, university_location) AS distance_m
    FROM public.apartments AS a
    WHERE gis.ST_DWithin(a.location::gis.geography, university_location, range_km * 1000)
    ORDER BY distance_m
    OFFSET offset_value LIMIT page_limit;
END;
$$ LANGUAGE plpgsql;

-- Example usage
SELECT * FROM get_nearby_apartments('25f247de-78b8-4ebc-91ac-1451302dc9ff', 1000);


CREATE OR REPLACE FUNCTION get_nearby_marketplaces(
    uid UUID,
    range_km DOUBLE PRECISION DEFAULT 100,
    offset_value INTEGER DEFAULT 0,
    page_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
    id BIGINT,
    name TEXT,
    category JSON,
    description TEXT,
    price INTEGER,
    photos JSON,
    link JSON,
    period JSON,
    is_available BOOLEAN,
    user_id UUID,
    created_at BIGINT,
    address TEXT,
    distance_m DOUBLE PRECISION
) AS $$
DECLARE
    university_location gis.geography;
BEGIN
    -- Get the university location for the given user_id
    SELECT u.location INTO university_location
    FROM public.user_details AS ud
    INNER JOIN const.universities AS u ON ud.college = u.title
    WHERE ud.id = uid;

    -- Return nearby marketplaces based on the university location with pagination and distance
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
        gis.ST_Distance(m.location::gis.geography, university_location) AS distance_m
    FROM public.marketplaces AS m
    WHERE gis.ST_DWithin(m.location::gis.geography, university_location, range_km * 1000)
    ORDER BY distance_m
    OFFSET offset_value LIMIT page_limit;
END;
$$ LANGUAGE plpgsql;

-- Example usage
SELECT * FROM get_nearby_marketplaces('25f247de-78b8-4ebc-91ac-1451302dc9ff', 1000);


CREATE OR REPLACE FUNCTION get_users(
    exclude_user UUID,
    target_college TEXT,
    offset_value INTEGER DEFAULT 0,
    page_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
    id UUID,
    full_name TEXT,
    profile_image TEXT,
    selected_course_name TEXT,
    college TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    work_experience SMALLINT,
    intake_period TEXT,
    intake_year SMALLINT,
    has_roommate_found BOOLEAN
) AS $$
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
        FROM public.user_details u
        WHERE u.college = target_college
        AND u.id != exclude_user
        ORDER BY u.intake_year DESC, u.intake_period DESC
        LIMIT page_limit OFFSET offset_value * page_limit
    )
    UNION ALL
    (
        -- Get users from other colleges after the same college users are exhausted, excluding the specified user
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
        FROM public.user_details u
        WHERE u.college != target_college
        AND u.id != exclude_user
        ORDER BY u.intake_year DESC, u.intake_period DESC
        LIMIT page_limit OFFSET offset_value * page_limit
    );
END;
$$ LANGUAGE plpgsql;

-- Example usage
SELECT * FROM get_users('25f247de-78b8-4ebc-91ac-1451302dc9ff', 'New York University (NYU)');







CREATE OR REPLACE FUNCTION get_nearby_apartments(
    uid UUID,
    range_km DOUBLE PRECISION DEFAULT 100,
    offset_value INTEGER DEFAULT 0,
    page_limit INTEGER DEFAULT 10,
    source_latitude DOUBLE PRECISION DEFAULT 100,
    source_longitude DOUBLE PRECISION DEFAULT 100
)
RETURNS TABLE(
    id BIGINT,
    apartment_description TEXT,
    rent REAL,
    photos JSON,
    amenities_available JSON,
    is_available BOOLEAN,
    user_id UUID,
    start_date BIGINT,
    end_date BIGINT,
    beds SMALLINT,
    baths SMALLINT,
    created_at TIMESTAMP WITH TIME ZONE,
    address TEXT,
    distance_m DOUBLE PRECISION,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    location gis.geometry
) AS $$
DECLARE
    university_location gis.geometry;
    search_location gis.geometry;
BEGIN
    -- If source_latitude and source_longitude are provided, convert them to gis.geometry
    IF source_latitude IS NOT NULL AND source_longitude IS NOT NULL THEN
        search_location := gis.ST_SetSRID(gis.ST_MakePoint(source_longitude, source_latitude), 4326);
    ELSE
        -- Otherwise, get the university location for the given user_id
        SELECT u.location INTO university_location
        FROM public.user_details AS ud
        INNER JOIN const.universities AS u ON ud.college = u.title
        WHERE ud.id = uid;
        search_location := university_location;
    END IF;

    -- Return nearby apartments based on the search location with pagination and distance
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
        a.location::gis.geometry
        gis.ST_Distance(a.location::gis.geometry, search_location) AS distance_m,
        gis.ST_Y(a.location::gis.geometry) AS latitude, -- Extract latitude
        gis.ST_X(a.location::gis.geometry) AS longitude, -- Extract longitude
    FROM public.apartments AS a
    WHERE gis.ST_DWithin(a.location::gis.geometry, search_location, range_km * 1000) -- Convert km to meters
    ORDER BY distance_m
    OFFSET offset_value LIMIT page_limit;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_nearby_apartments('25f247de-78b8-4ebc-91ac-1451302dc9ff', 5, 0, 10,-74.01069425046444, 40.64151070303465);


CREATE OR REPLACE FUNCTION get_nearby_apartments(
    uid UUID,
    range_km DOUBLE PRECISION DEFAULT 100,
    offset_value INTEGER DEFAULT 0,
    page_limit INTEGER DEFAULT 10,
    source_latitude DOUBLE PRECISION DEFAULT 100,
    source_longitude DOUBLE PRECISION DEFAULT 100
)
RETURNS TABLE(
    id BIGINT,
    apartment_description TEXT,
    rent REAL,
    photos JSON,
    amenities_available JSON,
    is_available BOOLEAN,
    user_id UUID,
    start_date BIGINT,
    end_date BIGINT,
    beds SMALLINT,
    baths SMALLINT,
    created_at TIMESTAMP WITH TIME ZONE,
    address TEXT,
    distance_m DOUBLE PRECISION,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    location gis.geometry
) AS $$
DECLARE
    search_location gis.geography;
BEGIN
    -- If source_latitude and source_longitude are provided, convert them to gis.geography
    IF source_latitude IS NOT NULL AND source_longitude IS NOT NULL THEN
        search_location := gis.ST_SetSRID(gis.ST_MakePoint(source_longitude, source_latitude), 4326);
    ELSE
        -- Otherwise, get the university location for the given user_id
        SELECT u.location INTO search_location
        FROM public.user_details AS ud
        INNER JOIN const.universities AS u ON ud.college = u.title
        WHERE ud.id = uid;
    END IF;

    -- Return nearby sublets based on the search location with pagination and distance
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
        gis.ST_Distance(a.location::gis.geography, search_location) AS distance_m,
        gis.ST_Y(a.location::gis.geometry) AS latitude, -- Extract latitude
        gis.ST_X(a.location::gis.geometry) AS longitude, -- Extract longitude
        a.location::gis.geometry
    FROM public.apartments AS a
    WHERE gis.ST_DWithin(a.location::gis.geography, search_location, range_km * 1000) -- Convert km to meters
    ORDER BY distance_m
    OFFSET offset_value LIMIT page_limit;
END;
$$ LANGUAGE plpgsql;