#!/bin/bash

KUBECTL="${HOME}/kubernetes/cluster/kubectl.sh"

RC_LIST="pulp-apache-rc pulp-worker-rc pulp-resource-manager-rc pulp-beat-rc
  pulp-msg-rc pulp-db-rc"

POD_LIST="pulp-db-init"

SERVICE_LIST="pulp-web pulp-msg pulp-db"

#
# Reduce replicas to 0
#
for RC in ${RC_LIST}
do
    ${KUBECTL} --replicas=0 resize replicationcontrollers ${RC} 
done

#
# Remove all replication controllers
#
for RC in ${RC_LIST}
do
    ${KUBECTL} delete replicationcontrollers ${RC} 
done

for POD in ${POD_LIST}
do
    ${KUBECTL} delete pods ${POD}
done
#
# Remove services
#
for SERVICE in ${SERVICE_LIST}
do
    ${KUBECTL} delete services ${SERVICE}
done
