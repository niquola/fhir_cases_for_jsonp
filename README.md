Cases for jsonp by Medclient HS-Choice


1. My Encounters for emergency:

FHIR encounter resource is described - http://www.hl7.org/implement/standards/fhir/encounter.html


Select active emergency encounters where 'doc1' is attending or admiting physician:

```
  Encounter.class = 'emergency'
  Encounter.status not in ('planned', 'finished', 'cancelled')

  Encounter
    .participant*
      [.individual
        .type*.coding* [ .coding.code in ('ADM', 'ATND')
                         AND
                         .coding.system = 'encounter-participant-type' ]
       AND .individual.reference = 'concrete physician' ]
```

To generate test data:

env FHIR_NUM=1000 FHIR_HOME=`pwd` psql -d <db> < generate_encounters.sql


Generation script in generate_encouters.sh
