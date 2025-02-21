-- Worst performing I/O bound queries
SELECT TOP 5
st.text AS Worst_IO_bound_query,
qp.query_plan,
qs.*
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY total_logical_reads DESC
GO

-- Worst performing CPU bound queries
SELECT TOP 5
st.text AS Worst_CPU_bound_query,
qp.query_plan,
qs.*
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY total_worker_time DESC
GO