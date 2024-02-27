---FIND NON CONFORMING DB OWNERS
---------------------------------------------------
select [name]AS 'DB NAME' 
,suser_sname(owner_sid)AS 'OWNER'
, count(*) AS 'NON CONFORMING' from sys.databases
where suser_sname(owner_sid) NOT in ('sa','topdog')
GROUP BY [name],[owner_sid]