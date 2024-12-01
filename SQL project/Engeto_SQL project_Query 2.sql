/*
Primární tabulky:

czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených
 dat ČR.
czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.
czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.
czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.
czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.
czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených 
dat ČR.
czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.
Číselníky sdílených informací o ČR:

czechia_region – Číselník krajů České republiky dle normy CZ-NUTS 2.
czechia_district – Číselník okresů České republiky dle normy LAU.
Dodatečné tabulky:

countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška 
populace.
economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období
 v dostupných datech cen a mezd?
/*
czechia_payroll
-- Min_Date = 2000
-- Max_Date = 2021
*/
SELECT cp.*
FROM engeto_26_09_2024.czechia_payroll AS cp
ORDER BY cp.payroll_year DESC 
-- limit 500;

/*
100 - fyzický
200 - přepočtený
*/

SELECT cpc.*
FROM engeto_26_09_2024.czechia_payroll_calculation AS cpc;

/*
316	- Průměrný počet zaměstnaných osob
5958 - Průměrná hrubá mzda na zaměstnance
*/

SELECT cpvt.*
FROM engeto_26_09_2024.czechia_payroll_value_type as cpvt;

/*
200	- Kč
80403 - tis. osob (tis. os.)
*/

SELECT cpu.*
FROM engeto_26_09_2024.czechia_payroll_unit as cpu;

/*
111301 - Chléb konzumní kmínový  1.0 kg
114201 - Mléko polotučné pasterované 1.0 l
 */

SELECT cpca.*
FROM engeto_26_09_2024.czechia_price_category AS cpca
WHERE cpca.name LIKE "Mléko %" 
OR cpca.name LIKE "Chléb %";

/*
czechia_price
Min_Date = 2006-01-02 00:00:00.000
Max_Date = 2018-12-10 00:00:00.000
 */
SELECT MAX(cp.date_from)
FROM engeto_26_09_2024.czechia_price AS cp;

SELECT cp.*
FROM engeto_26_09_2024.czechia_price AS cp
WHERE cp.category_code IN (111301, 114201)
AND YEAR(cp.date_from) BETWEEN '2006' AND '2018'
ORDER BY cp.date_from DESC;
-- LIMIT 500;