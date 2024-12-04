/*
Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
*/

WITH cte_food_prices AS (
    SELECT
        tvvpspf.`year`,
        tvvpspf.code AS food_code,
        tvvpspf.data_name AS food_name,
        tvvpspf.average_value AS average_food_price,
        tvvpspf.average_value / LAG(tvvpspf.average_value) OVER (PARTITION BY tvvpspf.data_name ORDER BY tvvpspf.`year`) AS average_yty_food_price_change_percentage
    FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS tvvpspf
    WHERE data_type = 'Průměrná cena za jednotku'
)
SELECT DISTINCT
    cte_fp.food_code,
    cte_fp.food_name,
    ROUND(SUM(cte_fp.average_yty_food_price_change_percentage), 4) AS average_food_price_increase_percentage
FROM cte_food_prices AS cte_fp
GROUP BY 
    cte_fp.food_code,
    cte_fp.food_name
ORDER BY 
    average_food_price_increase_percentage ASC
LIMIT 2;