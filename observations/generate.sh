num_rows=$1

names=(
    '"name": {"coding": [{"system": "http://loinc.org", "code": "8310-5", "display": "Body temperature"}], "text": "Body temperature"}'
    '"name": {"coding": [{"system": "http://loinc.org", "code": "55284-4", "display": "Blood pressure systolic \& diastolic"}]}'
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
    status=${statuses[$((RANDOM%6))]}

    name_index=$((RANDOM%3))
    if (($name_index < 2)); then
        name=${names[$name_index]}
    else
        name="\"name\": {\"coding\": [{\"system\": \"http://loinc.org\", \"code\": \"noise-$name_index\", \"display\": \"noise $name_index\"}], \"text\": \"Noise $name_index\"}"
    fi

    sed -e "s/{{patient_id}}/$patient_id/g"  \
        -e "s@{{name}}@$name@" \
        -e "s/{{status}}/$status/g" \
        template.json
done
