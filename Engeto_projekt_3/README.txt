Program na sbírání výsledků voleb
Program je napsaný v programovacím jazyce Python a je určen k automatizovanému sběru dat o výsledku voleb do Poslanecké sněmovny ČR v roce 2017 z oficiálních webových stránek Českého statistického úřadu (viz. odkaz https://volby.cz/pls/ps2017nss/ps3?xjazyk=CZ) ve zvoleném okrese a k jejich uložení do csv souboru.
 
Program potřebuje ke svému běhu dva argumenty zadané z příkazové řádky. Prvním je odkaz na volební okres, ze kterého chcete posbírat data, zadaný jako URL, např.: https://www.volby.cz/pls/ps2017nss/ps32?xjazyk=CZ&xkraj=9&xnumnuts=5302). Druhým je jméno výstupního csv souboru.
Použité knihovny
Program používá tyto knihovny:
• requests
• argparse
• re
• os
• BeautifulSoup
• csv
Popis funkce
1. Validace URL
Funkce “overeni_url“ nejdříve zkontroluje, že zadané URL je platné pomocí knihovny “requests”.
2. Validace programových argumentů zadaných z příkazové řádky
Funkce “overeni_argumentu“ zkontroluje pomocí knihovny “argparse” a „re“ programové argumenty zadané z příkazové řádky a pokud projdou ověřením, tak je vrátí jako n-tici (URL a název výstupního csv souboru).
3. Sbírání jmen obcí
Funkce “sber_jmen_obci” ze zadaného URL získá kódy a jména všech obcí a to za pomoci knihoven “requests” (získání HTML obsahu) a “BeautifulSoup” (parsování HTML obsahu).
4. Vytvoření sběrného URL pro všechny obce
Funkce “ziskej_url_obce” přijímá jako argument URL pro zvolený okres a vytvoří seznam s URL pro všechny obce nalezené v tomto okrese.
5. Získání dat o průběhu voleb v dané obci
Funkce “volby_v_obci_prehled“ vytvoří seznam s základními daty o průběhu voleb v dané obci (počet registrovaných voličů, počet vydaných obálek s volebními lístky, počet odevzdaných platných hlasů a to za pomoci knihoven “requests” (získání HTML obsahu) a “BeautifulSoup” (parsování HTML obsahu).


6. Získání jmen politických stran
Funkce “seznam_politickych_stran” získá jména politických stran, jejichž kandidáti se účastnili voleb v dané obci a to za pomoci knihoven “requests” (získání HTML obsahu) a “BeautifulSoup” (parsování HTML obsahu).
7. Získání počtu hlasů pro každou politickou stranu v dané obci
Funkce “secti_hlasy” získá počty hlasů pro každou politickou stranu v dané obci a to za pomoci knihoven “requests” (získání HTML obsahu) a “BeautifulSoup” (parsování HTML obsahu).
8. Zápis sesbíraných dat do csv souboru
Funkce “zapis_csv” zapíše sesbíraná data do jednoho csv souboru a ten uloží pod jménem, který byl zadán jako druhý argument z příkazové řádky.
Spuštění
Program lze spustit v jakémkoliv Python integrovaném vývojovém prostředí např. v MS Visual Studio Code po zadání příkazu se dvěma povinnými argumenty (URL, název souboru) z příkazové řádky.
Vzorový příkaz vypadá takto:
-------------------------------------------------------------------------------------------------------------------
python projekt_3.py "https://www.volby.cz/pls/ps2017nss/ps32?xjazyk=CZ&xkraj=12&xnumnuts=7103" "Prostejov.csv"
-------------------------------------------------------------------------------------------------------------------
Autor
Vít Vogner
Email: vit.vogner@gmx.com
Discord: jovial_otter_10639
