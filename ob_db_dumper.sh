#!/bin/bash
#------内置脚本方法，可以直接调用------
anynowtime=$(date +'%Y-%m-%d %H:%M:%S')
NOW="echo [$anynowtime][PID:$$]"

#可在脚本开始运行时调用，打印当时的时间戳及PID。
job_start(){
    echo "$(eval $NOW) job_start"
}

#可在脚本执行成功的逻辑分支处调用，打印当时的时间戳及PID。 
job_success(){
    MSG="$*"
    echo "$(eval $NOW) job_success:[$MSG]"
    exit 0
}

#可在脚本执行失败的逻辑分支处调用，打印当时的时间戳及PID。
job_fail(){
    MSG="$*"
    echo "$(eval $NOW) job_fail:[$MSG]"
    exit 1
}

job_start
#------可在此处下面开始编写您的脚本逻辑代码------

## para1: tent_name; para2: dump_DB_name; para3: dump_username; para4: dump_userpwd

BAK_TEN=$1
DB_NAME=$2
BAK_USER=$3
BAK_PWD=$4
BAK_CLS='obbk'
DB_HOST='10.10.10.41'
DB_PORT='2883'
OBDUMP_PATH=/data/backup/obdumper

DATE_TIME=$(date +%Y%m%d_%H%M%S)
DEST=${OBDUMP_PATH}/${BAK_TEN}-${DB_NAME}/
BAK_PATH=${DEST}/${DATE_TIME}
BAK_LOG=${DEST}/RS_obdumper_${DATE_TIME}.log 

/usr/bin/mkdir -p "${BAK_PATH}"
if [ ! -d "${BAK_PATH}" ]; then
    job_fail "backup failed"
fi

echo "backup save to ----${BAK_PATH}" >> "${BAK_LOG}"
echo "backup log save to ---${BAK_LOG}" >> "${BAK_LOG}"

cd ${DEST} || exit
/usr/local/ob-loader-dumper/bin/obdumper -h ${DB_HOST} -u ${BAK_USER} -P ${DB_PORT} -p ${BAK_PWD} --sys-user ${BAK_USER} --sys-password ${BAK_PWD} -t ${BAK_TEN} -c ${BAK_CLS} -D ${DB_NAME} --all --ddl --csv -f "${BAK_PATH}"  --thread 2 2>&1 1>>"${BAK_LOG}"
[ $? -eq 0 ] && /usr/bin/tar czvf "${DATE_TIME}.tar.gz" "${DATE_TIME}"/ --remove-files &&  echo "--Backup ${DB_NAME} successfully!" || echo "--Backup ${DB_NAME} failed!"

job_success "备份成功！"
