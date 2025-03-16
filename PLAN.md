# Sublet Form: Address Handling and Filtering Update  

## User Side (Supabase)

- University Table
  - Add location field
  - Remove score and rank_display columns
  - Foreign key to user_details

- User Table
  - Add college_location field
  - Add foreign key to university table

- Extensions
  - Add PostGIS extension to the database

- Add RPC to supabase
  Use the user college location (inner join from user_details and universities) to filter from the location of the sublet, apartment, and marketplace
  - `nearby_sublets` with pagination
  - `nearby_apartments` with pagination
  - `nearby_marketplaces` with pagination


## Marketplace / Apartment / Sublet

### Form

- Update the location field to show dialog for address
- The address comes from Google Places API
- Store the lat lng in the database

### User side
- Filter by location, default taken from user college location (10km radius)
- Show Alternative sublets if not available in your area (Api will be called when no items are found from the previous call) (pagination will be difficult)

## User Creation Page

  - Add location field to the user creation form
  - Convert to lat lng and store in the database

CREATE OR REPLACE FUNCTION get_nearby_sublets(
    user_id uuid, 
    range_km double precision DEFAULT 100, 
    offset_value integer DEFAULT 0, 
    page_limit integer DEFAULT 10
)
RETURNS TABLE(sublet_id bigint, sublet_details jsonb, distance_m double precision) AS
$$
DECLARE
    university_location gis.geography;
BEGIN
    -- Get the university location for the given user_id
    SELECT u.location INTO university_location
    FROM public.user_details AS ud
    INNER JOIN const.universities AS u ON ud.college = u.title
    WHERE ud.id = user_id;

    -- Return nearby sublets based on the university location with pagination and distance
    RETURN QUERY
    SELECT 
        s.id AS sublet_id, 
        s.details AS sublet_details,
        ST_Distance(s.location::geography, university_location) AS distance_m
    FROM public.sublets AS s
    WHERE ST_DWithin(s.location::geography, university_location, range_km * 1000) -- Convert km to meters
    ORDER BY distance_m -- Order by distance
    OFFSET offset_value LIMIT page_limit; -- Apply pagination
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_nearby_sublets(
    uid uuid, 
    range_km double precision DEFAULT 100, 
    offset_value integer DEFAULT 0, 
    page_limit integer DEFAULT 10
)
RETURNS TABLE(
    sublet_id bigint, 
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
    created_at timestamp with time zone, 
    address text, 
    distance_m double precision
) AS
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

<!-- //deepseek -->
CREATE OR REPLACE FUNCTION nearby_sublets(
  user_lat float,
  user_long float,
  max_distance float
)
RETURNS TABLE (
  id bigint,
  room_description text,
  rent real,
  address text,
  distance_meters float
)
LANGUAGE sql
AS $$
  SELECT
    id,
    room_description,
    rent,
    address,
    ST_Distance(location::geography, ST_SetSRID(ST_MakePoint(user_long, user_lat), 4326) AS distance_meters
  FROM public.sublets
  WHERE ST_DWithin(location::geography, ST_SetSRID(ST_MakePoint(user_long, user_lat), 4326), max_distance)
  ORDER BY distance_meters ASC;
$$;



@override
Future<List<SubletModel>> getSublets({
  required String userId,
  required double userLat,
  required double userLong,
  int range = 10,
  int paginationKey = 0,
  double maxDistance = 10000, // 10 km in meters
}) async {
  try {
    final response = await _supabaseClient
        .rpc('get_nearby_sublets', params: {
          'user_id': userId, // Pass the user_id to find the university location
          'range_km': maxDistance / 1000, // Convert meters to kilometers
          'offset_value': paginationKey,
          'page_limit': range,
        })
        .neq("user_id", userId) // Exclude sublets owned by the current user
        .eq("is_available", true); // Only fetch available sublets

    return response.map((e) => SubletModel.fromMap(e)).toList();
  } on supabase.PostgrestException catch (e) {
    throw SubletErrorFactory.createSubletError(
      SubletErrorCode.DB_ERR,
      '${e.details}, ${e.message}, ${e.hint}',
    );
  } on SocketException catch (_) {
    throw NoNetworkError();
  } catch (e) {
    if (e is Exception) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.GET_SUBLETS_ERR,
        e.getException,
      );
    } else {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.GET_SUBLETS_ERR,
        e.toString(),
      );
    }
  }
}


class SubletModel {
  // Existing fields...
  double? distanceMeters;

  SubletModel({
    // Existing fields...
    this.distanceMeters,
  });

  factory SubletModel.fromMap(Map<String, dynamic> map) {
    return SubletModel(
      // Existing fields...
      distanceMeters: map['distance_m']?.toDouble(), // Map the distance field
    );
  }
}

INSERT INTO public.sublets (id, details, location, is_available)
VALUES (
  1,
  '{"description": "Cozy apartment near campus"}',
  ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326), -- Longitude, Latitude
  true
);


0101000020E61000001FF64201DB7B52C0B610E4A0845D4440