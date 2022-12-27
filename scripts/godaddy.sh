#!/bin/bash

update_domain_ipv4=(web vpn mine)
update_domain_ipv6=(web vpn mine ip6)
DOMAIN=snail2sky.live
KEY=
SECRET=
TYPE=A

EXE=`basename $0`

del(){
    if [ $# -lt 1 ]; then
            return 2
    fi

    curl -X 'DELETE' \
  "https://api.godaddy.com/v1/domains/$DOMAIN/records/$TYPE/$1" \
  -H 'accept: application/json' \
  -H "Authorization: sso-key $KEY:$SECRET"
}

upd(){
    if [ $# -lt 1 ]; then
            return 2
    fi
    # resolve from command line
    # such key=value
    # and then, has been load by shell
    eval `echo $1 | awk -F= '{printf "key=%s;value=%s\n", $1, $2}'`
    curl -X 'PUT' \
  "https://api.godaddy.com/v1/domains/$DOMAIN/records/$TYPE/$key" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -H "Authorization: sso-key $KEY:$SECRET" \
  -d "[
  {
    \"data\": \"$value\",
    \"port\": 1,
    \"priority\": 0,
    \"protocol\": \"string\",
    \"service\": \"string\",
    \"ttl\": 600,
    \"weight\": 0
  }
]"
}

add(){
    upd $@
}

get(){
    if [ $# -lt 1 ]; then
            return 2
    fi

    curl -X 'GET' \
  "https://api.godaddy.com/v1/domains/$DOMAIN/records/$TYPE/$1" \
  -H 'accept: application/json' \
  -H "Authorization: sso-key $KEY:$SECRET"
}

getall(){
    curl -X 'GET' \
  "https://api.godaddy.com/v1/domains/$DOMAIN" \
  -H 'accept: application/json' \
  -H "Authorization: sso-key $KEY:$SECRET"
}

update(){
    case $TYPE in
            A)
                current_ipaddr=`/bin/curl ifconfig.me 2>/dev/null`
                update_domain=${update_domain_ipv4[@]}
                ;;
            AAAA)
                current_ipaddr=`/bin/curl 6.ipw.cn 2>/dev/null`
                update_domain=${update_domain_ipv6[@]}
                ;;
    esac
    # only ipaddr changed, will be update
    for domain in ${update_domain[@]}; do
        dns_ipaddr=`main -t $TYPE get $domain 2>/dev/null | jq .[].data | egrep -o '[0-9.]+'`
        if [ "$current_ipaddr" != "$dns_ipaddr" ]; then
            main upd $domain=$current_ipaddr
        fi
    done
}

help(){
    echo "Usage: $EXE <{ add | del | upd | get | getall | update}>"
    echo "       [-t 4|6] add <sub_domain>=<address>"
    echo "       [-t 4|6] del <sub_domain>"
    echo "       [-t 4|6] upd <sub_domain>=<address>"
    echo "       [-t 4|6] get <sub_domain>"
    echo "       getall"
    echo "       [-t 4|6] update"
    echo "       default type is ipv4"
    exit 1
}

main(){
    if [ $# -lt 1 ]; then
            help
    fi
    case $1 in
            -t)
                    shift
                    if [ "$1" == 4 ]; then
                        TYPE=A
                    else
                        TYPE=AAAA
                    fi
                    shift
                    ;;
    esac

    case $1 in
            add|del|upd|get|getall)
                    $@
                    ;;
            update)
                    update
                    ;;
            *)
                    help
                    ;;
    esac
}

main $@
