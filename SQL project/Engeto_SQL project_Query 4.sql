-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
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
*/

WITH cte_vyvoj_cen_potravin AS (
    SELECT
        zdroj.rok,
        AVG(zdroj.prumerna_hodnota) AS prumerna_cena,
        LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) AS prumerna_cena_predchozi_rok,
        AVG(zdroj.prumerna_hodnota) - LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) AS rozdil_prumernych_cen,
        CASE 
            WHEN AVG(zdroj.prumerna_hodnota) - LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) > 0 THEN 'Rostoucí cena potravin'
            WHEN AVG(zdroj.prumerna_hodnota) - LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) < 0 THEN 'Klesajici cena potravin'
        END AS trend_cen
    FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj 
    WHERE zdroj.datovy_typ = 'Pruměrná cena za jednotku'
    GROUP BY zdroj.rok
)
SELECT 
    cte_vcp.rok,
    CONCAT(FORMAT(cte_vcp.prumerna_cena, 2), ",- Kč") AS prumerna_cena,
    CONCAT(FORMAT(cte_vcp.prumerna_cena_predchozi_rok, 2), ",- Kč") AS prumerna_cena_predchozi_rok,
    CONCAT(FORMAT(cte_vcp.rozdil_prumernych_cen, 2), ",- Kč") AS rozdil_prumernych_cen,
    cte_vcp.trend_cen 
FROM cte_vyvoj_cen_potravin AS cte_vcp;
    