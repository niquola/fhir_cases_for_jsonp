num_rows=$1

statuses=(
    "amended"
    "cancelled"
    "entered in error"
    "final"
    "preliminary"
    "registered"
)

for ((i = 1; i <= $num_rows; i++)); do
    status=${statuses[$((RANDOM%6))]}
    patient_id=$(($i%1000))
    sed -e s/{{patient_id}}/$patient_id/  \
        -e "s/{{status}}/$status/g" \
        template.json
done
