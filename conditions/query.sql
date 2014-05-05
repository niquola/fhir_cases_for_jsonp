\timing
CREATE EXTENSION IF NOT EXISTS jsquery;
SELECT count(*) FROM conditions;

SELECT
doc#>'{status}',
doc#>'{category,coding}',
doc#>'{code,coding}'
FROM conditions
limit 10;

SELECT  count(*)
FROM conditions
WHERE
doc @@
'("status" = "confirmed" &
  "category"."coding".# (
    "system" = "http://snomed.info/sct" &
    "code" = "diagnosis") &
  "code"."coding".#."system" = "http://snomed.info/sct")'
AND (doc #>> '{code,coding,0,code}' ) in  (SELECT code from stroke_diagnoses)
;
