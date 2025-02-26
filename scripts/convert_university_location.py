import pandas as pd
from geopy.geocoders import Nominatim
from geopy.extra.rate_limiter import RateLimiter

# Load the CSV file
input_file = "universities.csv"  # Replace with your CSV file path
df = pd.read_csv(input_file)

# Initialize the geocoder
geolocator = Nominatim(user_agent="university_locator")
geocode = RateLimiter(
    geolocator.geocode, min_delay_seconds=2, error_wait_seconds=5, max_retries=5
)  # Add delay to avoid overloading the service


# Function to get latitude and longitude
def get_lat_lon(university_name):
    try:
        location = geocode(university_name)
        if location:
            return location.latitude, location.longitude
        else:
            return None, None
    except Exception as e:
        print(f"Error fetching data for {university_name}")
        return None, None


# Add new columns for latitude and longitude
df["Latitude"] = None
df["Longitude"] = None

# Loop through the universities and fetch coordinates
for index, row in df.iterrows():
    university_name = row["title"]  # Replace "University" with your column name
    lat, lon = get_lat_lon(university_name)
    df.at[index, "Location"] = f"POINT({lat} {lon})"
    print(f"Processed: {university_name} -> Latitude: {lat}, Longitude: {lon}")

# Save the updated DataFrame back to the CSV file
df.to_csv(input_file, index=False)
print(f"Data saved to {input_file}")
