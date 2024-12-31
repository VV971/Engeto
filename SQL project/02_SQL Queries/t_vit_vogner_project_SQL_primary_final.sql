/*
Výstup projektu: dvě tabulky v databázi, ze kterých se požadovaná data dají získat. Tabulky pojmenujte t_{jmeno}_{prijmeni}_project_SQL_primary_final (pro data mezd
 a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky) a t_{jmeno}_{prijmeni}_project_SQL_secondary_final (pro dodatečná 
 data o dalších evropských státech).
*/

/*
Poznámka k výkonnosti - tento SQL dotaz jsem napsal tak, aby přesně odpovídal zadání, což se odrazilo na tom, že je prakticky nepoužitelný kvůli době výpočtu, která 
pro lokální databázi činila cca 140 vteřin. V praxi bych dotaz upravil tak, že bych limity roků zadal buď napevno nebo bych je uložil do proměnných, které bych 
potom použil v proceduře.
*/

CREATE TABLE IF NOT EXISTS t_vit_vogner_project_SQL_primary_final AS (
WITH cte_platy AS (
    SELECT  
        cp.payroll_year AS rok,
        NULL AS kod,
        cpib.name AS nazev,
        cpvt.name AS datovy_typ,
        AVG(cp.value) AS prumerna_hodnota,
        cpu.name AS jednotka
    FROM engeto_26_09_2024.czechia_payroll AS cp
    LEFT JOIN engeto_26_09_2024.czechia_payroll_value_type AS cpvt
    ON cp.value_type_code = cpvt.code
    LEFT JOIN engeto_26_09_2024.czechia_payroll_unit AS cpu
    ON cp.unit_code = cpu.code
    LEFT JOIN engeto_26_09_2024.czechia_payroll_calculation AS cpc
    ON cp.calculation_code = cpc.code
    LEFT JOIN engeto_26_09_2024.czechia_payroll_industry_branch AS cpib
    ON cp.industry_branch_code = cpib.code
    WHERE cpvt.code = 5958  -- 5958 = Průměrná hrubá mzda na zaměstnance
    AND cpu.code = 200      -- 200 = Kč
    AND cpc.code = 100      -- 100 = Fyzické osoby (200 = Přepočtené počty, ale neznám počet zaměstnanců, proto je z dotazu vyřazuji)
    AND cpib.code IS NOT NULL
    AND cp.payroll_year >= (
                            SELECT
                                CASE 
                                    WHEN MIN(cpa.payroll_year) > MIN(YEAR(cpi.date_from)) THEN MIN(cpa.payroll_year)
                                    WHEN MIN(YEAR(cpi.date_from)) > MIN(cpa.payroll_year) THEN MIN(YEAR(cpi.date_from))
                                END AS min_rok  -- vybírám větší z minimálních roků, abych data sjednotil na totožné období 
                            FROM engeto_26_09_2024.czechia_payroll AS cpa
                            LEFT JOIN engeto_26_09_2024.czechia_price AS cpi
                            ON cpa.payroll_year = YEAR(cpi.date_from))
    AND cp.payroll_year <= (
                            SELECT
                                CASE 
                                    WHEN MAX(cpa.payroll_year) > MAX(YEAR(cpi.date_from)) THEN MAX(YEAR(cpi.date_from))
                                    WHEN MAX(YEAR(cpi.date_from)) > MAX(cpa.payroll_year) THEN MAX(cpa.payroll_year)
                            END AS max_rok  -- vybírám menší z maximálních roků, abych data sjednotil na totožné období
                            FROM engeto_26_09_2024.czechia_payroll AS cpa
                            LEFT JOIN engeto_26_09_2024.czechia_price AS cpi
                            ON cpa.payroll_year = YEAR(cpi.date_from))
    GROUP BY cp.payroll_year, cpib.name
    ORDER BY cp.payroll_year, cpib.name ASC
    ),
     cte_ceny AS (
    SELECT 
        YEAR(cp.date_from) AS rok,
        cp.category_code AS kod,
        cpc.name AS nazev,
        'Průměrná cena za jednotku' AS datovy_typ,
        ROUND(AVG(cp.value), 2) AS prumerna_hodnota,
        cpc.price_unit AS jednotka
    FROM engeto_26_09_2024.czechia_price AS cp
    LEFT JOIN engeto_26_09_2024.czechia_price_category AS cpc 
    ON cp.category_code = cpc.code
    WHERE YEAR(cp.date_from) >= (SELECT
                                    CASE 
                                        WHEN MIN(cpa.payroll_year) > MIN(YEAR(cpi.date_from)) THEN MIN(cpa.payroll_year)
                                        WHEN MIN(YEAR(cpi.date_from)) > MIN(cpa.payroll_year) THEN MIN(YEAR(cpi.date_from))
                                    END AS min_rok  -- vybírám větší z minimálních roků, abych data sjednotil na totožné období
                                FROM engeto_26_09_2024.czechia_payroll AS cpa
                                LEFT JOIN engeto_26_09_2024.czechia_price AS cpi
                                ON cpa.payroll_year = YEAR(cpi.date_from))
    AND YEAR(cp.date_from) <= (SELECT
                                    CASE 
                                        WHEN MAX(cpa.payroll_year) > MAX(YEAR(cpi.date_from)) THEN MAX(YEAR(cpi.date_from))
                                        WHEN MAX(YEAR(cpi.date_from)) > MAX(cpa.payroll_year) THEN MAX(cpa.payroll_year)
                                END AS max_rok  -- vybírám menší z maximálních roků, abych data sjednotil na totožné období
                                FROM engeto_26_09_2024.czechia_payroll AS cpa
                                LEFT JOIN engeto_26_09_2024.czechia_price AS cpi
                                ON cpa.payroll_year = YEAR(cpi.date_from))
    GROUP BY rok, nazev, datovy_typ
    ORDER BY YEAR(cp.date_from) ASC
    )
SELECT cte_pl.*
FROM cte_platy AS cte_pl
GROUP BY cte_pl.rok, cte_pl.nazev
UNION ALL
SELECT cte_ce.*
FROM cte_ceny AS cte_ce
GROUP BY cte_ce.rok, cte_ce.nazev);