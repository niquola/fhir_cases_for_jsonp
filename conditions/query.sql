SELECT count(*) FROM conditions;

SELECT
doc#>'{category,coding}' as part,
doc#>'{code,coding}' as cls
FROM conditions
limit 10;
