num_rows=$1

names=(
    '"name": {"coding": [{"system": "http://loinc.org", "code": "8310-5", "display": "Body temperature"}], "text": "Body temperature"}'
)
statuses=(
    "amended"
    "cancelled"
    "entered in error"
    "final"
    "preliminary"
    "registered"
)

for ((i = 1; i <= $num_rows; i++)); do
    patient_id=$(($i%1000))
    name=${names[$((RANDOM%1))]}
    status=${statuses[$((RANDOM%6))]}
    sed -e "s/{{patient_id}}/$patient_id/g"  \
        -e "s@{{name}}@$name@g" \
        -e "s/{{status}}/$status/g" \
        template.json
done
