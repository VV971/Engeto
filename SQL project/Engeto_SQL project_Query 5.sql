-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve
-- stejném nebo následujícím roce výraznějším růstem?

WITH cte_vyvoj_HDP AS (
    SELECT
        c.region_in_world AS region,
        c.country AS stat,
    	c.currency_code AS zkratka_meny,
    	e.`year` AS rok,
    	e.GDP AS HDP,
    	LAG(e.GDP) OVER (ORDER BY e.`year`) AS HDP_predchozi_rok,
    	ROUND(e.GDP - LAG(e.GDP) OVER (PARTITION BY c.country ORDER BY e.`year`), 3) AS mezirocni_zmena_HDP_abs,
    	(ROUND(e.GDP / LAG(e.GDP) OVER (PARTITION BY c.country ORDER BY e.`year`), 5) - 1) * 100 AS mezirocni_zmena_HDP_procentni,
    	CASE
           WHEN LAG(e.GDP) OVER (PARTITION BY c.country ORDER BY e.`year`) IS NULL THEN 'Chybí data'
    	   WHEN ABS((ROUND(e.GDP / LAG(e.GDP) OVER (PARTITION BY c.country ORDER BY e.`year`), 5) - 1) * 100) >= 2.5 THEN 'Změna HDP větší než 2,5%'
    	   WHEN ABS((ROUND(e.GDP / LAG(e.GDP) OVER (PARTITION BY c.country ORDER BY e.`year`), 5) - 1) * 100) < 2.5 THEN 'Změna HDP menší než 2,5%'
    	END AS trend_HDP 
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
            zdroj.prumerna_hodnota AS prumerny_plat,
            LAG(zdroj.prumerna_hodnota) OVER (PARTITION BY zdroj.nazev ORDER BY zdroj.rok) AS prumerny_plat_predchozi_rok,
            zdroj.prumerna_hodnota - LAG(zdroj.prumerna_hodnota) OVER (PARTITION BY zdroj.nazev ORDER BY zdroj.rok) AS mezirocni_zmena_platu_abs,
            ROUND((zdroj.prumerna_hodnota / LAG(zdroj.prumerna_hodnota) OVER (PARTITION BY zdroj.nazev ORDER BY zdroj.rok) - 1 ) * 100, 3) AS mezirocni_zmena_platu_procentne,
            CASE 
                WHEN ROUND((zdroj.prumerna_hodnota / LAG(zdroj.prumerna_hodnota) OVER (PARTITION BY zdroj.nazev ORDER BY zdroj.rok) - 1 ) * 100, 3) >= 5 THEN 'Růst platů o 5 a více %'
                WHEN ROUND((zdroj.prumerna_hodnota / LAG(zdroj.prumerna_hodnota) OVER (PARTITION BY zdroj.nazev ORDER BY zdroj.rok) - 1 ) * 100, 3) < 5 THEN 'Růst platů o méně než 5%'
            END AS trend_platu
        FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj
        WHERE zdroj.datovy_typ = 'Průměrná hrubá mzda na zaměstnance'
        AND zdroj.rok BETWEEN 2006 AND 2018
        GROUP BY zdroj.rok, zdroj.nazev
    ), cte_vyvoj_cen_potravin AS (
            SELECT
                zdroj.rok,
                zdroj.nazev AS potravina,
                zdroj.prumerna_hodnota AS prumerna_cena,
                LAG(zdroj.prumerna_hodnota) OVER (PARTITION BY zdroj.nazev ORDER BY zdroj.rok) AS prumerna_cena_predchozi_rok,
                zdroj.prumerna_hodnota - LAG(zdroj.prumerna_hodnota) OVER (PARTITION BY zdroj.nazev ORDER BY zdroj.rok) AS mezirocni_zmena_cen_abs,
                ROUND((zdroj.prumerna_hodnota / LAG(zdroj.prumerna_hodnota) OVER (PARTITION BY zdroj.nazev ORDER BY zdroj.rok) - 1 ) * 100, 3) AS mezirocni_zmena_cen_procentne,
                CASE 
                    WHEN ROUND((zdroj.prumerna_hodnota / LAG(zdroj.prumerna_hodnota) OVER (PARTITION BY zdroj.nazev ORDER BY zdroj.rok) - 1 ) * 100, 3) >= 5 THEN 'Růst cen potravin o 5 a více %'
                    WHEN ROUND((zdroj.prumerna_hodnota / LAG(zdroj.prumerna_hodnota) OVER (PARTITION BY zdroj.nazev ORDER BY zdroj.rok) - 1 ) * 100, 3) < 5 THEN 'Růst cen potravin o méně než 5%'
                END AS trend_cen
            FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj 
            WHERE zdroj.datovy_typ = 'Pruměrná cena za jednotku'
            AND zdroj.rok BETWEEN 2006 AND 2018
            GROUP BY zdroj.rok, zdroj.nazev
    )
SELECT 
    cte_hdp.region,
    cte_hdp.stat,
    cte_hdp.zkratka_meny,
    cte_hdp.rok,
    CONCAT(FORMAT(cte_hdp.HDP, 2), ',- Kč') AS HDP,
    CONCAT(FORMAT(cte_hdp.HDP_predchozi_rok, 2), ',- Kč') AS HDP_predchozi_rok,
    CONCAT(FORMAT(cte_hdp.mezirocni_zmena_HDP_abs,  2), ',- Kč') AS mezirocni_zmena_HDP_abs,
    CONCAT(FORMAT(cte_hdp.mezirocni_zmena_HDP_procentni,  2), ' %') AS mezirocni_zmena_HDP_procentni,
    cte_hdp.trend_HDP,
    cte_plat.odvetvi,
    CONCAT(FORMAT(cte_plat.prumerny_plat, 2), ',- Kč') AS prumerny_plat,
    CONCAT(FORMAT(cte_plat.prumerny_plat_predchozi_rok, 2), ',- Kč') AS prumerny_plat_predchozi_rok,
    CONCAT(FORMAT(cte_plat.mezirocni_zmena_platu_abs, 2), ',- Kč') AS mezirocni_zmena_platu_abs,
    CONCAT(FORMAT(cte_plat.mezirocni_zmena_platu_procentne, 2), ' %') AS mezirocni_zmena_platu_procentne,
    cte_plat.trend_platu,
    cte_potr.potravina,
    CONCAT(FORMAT(cte_potr.prumerna_cena, 2), ',- Kč') AS prumerna_cena,
    CONCAT(FORMAT(cte_potr.prumerna_cena_predchozi_rok, 2), ',- Kč') AS prumerna_cena_predchozi_rok,
    CONCAT(FORMAT(cte_potr.mezirocni_zmena_cen_abs, 2), ',- Kč') AS mezirocni_zmena_cen_abs,
    CONCAT(FORMAT(cte_potr.mezirocni_zmena_cen_procentne, 2), ' %') AS mezirocni_zmena_cen_procentne,
    cte_potr.trend_cen
FROM cte_vyvoj_HDP AS cte_hdp
JOIN cte_vyvoj_platu AS cte_plat
ON cte_hdp.rok = cte_plat.rok
JOIN cte_vyvoj_cen_potravin AS cte_potr
ON cte_hdp.rok = cte_potr.rok
WHERE cte_hdp.trend_HDP = 'Změna HDP větší než 2,5%'
AND cte_plat.trend_platu = 'Růst platů o 5 a více %'
AND cte_potr.trend_cen = 'Růst cen potravin o 5 a více %';