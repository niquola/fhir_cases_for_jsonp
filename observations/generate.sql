--db: -p 5455 -h localhost jsonb
--{{{
\set prog `echo "cd $FHIR_HOME && bash generate.sh $FHIR_NUM"`

DROP TABLE IF EXISTS observations;
CREATE TABLE observations (
  id SERIAL primary key,
  doc jsonb
);

COPY observations (doc) FROM PROGRAM :'prog';

-- select doc #>>'{name}'
-- from observations
-- limit 10;
--}}}
