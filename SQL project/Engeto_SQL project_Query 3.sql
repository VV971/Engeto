-- 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

/*Varianta č. 1 - řadím vzestupně a vybírám jen první hodnotu
WITH cte_ceny_potravin AS (
    SELECT
        zdroj.rok,
        zdroj.kod AS kod_potraviny,
        zdroj.nazev AS nazev_potraviny,
        zdroj.prumerna_hodnota AS prumerna_cena_potraviny,
        zdroj.prumerna_hodnota / LAG(zdroj.prumerna_hodnota) OVER (PARTITION BY zdroj.nazev ORDER BY zdroj.rok) AS prumerna_mezirocni_zmena_ceny_potraviny_procentne
    FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj
    WHERE zdroj.datovy_typ = 'Průměrná cena za jednotku'
) 
SELECT  
    cte_cp.nazev_potraviny,
    CONCAT(FORMAT(SUM(cte_cp.prumerna_mezirocni_zmena_ceny_potraviny_procentne), 4), ' %') AS prumerna_mezirocni_zmena_ceny_potraviny_procentne
FROM cte_ceny_potravin AS cte_cp
GROUP BY
    cte_cp.nazev_potraviny
ORDER BY 
    prumerna_mezirocni_zmena_ceny_potraviny_procentne ASC
LIMIT 1;
*/

-- Varianta č. 2 - s využitím window fce DENSE_RANK 
WITH cte_ceny_potravin AS (
    SELECT
        zdroj.rok,
        zdroj.kod AS kod_potraviny,
        zdroj.nazev AS nazev_potraviny,
        zdroj.prumerna_hodnota AS prumerna_cena_potraviny,
        zdroj.prumerna_hodnota / LAG(zdroj.prumerna_hodnota) OVER (PARTITION BY zdroj.nazev ORDER BY zdroj.rok) AS prumerna_mezirocni_zmena_ceny_potraviny_procentne
    FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj
    WHERE zdroj.datovy_typ = 'Průměrná cena za jednotku'
) 
SELECT  
    cte_cp.nazev_potraviny,
    CONCAT(FORMAT(SUM(cte_cp.prumerna_mezirocni_zmena_ceny_potraviny_procentne), 4), ' %') AS prumerna_mezirocni_zmena_ceny_potraviny_procentne,
    DENSE_RANK() OVER (ORDER BY prumerna_mezirocni_zmena_ceny_potraviny_procentne ASC) AS poradi
FROM cte_ceny_potravin AS cte_cp
GROUP BY
    cte_cp.nazev_potraviny
ORDER BY 
    prumerna_mezirocni_zmena_ceny_potraviny_procentne ASC;