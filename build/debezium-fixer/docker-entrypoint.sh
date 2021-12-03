#!/bin/bash

#MY_POD_IP= obtained from env
#PROBE_TIME_PERIOD= obtained from env
#ERROR_LEVEL1= obtained from env
#ERROR_LEVEL2= obtained from env
while true; do
  for i in $(curl "http://$MY_POD_IP:8083/connectors" | jq -r '.[]'); do
    TASK_COUNT=$(curl "http://$MY_POD_IP:8083/connectors/$i/tasks" | jq length)
    for j in $(seq 0 $((TASK_COUNT-1))); do
      if ! [ -z $(curl "http://$MY_POD_IP:8083/connectors/$i/tasks/$j/status" | jq '.' | grep -i $ERROR_LEVEL1 | grep -i $ERROR_LEVEL2) ]; then
        echo "$(date) [ERROR]: Ran into the given error $ERROR_LEVEL1 -> $ERROR_LEVEL2; in batch number $which_batch; in the connector $i; in task number $j. Restarting ..."
        curl -XPOST "http://$MY_POD_IP:8083/connectors/$i/tasks/$j/restart"
      fi
    done
  done
  sleep $PROBE_TIME_PERIOD
done