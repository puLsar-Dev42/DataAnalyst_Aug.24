import requests
from bs4 import BeautifulSoup
import time
import random

from utils import BASE_URL, get_poet_name, turn_poet_to_ressource, create_url, \
    request_url, encode_and_turn_to_text, cook_soup_from_string, get_famous_poems_links, \
    replace_brs_with_newlines, scrape_poem, generate_filename, create_author_folder, \
    write_poem

# 1. Generating Author URL:
poet_name = get_poet_name()
poet_path = turn_poet_to_ressource(poet_name)

poet_url = create_url(BASE_URL, poet_path)

# 2. Getting Author site (if possible) into Beautifulsoup and links to famous poems:
poet_site = request_url(poet_url)
if not poet_site:
    print('Could not get that author. Please check the spelling.')
    exit()

# 3. Creating a folder for scraped contents:
create_author_folder(poet_path)

# 4. Getting links to famous poems from author site:
poet_site = encode_and_turn_to_text(poet_site)
soup = cook_soup_from_string(poet_site)
famous_links = get_famous_poems_links(soup, BASE_URL)

# 5. Scraping the contents via for loop:
for i, link in enumerate(famous_links):
    try:
        response = request_url(link)
        if not response:
            print('Could not get:', link)
            continue
        poem_site = encode_and_turn_to_text(response)
        soup = cook_soup_from_string(poem_site)

        processed_site = replace_brs_with_newlines(soup)
        poem = scrape_poem(processed_site)
        filename = generate_filename(processed_site, poet_path)
        write_poem(filename, poem)

    # Simple Error handling:
    except UnicodeEncodeError as e:
        print('Encoding Error with:', link)
        print(e)
    except requests.exceptions.HTTPError as err:
        print(f'HTTP error occurred: {err}')
    except requests.exceptions.Timeout:
        print('The request timed out.')
    except requests.exceptions.RequestException as err:
        print(f'Error occurred: {err}')

print('Thank you for using the poem scraper!')


# Todo:
# Separate utily.py into several modules like
# url_utils.py
# text_utils.py
# scraper_utils.py
# file_utils.py
