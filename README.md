## Medclient cases for jsonb

### Requirements
  golang (sudo apt-get install golang)


### generation

To generate data run:

```sh
  bash generate.sh <encounters,conditions,observations> 100000 | psql -p 5435 -U vagrant -l localhost -d vagrant
```
