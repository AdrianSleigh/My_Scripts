--PageLifeExpectancy
SELECT
    SUBSTRING(counter_name, 1, 20) AS PageLifeExpectancy,
    cntr_value AS PageLifeValue,
    RIGHT('0' + CAST(cntr_value / 3600 AS VARCHAR(10)), 2) + ':' +
    RIGHT('0' + CAST((cntr_value % 3600) / 60 AS VARCHAR(10)), 2) + ':' +
    RIGHT('0' + CAST(cntr_value % 60 AS VARCHAR(10)), 2) AS TimeHMS
FROM sys.dm_os_performance_counters
WHERE object_name LIKE '%Buffer Manager%'
  AND counter_name = 'Page life expectancy';
