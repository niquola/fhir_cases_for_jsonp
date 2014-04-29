--db:jsonp
--{{{
\set prog `echo "cd $FHIR_HOME && bash generate.sh $FHIR_NUM"`

DROP TABLE IF EXISTS observations;
CREATE TABLE observations (
  id SERIAL primary key,
  doc jsonp
);

COPY observations (doc) FROM PROGRAM :'prog';

-- select doc #>>'{name}'
-- from observations
-- limit 10;
--}}}
