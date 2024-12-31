-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

WITH cte_platy_zmeny AS (
	SELECT 
		zdroj.rok,
		zdroj.nazev AS odvetvi,
		zdroj.datovy_typ AS typ_platu,
		zdroj.prumerna_hodnota AS prumerny_plat,
		CASE
			WHEN LAG(zdroj.prumerna_hodnota) OVER (PARTITION BY zdroj.nazev ORDER BY zdroj.rok) IS NULL THEN 'Chybí data'
			WHEN zdroj.prumerna_hodnota > (
				SELECT zdroj2.prumerna_hodnota
				FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj2
				WHERE zdroj2.rok = zdroj.rok - 1
				AND zdroj2.nazev = zdroj.nazev
				GROUP BY zdroj2.nazev
				) THEN 'Rostoucí'
			ELSE 'Klesající'
		END AS mezirocni_trend,
		LAG(zdroj.prumerna_hodnota) OVER (PARTITION BY zdroj.nazev ORDER BY zdroj.rok) AS prumerny_plat_predchozi_rok,
		zdroj.prumerna_hodnota - LAG(zdroj.prumerna_hodnota) OVER (PARTITION BY zdroj.nazev ORDER BY zdroj.rok) AS prumerna_mezirocni_zmena_platu_abs,
		zdroj.prumerna_hodnota / LAG(zdroj.prumerna_hodnota) OVER (PARTITION BY zdroj.nazev ORDER BY zdroj.rok) AS prumerna_mezirocni_zmena_platu_procentne
	FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS zdroj
	WHERE zdroj.datovy_typ = 'Průměrná hrubá mzda na zaměstnance'
	GROUP BY zdroj.rok, zdroj.nazev
)
SELECT 
	cte_pz.rok,
	cte_pz.odvetvi,
	cte_pz.typ_platu,
	CONCAT(FORMAT(cte_pz.prumerny_plat, 2), ',- Kč') AS prumerny_plat,
	cte_pz.mezirocni_trend,
	CONCAT(FORMAT(cte_pz.prumerny_plat_predchozi_rok, 2), ',- Kč') AS prumerny_plat_predchozi_rok,
	CONCAT(FORMAT(cte_pz.prumerna_mezirocni_zmena_platu_abs, 2), ',- Kč') AS prumerna_mezirocni_zmena_platu_abs,
	CONCAT(FORMAT((cte_pz.prumerna_mezirocni_zmena_platu_procentne * 100) - 100, 3), ' %') AS prumerna_mezirocni_zmena_platu_procentne
FROM cte_platy_zmeny AS cte_pz
GROUP BY cte_pz.rok, cte_pz.odvetvi;