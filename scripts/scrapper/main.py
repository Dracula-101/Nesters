# -*- coding: utf-8 -*-
"""
Created on Sun Jul 12 11:02:06 2020

@author: OHyic

"""
# Import libraries
import os
import concurrent.futures
import sys
from GoogleImageScraper import GoogleImageScraper
from patch import webdriver_executable


def worker_thread(search_key):
    image_scraper = GoogleImageScraper(
        webdriver_path,
        image_path,
        search_key,
        number_of_images,
        headless,
        min_resolution,
        max_resolution,
        max_missed,
    )
    image_urls = image_scraper.find_image_urls()
    image_scraper.save_images(image_urls, keep_filenames)

    # Release resources
    del image_scraper


if __name__ == "__main__":
    # Define file path
    webdriver_path = os.path.normpath(
        os.path.join(os.getcwd(), "webdriver", webdriver_executable())
    )
    image_path = os.path.normpath(os.path.join(os.getcwd(), "photos"))

    # get from args
    search_keys = sys.argv[2:]
    # check if search_keys is empty
    if len(search_keys) == 0:
        exit(
            "[INFO] No search keys found. Usage: python main.py <num_images> <search_key1> <search_key2> ..."
        )
    # Parameters
    number_of_images = int(sys.argv[1])  # Number of images to scrape
    headless = True  # True = No Chrome GUI
    min_resolution = (0, 0)  # Minimum desired image resolution
    max_resolution = (1920, 1080)  # Maximum desired image resolution
    max_missed = 100  # Max number of failed images before exit
    number_of_workers = min(len(search_keys), 5)  # Number of "workers" used
    keep_filenames = False  # Keep original URL image filenames

    # Run each search_key in a separate thread
    # Automatically waits for all threads to finish
    # Removes duplicate strings from search_keys
    with concurrent.futures.ThreadPoolExecutor(
        max_workers=number_of_workers
    ) as executor:
        executor.map(worker_thread, search_keys)
