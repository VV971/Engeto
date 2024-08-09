"""
projekt_2.py: druhý projekt do Engeto Online Python Akademie

author: Vít Vogner
email: vit.vogner@gmx.com
discord: jovial_otter_10639
"""
#Importuji knihovnu random pro generování náhodných čísel
import random

#Importuji knihovnu timeit pro změření času potřebného pro uhádnutí čísla
import timeit

#Tisknu uvítání
print("Hi there!")
welcome_text_I = "I've generated a random 4 digit number for you."
welcome_text_II = "Let's play a bulls and cows game."
print("-" * len(welcome_text_I))
print(welcome_text_I)
print(welcome_text_II)
print("-" * len(welcome_text_I))

#Definuji funkci, která vrací seznam číslic ze zadaného čtyřmístného čísla
def get_digits_from_number(num):
    """
    Funkce, která vrací seznam číslic ze zadaného čtyřmístného čísla.
    """ 
    return [int(i) for i in str(num)]

#Definuji funkci, která ověřuje, že se v zadaném čísle neopakují jednotlivé číslice
def no_duplicate_number(num):
    """
    Funkce, která vrací True, pokud se v zadaném čísle neopakují jednotlivé číslice.
    """
    list_numbers = get_digits_from_number(num)
    #Porovnávám délku seznamu se setem (do setu se mi zapíší jen unikátní čísla) 
    if len(list_numbers) == len(set(list_numbers)): 
        return True
    else: 
        return False

#Definuji funkci, která ověřuje, že zadané číslo obsahuje jen čísla, nezačíná nulou, je právě \
#čtyřmístné a že číslo neobsahuje duplikáty
def verify_correct_number_format(input_number):
    """
    Funkce, prověří, že zadané číslo obsahuje jen čísla, nezačíná nulou, je právě čtyřmístné 
    a že číslo neobsahuje duplikáty.
    """
    #Připravuji vstupy pro cyklus
    correct_input = True
    #Definuji pomocnou proměnnou pro případné opakováné zadávání čísla
    var_k = 0
    #Začínám cyklus vyhodnocování, jestli zadané číslo splňuje všechny požadavky na správný formát
    while correct_input:
        #V prvním cyklu je použito uživatelem zadané číslo
        if var_k == 0:
            guessed_number = input_number
            var_k = var_k + 1
        else:
            #Pokud první zadání bylo vyhodnoceno jako NOK, tak vyzývám uživatele k opakovanému \n
            #zadání čísla
            guessed_number = input("Enter your 4 digit numer:")
        #Kontroluji, jestli je zadáno číslo
        if not guessed_number.isdigit():
            print("Only numbers are allowed in input.")
            break
        #Kontroluji, jestli číslo nezačíná 0
        if guessed_number.startswith("0"):
            print("Number must not start with 0.")
            break
        #Kontroluji, jestli je zadané číslo čtyřmístné
        if not (len(guessed_number) == 4):
            print("Enter number with exactly 4 digits.")
            break
        #Kontroluji, že v zadaném čísle nejsou žádné duplikáty
        if not no_duplicate_number(guessed_number):
            print("Duplicated numbers are not allowed.")
            break
        else:
            print(">>> ", guessed_number)
            correct_input = False
            return int(guessed_number)

#Definuji funkci, která generuje náhodné čtyřmístné číslo a vrací ho, pokud v něm \n
#nejsou číselné duplikáty
def generate_four_digit_number():
    """
    Funkce vygeneruje náhodné čtyřmístné číslo a vrátí ho, pokud v něm nejsou číselné duplikáty.
    """
    while True:
        #Generuji náhodné celé čtyřmístné číslo
        random_number = random.randint(1000, 9999)
        #Pomocí funkce ověřuji, že v něm nejsou žádné duplikáty
        if no_duplicate_number(random_number):
            return random_number

#Definuji funkci, která vrátí počet uhádnutých čísel na správné pozici a počet uhádnutých čísel \n
#na nesprávné pozici 
def count_bulls_cows(secret_number, input_number):
    """
    Funkce vrátí počet uhádnutých čísel na správné pozici a počet \n
    uhádnutých čísel na nesprávné pozici. 
    """ 
    bulls_cows = [0, 0] 
    list_secret = get_digits_from_number(secret_number) 
    list_input = get_digits_from_number(input_number) 
    for var_i, var_j in zip(list_secret, list_input): 
        #Pokud je zadané číslo v tajném čísle  
        if var_j in list_secret: 
            #Počítám jako "bull", pokud je zadané číslo v tajném čísle na stejné pozici
            if var_j == var_i: 
                bulls_cows[0] += 1
            #Počítám jako "cow", pokud je zadané číslo v tajném čísle na jiné pozici
            else: 
                bulls_cows[1] += 1
    return bulls_cows 

#Generuji tajné číslo k uhádnutí
secret_number = generate_four_digit_number()
#Zakomentovaný tisk pro rychlejší debuggování 
print(secret_number)

#Začínám hádat tajné číslo
var_l = 0
bulls_cows = [0, 0]
#V hádání čísla pokračuji do jeho uhádnutí
while bulls_cows[0] < 4:
    #Vyzývým uživatele k zadání jeho čísla
    input_number = input("Enter your 4 digit numer:")
    #Začínám měření času do uhádnutí tajného čísla
    start = timeit.default_timer()
    var_l += 1
    #Pokud číslo projde ověřením, tak ho předám k porovnání s tajným číslem
    if (type(verify_correct_number_format(input_number)) == int) is True:
        #Volám funkci pro porovnání zadaného čísla s tajným číslem
        bulls_cows = count_bulls_cows(secret_number, input_number)
        #Připravuji si proměnné do f-stringu
        if bulls_cows[0] == 1:
            wording_bulls = 'bull'
        else:
            wording_bulls = 'bulls'
        if bulls_cows[1] == 1:
            wording_cows = 'cow'
        else:
            wording_cows = 'cows'
        #Tisknu výsledek hádání jako f-string
        print(f"{bulls_cows[0]} {repr(wording_bulls).strip('"\'')}, {bulls_cows[1]} {repr(wording_cows).strip('"\'')}")
        print("-" * len(welcome_text_I))
else: 
    #Pokud se všechna čtyři čísla v tajném i zadaném čísle shodují, tak ukončuji hru
    if bulls_cows[0] == 4:
        #Ukončuji měření času do uhádnutí tajného čísla
        end = timeit.default_timer()
        print("Correct, you've guessed the right number in", var_l, "guesses!")
        var_elapsed_time = round(end - start, 2)
        print(f"You needed {var_elapsed_time} seconds to guess the secret number.")
        #print("You needed", round(var_elapsed_time, 2), "seconds to guess the secret number.")