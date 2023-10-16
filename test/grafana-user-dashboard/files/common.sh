### EXPORT ###

set -e

fetch_fields() {
    curl --noproxy "*" -k -H "Authorization: Bearer ${1}" "${HOST_exp}/api/${2}" | jq -r "if type==\"array\" then .[] else . end| .${3}"
}

for row in "${ORGS_exp[@]}" ; do
    ORG=${row%%:*}
    KEY=${row#*:}
    DIR="$FILE_DIR_exp/$ORG"

    mkdir -p "$DIR/dashboards"
    mkdir -p "$DIR/datasources"
    mkdir -p "$DIR/alert-notifications"

    for dash in $(fetch_fields $KEY 'search?query=&' 'uri'); do
        DB=$(echo ${dash}|sed 's,db/,,g').json
        echo $DB
        curl --noproxy "*" -k -H "Authorization: Bearer ${KEY}" "${HOST_exp}/api/dashboards/${dash}" | jq 'del(.overwrite,.dashboard.version,.meta.created,.meta.createdBy,.meta.updated,.meta.updatedBy,.meta.expires,.meta.version)' > "$DIR/dashboards/$DB"
    done

    for id in $(fetch_fields $KEY 'datasources' 'id'); do
        DS=$(echo $(fetch_fields $KEY "datasources/${id}" 'name')|sed 's/ /-/g').json
        echo $DS
        curl --noproxy "*" -k -H "Authorization: Bearer ${KEY}" "${HOST_exp}/api/datasources/${id}" | jq '' > "$DIR/datasources/${id}.json"
    done

    for id in $(fetch_fields $KEY 'alert-notifications' 'id'); do
        FILENAME=${id}.json
        echo $FILENAME
        curl --noproxy "*" -k -H "Authorization: Bearer ${KEY}" "${HOST_exp}/api/alert-notifications/${id}" | jq 'del(.created,.updated)' > "$DIR/alert-notifications/$FILENAME"
    done

done

### PUSH TO GIT ###

branch=`git rev-parse --abbrev-ref HEAD`

cd /home/ansible/git/obs-infrastructure/roles/grafana-user-dashboard/files/grafana-user-dashboard/sources/
echo "INFO: Update git repository"
git checkout $branch && 
git pull && 
echo "INFO: Commit changes" && 
git add . && 
set +e
git commit -m "There are changes in Grafana sources" && 
set -e
echo "INFO: Push changes to git repository" && 
git push

### IMPORT ###

declare -aa ORGMAP
for row in "${ORGS[@]}"; do
    IFS=':' read -r -a values <<< "$row"
    ORGMAP[${values[0]}]=${values[1]}
done

curl_wrap() {
    local FILE=$1
    local KEY=$2
    local URL=$3

    cat $FILE | jq '. * {overwrite: true, dashboard: {id: null}}' | \
    curl --noproxy '*' -X POST -H "Content-Type: application/json" \
    -H "Authorization: Bearer $KEY" $URL -d @-

}

import_file() {
    local FILE="$1"
    local KEY="$2"
    local TYPE="$3"

    if ! [ -f "$FILE" ]; then
        echo "$FILE not found." >>/dev/stderr
        return
    fi

    echo "Processing $FILE file..."
    curl_wrap "$FILE" "$KEY" "${HOST}/api/$TYPE"
    CURL_EXIT=$?
    echo

    if [[ ${CURL_EXIT} = 22 && $TYPE = "datasources" ]]; then
        echo "409 conflict error is normal. Retrying as update."
        id=$(basename $file .json)
        curl_wrap "$FILE" "$KEY" "${HOST}/api/$TYPE/$id" PUT
    elif [[ ${CURL_EXIT} = 22 && $TYPE = "alert-notifications" ]]; then
        echo "500 server error is normal. Retrying as update."
        id=$(basename $file .json)
        curl_wrap "$FILE" "$KEY" "${HOST}/api/$TYPE/$id" PUT
    fi

}
function main() {
if [[ $# -eq 0 ]]; then
    ARGS=(${FILE_DIR}/*/*/*.json)
else
    ARGS=("$@")
fi

for FILE in "${ARGS[@]}"; do

    IFS='/' read -r -a args <<< "$FILE"
    if [ ${#args[@]} -ne 13 ]; then
        echo "Wrong param \"${FILE}\". Must be data/{organization}/{type}/{file}"
    fi

    KEY=${ORGMAP[${args[1]}]}
    TYPE=${args[11]}

    case $TYPE in
    dashboards)
        import_file $FILE "$KEY" 'dashboards/db'
        ;;
    datasources)
	import_file $FILE "$KEY" 'datasources'
	;;
    alert-notifications)
	import_file $FILE "$KEY" 'alert-notifications'
	;;
    *)
        echo "Unknown type $TYPE"
        ;;
    esac
done
}