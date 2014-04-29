## Cases for jsonp by Medclient HS-Choice

### Observation

select all body temperature observations for last 3 month

FHIR resource Observation - http://www.hl7.org/implement/standards/fhir/observation.html#resource

name: body temperature or blood pressure

```javascript
{
  "coding": [
    {
      "system": "http://snomed.info/sct",
      "code": "415945006",
      "display": "Oral temperature"
    },
    {
      "system": "http://loinc.org",
      "code": "8310-5",
      "display": "Body temperature"
    }
  ],
  "text": "Body temperature"
}

OR

{
  "coding": [
    {
      "system": "http://loinc.org",
      "code": "55284-4",
      "display": "Blood pressure systolic & diastolic"
    }
  ]
},
```

```javascript
status = "final"
```

appliesPeriod OR appliesDateTime

```javascript
appliesPeriod = {"end": greater_than_or_equal("2014-01-29T09:30:10+01:00")}

OR

appliesDateTime >= "2014-01-29T09:30:10+01:00",

```

To generate & fill conditions table and stroke_diagnoses table

```bash

  cd conditions

  env FHIR_NUM=1000 FHIR_HOME=`pwd` psql -d <db> < generate.sql
```
