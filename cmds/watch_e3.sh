

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_TOP="${SC_SCRIPT%/*}"



watch -n 1 "bash ${SC_TOP}/../caget_pvs.bash ${SC_TOP}/20180509_E3Test_PVs.list "HEART""
