--db:jsonp
--{{{
DROP TABLE IF EXISTS encounters;
CREATE TABLE encounters (doc json);

COPY encounters FROM PROGRAM 'cd /home/nicola/w/jsonp_fhir && bash generate_encounters.sh';

select * from encounters
limit 10;
--}}}
