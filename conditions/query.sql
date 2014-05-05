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
AND (doc #>> '{code,coding,0,code}' ) in  (SELECT code from stroke_diagnoses) ;

SELECT  count(*)
FROM conditions
WHERE
doc @@
'("status" = "confirmed" &
  "category"."coding".# (
    "system" = "http://snomed.info/sct" &
    "code" = "diagnosis") &
  "code"."coding".# (
    "system" = "http://snomed.info/sct" &
    "code" in ("433.01", "433.10", "433.11", "433.21", "433.31", "433.81", "433.91", "434.00", "434.01", "434.11", "434.91", "436", "430", "431")
  ))'
;
