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

SELECT cp.id, cp.category_code, cpc.name, cp.value, 'Kč' AS currency, cpc.price_value, cpc.price_unit, cp.date_from, cp.region_code 
FROM engeto_26_09_2024.czechia_price AS cp
LEFT JOIN engeto_26_09_2024.czechia_price_category AS cpc 
ON cp.category_code = cpc.code 
WHERE cp.category_code IN (111301, 114201)
AND YEAR(cp.date_from) BETWEEN '2006' AND '2018'
ORDER BY cp.date_from DESC;
-- WHERE cp.category_code IN (111301, 114201) -- 111301 - Chléb konzumní kmínový  1.0 kg, 114201 - Mléko polotučné pasterované 1.0 l
-- AND YEAR(cp.date_from) BETWEEN '2006' AND '2018'
-- LIMIT 500;

SELECT MIN(cp.payroll_year) FROM engeto_26_09_2024.czechia_payroll AS cp

SELECT cp.id, cp.category_code, cpc.name, cp.value, 'Kč' AS currency, cpc.price_value, cpc.price_unit, cp.date_from, cp.region_code 
FROM engeto_26_09_2024.czechia_price AS cp
LEFT JOIN engeto_26_09_2024.czechia_price_category AS cpc 
ON cp.category_code = cpc.code 
WHERE cp.category_code IN (111301, 114201)
AND YEAR(cp.date_from) BETWEEN (SELECT MIN(cp.payroll_year) FROM engeto_26_09_2024.czechia_payroll AS cp) 
AND (SELECT MAX(cp.payroll_year) FROM engeto_26_09_2024.czechia_payroll AS cp)
ORDER BY cp.date_from DESC;

WITH cte_payroll AS (
    SELECT
        `year`,
        -- code,
        -- data_name,
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
        -- code,
        data_name,
        data_type,
        average_value,
        unit
    FROM engeto_26_09_2024.t_vit_vogner_project_sql_primary_final AS tvvpspf
    WHERE code IN (111301, 114201)
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
    