CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MyStr0ng!Pass#2024'

CREATE DATABASE SCOPED CREDENTIAL cred_bhavith
WITH
    IDENTITY = 'Managed Identity'

CREATE EXTERNAL DATA SOURCE source_silver
WITH
(
    LOCATION = 'https://storagedatalake2201.blob.core.windows.net/silver',
    CREDENTIAL = cred_bhavith
)

CREATE EXTERNAL DATA SOURCE source_gold
WITH
(
    LOCATION = 'https://storagedatalake2201.blob.core.windows.net/gold',
    CREDENTIAL = cred_bhavith
)

CREATE EXTERNAL FILE FORMAT format_parquet
WITH
(
    FORMAT_TYPE=PARQUET,
    DATA_COMPRESSION='org.apache.hadoop.io.compress.SnappyCodec'
)

CREATE EXTERNAL TABLE gold.extsales
WITH
(
    LOCATION = 'extsales',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
) AS 
SELECT * FROM gold.sales


SELECT * FROM gold.extsales