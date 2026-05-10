
CREATE VIEW gold.Calendar
AS
SELECT
    *
FROM
    OPENROWSET
        (
            BULK 'https://storagedatalake2201.blob.core.windows.net/silver/Calendar/',
            FORMAT = 'PARQUET'
        ) as Query1



CREATE VIEW gold.Products
AS
SELECT
    *
FROM
    OPENROWSET
        (
            BULK 'https://storagedatalake2201.blob.core.windows.net/silver/Products/',
            FORMAT = 'PARQUET'
        ) as Query1



CREATE VIEW gold.Customers
AS
SELECT
    *
FROM
    OPENROWSET
        (
            BULK 'https://storagedatalake2201.blob.core.windows.net/silver/Customers/',
            FORMAT = 'PARQUET'
        ) as Query1




CREATE VIEW gold.Product_Categories
AS
SELECT
    *
FROM
    OPENROWSET
        (
            BULK 'https://storagedatalake2201.blob.core.windows.net/silver/Product_Categories/',
            FORMAT = 'PARQUET'
        ) as Query1


CREATE VIEW gold.Product_Subcategories
AS
SELECT
    *
FROM
    OPENROWSET
        (
            BULK 'https://storagedatalake2201.blob.core.windows.net/silver/Product_Subcategories/',
            FORMAT = 'PARQUET'
        ) as Query1



CREATE VIEW gold.Returns
AS
SELECT
    *
FROM
    OPENROWSET
        (
            BULK 'https://storagedatalake2201.blob.core.windows.net/silver/Returns/',
            FORMAT = 'PARQUET'
        ) as Query1




CREATE VIEW gold.Sales
AS
SELECT
    *
FROM
    OPENROWSET
        (
            BULK 'https://storagedatalake2201.blob.core.windows.net/silver/Sales/',
            FORMAT = 'PARQUET'
        ) as Query1

DROP VIEW IF EXISTS gold.Sales


CREATE VIEW gold.Territories
AS
SELECT
    *
FROM
    OPENROWSET
        (
            BULK 'https://storagedatalake2201.blob.core.windows.net/silver/Territories/',
            FORMAT = 'PARQUET'
        ) as Query1







