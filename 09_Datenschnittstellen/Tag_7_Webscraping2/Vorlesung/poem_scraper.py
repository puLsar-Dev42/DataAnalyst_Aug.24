import requests
from bs4 import BeautifulSoup
import time
import random

# Aufgabe: Alle berühmten Gedichte von Gryphius scrapen

base = 'https://www.gedichte7.de/'
dichter_url = 'https://www.gedichte7.de/andreas-gryphius.html'
response = requests.get(dichter_url)
response.encoding = 'utf-8'

response.text.replace('<br/>', '\n')

soup = BeautifulSoup(response.text, 'html.parser')

content = soup.find('div', id='content')

famous = content.find('ul').find_all('a')

sub_links = [link.get('href') for link in famous]

complete_links = [base + sub for sub in sub_links]

for i, link in enumerate(complete_links):
    try:
        print('Getting:', link)
        time.sleep(random.uniform(1, 3))
        r = requests.get(link)
        r.encoding = 'utf-8'
        soup = BeautifulSoup(r.text, 'html.parser')

        title = soup.find('h1').text + 3*'\n'

        for br in soup.find_all("br"):
            br.replace_with("\n")

        all_paragraphs = soup.find('div', class_='poems-container') \
                             .find_all('p')

        poem = [p.text + '\n\n' for p in all_paragraphs]
        poem.insert(0, title)

        with open(sub_links[i] + '.txt', 'w') as f:
            f.writelines(poem)

    except UnicodeEncodeError as e:
        print('Encoding Error with:', link)
        print(e)

print('Dude, ich bin durch!')
