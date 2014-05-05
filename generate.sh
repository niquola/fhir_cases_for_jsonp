# Profiling:
# $ `time bash ./generate.sh 1000 > /dev/nul`
# real    ~ 0m4.730s

num_rows=$1
cd encounters
cat generate.sql
./../generate $num_rows
