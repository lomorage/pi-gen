#!/bin/bash

set -x
set -e

INGRESS_INF="wlan0"
EGRESS_INF="eth0"

FILTER_IP1="10.35.201.44"
FILTER_IP2="10.35.201.45"

# kbit
LINK_BW1="1000"
LINK_BW2="8000"

RAND_LOSS1="0%"
RAND_LOSS2="0%"

# ms
DELAY1=1
DELAY2=1

# ms
QDELAY1=100
QDELAY2=100

BURST_LEN1=
BURST_LEN2=

DIRECTION="dst"
INPUT_INF=$EGRESS_INF
OUTPUT_INF=$INPUT_INF

usage() {
    echo "usage: $0 [parameters] {start|stop|restart}
    -b|--bw [bandwidthKbps]            bandwidth in kbps
    -l|--loss [loss-percentage]        loss in percentage %
    -d|--delay [delayMs]               delay in milliseconds
    -q|--qdelay [qdelayMs]             maxinum queueing delay in milliseconds
    -f|--filter [ipFilter]             filter of source/destination ip address
    --burst [burstLen]                 burst length in packets
    --uplink                           enforce on uplink
    --downlink                         enforce on downlink
"
}

OPTIONS=b:,l:,d:,q:,f:
LONGOPTIONS=bw:,loss:,delay:,qdelay:,filter:,burst:,uplink,downlink
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")
if [ $? -ne 0 ]; then
    exit 2
    usage
fi

eval set -- "$PARSED"

while true; do
    case "$1" in
        -b|--bw)
            LINK_BW2=$2
            shift 2
            ;;
        -l|--loss)
            RAND_LOSS2=$2
            shift 2
            ;;
        -d|--delay)
            DELAY2=$2
            shift 2
            ;;
        -q|--qdelay)
            QDELAY2=$2
            shift 2
            ;;
        -f|--filter)
            FILTER_IP2=$2
            shift 2
            ;;
        --burst)
            BURST_LEN2=$2
            shift 2
            ;;
        --uplink)
            INPUT_INF=$INGRESS_INF
            OUTPUT_INF=$EGRESS_INF
            DIRECTION="src"
            shift
            ;;
        --downlink)
            INPUT_INF=$EGRESS_INF
            OUTPUT_INF=$INPUT_INF
            DIRECTION="dst"
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "option not found!"
            usage
            exit 3
            ;;
    esac
done

TB_QSIZE1=`expr $LINK_BW1 \* 1000 \* $QDELAY1 / 8000`
TB_QSIZE2=`expr $LINK_BW2 \* 1000 \* $QDELAY2 / 8000`

start()
{
    modprobe ifb numifbs=10

    ip link set dev ifb0 up
    ip link set dev ifb1 up

    tc qdisc add dev $INPUT_INF ingress

    tc filter add dev $INPUT_INF parent ffff: protocol ip prio 1 u32 match ip $DIRECTION $FILTER_IP1 flowid 1:1 action mirred egress redirect dev ifb0
    tc filter add dev $INPUT_INF parent ffff: protocol ip prio 1 u32 match ip $DIRECTION $FILTER_IP2 flowid 1:1 action mirred egress redirect dev ifb1
    #tc filter add dev $INPUT_INF parent ffff: protocol ip prio 1 u32 match ip $DIRECTION $FILTER_IP1 match ip protocol 17 0xff flowid 1:1 action mirred egress redirect dev ifb0
    #tc filter add dev $INPUT_INF parent ffff: protocol ip prio 1 u32 match ip $DIRECTION $FILTER_IP2 match ip protocol 17 0xff flowid 1:1 action mirred egress redirect dev ifb1

    if [ -z "$BURST_LEN1" ]; then
        tc qdisc add dev ifb0 root handle 1: netem loss random $RAND_LOSS1 delay $DELAY1"ms"
    else
        RATIO_PERC=$(echo "${RAND_LOSS1::-1} / 100.0" | bc -ql)
        GEMODEL_P=$(echo "100 * $RATIO_PERC / $BURST_LEN1 / (1 - $RATIO_PERC)" | bc -ql)
        GEMODEL_R=$(echo "100.0 / $BURST_LEN1" | bc -ql)
        tc qdisc add dev ifb0 root handle 1: netem loss gemodel $GEMODEL_P% $GEMODEL_R% delay $DELAY1"ms"
    fi


    if [ -z "$BURST_LEN2" ]; then
        tc qdisc add dev ifb1 root handle 1: netem loss random $RAND_LOSS2 delay $DELAY2"ms"
    else
        RATIO_PERC=$(echo "${RAND_LOSS2::-1} / 100.0" | bc -ql)
        GEMODEL_P=$(echo "100 * $RATIO_PERC / $BURST_LEN2 / (1 - $RATIO_PERC)" | bc -ql)
        GEMODEL_R=$(echo "100.0 / $BURST_LEN2" | bc -ql)
        tc qdisc add dev ifb1 root handle 1: netem loss gemodel $GEMODEL_P% $GEMODEL_R% delay $DELAY2"ms"
    fi

    tc qdisc add dev $OUTPUT_INF root handle 1: htb default 12

    tc class add dev $OUTPUT_INF parent 1: classid 1:1 htb rate 1000mbit

    tc class add dev $OUTPUT_INF parent 1:1 classid 1:10 htb rate $LINK_BW1"kbit"

    tc class add dev $OUTPUT_INF parent 1:1 classid 1:11 htb rate $LINK_BW2"kbit"

    tc class add dev $OUTPUT_INF parent 1:1 classid 1:12 htb rate 1000mbit

    tc filter add dev $OUTPUT_INF protocol ip parent 1:0 prio 1 u32 match ip $DIRECTION $FILTER_IP1 flowid 1:10
    tc filter add dev $OUTPUT_INF protocol ip parent 1:0 prio 1 u32 match ip $DIRECTION $FILTER_IP2 flowid 1:11
    #tc filter add dev $OUTPUT_INF protocol ip parent 1:0 prio 1 u32 match ip $DIRECTION $FILTER_IP1 match ip protocol 17 0xff flowid 1:10
    #tc filter add dev $OUTPUT_INF protocol ip parent 1:0 prio 1 u32 match ip $DIRECTION $FILTER_IP2 match ip protocol 17 0xff flowid 1:11

    tc qdisc add dev $OUTPUT_INF parent 1:10 bfifo limit $TB_QSIZE1
    tc qdisc add dev $OUTPUT_INF parent 1:11 bfifo limit $TB_QSIZE2
}

stop()
{
    tc qdisc del dev $OUTPUT_INF root
    tc qdisc del dev $INPUT_INF ingress
    tc qdisc del dev ifb0 root
    tc qdisc del dev ifb1 root
    ip link set dev ifb0 down
    ip link set dev ifb1 down
    modprobe -r ifb
}

case "$1" in

start)

    start
    ;;

stop)

    stop
    ;;

restart)

    stop
    start
    ;;

*)
    usage
    ;;
esac

date
