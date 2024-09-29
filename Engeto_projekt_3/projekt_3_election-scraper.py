"""
projekt_3_election-scraper.py: třetí projekt do Engeto Online Python Akademie

author: Vít Vogner
email: vit.vogner@gmx.com
discord: jovial_otter_10639
"""

import requests
import pandas 
from bs4 import BeautifulSoup as bs

url = 'https://www.volby.cz/pls/ps2017nss/ps32?xjazyk=CZ&xkraj=7&xnumnuts=5103'

odpoved_serveru = requests.get(url)
rozdelene_html = bs(odpoved_serveru.content, features = "html.parser")

table = bs.find("table", {"class" : "table"})

print(table.prettify())


