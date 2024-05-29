#!/bin/bash

#kubesec-scan.sh

scan_result=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < k8s_deployment_service.yaml)
scan_message=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < k8s_deployment_service.yaml | jq .[].message -r)
scan_score=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < k8s_deployment_service.yaml | jq .[].score)

# Kubesec scan result processing
    # echo "Scan Score : $scan_score"

	if [ "${scan_score}" -le 1 ]; then
	    echo "Score is $scan_score"
	    echo "Kubesec Scan $scan_message"
	else
	    echo "Score is $scan_score, which is greater than 1"
	    echo "Scanning Kubernetes Resource has Failed"
	    exit 1;
	fi;
