"""
projekt_2.py: druhý projekt do Engeto Online Python Akademie

author: Vít Vogner
email: vit.vogner@gmx.com
discord: jovial_otter_10639
"""
#Importuji knihovnu random pro generování náhodných čísel
import random

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
    if len(list_numbers) == len(set(list_numbers)): 
        return True
    else: 
        return False

#Definuji funkci, která ověřuje, že zadané číslo obsahuje jen čísla, nezačíná nulou, je právě \
#čtyřmístné a že číslo neobsahuje duplikáty
def verify_correct_number_format(input_number):
    """
    Funkce, prověří, že zadané číslo obsahuje jen čísla, nezačíná nulou, je právě čtyřmístné 
    a že číslo neobsahuje duplikáty
    """
    #Připravuji vstupy pro cyklus
    correct_input = True
    #Definuji pomocnou proměnnou pro případné opakování zadávání čísla
    var_k = 0
    #Začínám cyklus vyhodnocování, jestli zadané číslo splňuje všechny požadavky na správný formát
    while correct_input:
        if var_k == 0:
            guessed_number = input_number
            var_k = var_k + 1
        else:
            #Pokud první zadání bylo vyhodnoceno jako NOK, tak vyzývám uživatele k opakovanému zadání čísla
            guessed_number = input("Enter your 4 digit numer:")
        #Kontroluji, jestli je zadáno číslo
        if not guessed_number.isdigit():
            print("Only numbers are allowed in input.")
            continue
        #Kontroluji, jestli číslo nezačíná 0
        if guessed_number.startswith("0"):
            print("Number must not start with 0.")
            continue
        #Kontroluji, jestli je zadané číslo čtyřmístné
        if not (len(guessed_number) == 4):
            print("Enter number with exactly 4 digits.")
            continue
        if not no_duplicate_number(guessed_number):
            print("Duplicated numbers are not allowed.")
            continue
        else:
            print(">>> ", guessed_number)
            correct_input = False
            return int(guessed_number)

#Definuji funkci, která generuje náhodné čtyřmístné číslo a vrací ho, pokud v něm nejsou číselné duplikáty
def generate_four_digit_number():
    while True:
        random_number = random.randint(1000, 9999)
        if no_duplicate_number(random_number):
            return random_number

#Definuji funkci, která vrátí počet uhádnutých čísel na správné pozici a počet uhádnutých čísel na nesprávné pozici 
def count_bulls_cows(secret_number, input_number): 
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
print(secret_number)

#Začínám hádat tajné číslo
#V hádání čísla pokračuji do jeho uhádnutí
var_l = 0
bulls_cows = [0, 0]
while bulls_cows[0] < 4:
    input_number = input("Enter your 4 digit numer:")
    var_l += 1
    if verify_correct_number_format(input_number):
        #Volám funkci pro porovnání zadaného čísla s tajným číslem
        bulls_cows = count_bulls_cows(secret_number, input_number)
        #Tisknu výsledek hádání 
        if bulls_cows[0] == 1:
            wording_bulls = 'bull'
        else:
            wording_bulls = 'bulls'
        if bulls_cows[1] == 1:
            wording_cows = 'cow'
        else:
            wording_cows = 'cows'
        print(f"{bulls_cows[0]} {repr(wording_bulls).strip('"\'')}, {bulls_cows[1]} {repr(wording_cows).strip('"\'')}")
        print("-" * len(welcome_text_I))
else: 
    #Pokud se všechna čtyři čísla v tajném i zadaném čísle shodují, tak ukončuji hru
    if bulls_cows[0] == 4: 
        print("Correct, you've guessed the right number in", var_l, "guesses!")
"""
Zbývá ošetřit crash ve fci "get_digits_from_number", asi při doplnění nějakého neviditelného znaku"""