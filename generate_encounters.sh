# for ((i = 1; i <= 10; i++)); do
# done
#cat `pwd`/encounter.tpl.json

types=("emergency" "inpatient")
part_types=("ADM" "ATND" "CALLBCK" "CON" "DIS" "ESC" "REF")

for ((i = 1; i <= 10; i++)); do

  type=${types[$i%2]}
  part_type=${part_types[$i%7]}
  reason="reason$i"

  rand_y=$((RANDOM%1+2013))
  rand_m=$((RANDOM%12+1))
  rand_d=$((RANDOM%28+1))
  start_at=`date -d "$rand_y-$rand_m-$rand_d" '+%Y-%m-%d'`


  cat `pwd`/encounter.tpl.json  \
    | sed "s/{{id}}/$i/"  \
    | sed "s/{{type}}/$type/"  \
    | sed "s/{{part_type}}/$part_type/"  \
    | sed "s/{{reason}}/$reason/"  \
    | sed "s/{{start_at}}/$start_at/"  \
    | sed ':a;N;$!ba;s/\n/ /g'
done
