## Cases for jsonp by Medclient HS-Choice

### Observation

select all body temperature, and  observation

FHIR resource Observation - http://www.hl7.org/implement/standards/fhir/observation.html#resource

To generate & fill conditions table and stroke_diagnoses table

```bash

  cd conditions

  env FHIR_NUM=1000 FHIR_HOME=`pwd` psql -d <db> < generate.sql
```
