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

WITH cte_gdp_CZ AS (
    SELECT
        c.region_in_world AS region,
        c.country AS country,
    	c.abbreviation,
    	e.`year`,
    	e.GDP,
    	LAG(e.GDP) OVER (PARTITION BY c.country AND e.`year` ORDER BY e.`year`) AS GDP_previous_year,
    	ROUND(e.GDP - LAG(e.GDP) OVER (PARTITION BY c.country AND e.`year` ORDER BY e.`year`), 2) AS GDP_YtY_difference_abs,
    	(ROUND(e.GDP / LAG(e.GDP) OVER (PARTITION BY c.country AND e.`year` ORDER BY e.`year`), 5) - 1) * 100 AS GDP_YtY_difference_percentage,
    	CASE
    	   WHEN ABS(((ROUND(e.GDP / LAG(e.GDP) OVER (PARTITION BY c.country AND e.`year` ORDER BY e.`year`), 5) - 1) * 100)) >= 2.5 THEN 'Significant YtY change of GDP'
    	   ELSE 'Unsignificant YtY change of GDP'
    	END AS GDP_change_evaluation,    	
    	e.population,
    	c.currency_code 
    FROM engeto_26_09_2024.countries AS c
    LEFT JOIN engeto_26_09_2024.economies AS e 
    ON c.country = e.country
    WHERE c.continent = 'Europe'
    AND e.`year` BETWEEN 2006 AND 2018
    AND c.country = 'Czech Republic'
    /*
    AND e.`year` BETWEEN (SELECT
                              CASE 
                                  WHEN MIN(cpa.payroll_year) > MIN(YEAR(cpi.date_from)) THEN MIN(cpa.payroll_year)
                                  WHEN MIN(YEAR(cpi.date_from)) > MIN(cpa.payroll_year) THEN MIN(YEAR(cpi.date_from))
                              END AS min_rok  -- vybírám větší z minimálních roků, abych data sjednotil na totožné období 
                          FROM engeto_26_09_2024.czechia_payroll AS cpa
                          LEFT JOIN engeto_26_09_2024.czechia_price AS cpi
                          ON cpa.payroll_year = YEAR(cpi.date_from))
    AND (SELECT
            CASE 
                WHEN MAX(cpa.payroll_year) > MAX(YEAR(cpi.date_from)) THEN MAX(YEAR(cpi.date_from))
                WHEN MAX(YEAR(cpi.date_from)) > MAX(cpa.payroll_year) THEN MAX(cpa.payroll_year)
            END AS max_rok  -- vybírám menší z maximálních roků, abych data sjednotil na totožné období
            FROM engeto_26_09_2024.czechia_payroll AS cpa
            LEFT JOIN engeto_26_09_2024.czechia_price AS cpi
            ON cpa.payroll_year = YEAR(cpi.date_from))
    */
), WITH cte_salaries_prices AS (
    SELECT 
        zdroj.rok AS `year`,
        zdroj.kod,
        zdroj.nazev,
        zdroj.datovy_typ,
        zdroj.prumerna_hodnota,
        zdroj.jednotka
    FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj
    WHERE zdroj.rok BETWEEN 2006 AND 2018
)
SELECT cte_cz.*
FROM cte_GDP_CZ AS cte_cz;