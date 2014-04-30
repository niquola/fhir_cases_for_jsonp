--db: -p 5455 -h localhost jsonb
--{{{
\set prog `echo "cd $FHIR_HOME && bash generate.sh $FHIR_NUM"`

DROP TABLE IF EXISTS encounters;
CREATE TABLE encounters (
  id SERIAL primary key,
  doc jsonb
);

COPY encounters (doc) FROM PROGRAM :'prog';

select * from encounters
limit 10;
--}}}
