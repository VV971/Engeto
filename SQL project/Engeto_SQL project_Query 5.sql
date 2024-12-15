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

WITH cte_HDP_CZ AS (
    SELECT
        c.region_in_world AS region,
        c.country AS stat,
    	c.abbreviation AS zkratka_statu,
    	c.currency_code AS zkratka_meny,
    	e.`year` AS rok,
    	e.GDP AS HDP,
    	LAG(e.GDP) OVER (PARTITION BY c.country AND e.`year` ORDER BY e.`year`) AS HDP_minuly_rok,
    	ROUND(e.GDP - LAG(e.GDP) OVER (PARTITION BY c.country AND e.`year` ORDER BY e.`year`), 2) AS mezirocni_zmena_HDP_abs,
    	(ROUND(e.GDP / LAG(e.GDP) OVER (PARTITION BY c.country AND e.`year` ORDER BY e.`year`), 5) - 1) * 100 AS mezirocni_zmena_HDP_procentni,
    	CASE
    	   WHEN ABS(((ROUND(e.GDP / LAG(e.GDP) OVER (PARTITION BY c.country AND e.`year` ORDER BY e.`year`), 5) - 1) * 100)) >= 2.5 THEN 'Změna HDP o více než 2,5%'
    	   ELSE 'Změna HDP o méně než 2,5%'
    	END AS hodnoceni_zmeny_HDP 
    FROM engeto_26_09_2024.countries AS c
    LEFT JOIN engeto_26_09_2024.economies AS e 
    ON c.country = e.country
    WHERE c.continent = 'Europe'
    AND e.`year` BETWEEN 2006 AND 2018
    AND c.country = 'Czech Republic'
), cte_vyvoj_platu AS (
        SELECT 
            zdroj.rok,
            zdroj.nazev AS odvetvi,
            AVG(zdroj.prumerna_hodnota) AS prumerny_plat,
            LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) AS prumerny_plat_predchozi_rok,
            AVG(zdroj.prumerna_hodnota) - LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) AS rozdil_prumernych_platu_abs,
            (AVG(zdroj.prumerna_hodnota) / LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) * 100) - 100 AS rozdil_prumernych_platu_procentne,
            CASE 
                WHEN AVG(zdroj.prumerna_hodnota) / LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) > 5 THEN 'Růst platů o více než 5%'
                WHEN AVG(zdroj.prumerna_hodnota) / LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) <= 5 THEN 'Růst platů o méně než 5%'
            END AS trend_platu
        FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj
        WHERE zdroj.datovy_typ = 'Průměrná hrubá mzda na zaměstnance'
        GROUP BY zdroj.rok
    ), cte_vyvoj_cen_potravin AS (
            SELECT
                zdroj.rok,
                zdroj.nazev AS potravina,
                AVG(zdroj.prumerna_hodnota) AS prumerna_cena,
                LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) AS prumerna_cena_predchozi_rok,
                AVG(zdroj.prumerna_hodnota) - LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) AS rozdil_prumernych_cen_abs,
                (AVG(zdroj.prumerna_hodnota) / LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) * 100) - 100 AS rozdil_prumernych_cen_procentne,
                CASE 
                    WHEN AVG(zdroj.prumerna_hodnota) / LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) > 5 THEN 'Růst cen potravin o více než 5%'
                    WHEN AVG(zdroj.prumerna_hodnota) / LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) <= 5 THEN 'Růst cen potravin o méně než 5 %'
                END AS trend_cen
            FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj 
            WHERE zdroj.datovy_typ = 'Pruměrná cena za jednotku'
            GROUP BY zdroj.rok
    )
SELECT 
    cte_hdpcz.region,
    cte_hdpcz.stat,
    cte_hdpcz.zkratka_statu,
    cte_hdpcz.zkratka_meny,
    cte_hdpcz.rok,
    cte_hdpcz.HDP,
    cte_hdpcz.HDP_minuly_rok,
    cte_hdpcz.mezirocni_zmena_HDP_abs,
    cte_hdpcz.mezirocni_zmena_HDP_procentni,
    cte_hdpcz.hodnoceni_zmeny_HDP,
    cte_vcplat.odvetvi,
    cte_vcplat.prumerny_plat,
    cte_vcplat.prumerny_plat_predchozi_rok,
    cte_vcplat.rozdil_prumernych_platu_abs,
    cte_vcplat.rozdil_prumernych_platu_procentne,
    cte_vcplat.trend_platu 
FROM cte_HDP_CZ AS cte_hdpcz
JOIN cte_vyvoj_platu AS cte_vcplat
ON cte_hdpcz.rok = cte_vcplat.rok
JOIN cte_vyvoj_cen_potravin AS cte_vcpotr
ON cte_hdpcz.rok = cte_vcpotr.rok
WHERE cte_hdpcz.hodnoceni_zmeny_HDP = 'Změna HDP o více než 2,5%'
AND cte_vcplat.trend_platu = 'Růst platů o více než 5 %';
/*
AND cte_vcpotr.trend_cen = 'Růst cen potravin o více než 5 %';
*/
/*
,
    cte_vcpotr.*,
*/