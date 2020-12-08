#!/bin/bash
os="$(uname -s)"
if [ ${os} = "Linux" ]; then
    echo "Linux OS detected"
    SCRIPT_DIR=$(dirname $(readlink -f $0))
elif [ ${os} = "Darwin" ]; then
    echo "MacOS detected"
    SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
fi
ROOT_DIR=$(realpath "${SCRIPT_DIR}/..")
export HOST_PATH=${ROOT_DIR}

while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --clean)
        CLEAN=true
        shift
        ;;
    esac
done


SUBPROJECT=$( cat "${ROOT_DIR}/.docker/.env.template" | grep "PROJECT_ID" | awk -F "=" '{print $2}' )
# check if the environment is already up, and stop it
if [ -z "$(docker ps | grep -w \"${SUBPROJECT}\" | awk '{print $1}')" ]
then
    COMMANDS+=("PROJECT_ID=\"${SUBPROJECT}\" PROJECT_PATH=\"${ROOT_DIR}\" docker-compose -f \"${ROOT_DIR}/.docker/docker-compose.yml\" --env-file \"${ROOT_DIR}/.docker/.env\" down" )
fi

# join the commands in a string and execute
COMMAND_STRING=$(printf " && %s" "${COMMANDS[@]}")
COMMAND_STRING=${COMMAND_STRING:3}

# docker-compose -f "${SCRIPT_DIR}/docker-compose.yml" -p "${PROJECT_ID}" down
if [ -n "${DEBUG}" ]; then
    echo "${COMMAND_STRING}";
fi
echo "${COMMAND_STRING}";
eval "${COMMAND_STRING}"