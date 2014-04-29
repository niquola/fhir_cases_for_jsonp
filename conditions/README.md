## Cases for jsonp by Medclient HS-Choice


### First step in quality measures

select all heart diagnoses for last 3 month
for measures calculation


```
status = "confirmed"

category.coding = {
  "system": "http://snomed.info/sct",
  "code": "439401001",
  "display": "diagnosis"
}

dateAsserted > CURRENT_DATE - INTERVAL '3 months'

code.coding = {
  "system": "http://snomed.info/sct",
  "code": in (select code from stroke_cases_value_set)
}

```

To generate & fill conditions table and stroke_diagnoses table

```bash

  cd conditions

  env FHIR_NUM=1000 FHIR_HOME=`pwd` psql -d <db> < generate.sql
```
