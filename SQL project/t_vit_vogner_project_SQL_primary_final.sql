CREATE TABLE IF NOT EXISTS t_vit_vogner_project_SQL_primary_final AS (
WITH cte_payroll AS (
    SELECT  
        cp.payroll_year AS `year`,
        cpib.name AS data_name,
        cpvt.name AS data_type,
        AVG(cp.value) AS average_value,
        cpu.name AS unit
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
     cte_prices AS (
    SELECT 
        YEAR(cp.date_from) AS `year`,
        cpc.name AS data_name,
        'Průměrná cena za jednotku' AS data_type,
        ROUND(AVG(cp.value), 2) AS average_value,
        'Kč' AS unit
    FROM engeto_26_09_2024.czechia_price AS cp
    LEFT JOIN engeto_26_09_2024.czechia_price_category AS cpc 
    ON cp.category_code = cpc.code
    GROUP BY `year`, data_name, data_type
    ORDER BY cp.date_from DESC
    )
SELECT cte_pa.*
FROM cte_payroll AS cte_pa
GROUP BY cte_pa.`year`, cte_pa.data_name
UNION ALL
SELECT cte_pr.*
FROM cte_prices AS cte_pr
GROUP BY cte_pr.`year`, cte_pr.data_name);