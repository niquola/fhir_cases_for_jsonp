--db: -p 5455 -h localhost jsonb
--{{{
\set prog `echo "cd $FHIR_HOME && bash generate.sh $FHIR_NUM"`

DROP TABLE IF EXISTS stroke_diagnoses;
CREATE TABLE stroke_diagnoses (
    id SERIAL NOT NULL,
    label character varying(255),
    code character varying(255),
    description character varying(255),
    icd9cm_id integer
);

COPY stroke_diagnoses (id, label, code, description, icd9cm_id) FROM stdin;
1	OCL BSLR ART W INFRCT	433.01	Ischemic Stroke	28072
2	OCL CRTD ART WO INFRCT	433.10	Ischemic Stroke	28074
3	OCL CRTD ART W INFRCT	433.11	Ischemic Stroke	28075
4	OCL VRTB ART W INFRCT	433.21	Ischemic Stroke	28078
5	OCL MLT BI ART W INFRCT	433.31	Ischemic Stroke	28081
6	OCL SPCF ART W INFRCT	433.81	Ischemic Stroke	28084
7	OCL ART NOS W INFRCT	433.91	Ischemic Stroke	28087
8	CRBL THRMBS WO INFRCT	434.00	Ischemic Stroke	28090
9	CRBL THRMBS W INFRCT	434.01	Ischemic Stroke	28091
10	CRBL EMBLSM W INFRCT	434.11	Ischemic Stroke	28094
11	CRBL ART OCL NOS W INFRC	434.91	Ischemic Stroke	28097
12	CVA	436	Ischemic Stroke	28105
13	SUBARACHNOID HEMORRHAGE	430	Hemorrhagic Stroke	28063
14	INTRACEREBRAL HEMORRHAGE	431	Hemorrhagic Stroke	28064
\.

DROP TABLE IF EXISTS encounters;
CREATE TABLE encounters (
  id SERIAL primary key,
  doc jsonb
);

COPY encounters (doc) FROM PROGRAM :'prog';

select doc #>>'{code,coding}'
from encounters
limit 10;
--}}}
