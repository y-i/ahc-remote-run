#!/bin/bash

# 実行ファイルをダウンロードする
gcloud storage cp ${BUCKET_NAME}/${APP_NAME} ${APP_NAME}
chmod +x ${APP_NAME}
COUNT=${CLOUD_RUN_TASK_INDEX}

# TOを含む範囲
FROM=$((COUNT * STEP))
TO=$((COUNT * STEP + STEP - 1))
RESULT_FILE="${COUNT}_result.txt"

mkdir -p ./out
rm -f out/*

for i in $(seq -f "%04g" "$FROM" "$TO"); do
    IN_FILE=${i}.txt
    OUT_FILE=${i}.txt
    
    # コンテスト依存
    ./${APP_NAME} < in/${IN_FILE} > out/${OUT_FILE}
    TMP=$(./vis in/${IN_FILE} out/${OUT_FILE} | grep "Total Cost")
    COST=$(echo ${TMP} | awk -F' ' '{print $4}')
    if [ -z ${COST} ]; then
        COST="Error"
    fi
    echo ${i},${COST} >> out/${RESULT_FILE}
done

gcloud storage cp out/* ${BUCKET_NAME}/${JOB_NAME}/
