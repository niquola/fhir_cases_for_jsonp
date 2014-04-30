# Profiling:
# $ `time bash ./generate.sh 1000 > /dev/nul`
# real    0m4.969s - 0m5.002s

num_rows=$1

types=("emergency" "inpatient")
part_types=("ADM" "ATND" "CALLBCK" "CON" "DIS" "ESC" "REF")
physs=(
    "Charles R. Drew"
    "Helen Flanders Dunbar"
    "Galen"
    "Ian Olver"
    "Garcia de Orta"
    "Christiaan Eijkman"
    "Pierre Fauchard"
    "Rene Geronimo Favaloro"
    "Alexander Fleming"
    "Girolamo Fracastoro"
    "Sigmund Freud"
    "Daniel Carleton Gajdusek"
    "Henry Gray"
    "George E. Goodfellow"
    "William Harvey"
    "Ernst Haeckel"
    "Henry Heimlich"
    "Orvan Hess"
    "John Hunter"
    "Hippocrates"
    "Elliott P. Joslin"
    "Edward Jenner"
)
statuses=('planned' 'finished' 'cancelled' 'active')

for ((i = 1; i <= $num_rows; i++)); do
    type=${types[$((RANDOM%2))]}
    part_type=${part_types[$((RANDOM%7))]}
    phys=${physs[$((RANDOM%22))]}
    reason="reason$i"
    status=${statuses[$((RANDOM%4))]}

    rand_y=$((RANDOM%1+2013))
    rand_m=$((RANDOM%11+1))
    rand_d=$((RANDOM%15+1))
    rand_ed=$((rand_d + RANDOM%10+1))
    start_at=`date -d "$rand_y-$rand_m-$rand_d" '+%Y-%m-%d'`
    end_at=`date -d "$rand_y-$rand_m-$rand_ed" '+%Y-%m-%d'`

    sed -e ':a;N;$!ba;s/\n/ /g' \
        -e s/{{id}}/$i/  \
        -e "s/{{pt}}/Patient\/$i/"  \
        -e "s/{{type}}/$type/"  \
        -e "s/{{part_type}}/$part_type/"  \
        -e "s/{{reason}}/$reason/"  \
        -e "s/{{start_at}}/$start_at/"  \
        -e "s/{{end_at}}/$end_at/"  \
        -e "s/{{status}}/$status/"  \
        -e "s/{{phys}}/$phys/"  \
        encounter.tpl.json
done
