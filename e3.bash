GIT_URL="https://github.com/icshwi"
GIT_CMD="git clone"

function git_clone {

    local rep_name=$1
    ${GIT_CMD} ${GIT_URL}/$rep_name
    
}

declare -ga module_list

module_list="e3-env";
module_list+=" " ; module_list+="e3-base";
module_list+=" " ; module_list+="e3-require";
module_list+=" " ; module_list+="e3-iocStats";
module_list+=" " ; module_list+="e3-devlib2";
module_list+=" " ; module_list+="e3-mrfioc2";


for rep in  ${module_list[@]}; do
    git_clone ${rep}
done



for rep in  ${module_list[@]}; do
    cd ${rep}
    make init
    make env
done



for rep in  ${module_list[@]}; do
    cd ${rep}
    make build
done
