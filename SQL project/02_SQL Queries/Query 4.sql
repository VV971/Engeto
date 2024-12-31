-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

WITH cte_vyvoj_cen_potravin AS (
    SELECT
        zdroj.rok,
        AVG(zdroj.prumerna_hodnota) AS prumerna_cena,
        LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) AS prumerna_cena_predchozi_rok,
        AVG(zdroj.prumerna_hodnota) - LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) AS rozdil_prumernych_cen_abs,
        (AVG(zdroj.prumerna_hodnota) / LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) * 100) - 100 AS rozdil_prumernych_cen_procentne,
        CASE 
            WHEN ((AVG(zdroj.prumerna_hodnota) / LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) * 100) - 100) > 10 THEN 'Růst cen potravin větší než 10%'
            WHEN ((AVG(zdroj.prumerna_hodnota) / LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) * 100) - 100) <= 10 THEN 'Růst cen potravin o 10 a méně %'
        END AS trend_cen
    FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj 
    WHERE zdroj.datovy_typ = 'Pruměrná cena za jednotku'
    GROUP BY zdroj.rok
    ),
    cte_vyvoj_platu AS (
        SELECT 
            zdroj.rok,
            AVG(zdroj.prumerna_hodnota) AS prumerny_plat,
            LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) AS prumerny_plat_predchozi_rok,
            AVG(zdroj.prumerna_hodnota) - LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) AS rozdil_prumernych_platu_abs,
            (AVG(zdroj.prumerna_hodnota) / LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) * 100) - 100 AS rozdil_prumernych_platu_procentne,
            CASE 
                WHEN ((AVG(zdroj.prumerna_hodnota) / LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) * 100) - 100) > 10 THEN 'Růst platů větší než 10%'
                WHEN ((AVG(zdroj.prumerna_hodnota) / LAG(AVG(zdroj.prumerna_hodnota)) OVER (ORDER BY zdroj.rok) * 100) - 100) <= 10 THEN 'Růst platů o 10 a méně %'
            END AS trend_platu
        FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj
        WHERE zdroj.datovy_typ = 'Průměrná hrubá mzda na zaměstnance'
        GROUP BY zdroj.rok
    )
SELECT
    cte_vcp.rok,
    CONCAT(FORMAT(cte_vcp.prumerna_cena, 2), ",- Kč") AS prumerna_cena,
    CONCAT(FORMAT(cte_vcp.prumerna_cena_predchozi_rok, 2), ",- Kč") AS prumerna_cena_predchozi_rok,
    CONCAT(FORMAT(cte_vcp.rozdil_prumernych_cen_abs, 2), ",- Kč") AS rozdil_prumernych_cen_abs,
    CONCAT(FORMAT(cte_vcp.rozdil_prumernych_cen_procentne, 3), " %") AS rozdil_prumernych_cen_procentne,
    cte_vcp.trend_cen,
    CONCAT(FORMAT(cte_vp.prumerny_plat, 2), ",- Kč") AS prumerny_plat,
    CONCAT(FORMAT(cte_vp.prumerny_plat_predchozi_rok, 2), ",- Kč") AS prumerny_plat_predchozi_rok,
    CONCAT(FORMAT(cte_vp.rozdil_prumernych_platu_abs, 2), ",- Kč") AS rozdil_prumernych_platu_abs,
    CONCAT(FORMAT(cte_vp.rozdil_prumernych_platu_procentne, 3), " %") AS rozdil_prumernych_platu_procentne,
    cte_vp.trend_platu
FROM cte_vyvoj_cen_potravin AS cte_vcp
JOIN cte_vyvoj_platu AS cte_vp 
ON cte_vcp.rok = cte_vp.rok;