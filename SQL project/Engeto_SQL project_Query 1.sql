-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

WITH cte_pay_change AS (
	SELECT 
		tvv.payroll_year,
		tvv.industry_branch,
		tvv.pay_name,
		tvv.average_pay,
		CASE
			WHEN LAG(tvv.average_pay) OVER (PARTITION BY tvv.industry_branch ORDER BY tvv.payroll_year) IS NULL THEN 'Missing Data'
			WHEN tvv.average_pay > (
				SELECT tvv2.average_pay
				FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS tvv2
				WHERE tvv2.payroll_year = tvv.payroll_year - 1
				AND tvv2.industry_branch = tvv.industry_branch
				GROUP BY tvv2.industry_branch
				) THEN 'Rising'
			ELSE 'Decreasing'
		END AS YtY_pay_trend,
		LAG(tvv.average_pay) OVER (PARTITION BY tvv.industry_branch ORDER BY tvv.payroll_year) AS average_pay_previous_year,
		tvv.average_pay - LAG(tvv.average_pay) OVER (PARTITION BY tvv.industry_branch ORDER BY tvv.payroll_year) AS average_YtY_pay_change_Abs,
		tvv.average_pay / LAG(tvv.average_pay) OVER (PARTITION BY tvv.industry_branch ORDER BY tvv.payroll_year) AS average_YtY_pay_change_Percentage
	FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS tvv
	GROUP BY tvv.payroll_year, tvv.industry_branch
)
SELECT 
	cte_pc.payroll_year,
	cte_pc.industry_branch,
	cte_pc.pay_name,
	ROUND(cte_pc.average_pay, 2) AS average_pay,
	cte_pc.YtY_pay_trend,
	ROUND(cte_pc.average_pay_previous_year, 2) AS average_pay_previous_year,
	ROUND(cte_pc.average_YtY_pay_change_Abs, 2) AS average_YtY_pay_change_Abs,
	ROUND((cte_pc.average_YtY_pay_change_Percentage * 100) - 100, 3) AS average_YtY_pay_change_Percentage
FROM cte_pay_change AS cte_pc
GROUP BY cte_pc.payroll_year, cte_pc.industry_branch;