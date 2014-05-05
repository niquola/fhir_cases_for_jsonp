\timing
select count(*) from observations;

select count(*) FROM observations
WHERE doc @@ '(
  "name"."coding".# (
    "system" = "http://loinc.org"
     &
    "code" = "8310-5"
  )
)'
AND
(doc #>> '{appliesPeriod,start}')::timestamp > CURRENT_DATE - INTERVAL '3 month'
limit 10;
