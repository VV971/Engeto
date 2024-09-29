import requests
from bs4 import BeautifulSoup
import os
import csv

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
def seznam_politickych_stran(url_obce: list) -> list[str]:
    """
    Funkce pomocí knihoven "requests" a "BeautifulSoup" najde z url pro danou obec všechny prvky s třídou "overflow_name"
    a hlavičkami "t1sa1 t1sb2" a "t2sa1 t2sb2" a poté data uloží do seznamu "politicke_strany".
    """
    #Vytvářím prázdný seznam
    politicke_strany = []
    odpoved = requests.get(url_obce[0]).text
    data = BeautifulSoup(odpoved, "html.parser")
    #První tabulka
    table_1 = [j.text.replace("\xa0", "") for j in data.find_all("td", class_ = "overflow_name", headers = "t1sa1 t1sb2")]
    #Druhá tabulka
    table_2 = [j.text.replace("\xa0", "") for j in data.find_all("td", class_="overflow_name", headers="t2sa1 t2sb2")]
    #Slučuji tabulky
    politicke_strany.extend(table_1 + table_2)
    #print(politicke_strany)
    return politicke_strany

#Definuji funkci, která získá počty hlasů pro každou politickou stranu v dané obci
def secti_hlasy(url_obce: list) -> list:
    """
    Funkce pomocí knihoven "requests" a "BeautifulSoup" najde z url pro danou obec všechny prvky s třídou "cislo"
    a hlavičkami "t1sa2 t1sb3" a "t2sa2 t2sb3" a poté data uloží do seznamu "pocet_hlasu".
    """
    pocet_hlasu = []
    for i in url_obce:
        odpoved = requests.get(i).text
        data = BeautifulSoup(odpoved, "html.parser")
        table_1 = [j.text.replace("\xa0", "") for j in data.find_all("td", class_="cislo", headers="t1sa2 t1sb3")]
        table_2 = [j.text.replace("\xa0", "") for j in data.find_all("td", class_="cislo", headers="t2sa2 t2sb3")]
        pocet_hlasu.append(table_1 + table_2)
    #print(pocet_hlasu)
    return pocet_hlasu

#Definuji funkci, která zapíše sesbíraná data do csv souboru
def zapis_csv(nazev_souboru, seznam_obci, Data, politicke_strany, pocet_hlasu) -> None:
    """
    Funkce zapíše sesbíraná data do csv souboru dle vstupnách parametrů.
    """
    head = ["Kod obce", "Nazev obce", "Pocet volicu v seznamu", "Vydane obalky", "Platne hlasy"]
    current_directory = os.getcwd()
    file_path = os.path.join(current_directory, nazev_souboru)
    with open(nazev_souboru, "w", newline = "", encoding = "utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(head + politicke_strany)
        for i in range(len(seznam_obci[0])):
            writer.writerow(
                [seznam_obci[0][i], seznam_obci[1][i]]
                + [Data[0][i]]
                + [Data[1][i]]
                + [Data[2][i]]
                + pocet_hlasu[i]
            )
    print(f"Soubor {nazev_souboru} byl úspěšně vytvořen a uložen v:{file_path}")


# main function which runs the program


def main() -> None:
    """The main function performs following tasks:
         1) It validates the command line arguments
         2) scrapes city names
         3) retrieves city URLs
         4) collects voter turnout data
         5) retrieves political parties
         6) retrieves votes from individual cities
         7) writes the data to a CSV file.

    :raises: ValueError: If there is an error in the process of program."""

    try:
        url, file_name = validate_command_line_arguments()
        print(
            f'Initializing program with URL "{url}" and file name "{file_name}"\n'
            f"Extracting data...")
        city_list = city_names_scraper(url)
        city_url = get_city_url(url)
        data_collection = voter_turnout_data(city_url)
        political_parties = get_political_parties(city_url)
        total_votes = get_votes(city_url)
        file = write_csv(
            file_name, city_list, data_collection, political_parties, total_votes
        )
    except ValueError as error:
        print(f"Error: {error}")

url = 'https://www.volby.cz/pls/ps2017nss/ps32?xjazyk=CZ&xkraj=6&xnumnuts=4204'

url_obce = ziskej_url_obce(url)
seznam_obci = scraper_jmena_obci(url)
Data = volby_v_obci_prehled(url_obce)
politicke_strany = seznam_politickych_stran(url_obce)
pocet_hlasu = secti_hlasy(url_obce)
soubor = zapis_csv("Louny.csv", seznam_obci, Data, politicke_strany, pocet_hlasu)