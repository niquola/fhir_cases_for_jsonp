--db:jsonp
--{{{
\set prog `echo "cd $FHIR_HOME && bash generate_encounters.sh $FHIR_NUM"`

DROP TABLE IF EXISTS encounters;
CREATE TABLE encounters (
  id SERIAL primary key,
  doc json
);

COPY encounters (doc) FROM PROGRAM :'prog';

select * from encounters
limit 10;
--}}}
