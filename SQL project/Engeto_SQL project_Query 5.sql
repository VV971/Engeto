-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na 
-- cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

/*
Primární tabulky:

czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.
czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.
czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.
czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.
czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.
Číselníky sdílených informací o ČR:

czechia_region – Číselník krajů České republiky dle normy CZ-NUTS 2.
czechia_district – Číselník okresů České republiky dle normy LAU.
Dodatečné tabulky:

countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

Výzkumné otázky
Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin 
či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

Výstup projektu
Pomozte kolegům s daným úkolem. Výstupem by měly být dvě tabulky v databázi, ze kterých se požadovaná data dají získat. Tabulky pojmenujte 
t_{jmeno}_{prijmeni}_project_SQL_primary_final (pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období
 – společné roky) a t_{jmeno}_{prijmeni}_project_SQL_secondary_final (pro dodatečná data o dalších evropských státech).
*/

SELECT
    c.region_in_world AS region,
    c.country AS country,
    c.abbreviation,
    e.`year`,
    e.GDP,
    e.population,
    c.currency_name,
    c.currency_code 
FROM engeto_26_09_2024.countries AS c
LEFT JOIN engeto_26_09_2024.economies AS e 
ON c.country = e.country 
WHERE c.continent = 'Europe'
AND c.region_in_world IN ('Eastern Europe', 'Baltic Countries')
AND e.GDP IS NOT NULL
AND e.`year` BETWEEN (SELECT MIN(zdroj.rok) FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj) 
AND (SELECT MAX(zdroj.rok) FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj)
ORDER BY region, country, `year` ASC;

SELECT e.*
FROM engeto_26_09_2024.economies AS e 
-- WHERE e.country LIKE '% Europe %'