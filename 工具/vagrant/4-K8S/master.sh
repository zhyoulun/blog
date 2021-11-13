#!/bin/bash
# BASEDIR=$(dirname "$0")
# ${BASEDIR}/master-1-os.sh
# ${BASEDIR}/master-2-k8s.sh

sudo apt update

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo reboot