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

