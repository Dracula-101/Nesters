import json
import os
import cloudinary
import cloudinary.uploader
from concurrent.futures import ThreadPoolExecutor, as_completed
import sys
from dotenv import load_dotenv

load_dotenv()


def read_from_json(file_path: str) -> dict:
    if not file_path.endswith(".json"):
        raise ValueError("File must be a JSON file")
    if os.path.exists(file_path) is False:
        raise FileNotFoundError("File not found")
    with open(file_path, "r") as file:
        return json.load(file)


def title_case(s: str) -> str:
    return s.title()


config = read_from_json("config.json")
scrapping_allowed = config['scrapping_allowed']
scrap_room_images = config["seed_sublets"] or config["seed_apartments"]
scrap_marketplace_images = config["seed_marketplaces"]

room_images = [title_case(image) for image in config["room_images"]]
marketplace_images = [title_case(image) for image in config["marketplace_items"]]
room_images_len = 5
marketplace_images_len = 20

# activate the env for python for scrapper
try:
    os.chdir("scrapper")
    if os.path.exists("env") is False:
        print("Creating virtual environment for scrapper")
        os.system("python3 -m venv env")
    print("Installing requirements for scrapper")
    pip_path = "env\\Scripts\\pip.exe" if os.name == "nt" else "env/bin/pip"
    os.system("{} install -r requirements.txt".format(pip_path))
except Exception as e:
    print(e)

python_path = "env\\Scripts\\python.exe" if os.name == "nt" else "env/bin/python"
try:
    if scrap_room_images:
        print(
            "{} main.py {} {}".format(
                python_path, room_images_len, " ".join(room_images)
            )
        )
        os.system(
            "{} main.py {} {}".format(
                python_path, room_images_len, " ".join(room_images)
            )
        )
    else:
        print("Skipping room images scrapping")
except Exception as e:
    print(e)


try:
    if scrap_marketplace_images:
        print("Scrapping for marketplace images")
        os.system(
            "{} main.py {} {}".format(
                python_path, marketplace_images_len, " ".join(marketplace_images)
            )
        )
    else:
        print("Skipping marketplace images scrapping")
except Exception as e:
    print(e)

os.chdir("..")

# Configure Cloudinary with your credentials
cloudinary.config(
    cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
    api_key=os.getenv("CLOUDINARY_API_KEY"),
    api_secret=os.getenv("CLOUDINARY_API_SECRET"),
)

# Global flag to track API rate limits
API_LIMIT_EXCEEDED = False


def upload_image_to_cloudinary(image_path, folder_name):
    """
    Uploads an image to Cloudinary and returns the generated URL.

    :param image_path: Path to the image file to upload.
    :param folder_name: Name of the folder in Cloudinary to store the image.
    :return: Tuple of (image_path, image_url) or (image_path, None) if upload fails.
    """
    global API_LIMIT_EXCEEDED
    try:
        # Upload the image to Cloudinary
        response = cloudinary.uploader.upload(image_path, folder=folder_name)

        # Check if the API limit is exceeded
        if response.get("rate_limit_remaining", 1) <= 0:
            API_LIMIT_EXCEEDED = True
            print("API rate limit exceeded. Exiting program.")
            return (image_path, None)

        # Extract the URL from the response
        image_url = response["secure_url"]
        print(f"Uploaded {folder_name}")
        return (image_path, image_url)
    except Exception as e:
        print(f"Error uploading {image_path}: {e}")
        return (image_path, None)


def save_urls_to_file(image_urls, output_file):
    """
    Saves the generated image URLs to a file.

    :param image_urls: List of tuples containing (image_path, image_url).
    :param output_file: Path to the file where the URLs will be stored.
    """
    try:
        if not os.path.exists(output_file):
            os.makedirs(os.path.dirname(output_file), exist_ok=True)
        with open(output_file, "a") as file:
            for image_path, image_url in image_urls:
                if image_url:
                    file.write(f"{image_url}\n")
        print(f"URLs saved to {output_file}")
    except Exception as e:
        print(f"Error saving URLs to file: {e}")


def upload_folder(folder_name, image_dir, output_file):
    # Get a list of all image files in the directory
    image_paths = [
        os.path.join(image_dir, f)
        for f in os.listdir(image_dir)
        if f.endswith((".jpg", ".png", ".jpeg"))
    ]

    # Use ThreadPoolExecutor for parallel uploads
    with ThreadPoolExecutor(max_workers=10) as executor:  # Adjust max_workers as needed
        futures = [
            executor.submit(upload_image_to_cloudinary, image_path, folder_name)
            for image_path in image_paths
        ]

        # Collect results as they complete
        image_urls = []
        for future in as_completed(futures):
            result = future.result()
            if result[1]:  # If URL is not None
                image_urls.append(result)

            # Exit if API limit is exceeded
            if API_LIMIT_EXCEEDED:
                print("API limit exceeded. Exiting program.")
                sys.exit(1)

    # Save the URLs to the output file
    save_urls_to_file(image_urls, output_file)

if scrapping_allowed:
    room_images_dir = []
    for image in room_images:
        dir = f"scrapper/photos/{title_case(image)}"
        if os.path.exists(dir):
            room_images_dir.append(dir)

    marketplace_images_dir = []
    for image in marketplace_images:
        dir = f"scrapper/photos/{title_case(image)}"
        if os.path.exists(dir):
            marketplace_images_dir.append(dir)


    # upload room photos to cloudinary
    for dir in room_images_dir:
        room_type = str(dir).split("/")[-1].lower().replace(" ", "_")
        file_name = f"seed/data/room_photos/{room_type}_urls.txt"
        print(f"Uploading {room_type} and saving to {file_name}")
        upload_folder(f"room_images/{room_type}", dir, file_name)

    # upload marketplace photos to cloudinary
    for dir in marketplace_images_dir:
        marketplace_item = str(dir).split("/")[-1].lower().replace(" ", "_")
        file_name = f"seed/data/marketplace_photos/{marketplace_item}_urls.txt"
        print(f"Uploading {marketplace_item} and saving to {file_name}")
        upload_folder(f"marketplace_items_images/{marketplace_item}", dir, file_name)

    print(os.getcwd())

os.chdir("seed")
if os.path.exists("node_modules") is False:
    print("Installing node modules")
    os.system("npm install")
os.system("node index.js")

if scrapping_allowed:
    try:
        os.remove("data/room_photos")
        os.remove("data/marketplace_photos")
    except Exception as e:
        print(e)
    print("Seed data generated successfully")
