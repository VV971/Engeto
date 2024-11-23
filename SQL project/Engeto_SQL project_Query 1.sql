-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
/*
Primární tabulky:

czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.
czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.
czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.
czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.
czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.
Číselníky sdílených informací o ČR:

czechia_region – Číselník krajů České republiky dle normy CZ-NUTS 2.
czechia_district – Číselník okresů České republiky dle normy LAU.
Dodatečné tabulky:

countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.
*/
SELECT  *
FROM engeto_09_2024.czechia_payroll 

SELECT  *
FROM engeto_09_2024.czechia_payroll_calculation 

SELECT  *
FROM engeto_09_2024.czechia_payroll_industry_branch

SELECT  *
FROM engeto_09_2024.czechia_payroll_unit

SELECT  *
FROM engeto_09_2024.czechia_payroll_value_type

EXPLAIN
SELECT  cp.id, cp.value, cp.value_type_code, cpvt.name, cp. unit_code, cpu.name, cp.calculation_code, cpc.name, cp.industry_branch_code, cpib.name, cp.payroll_year, cp.payroll_quarter
FROM engeto_09_2024.czechia_payroll AS cp
LEFT JOIN engeto_09_2024.czechia_payroll_value_type AS cpvt
ON cp.value_type_code = cpvt.code
LEFT JOIN engeto_09_2024.czechia_payroll_unit AS cpu
ON cp.unit_code = cpu.code
LEFT JOIN engeto_09_2024.czechia_payroll_calculation AS cpc
ON cp.calculation_code = cpc.code
LEFT JOIN engeto_09_2024.czechia_payroll_industry_branch AS cpib
ON cp.industry_branch_code = cpib.code;

  
SELECT 	cp.payroll_year,
		cpib.name AS industry_branch,
		AVG(cp.value) AS summary_pay,
		-- cp.id,
		-- cp.value_type_code,
		-- cpvt.name AS payroll_value_type,
		-- cp. unit_code,
		cpu.name AS currency
		-- cp.calculation_code,
		-- cpc.name,
		-- cp.industry_branch_code,
		-- cp.payroll_quarter
FROM engeto_09_2024.czechia_payroll AS cp
LEFT JOIN engeto_09_2024.czechia_payroll_value_type AS cpvt
ON cp.value_type_code = cpvt.code
LEFT JOIN engeto_09_2024.czechia_payroll_unit AS cpu
ON cp.unit_code = cpu.code
-- LEFT JOIN engeto_09_2024.czechia_payroll_calculation AS cpc
-- ON cp.calculation_code = cpc.code
LEFT JOIN engeto_09_2024.czechia_payroll_industry_branch AS cpib
ON cp.industry_branch_code = cpib.code
WHERE cpvt.code = 5958 AND cpib.code IS NOT NULL 
GROUP BY cp.payroll_year, cpib.name
ORDER BY cp.payroll_year, cpib.name;


SELECT 	
	cp.payroll_year,
	cpib.name AS industry_branch,
	cpvt.name AS pay_name,
	AVG(cp.value) AS average_pay,
	cpu.name AS currency
FROM engeto_09_2024.czechia_payroll AS cp
LEFT JOIN engeto_09_2024.czechia_payroll_value_type AS cpvt
ON cp.value_type_code = cpvt.code
LEFT JOIN engeto_09_2024.czechia_payroll_unit AS cpu
ON cp.unit_code = cpu.code
LEFT JOIN engeto_09_2024.czechia_payroll_industry_branch AS cpib
ON cp.industry_branch_code = cpib.code
WHERE cpvt.code = 5958 AND cpib.code IS NOT NULL 
GROUP BY cp.payroll_year, cpib.name
ORDER BY cp.payroll_year, cpib.name;

SELECT 	
	cp.payroll_year,
	cpib.name AS industry_branch,
	cpvt.name AS pay_name,
	AVG(cp.value) AS average_pay,
	cpu.name AS currency
FROM engeto_09_2024.czechia_payroll AS cp
LEFT JOIN engeto_09_2024.czechia_payroll_value_type AS cpvt
ON cp.value_type_code = cpvt.code
LEFT JOIN engeto_09_2024.czechia_payroll_unit AS cpu
ON cp.unit_code = cpu.code
LEFT JOIN engeto_09_2024.czechia_payroll_industry_branch AS cpib
ON cp.industry_branch_code = cpib.code
WHERE cpvt.code = 5958 AND cpib.code IS NOT NULL 
GROUP BY cp.payroll_year, cpib.name
ORDER BY cp.payroll_year, cpib.name;

SELECT 
	tvv.payroll_year,
	tvv.industry_branch,
	tvv.pay_name,
	tvv.average_pay,
	tvv.average_pay > (
		SELECT tvv2.average_pay
		FROM engeto_09_2024.t_vit_vogner_project_sql_primary_final AS tvv2
		WHERE tvv2.payroll_year = tvv.payroll_year - 1
		AND tvv2.industry_branch = tvv.industry_branch
		AND tvv2.pay_name = 'Průměrná hrubá mzda na zaměstnance'
		GROUP BY tvv2.industry_branch
		) AS YtY_pay_growth,
	LAG(tvv.average_pay) OVER (PARTITION BY tvv.industry_branch ORDER BY tvv.payroll_year) AS avg_previous_year,
	tvv.average_pay / LAG(tvv.average_pay) OVER (PARTITION BY tvv.industry_branch ORDER BY tvv.payroll_year) AS average_change
FROM engeto_09_2024.t_vit_vogner_project_sql_primary_final AS tvv
GROUP BY tvv.payroll_year, tvv.industry_branch;