\timing

SELECT count(*) FROM encounters;

SELECT
  doc#>'{participant,0}' as part,
  doc#>'{class}' as cls,
  doc#>'{status}' as status
FROM encounters
WHERE
doc @@
'("class" = "emergency" &
  "participant".#."individual" (
    "reference" = "Galen" &
    "type".#."coding".# (
      "code" && ["ADM", "ATND"] &
      "system" = "encounter-participant-type")) &
  !("status" && ["planned", "finished", "cancelled"]))'
limit 10;

SELECT  count(*)
FROM encounters
WHERE
doc @@
'("class" = "emergency" &
  "participant".#."individual" (
    "reference" = "Galen" &
    "type".#."coding".# (
      "code" && ["ADM", "ATND"] &
      "system" = "encounter-participant-type")) &
  !("status" && ["planned", "finished", "cancelled"]))';
