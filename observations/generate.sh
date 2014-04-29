num_rows=$1

for ((i = 1; i <=$num_rows; i++)); do

    # sed -e s/{{id}}/$i/  \
    #     -e "s/{{status}}/$status/g"  \
    #     -e "s/{{i}}/$i/g" \
    #     template.json
done
