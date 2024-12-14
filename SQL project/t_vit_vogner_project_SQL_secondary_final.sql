/*
Výstup projektu: dvě tabulky v databázi, ze kterých se požadovaná data dají získat. Tabulky pojmenujte t_{jmeno}_{prijmeni}_project_SQL_primary_final (pro data mezd
 a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky) a t_{jmeno}_{prijmeni}_project_SQL_secondary_final (pro dodatečná 
 data o dalších evropských státech).
*/

CREATE TABLE IF NOT EXISTS t_vit_vogner_project_SQL_secondary_final AS (
SELECT
    c.region_in_world AS region,
    c.country AS country,
    c.abbreviation,
    e.`year`,
    e.GDP,
    e.population,
    c.currency_name,
    c.currency_code 
FROM engeto_26_09_2024.countries AS c
LEFT JOIN engeto_26_09_2024.economies AS e 
ON c.country = e.country 
WHERE c.continent = 'Europe'    -- vybírám Evropu
AND c.region_in_world IN ('Eastern Europe', 'Baltic Countries') -- vybírám střední Evropu a pobaltské státy
AND c.country <> 'Czech Republic'   -- vylučuji ČR, pro kterou už mám podrobná data v primární tabulce
AND e.GDP IS NOT NULL
AND e.`year` BETWEEN (SELECT
                          CASE 
                              WHEN MIN(cpa.payroll_year) > MIN(YEAR(cpi.date_from)) THEN MIN(cpa.payroll_year)
                              WHEN MIN(YEAR(cpi.date_from)) > MIN(cpa.payroll_year) THEN MIN(YEAR(cpi.date_from))
                          END AS min_year  -- vybírám větší z minimálních roků, abych data sjednotil na totožné období 
                      FROM engeto_26_09_2024.czechia_payroll AS cpa
                      LEFT JOIN engeto_26_09_2024.czechia_price AS cpi
                      ON cpa.payroll_year = YEAR(cpi.date_from))
AND (SELECT
        CASE 
            WHEN MAX(cpa.payroll_year) > MAX(YEAR(cpi.date_from)) THEN MAX(YEAR(cpi.date_from))
            WHEN MAX(YEAR(cpi.date_from)) > MAX(cpa.payroll_year) THEN MAX(cpa.payroll_year)
        END AS max_year  -- vybírám menší z maximálních roků, abych data sjednotil na totožné období
    FROM engeto_26_09_2024.czechia_payroll AS cpa
    LEFT JOIN engeto_26_09_2024.czechia_price AS cpi
    ON cpa.payroll_year = YEAR(cpi.date_from))
ORDER BY c.region_in_world ASC, c.country ASC, e.`year` ASC);