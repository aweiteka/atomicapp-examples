#!/bin/sh

#
#
#
#KUBECFG=/home/bos/mlamouri/kubernetes/_output/build/linux/amd64/kubecfg
KUBECFG=~/kubernetes/cluster/kubecfg.sh
KUBECTL=~/kubernetes/cluster/kubectl.sh

#
# test if a service exists
#
kube_service_exists() {
    # $1 = SERVICE_ID
    ${KUBECTL} --output=json get services $1 2>&1 >/dev/null
}

#kube_create_service() {
#    # $1 = SERVICE_ID
#    # $2 = SERVICE_PORT
#    # $3 = SERVICE_SELECTOR
#    ${KUBECTL} -c - create pods <<EOF
#{"kind": "Service", "apiversion": "v1beta1", 
# "id": "$1", "port": $2, "selector": {"name": "$3"},}
#EOF
#}

kube_create_service_file() {
    # SERVICE_FILE = $1
    ${KUBECTL} create -f $1
}

kube_create_pod_file() {
    # POD_FILE = $1
    ${KUBECTL} create -f $1
}

kube_create_replication_controller_file() {
    # RC_FILE = $1
    ${KUBECTL} create -f $1
}

kube_replication_controller_exists() {
    # RC_NAME=$1
    ${KUBECTL} get replicationcontrollers $1 2>&1 >/dev/null
}

kube_pod_exists() {
    # POD_NAME = $1
    ${KUBECTL} get pods | grep $1 2>&1 >/dev/null
}

kube_pod_status() {
    # POD_NAME = $1
    ${KUBECTL} get --output=yaml pods $1 
}

# create services

# - mongodb
if ! kube_service_exists pulp-db-service
then
    kube_create_service_file services/mongodb-service.yaml
fi

# - qpid
if ! kube_service_exists pulp-msg-service
then
    kube_create_service_file services/qpid-service.yaml
fi

# - Pulp repo and admin 
if ! kube_service_exists pulp-web-service
then
    kube_create_service_file services/pulp-web-service.yaml
fi

#
# create support service pods
#

# - mongodb
#kube_create_pod_file pods/mongodb.json
if ! kube_replication_controller_exists pulp-db-rc
then
    kube_create_replication_controller_file replication_controllers/mongodb-rc.yaml
fi

# - qpid
#kube_create_pod_file pods/qpid.json
if ! kube_replication_controller_exists pulp-msg-rc
then
    kube_create_replication_controller_file replication_controllers/qpid-rc.yaml
fi

while ! (${KUBECTL} get pods | grep pulp-db-rc | grep -q Running)
do
    echo "Waiting for pulp database container"
    sleep 10
done

echo Pulp database container ready
# check that it is bound to the endpoint!
# kubectl get endpoints pulp-db


while ! (${KUBECTL} get pods | grep pulp-msg-rc | grep -q Running)
do
    echo "Waiting for pulp message broker container"
    sleep 10
done
echo Pulp message broker ready
# check that it is bound to the endpoint!
# kubectl get endpoints pulp-msg

kube_create_pod_file pods/pulp-db-init.yaml
while ! (${KUBECTL} get pods pulp-db-init | grep -q Succeeded)
do
    echo "Waiting for pulp db initialization"
    sleep 10
done
echo Pulp DB initialized

#
# create pulp service pods
#

# - pulp-beat
if ! kube_replication_controller_exists pulp-beat-rc
then
    kube_create_replication_controller_file replication_controllers/pulp-beat-rc.yaml
fi
while ! (${KUBECTL} get pods | grep pulp-beat | grep -q Running)
do
    echo "Waiting for pulp beat service"
    sleep 10
done
echo Pulp Beat running

# - pulp-resource-manager
if ! kube_replication_controller_exists pulp-resource-manager-rc
then
    kube_create_replication_controller_file replication_controllers/pulp-resource-manager-rc.yaml
fi
while ! (${KUBECTL} get pods | grep pulp-resource-manager | grep -q Running)
do
    echo "Waiting for pulp resource-manager service"
    sleep 10
done
echo Pulp Resource Manager running


#
# Create the shared space on a minion
#
#ssh vagrant@10.245.1.3 sudo mkdir -p /opt/pulp/var/www

# - pulp-worker
#
if ! kube_replication_controller_exists pulp-worker-rc
then
    kube_create_replication_controller_file replication_controllers/pulp-worker-rc.yaml
fi
while ! (${KUBECTL} get pods | grep pulp-worker | grep -q Running)
do
    echo "Waiting for pulp worker service"
    sleep 10
done
echo Pulp Worker 1 running

#
# - pulp-apache
#
if ! kube_replication_controller_exists pulp-apache-rc
then
    kube_create_replication_controller_file replication_controllers/pulp-apache-rc.yaml
fi
while ! (${KUBECTL} get pods | grep pulp-apache | grep -q Running)
do
    echo "Waiting for pulp apache service"
    sleep 10
done
echo Pulp Apache running

# test auth - just get the header and look for a 200
curl --insecure -D - -d '' --user admin:admin https://10.245.1.3/pulp/api/v2/actions/login/ -o /dev/null


#(cd ~/kubernetes ; vagrant ssh minion-1 -c "sudo cat /var/lib/kube-proxy/kubeconfig" >kube-proxy-kubeconfig )

#sudo ~/kubernetes/_output/release-stage/server/linux-amd64/kubernetes/server/bin/kube-proxy --master=https://10.245.1.2:6443 --kubeconfig=${HOME}/kubernetes/kube-proxy-kubeconfig --v=2 &


