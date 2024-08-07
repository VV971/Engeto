"""
projekt_1.py: první projekt do Engeto Online Python Akademie

author: Vít Vogner
email: vit.vogner@gmx.com
discord: jovial_otter_10639

II. hodnocení:
1. Přihlášení nefunkční: 
    a) zkoušel jsem zadat username: bob a password: 12 - program se neukončil řízeně, ale spadl s NameError: name 'var_login' is not defined - způsobené do jaké podmínky to spadá
    b) zkoušel jsem zadat username: bob a password: pass123 - program mě úspěšně přihlásil (heslo k username bob je 123)
2. Neošetřeny uživatelské vstupy: když při výběru textu zadám písmeno, program neočekávaně spadne s chybou ValueError: invalid literal for int() with base 10: 's', je potřeba to mít pohlídané a buď nechat uživatele opakovat, nebo řízeně ukončit program.
3. Nesedí statistika pro slova začínající velkým písmenem There are 11 titlecase words. má jich být 12

Závěr: Projekt má celkově dobrý základ, ale určitě je potřeba opravit přihlášení a statistiky.

I. Hodnocení:
1. Projekty odevzdávat v v souboru .py tedy Pythonovským ne v notebooku
2. Neošetřeny uživatelské vstupy: když při výběru textu zadám písmeno, program neočekávaně spadne s chybou ValueError: invalid literal for int() with base 10: 's', je potřeba to mít pohlídané a buď nechat uživatele opakovat, nebo řízeně ukončit program.
3. Jednotlivý uživatelé v samostatných proměnných: když jich bude 1000 to budeš dělat proměnné d_user_1 ..... d_user_1000. Toto není efektivní přístup
4. Statistika pro slova začínající velkým písmem: There are 12 titlecase words. ['Situated', 'Kemmerer', 'Fossil', 'Butte', 'Twin', 'Creek', 'Valley', 'The', '30N', 'Union', 'Pacific', 'Railroad'] - 30N nezačíná velkým písmenem. Pozor na metodu istitle, jak se chová.
5. V grafu nesedí počty: způsobeno, že neodstraňuješ všechny nežádoucí znaky, ale jen čárky.

Závěr: Projekt má dobrý základ, ale je potřeba implementovat pár zlepšení. Určitě se jedná o body zlepšení 1, 2, 3 a 5. Budu se těšit na opravený kód, pokud budeš potřebovat něco dovysvětlit určitě mi napiš. Projekt neschvaluji.
"""
#Importuji knihovnu sys pro využití funkce exit
import sys
#Importuji knihovnu textwrap pro zalomení textu
import textwrap
#Importuji knihovnu string pro mapování a následné odstranění interpunkčních znamének v textu
import string

#Vytvářím řetezec s texty pro analýzu
str_texts = [
'''Situated about 10 miles west of Kemmerer, Fossil Butte is a ruggedly impressive topographic feature that rises sharply some 1000 feet above Twin Creek Valley to an elevation of more than 7500 feet above sea level. The butte is located just north of US 30N and the Union Pacific Railroad, which traverse the valley.''',
'''At the base of Fossil Butte are the bright red, purple, yellow and gray beds of the Wasatch Formation. Eroded portions of these horizontal beds slope gradually upward from the valley floor and steepen abruptly. Overlying them and extending to the top of the butte are the much steeper buff-to-white beds of the Green River Formation, which are about 300 feet thick.''',
'''The monument contains 8198 acres and protects a portion of the largest deposit of freshwater fish fossils in the world. The richest fossil fish deposits are found in multiple limestone layers, which lie some 100 feet below the top of the butte. The fossils represent several varieties of perch, as well as other freshwater genera and herring similar to those in modern oceans. Other fish such as paddlefish, garpike and stingray are also present.'''
]

#Vytvářím hlavní slovník s přístupovými údaji pro jednotlivé uživatele
d_registered_users = {"bob" : "123", \
                    "ann" : "pass123", \
                    "mike" : "password123", \
                    "liz" : "pass123"}

#Vyzývám uživatele k zadání jména
var_user_name = input("Enter your username:")

#Vyzývám uživatele k zadání hesla
var_user_password = input("Enter your password:")

#Vytvářím slovník pro zadané přihlašovací údaje
d_user_credentials = {var_user_name : var_user_password}

#Vyhodnocuji, jestli zadané uživatelské jméno je v hlavním slovníku
if var_user_name in d_registered_users.keys():
    #Pokud je, tak zjištuji, jestli pro zadané uživatelské jméno souhlasí zadané heslo:
    if d_registered_users[var_user_name] == d_user_credentials[var_user_name]:
        #Pokud souhlasí, tak pokračuji v běhu programu
        print("$ python projekt1.py")
        print("username:", var_user_name)
        print("password:", var_user_password)
        print("-" * 60)
        print("Welcome to the app, " + var_user_name, "We have 3 texts to be analyzed.", sep="\n")
        print("-" * 60)
    else:
        #Pokud nesouhlasí, tak ukončuji program
        print("$ python projekt1.py")
        print("username:", var_user_name)
        print("password:", var_user_password)
        print("Unregistered user, terminating the program..")
        sys.exit()  
