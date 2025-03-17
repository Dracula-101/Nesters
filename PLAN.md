CREATE OR REPLACE FUNCTION get_nearby_sublets(
uid uuid,
range_km double precision DEFAULT 100,
offset_value integer DEFAULT 0,
page_limit integer DEFAULT 10
)
RETURNS TABLE( sublet_id bigint, room_description text, roommate_description text, roommate_gender_pref text, rent real, photos json, amenities_available json, room_type text, is_available boolean, user_id uuid, start_date bigint, end_date bigint, beds smallint, baths smallint, created_at timestamp with time zone, address text, distance_m double precision ) AS

$$
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
        s.room_description,s.roommate_description, s.roommate_gender_pref, s.rent, s.photos, s.amenities_available,
        s.room_type, s.is_available, s.user_id, s.start_date, s.end_date, s.beds, s.baths, s.created_at, s.address,
        gis.ST_Distance(s.location::gis.geography, university_location) AS distance_m
    FROM public.sublets AS s
    WHERE gis.ST_DWithin(s.location::gis.geography, university_location, range_km * 1000) -- Convert km to meters
    ORDER BY distance_m -- Order by distance
    OFFSET offset_value LIMIT page_limit; -- Apply pagination
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_nearby_sublets('25f247de-78b8-4ebc-91ac-1451302dc9ff', 1000);



CREATE OR REPLACE FUNCTION get_nearby_apartments(
    uid uuid,
    range_km double precision DEFAULT 100,
    offset_value integer DEFAULT 0,
    page_limit integer DEFAULT 10
)
RETURNS TABLE(id bigint, apartment_description text, rent real, photos json, amenities_available json, is_available boolean, user_id uuid, start_date bigint, end_date bigint, beds smallint, baths smallint, created_at timestamp with time zone, address text, distance_m double precision) AS
$$

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
        a.id AS id,
        a.apartment_description, a.rent, a.photos, a.amenities_available,
        a.is_available, a.user_id, a.start_date, a.end_date, a.beds, a.baths, a.created_at, a.address,
        gis.ST_Distance(a.location::gis.geography, university_location) AS distance_m
    FROM public.apartments AS a
    WHERE gis.ST_DWithin(a.location::gis.geography, university_location, range_km * 1000) -- Convert km to meters
    ORDER BY distance_m -- Order by distance
    OFFSET offset_value LIMIT page_limit; -- Apply pagination

END;

$$
LANGUAGE plpgsql;

SELECT * FROM get_nearby_apartments('25f247de-78b8-4ebc-91ac-1451302dc9ff', 1000);
$$
