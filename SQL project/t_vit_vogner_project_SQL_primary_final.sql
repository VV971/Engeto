CREATE TABLE IF NOT EXISTS t_vit_vogner_project_SQL_primary_final AS (
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
ORDER BY cp.payroll_year, cpib.name
);
