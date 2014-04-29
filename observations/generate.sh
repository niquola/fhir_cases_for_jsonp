num_rows=$1

statuses=("final")

for ((i = 1; i <= $num_rows; i++)); do
    status=${statuses[$((RANDOM%1))]}
    patient_id=$(($i%1000))
    sed -e s/{{patient_id}}/$patient_id/  \
        -e "s/{{status}}/$status/g" \
        template.json
done
