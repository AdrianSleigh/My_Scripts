----page life
SELECT object_name,counter_name,cntr_value as PageLifeValue
FROM sys.dm_os_performance_counters WHERE
object_name like '%Buffer Manager%'
AND counter_name = 'Page life expectancy'  