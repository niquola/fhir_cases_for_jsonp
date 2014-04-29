num_rows=$1


tpl=`cat template.json`

statuses=("provisional" "working" "confirmed" "refuted")

categories=( "complaint" "symptom" "finding" "diagnosis")


codes=(
"433.01"
"433.10"
"433.11"
"433.21"
"433.31"
"433.81"
"433.91"
"434.00"
"434.01"
"434.11"
"434.91"
"436"
"430"
"431")

labels=(
"OCL BSLR ART W INFRCT"
"OCL CRTD ART WO INFRCT"
"OCL CRTD ART W INFRCT"
"OCL VRTB ART W INFRCT"
"OCL MLT BI ART W INFRCT"
"OCL SPCF ART W INFRCT"
"OCL ART NOS W INFRCT"
"CRBL THRMBS WO INFRCT"
"CRBL THRMBS W INFRCT"
"CRBL EMBLSM W INFRCT"
"CRBL ART OCL NOS W INFRC"
"CVA"
"SUBARACHNOID HEMORRHAGE"
"INTRACEREBRAL HEMORRHAGE")


# tpl=`cat template.json`
for ((i = 1; i <=$num_rows; i++)); do

  status=${statuses[$((RANDOM%4))]}
  category=${categories[$((RANDOM%4))]}
  idx=$(($i%1000))


  rand_y=$((RANDOM%1+2013))
  rand_m=$((RANDOM%11+1))
  rand_d=$((RANDOM%15+1))
  time_at=`date -d "$rand_y-$rand_m-$rand_d" '+%Y-%m-%d'`

  rand_code=$((RANDOM%110))

if (($rand_code < 11))
then
  code=${codes[$rand_code]}
  label=${labels[$rand_code]}
else
  code="noise-$rand_code"
  label="noise-$rand_code"
fi


  # cat `pwd`/encounter.tpl.json  \

    echo $tpl | sed -e s/{{id}}/$i/  \
    -e "s/{{status}}/$status/g"  \
    -e "s/{{i}}/$i/g"  \
    -e "s/{{idx}}/$idx/g"  \
    -e "s/{{time_at}}/$time_at/g"  \
    -e "s/{{category}}/$category/g"  \
    -e "s/{{code}}/$code/g"  \
    -e "s/{{label}}/$label/g"  \
    -e ':a;N;$!ba;s/\n/ /g'
  done
