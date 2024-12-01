/*
Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
*/

WITH cte_payroll AS (
    SELECT
        `year`,
        data_type,
        ROUND(AVG(average_value), 2) AS average_value,
        unit
    FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS tvvpspf
    WHERE data_type  = 'Průměrná hrubá mzda na zaměstnance'
    AND `year` IN (
    (SELECT MIN(tvvpspf.`year`) FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS tvvpspf WHERE tvvpspf.data_type = 'Průměrná cena za jednotku'),
    (SELECT MAX(tvvpspf.`year`) FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS tvvpspf WHERE tvvpspf.data_type = 'Průměrná cena za jednotku')
    )
    GROUP BY `year`, data_type
    ), 
cte_prices AS (
    SELECT
        `year`,
        data_name,
        data_type,
        average_value,
        unit
    FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS tvvpspf
    WHERE code IN (111301, 114201) -- 111301 - Chléb konzumní kmínový  1.0 kg, 114201 - Mléko polotučné pasterované 1.0 l
    AND `year` IN (
    (SELECT MIN(tvvpspf.`year`) FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS tvvpspf WHERE tvvpspf.data_type = 'Průměrná cena za jednotku'),
    (SELECT MAX(tvvpspf.`year`) FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS tvvpspf WHERE tvvpspf.data_type = 'Průměrná cena za jednotku')
    )
    )
SELECT
    pr.`year`,
    pr.data_name AS food_name,
    CONCAT(FORMAT(pr.average_value, 2), ' Kč/', pr.unit) AS average_food_price,
    CONCAT(FORMAT(pa.average_value, 2), ' ', pa.unit, '/měsíc') AS average_salary,
    CONCAT(FORMAT(pa.average_value / pr.average_value, 2), ' ', pr.unit) AS average_food_amount_per_salary
FROM cte_payroll AS pa
JOIN cte_prices AS pr
ON pa.`year` = pr.`year`;
    