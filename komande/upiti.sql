-- ORDER_FACT
-- Prihodi po kvartalima
SELECT dt.YEAR AS Godina,
       dt.QUARTER AS Kvartal,
       CAST(SUM(ofc.QUANTITY * ofc.PROFIT_MARGIN) AS INTEGER) AS "Ukupni prihodi"
FROM ORDER_FACT ofc
JOIN DIM_TIME dt ON ofc.ORDER_DATE_FK = dt.ORDER_DATE_ID
GROUP BY dt.YEAR, dt.QUARTER
ORDER BY dt.YEAR, dt.QUARTER;

-- Profit po kategoriji proizvoda
SELECT dp.CATEGORY_NAME AS "Ime kategorije",
       SUM(ofc.QUANTITY) AS "Ukupno narudžbi",
       CAST(SUM(ofc.QUANTITY * ofc.PROFIT_MARGIN) AS INTEGER) AS "Ukupni profit",
       CAST(SUM(ofc.QUANTITY * ofc.PROFIT_MARGIN)/NULLIF(SUM(ofc.QUANTITY), 0) AS INTEGER) AS "Zarada po jedinici proizvoda"
FROM ORDER_FACT ofc
JOIN DIM_PRODUCT dp ON ofc.DIM_PRODUCT_FK = dp.DIM_PRODUCT_ID
WHERE ofc.STATUS != 'Pending'
GROUP BY dp.CATEGORY_NAME
ORDER BY "Ukupni profit" DESC;

-- Top 5 kompanija kupaca po ukupnoj potrošnji
SELECT dc.COMPANY_NAME AS "Ime kompanije kupca",
       CAST(SUM(ofc.QUANTITY * ofc.LIST_PRICE) AS INTEGER) AS "Ukupna potrošnja kompanije kupca",
       CAST(SUM(ofc.QUANTITY * ofc.PROFIT_MARGIN) AS INTEGER) AS "Naš ukupni profit poslovanja s njima"
FROM ORDER_FACT ofc
JOIN DIM_CUSTOMER dc ON ofc.DIM_CUSTOMER_FK = dc.DIM_CUSTOMER_ID
GROUP BY dc.COMPANY_NAME
ORDER BY "Ukupna potrošnja kompanije kupca" DESC
LIMIT 5;

-- Uspjeh prodavača rangirano opadajuće
SELECT de.FULL_NAME AS Ime,
       COUNT(DISTINCT ofc.ORDER_ID) AS "Broj narudžbi",
       CAST(SUM(ofc.QUANTITY * ofc.LIST_PRICE) AS INTEGER) AS "Ukupna vrijednost dogovorenih narudžbi"
FROM ORDER_FACT ofc
JOIN DIM_EMPLOYEE de ON ofc.DIM_EMPLOYEE_FK = de.DIM_EMPLOYEE_ID
GROUP BY de.FULL_NAME
ORDER BY "Ukupna vrijednost dogovorenih narudžbi" DESC;

-- Mjesečni trendovi po statusu narudžbi
SELECT dt.YEAR AS Godina,
       dt.MONTH AS Mjesec,
       ofc.STATUS AS Status,
       COUNT(ofc.ORDER_ID) AS "Ukupno narudžbi",
       CAST(SUM(ofc.QUANTITY * ofc.PROFIT_MARGIN) AS INTEGER) AS Profit
FROM ORDER_FACT ofc
JOIN DIM_TIME dt ON ofc.ORDER_DATE_FK = dt.ORDER_DATE_ID
GROUP BY dt.YEAR, dt.MONTH, ofc.STATUS
ORDER BY dt.YEAR, dt.MONTH, Profit;

-- INVENTORY_FACT
-- Top 10 proizvoda na stanju po različitim skladištima
WITH RangiraniProizvodi AS ( -- CTE (Common Table Expression)
    SELECT dw.CITY_NAME AS "Lokacija skladišta",
           dp.CATEGORY_NAME AS "Kategorija proizvoda",
           dp.PRODUCT_NAME AS "Ime proizvoda",
           SUM(ifc.QUANTITY) AS "Trenutno stanje",
           ROW_NUMBER() OVER (
               PARTITION BY dw.CITY_NAME
               ORDER BY SUM(ifc.QUANTITY) DESC
           ) AS br_reda
    FROM INVENTORY_FACT ifc
    JOIN DIM_WAREHOUSE dw ON ifc.DIM_WAREHOUSE_FK = dw.DIM_WAREHOUSE_ID
    JOIN DIM_PRODUCT dp ON ifc.DIM_PRODUCT_FK = dp.DIM_PRODUCT_ID
    GROUP BY dw.CITY_NAME, dp.PRODUCT_NAME
)
SELECT "Ime proizvoda",
       "Kategorija proizvoda",
       "Lokacija skladišta",
       "Trenutno stanje"
FROM RangiraniProizvodi
WHERE br_reda <= 10
ORDER BY "Lokacija skladišta" ASC, "Trenutno stanje" DESC;

-- Skladišta sa najvećom vrijednošću
SELECT dw.CITY_NAME,
       CAST(SUM(ifc.QUANTITY * ifc.STANDARD_COST) AS INTEGER) AS "Ukupna vrijednost",
       CAST(SUM(ifc.QUANTITY * ifc.PROFIT_MARGIN) AS INTEGER) AS "Potencijalni profit"
FROM INVENTORY_FACT ifc
JOIN DIM_WAREHOUSE dw ON ifc.DIM_WAREHOUSE_FK = dw.DIM_WAREHOUSE_ID
GROUP BY dw.CITY_NAME
ORDER BY "Ukupna vrijednost" DESC;

-- 10 najzastupljenijih proizvoda u skladištima
SELECT dp.PRODUCT_NAME AS "Ime proizvoda",
       SUM(ifc.QUANTITY) AS "Dostupna količina",
       dw.CITY_NAME AS "Lokacija skladišta"
FROM INVENTORY_FACT ifc
JOIN DIM_WAREHOUSE dw ON ifc.DIM_WAREHOUSE_FK = dw.DIM_WAREHOUSE_ID
JOIN DIM_PRODUCT dp ON ifc.DIM_PRODUCT_FK = dp.DIM_PRODUCT_ID
GROUP BY dp.PRODUCT_NAME, dw.CITY_NAME
ORDER BY "Dostupna količina" DESC
LIMIT 10;
