#!/bin/sh

function mongo_logrotate_thread() {
    while true
    do
        logrotate
        sleep 5
    done
}

function logrotate () {
    local KBYTE=1024
    local MBYTE=$(echo "1024*1024" | bc)
    local GBYTE=$(echo "1024*1024*1024" | bc)

    # default threshold - 100MB
    local THRESHOLD_SIZE=$(echo "${MBYTE}*100" | bc)

    local MONGODB_LOGPATH=/var/log/mongodb

    find ${MONGODB_LOGPATH} -type f -iname "mongodb.log" -print0 | while IFS= read -r -d '' file
    do
        local LOG_SIZE=$(ls -la $(printf '%s' ${file}) | awk '{print $5}' | sed -e 's/ //g')

        local LIMIT_REACHED=$(echo "${LOG_SIZE}>${THRESHOLD_SIZE}" | bc)

        if [[ ${LIMIT_REACHED} -eq 1 ]]; then
            mongo admin -eval "db.runCommand({logRotate: 1})"
        fi
    done
}

mongo_logrotate_thread >/dev/null 2>/dev/null &
