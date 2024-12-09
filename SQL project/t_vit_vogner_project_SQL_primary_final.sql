CREATE TABLE IF NOT EXISTS t_vit_vogner_project_SQL_primary_final AS (
WITH cte_platy AS (
    SELECT  
        cp.payroll_year AS rok,
        NULL AS kod,
        cpib.name AS nazev,
        cpvt.name AS datovy_typ,
        AVG(cp.value) AS prumerna_hodnota,
        cpu.name AS jednotka
    FROM engeto_26_09_2024.czechia_payroll AS cp
    LEFT JOIN engeto_26_09_2024.czechia_payroll_value_type AS cpvt
    ON cp.value_type_code = cpvt.code
    LEFT JOIN engeto_26_09_2024.czechia_payroll_unit AS cpu
    ON cp.unit_code = cpu.code
    LEFT JOIN engeto_26_09_2024.czechia_payroll_industry_branch AS cpib
    ON cp.industry_branch_code = cpib.code
    WHERE cpvt.code = 5958 AND cpib.code IS NOT NULL -- 5958 - Průměrná hrubá mzda na zaměstnance
    GROUP BY cp.payroll_year, cpib.name
    ORDER BY cp.payroll_year, cpib.name
    ),
     cte_ceny AS (
    SELECT 
        YEAR(cp.date_from) AS rok,
        cp.category_code AS kod,
        cpc.name AS nazev,
        'Průměrná cena za jednotku' AS datovy_typ,
        ROUND(AVG(cp.value), 2) AS prumerna_hodnota,
        cpc.price_unit AS jednotka
    FROM engeto_26_09_2024.czechia_price AS cp
    LEFT JOIN engeto_26_09_2024.czechia_price_category AS cpc 
    ON cp.category_code = cpc.code
    GROUP BY rok, nazev, datovy_typ
    ORDER BY cp.date_from DESC
    )
SELECT cte_pl.*
FROM cte_platy AS cte_pl
GROUP BY cte_pl.rok, cte_pl.nazev
UNION ALL
SELECT cte_ce.*
FROM cte_ceny AS cte_ce
GROUP BY cte_ce.rok, cte_ce.nazev);