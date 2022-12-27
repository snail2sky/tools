#!/bin/bash

time=`date "+%F_%T"`
ips=`hostname -I`
webhook_url='https://open.feishu.cn/open-apis/bot/v2/hook/?????????'
json='{"msg_type":"text","content":{"text":"%s"}}'

report(){
        let i=1
        head="Currente time：`date '+%F %T'`\n`uptime | cut -d' ' -f3-`"
        for ip in $ips;do
                if [ -z "$newip" ]; then
                        newip="$i: $ip"
                else
                        newip="${newip}\n$i: ${ip}"
                fi
                let i++
        done
        json=`printf "$json" "$head\n$newip"`
        curl -X POST -H "Content-Type: application/json" -d "$json" "$webhook_url"
}

report
