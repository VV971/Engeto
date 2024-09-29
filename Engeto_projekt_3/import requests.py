import requests
from bs4 import BeautifulSoup

#Definuji funkci, která ze zadaného url získá kód a jméno města
def scraper_jmena_obci(url) -> list:
    """
    Funkce získá ze zadaného url získá kód (všechny prvky s třídou "cislo") a jméno města (všechny prvky s třídou "overflow_name").
    """
    odpoved = requests.get(url).text
    data = BeautifulSoup(odpoved, "html.parser")
    #Získávám kódy obcí
    kody_obci = [mesto.text for mesto in data.find_all("td", class_ = "cislo")]
    #Získávám názvy obcí
    jmena_obci = [mesto.text for mesto in data.find_all("td", class_ = "overflow_name")]
    #Vytvářím seznam s kódy a názvy obcí
    seznam_obci = [kody_obci, jmena_obci]
    #print(seznam_obci)
    return seznam_obci

#Definuji funkci, která vytvoří url pro všechny obce nalezené v okrese
def ziskej_url_obce(url: str) -> list[str]:
    """
    Funkce přijímá jako argument url pro okres a vytvoří seznam s url pro všechny obce nalezené v tomto okrese.
    """
    #Vytvářím neměnné jádro url
    jadro_url = "https://www.volby.cz/pls/ps2017nss/"
    #Definuji seznam tabulek, které obsahují řetězce s hlavičkami tabulek 
    tables = ["t1sa1 t1sb1", "t2sa1 t2sb1", "t3sa1 t3sb1"]
    #Získávám odpověď z webového serveru
    odpoved = requests.get(url).text
    #Parsuji odpověď
    data = BeautifulSoup(odpoved, "html.parser")
    url_obce = []
    for table in tables:
        #Hledám každou hodnotu td třídy "cislo" a hlavičku specifikovanou v seznamu tabulek
        for td in data.find_all("td", class_="cislo", headers = table):
            #Pro každý odpovídající prvek "td" hledám tag "a"
            a = td.find("a")
            if a:
                #Pokud tag "a" existuje, tak z jádra url a hodnoty href složím kompletní url pro danou obec
                url_obce.append(jadro_url + a["href"])
    #print(url_obce)
    #Vracím seznam s url pro všechny obce v okrese
    return url_obce

#Definuji funkci, která získá data o průběhu voleb v dané obci
def volby_v_obci_prehled(url_obce) -> list:
    """
    Funkce pomocí knihoven "requests" a "BeautifulSoup" najde z url pro danou obec všechny prvky s třídou "class"
    a hlavičkami "sa2" -> "Voliči v seznamu", "sa3" -> "Vydané obálky", "sa6" -> "Platné hlasy". Poté z dat pro 
    jednotlivé obce vytvoří tři seznamy ("volici_v_seznamu", "vydane_obalky", "platne_hlasy") a z nich nakonec 
    vytvoří jeden kompletní seznam "Data".
    """
    #Vytvářím prázdný seznam
    volici_v_seznamu = []
    for i in url_obce:
        odpoved = requests.get(i).text
        data = BeautifulSoup(odpoved, "html.parser")
        #Sbírám očištěná čísla po obcích
        volici = [j.text.replace("\xa0", "") for j in data.find_all("td", class_ = "cislo", headers = "sa2")]
        #Přidávám číslo za obec do seznamu voličů
        volici_v_seznamu.extend(volici)
    #Vytvářím prázdný seznam
    vydane_obalky = []
    for i in url_obce:
        odpoved = requests.get(i).text
        data = BeautifulSoup(odpoved, "html.parser")
        #Sbírám očištěná čísla po obcích
        obalky = [j.text.replace("\xa0", "") for j in data.find_all("td", class_ = "cislo", headers = "sa3")]
        #Přidávám číslo za obec do seznamu
        vydane_obalky.extend(obalky)
    #Vytvářím prázdný seznam
    platne_hlasy = []
    for i in url_obce:
        odpoved = requests.get(i).text
        data = BeautifulSoup(odpoved, "html.parser")
        #Sbírám očištěná čísla po obcích
        hlasy = [j.text.replace("\xa0", "") for j in data.find_all("td", class_="cislo", headers="sa6")]
        #Přidávám číslo za obec do seznamu
        platne_hlasy.extend(hlasy)
    #Vytvářím kompletní seznam
    Data = [volici_v_seznamu, vydane_obalky, platne_hlasy]
    #print(Data)
    return Data

#Definuji funkci, která získá jména politických stran, jejichž kandidáti se účastnili voleb
def politicke_strany(url_obce: list) -> list[str]:
    """
    Funkce pomocí knihoven "requests" a "BeautifulSoup" najde z url pro danou obec všechny prvky s třídou "overflow_name"
    a hlavičkami "t1sa1 t1sb2" a "t2sa1 t2sb2" a poté data uloží do seznamu "politicke_strany".
    """
    #Vytvářím prázdný seznam
    politicke_strany = []
    odpoved = requests.get(url_obce[0]).text
    data = BeautifulSoup(odpoved, "html.parser")
    #První tabulka
    table1 = [j.text.replace("\xa0", "") for j in data.find_all("td", class_ = "overflow_name", headers = "t1sa1 t1sb2")]
    #Druhá tabulka
    table2 = [j.text.replace("\xa0", "") for j in data.find_all("td", class_="overflow_name", headers="t2sa1 t2sb2")]
    #Slučuji tabulky
    politicke_strany.extend(table1 + table2)
    #print(politicke_strany)
    return politicke_strany


def get_votes(city_url: list) -> list:
    """This function performs following tasks:
    1) The function finds for each city url all elements with the class "cislo"
    and headers "t1sa2 t1sb3" and "t2sa2 t2sb3" representing votes each political party received in the particular city.
    2) The vote counts are collected in a list `total_votes` for each city in the selected district.

    :return: list of vote counts"""
    total_votes = []
    for i in city_url:
        response_2 = requests.get(i)
        doc_2 = BeautifulSoup(response_2.text, "html.parser")
        table1 = [
            j.text.replace("\xa0", "")
            for j in doc_2.find_all("td", class_="cislo", headers="t1sa2 t1sb3")
        ]
        table2 = [
            j.text.replace("\xa0", "")
            for j in doc_2.find_all("td", class_="cislo", headers="t2sa2 t2sb3")
        ]
        total_votes.append(table1 + table2)
    return total_votes

url = 'https://www.volby.cz/pls/ps2017nss/ps32?xjazyk=CZ&xkraj=6&xnumnuts=4204'

city_list = scraper_jmena_obci(url)
url_obce = ziskej_url_obce(url)
volby_v_obci_prehled(url_obce)
politicke_strany(url_obce)
