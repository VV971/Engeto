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

SELECT  cp.id, cp.value, cp.value_type_code, cpvt.name, cp. unit_code, cpu.name, cp.calculation_code, cpc.name, cp.industry_branch_code, cp.payroll_year, cp.payroll_quarter
FROM engeto_09_2024.czechia_payroll AS cp
LEFT JOIN engeto_09_2024.czechia_payroll_value_type AS cpvt
ON cp.value_type_code = cpvt.code
LEFT JOIN engeto_09_2024.czechia_payroll_unit AS cpu
ON cp.unit_code = cpu.code
LEFT JOIN engeto_09_2024.czechia_payroll_calculation AS cpc
ON cp.calculation_code = cpc.code