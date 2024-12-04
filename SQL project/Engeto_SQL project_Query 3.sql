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

Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
*/


WITH cte_food_prices AS (
    SELECT
        tvvpspf.`year`,
        tvvpspf.code AS food_code,
        tvvpspf.data_name AS food_name,
        tvvpspf.average_value AS average_food_price,
        tvvpspf.average_value / LAG(tvvpspf.average_value) OVER (PARTITION BY tvvpspf.data_name ORDER BY tvvpspf.`year`) AS average_yty_food_price_change_percentage,
        tvvpspf.unit AS food_unit
    FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS tvvpspf
    WHERE data_type = 'Průměrná cena za jednotku'
)
SELECT DISTINCT
    -- cte_fp.`year`,
    cte_fp.food_code,
    cte_fp.food_name,
    -- cte_fp.average_food_price,
    ROUND(SUM(cte_fp.average_yty_food_price_change_percentage), 4) AS average_food_price_percentage
    -- cte_fp.food_unit
FROM cte_food_prices AS cte_fp
GROUP BY 
    -- cte_fp.`year`,
    cte_fp.food_code,
    cte_fp.food_name
ORDER BY 
    average_food_price_percentage ASC
LIMIT 2;