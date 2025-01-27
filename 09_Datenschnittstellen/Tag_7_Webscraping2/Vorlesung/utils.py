import os
import bs4
import requests
from bs4 import BeautifulSoup

BASE_URL = 'https://www.gedichte7.de/'


def get_poet_name() -> str:
    poet_name = input('Bitte Dichter eingeben: ').lower()
    return poet_name


def turn_poet_to_ressource(poet_name: str) -> str:
    to_replace = [' ', 'ä', 'ö', 'ü']
    replace_with = ['-', 'ae', 'oe', 'ue']
    for tup in zip(to_replace, replace_with):
        # tup[0] > ursprüngliches Zeichen, tup[1] Zeichen nach Ersetzung
        # named tuple Stelle...
        poet_name = poet_name.replace(tup[0], tup[1])
    return poet_name


def create_url(base: str, poet_path: str) -> str:
    return base + poet_path + '.html'


def request_url(url: str) -> requests.Response:
    try:
        response = requests.get(url)
        return response
    except requests.exceptions.RequestException as e:
        print('Request Exception:', e)
    except UnicodeEncodeError as e:
        print('Encoding Error:', e)


def encode_and_turn_to_text(page: requests.Response) -> str:
    page.encoding = 'utf-8'
    return page.text


def cook_soup_from_string(text: str) -> bs4.BeautifulSoup:
    return BeautifulSoup(text, 'html.parser')


def get_famous_poems_links(soup: bs4.BeautifulSoup, base_url: str) -> list:
    anchors = soup.find(id='content').find('ul').find_all('a')
    famous_links = [base_url + anchor['href'] for anchor in anchors]
    return famous_links


def replace_brs_with_newlines(poem: bs4.BeautifulSoup) -> bs4.BeautifulSoup:
    for br in poem.find_all('br'):
        br.replace_with('\n')
    return poem


def scrape_poem(processed_poem: bs4.BeautifulSoup):
    title = processed_poem.find('h1').text + 3 * '\n'
    paragraphs = processed_poem.find('div', class_='poems-container').find_all('p')
    poem = [p.text + '\n\n' for p in paragraphs]
    poem.insert(0, title)
    return poem


def create_author_folder(author_name: str):
    if os.path.isdir(author_name):
        print('Author folder already exists. Please delete to scrape again!')
        quit()
    os.mkdir(author_name)
    print(f'Folder {author_name} successfully created!')


def generate_filename(processed_poem: bs4.BeautifulSoup, author_folder: str):
    processed_title = processed_poem.find('h1').text.lower()
    processed_title = processed_title.replace(' ', '-')
    return os.path.join(author_folder, processed_title + '.txt')


def write_poem(filepath: str, poem: list) -> None:
    with open(filepath, 'w', encoding='utf-8') as file:
        file.writelines(poem)
        print(f'Written successfully: {filepath}')