# Profiling:
# $ `time bash ./generate.sh 1000 > /dev/nul`
# real    ~ 0m4.730s

go build generate.go
num_rows=$2
cd "$1"
cat generate.sql
./../generate $num_rows
