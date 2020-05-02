#!/bin/bash

RANGE_START=${1:-1}
RANGE_END=${2:-16}

shift 2
for i in $(seq $RANGE_START $RANGE_END); do
	IP=192.168.0.$i

	echo -e "\n=======\t$IP\t=======\n"
	ssh $IP "$@"
done
