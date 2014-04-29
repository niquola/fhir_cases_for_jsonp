Cases for jsonp by Medclient HS-Choice

## Select all heart deceases

```

status = "confirmed"

category.coding = {
  "system": "http://snomed.info/sct",
  "code": "439401001",
  "display": "diagnosis"
}

dateAsserted > 1 month

code.coding = {
  "system": "http://snomed.info/sct",
  "code": in (select code from value_sets.stroke_cases)
}


```

To generate test data:

```bash

  git clone https://github.com/niquola/fhir_cases_for_jsonp.git

  cd fhir_cases_for_jsonp/conditions

  env FHIR_NUM=1000 FHIR_HOME=`pwd` psql -d <db> < generate.sql
```


Generation script in generate_encouters.sh
