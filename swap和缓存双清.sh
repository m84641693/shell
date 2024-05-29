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

free -m

echo "开始关闭 swap"
if  swapoff -a; then
    job_fail "关闭 swap 失败"
fi
echo "关闭 swap 成功"

echo "开始开启 swap"
if  swapon -a; then
    job_fail "开启 swap 失败"
fi
echo "开启 swap 成功"

sync && sleep 5
sync && sleep 5
sync && sleep 5

echo "开始清理缓存"
if echo 3 > /proc/sys/vm/drop_caches; then
    job_fail "清理缓存失败"
fi
echo "清理缓存成功"

free -m
job_success "SWAP 和缓存双清成功！"
