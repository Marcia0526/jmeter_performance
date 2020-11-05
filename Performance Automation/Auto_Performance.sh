#!/usr/bin/env bash
export jmx_template="SearchTemplate"
export suffix=".jmx"
export jmx_template_filename="${jmx_template}${suffix}"

# 清空nohup.out
cat /dev/null > nohup.out

# 强制杀掉JMeter进程
killJMeter()
{
    pid=`ps -ef|grep jmeter|grep java|awk '{print $2}'`
    echo "jmeter Id list :$pid"
    if [[ "$pid" = "" ]]
    then
      echo "no jmeter pid alive"
    else
      kill -9 $pid
    fi
}

thread_number_array=(10 20 30)
for num in "${thread_number_array[@]}"
do
    
    # 定义对应压测文件名
    export jmx_filename="${jmx_template}_${num}${suffix}"
    export jtl_filename="test_${num}.jtl"
    export report_name="report_${num}"
    if [ -e ${jmx_filename} ]; then
        rm -f ${jmx_filename}
    fi
    if [ -e ${jtl_filename} ]; then
        rm -f ${jtl_filename}
    fi
    if [ -d ${report_name} ]; then
   	rm -rf ${report_name}
    fi

    #rm -f ${jmx_filename} ${jtl_filename}

    cp ${jmx_template_filename} ${jmx_filename}
    echo "生成jmx压测脚本 ${jmx_filename}"

    sed -i "" "s/Thread_Num/${num}/g" ${jmx_filename}

    # JMeter 执行压测
    echo "${JMETER_HOME}/bin/jmeter"
    echo ${jmx_filename}
   ${JMETER_HOME}/bin/jmeter -n -t ${jmx_filename} -l ${jtl_filename} -e -o ${report_name}

    sleep 15m 30s
    killJMeter
   # rm -f ${jmx_filename} ${jtl_filename} ${web_report_path_name}
done
echo "自动化压测全部结束"