else:
    #Pokud zadané uživatelské jméno není v hlavním slovníku, tak ukončuji program
    print("$ python projekt1.py")
    print("username:", var_user_name)
    print("password:", var_user_password)
    print("Unregistered user, terminating the program..")
    sys.exit()

#Vyzývám uživatele k vybrání textu pro analýzu
var_text_number = input("Enter a number btw. 1 and 3 to select:")

#Pokud uživatel nezadal číslo, tak ukončuji program:
if var_text_number.isnumeric() != True:
    print("Invalid value, terminating the program..")
    sys.exit()
else:
    var_text_number_forstring = int(var_text_number) - 1 #1 odečítám, abych vyhověl zadání
    #Pokud uživatel nevybral dostupný text, tak ukončuji program
    if var_text_number_forstring not in range(0, len(str_texts)):
        print("Invalid value, terminating the program..")
        sys.exit()
    else:
        #Pokud uživatel vybral dostupný text, tak pokračuji v běhu programu
        print("Enter a number btw. 1 and 3 to select:", var_text_number)
        #Tisknu text vybraný uživatelem (tento tisk nebyl v zadání, ale dává mi smysl, aby se zvolený text ve výstupu programu ukázal)
        print("-" * 60)
        print(textwrap.fill(str_texts[var_text_number_forstring], 60))
        print("-" * 60)

        #Z vybraného textu vytvářím string pro další analýzu pomocí metod stringu
        str_text_selected_original = str(str_texts[var_text_number_forstring])     

        #Definuji uživatelskou funkci pro odstranění interpunkčních znamének z textu
        def remove_punctuation(str_text_selected_original):
            #Vytvářím mapu, která nahradí interpunkční znaménka prázdnou hodnotou
            translator = str.maketrans('', '', string.punctuation)
            #Překládám text pomocí mapy
            return str_text_selected_original.translate(translator)
        
        #Z vybraného textu vytvářím string bez interpunkčních znamének
        str_text_selected_nopunctuation = remove_punctuation(str_text_selected_original)
    
        #Počet slov v textu
        print("There are", len(str_text_selected_nopunctuation.strip().split(" ")), "words in the selected text.")

        #Z vybraného textu vytvářím seznam pro další analýzu pomocí metod seznamu
        l_text_selected = str_text_selected_nopunctuation.strip().split(" ")
        var_count_titlecase = 0
        var_count_uppercase = 0
        var_count_lowercase = 0
        var_count_numeric = 0
        var_sum_numeric = 0
        for var_j in range(0, (int(len(l_text_selected)))):
            #Počet slov začínajících velkým písmenem
            if l_text_selected[var_j][:1].istitle() is True:
                var_count_titlecase = var_count_titlecase + 1
            else:
                var_count_titlecase

            #Počet slov psaných velkými písmeny
            if l_text_selected[var_j].isalpha() is True and l_text_selected[var_j].isupper() is True:
                var_count_uppercase = var_count_uppercase + 1
            else:
                var_count_uppercase

            #Počet slov psaných malými písmeny
            if l_text_selected[var_j].isalpha() is True and l_text_selected[var_j].islower() is True:
                var_count_lowercase = var_count_lowercase + 1
            else:
                var_count_lowercase

            #Počet čísel (ne cifer) v textu
            if l_text_selected[var_j].isnumeric() is True:
                var_count_numeric = var_count_numeric + 1
            else:
                var_count_numeric

            #Suma všech čísel (ne cifer) v textu
            if l_text_selected[var_j].isnumeric() is True:
                var_sum_numeric = var_sum_numeric + int(l_text_selected[var_j])
            else:
                var_sum_numeric
        
        #Tisknu výsledek analýzy textu
        print("There are", var_count_titlecase, "titlecase words.")
        print("There are", var_count_uppercase, "uppercase words.")
        print("There are", var_count_lowercase, "lowercase words.")
        print("There are", var_count_numeric, "numeric strings.")
        print("The sum of all the numbers in the text is:", var_sum_numeric)
        
        #Vytvářím prázdný slovník pro uložení slov a jejich délky
        d_word_length = {}

        #Zjišťuji délku jednotlivých slov
        for word in l_text_selected:
            d_word_length[word] = len(word)

        #Vytvářím prázdný slovník pro uložení frekvence výskytu délek jednotlivých slov
        d_word_length_frequency = {}

        #Počítám frekvenci výskytu délek jednotlivých slov
        for var_length in range(0 , int(max(d_word_length.values())) + 1):
            d_word_length_frequency[var_length] = list(d_word_length.values()).count(var_length)

        #Určuji délku nejdelšího slova, níže ji používám pro naformátování zarovnání grafického výstupu
        var_max_word_length = int(max(d_word_length.values()))
        
        #Tisknu hlavičku grafického výstupu
        print("-" * 60)
        print('{0:>3}'.format("LEN|"), '{:^{max_word_length}}'.format("OCCURENCES", max_word_length = var_max_word_length), '{:<}'.format("|NR."))
        print("-" * 60)

        #Tisknu grafický výstup pro jednotlivé délky slov
        for var_length in d_word_length_frequency:
            print('{0:>3}|'.format(str(var_length)), '{:<{max_word_length}}'.format(list(d_word_length_frequency.values())[var_length] * "*", max_word_length = var_max_word_length), '|{:<}'.format(list(d_word_length_frequency.values())[var_length]))