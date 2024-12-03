-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

WITH cte_pay_change AS (
	SELECT 
		tvvpspf.`year`,
		tvvpspf.data_name AS industry_branch,
		tvvpspf.data_type AS pay_name,
		tvvpspf.average_value AS average_pay,
		CASE
			WHEN LAG(tvvpspf.average_value) OVER (PARTITION BY tvvpspf.data_name ORDER BY tvvpspf.`year`) IS NULL THEN 'Missing Data'
			WHEN tvvpspf.average_value > (
				SELECT tvvpspf2.average_value
				FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS tvvpspf2
				WHERE tvvpspf2.`year` = tvvpspf.`year` - 1
				AND tvvpspf2.data_name = tvvpspf.data_name
				GROUP BY tvvpspf2.data_name
				) THEN 'Rising'
			ELSE 'Decreasing'
		END AS yty_pay_trend,
		LAG(tvvpspf.average_value) OVER (PARTITION BY tvvpspf.data_name ORDER BY tvvpspf.`year`) AS average_pay_previous_year,
		tvvpspf.average_value - LAG(tvvpspf.average_value) OVER (PARTITION BY tvvpspf.data_name ORDER BY tvvpspf.`year`) AS average_yty_pay_change_abs,
		tvvpspf.average_value / LAG(tvvpspf.average_value) OVER (PARTITION BY tvvpspf.data_name ORDER BY tvvpspf.`year`) AS average_yty_pay_change_percentage
	FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS tvvpspf
	GROUP BY tvvpspf.`year`, tvvpspf.data_name
)
SELECT 
	cte_pc.`year` AS payroll_year,
	cte_pc.industry_branch,
	cte_pc.pay_name,
	ROUND(cte_pc.average_pay, 2) AS average_pay,
	cte_pc.yty_pay_trend,
	ROUND(cte_pc.average_pay_previous_year, 2) AS average_pay_previous_year,
	ROUND(cte_pc.average_yty_pay_change_abs, 2) AS average_yty_pay_change_abs,
	ROUND((cte_pc.average_yty_pay_change_percentage * 100) - 100, 3) AS average_yty_pay_change_percentage
FROM cte_pay_change AS cte_pc
GROUP BY cte_pc.`year`, cte_pc.industry_branch;