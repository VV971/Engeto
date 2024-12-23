-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

WITH cte_platy AS (
    SELECT
        zdroj.rok,
        zdroj.datovy_typ,
        ROUND(AVG(zdroj.prumerna_hodnota), 2) AS prumerna_hodnota,
        zdroj.jednotka
    FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj
    WHERE zdroj.datovy_typ  = 'Průměrná hrubá mzda na zaměstnance'
    AND zdroj.rok IN (
    (SELECT MIN(zdroj.rok) FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj WHERE zdroj.datovy_typ = 'Průměrná cena za jednotku'),
    (SELECT MAX(zdroj.rok) FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj WHERE zdroj.datovy_typ = 'Průměrná cena za jednotku')
    )
    GROUP BY zdroj.rok, zdroj.datovy_typ
    ), 
    cte_ceny AS (
        SELECT
            zdroj.rok,
            zdroj.nazev,
            zdroj.datovy_typ,
            zdroj.prumerna_hodnota,
            zdroj.jednotka
        FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj
        WHERE zdroj.kod IN (111301, 114201) -- 111301 - Chléb konzumní kmínový  1.0 kg, 114201 - Mléko polotučné pasterované 1.0 l
        AND zdroj.rok IN (
        (SELECT MIN(zdroj.rok) FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj WHERE zdroj.datovy_typ = 'Průměrná cena za jednotku'),
        (SELECT MAX(zdroj.rok) FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj WHERE zdroj.datovy_typ = 'Průměrná cena za jednotku')
        )
    )
SELECT
    cte_ce.rok,
    cte_ce.nazev AS nazev_potraviny,
    CONCAT(FORMAT(cte_ce.prumerna_hodnota, 2), ' Kč/', cte_ce.jednotka) AS prumerna_cena_potraviny,
    CONCAT(FORMAT(cte_pl.prumerna_hodnota, 2), ' ', cte_pl.jednotka, '/měsíc') AS prumerny_plat,
    CONCAT(FORMAT(cte_pl.prumerna_hodnota / cte_ce.prumerna_hodnota, 2), ' ', cte_ce.jednotka) AS mnozstvi_potraviny_za_prumerny_plat
FROM cte_platy AS cte_pl
JOIN cte_ceny AS cte_ce
ON cte_pl.rok = cte_ce.rok;