"""
projekt_3_election-scraper.py: třetí projekt do Engeto Online Python Akademie

author: Vít Vogner
email: vit.vogner@gmx.com
discord: jovial_otter_10639
"""

"#imports"
import requests
from bs4 import BeautifulSoup
import argparse
import re
import csv
import os

"#functions"


def validate_url(url: str) -> bool:
    """This function validates URL using the requests library."""
    try:
        response = requests.get(url)
        return response.status_code == 200
    except requests.exceptions.RequestException:
        return False


def validate_command_line_arguments() -> tuple:
    """This function validates the command line arguments and return the URL and file name as a tuple."""
    parser = argparse.ArgumentParser(description="Validate command line arguments.")
    parser.add_argument("url", type=str, help="The URL to validate.")
    parser.add_argument("file_name", type=str, help="The file name to validate.")
    args = parser.parse_args()
    url, file_name = args.url, args.file_name

    expected_core_url = "https://www.volby.cz/pls/ps2017nss/"
    match = re.match(expected_core_url, url)
    if not match:
        raise ValueError(
            f'Invalid URL. Expected URL to start with "{expected_core_url}", got "{url}"'
        )

    if not file_name.endswith(".csv"):
        raise ValueError(
            f"Invalid file type. Expected .csv, got {os.path.splitext(file_name)[1]}"
        )

    if not validate_url(url):
        raise ValueError(f"Invalid URL: {url}")

    return url, file_name


def city_names_scraper(url) -> list:
    """The function city_names_scraper performs following tasks:
    1. takes a URL as input and returns a list of city codes and names
    2. It uses the requests library to get the HTML content from the URL and parse it using the BeautifulSoup library.
    3.The function finds all elements with the class "cislo" and extracts the text to get the city codes.
    4.Similarly, it finds all elements with the class "overflow_name" and extracts the text to get the city names.
    5.Finally, it combines the city codes and names in a list and returns the result."""

    response = requests.get(url)
    doc = BeautifulSoup(response.text, "html.parser")
    city_codes = [city.text for city in doc.find_all("td", class_="cislo")]
    city_names = [city.text for city in doc.find_all("td", class_="overflow_name")]
    city_list = [city_codes, city_names]
    return city_list


def get_city_url(url: str) -> list[str]:
    """This function performs following tasks:
     1) It starts by defining a core_url which will be used as the base for all the city URLs that will be extracted.
     2) It defines a list of tables that contain strings representing table headers.
     3) The BeautifulSoup object (doc) is used to search for all 'td' elements that have the class "cislo"
     and a header specified in the tables list.
     4) For each matching 'td' element, the function searches for an 'a' element within it, and if found,
     it appends the 'href' attribute to the core_url to form a complete city URL.
     5) Finally, the function returns the city_url list, which now contains all the city URLs from the web page.

    :param url:URL from which to scrape city URLs.
    :return: List of city URLs.
    """

    core_url = "https://www.volby.cz/pls/ps2017nss/"
    tables = ["t1sa1 t1sb1", "t2sa1 t2sb1", "t3sa1 t3sb1"]
    response = requests.get(url)
    doc = BeautifulSoup(response.text, "html.parser")
    city_url = []
    for table in tables:
        for td in doc.find_all("td", class_="cislo", headers=table):
            a = td.find("a")
            if a:
                city_url.append(core_url + a["href"])
    return city_url


def voter_turnout_data(city_url) -> list:
    """This function performs following tasks:
     1) The function uses the BeautifulSoup library and the requests library to extract data from the city URLs.
     2) For each URL the function finds all the elements with the class "cislo" and headers "sa2", "sa3", and "sa6".
     3) The data is collected in the form of three lists: `registered_voters`, `ballot_papers`, and `valid_votes`.
     4) The function returns a list of lists `data_collection` which contains individual lists

    :return: a list of lists containing the voter turnout data."""

    registered_voters = (
        []
    )  # this line of code scrapes the number of registered voters in a particular city
    for i in city_url:
        response_2 = requests.get(i)
        doc_2 = BeautifulSoup(response_2.text, "html.parser")
        voters = [
            j.text.replace("\xa0", "")
            for j in doc_2.find_all("td", class_="cislo", headers="sa2")
        ]
        registered_voters.extend(voters)

    ballot_papers = (
        []
    )  # this line of code scrapes the number of issued ballot papers in a particular city
    for i in city_url:
        response_2 = requests.get(i)
        doc_2 = BeautifulSoup(response_2.text, "html.parser")
        papers = [
            j.text.replace("\xa0", "")
            for j in doc_2.find_all("td", class_="cislo", headers="sa3")
        ]
        ballot_papers.extend(papers)

    valid_votes = (
        []
    )  # this line of code scrapes the number of valid votes cast in election in a particular city
    for i in city_url:
        response_2 = requests.get(i)
        doc_2 = BeautifulSoup(response_2.text, "html.parser")
        votes = [
            j.text.replace("\xa0", "")
            for j in doc_2.find_all("td", class_="cislo", headers="sa6")
        ]
        valid_votes.extend(votes)
    data_collection = [registered_voters, ballot_papers, valid_votes]
    return data_collection


def get_political_parties(city_url: list) -> list[str]:
    """This function performs following tasks:
    1) The function extracts data from the first city URL in the `city_url` list.
    2) It finds all the elements with the class "overflow_name" and headers "t1sa1 t1sb2" and "t2sa1 t2sb2".
    3) Finally, The political party names are stored in a list `political_parties`.

    :return: political_parties (list): a list of political parties.
    """

    # get political party names
    political_parties = []
    response_2 = requests.get(city_url[0])
    doc_2 = BeautifulSoup(response_2.text, "html.parser")
    table1 = [
        j.text.replace("\xa0", "")
        for j in doc_2.find_all("td", class_="overflow_name", headers="t1sa1 t1sb2")
    ]
    table2 = [
        j.text.replace("\xa0", "")
        for j in doc_2.find_all("td", class_="overflow_name", headers="t2sa1 t2sb2")
    ]
    political_parties.extend(table1 + table2)
    return political_parties


def get_votes(city_url: list) -> list:
    """This function performs following tasks:
    1) The function finds for each city URL all elements with the class "cislo"
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


def write_csv(
    file_name, city_list, data_collection, political_parties, total_votes
) -> None:
    """This function writes data collected from websites to a CSV file.
    Parameters:
    1) file_name (str): The name of the CSV file to be written.
    2) city_list (list): A list of two lists, the first list contains city codes, the second list contains city names.
    3) data_collection (list): A list of three lists, the first list contains registered voters, the second list contains issued ballots, and the third list contains valid votes.
    4) political_parties (list): A list of political parties.
    5) total_votes (list): A list of lists, each inner list contains the total votes for each political party in a city.
    6) head (list): A list of header names"""

    head = [
        "City Code",
        "City Name",
        "Registered Voters",
        "Issued Ballots",
        "Valid Votes",
    ]
    current_directory = os.getcwd()
    file_path = os.path.join(current_directory, file_name)
    with open(file_name, "w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(head + political_parties)
        for i in range(len(city_list[0])):
            writer.writerow(
                [city_list[0][i], city_list[1][i]]
                + [data_collection[0][i]]
                + [data_collection[1][i]]
                + [data_collection[2][i]]
                + total_votes[i]
            )
    print(
        f"Your file {file_name} has been successfully generated and stored in the following directory:{file_path}"
    )


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


if __name__ == "__main__":
    main()