import requests
from bs4 import BeautifulSoup

BASE_URL = 'https://www.gedichte7.de/'

poet_site = 'https://www.gedichte7.de/stefan-george.html'
response = requests.get(poet_site)
response.encoding = 'utf-8'

soup = BeautifulSoup(response.text, 'html.parser')

content = soup.find(id='content')
famous_anchors = content.find('ul').find_all('a')

sub_links = [anchor.get('href') for anchor in famous_anchors]

# Das sind die Links zu den jeweiligen Gedichten:
full_links = [BASE_URL + sub_link for sub_link in sub_links]

# Das eigentliche Scrapen der Gedichte findet hier statt:
for i, link in enumerate(full_links):
    print('\n\n')
    print('Getting:', link)
    response = requests.get(link)
    response.encoding = 'utf-8'
    soup = BeautifulSoup(response.text, 'html.parser')
    poem_title = soup.find('h1').text
    print(poem_title)
    poem_body = soup.find(class_='poems-container')
    for br in poem_body.find_all('br'):
        br.replace_with('\n')

    print(poem_body.text)
