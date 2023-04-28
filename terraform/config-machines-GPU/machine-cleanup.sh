
/usr/local/bin/rke2-killall.sh > /tmp/machine-cleanup.log

/usr/local/bin/rke2-uninstall.sh >> /tmp/machine-cleanup.log

killall /usr/local/bin/rancher-system-agent

rm -rf /etc/rancher/agent/
rm -rf /var/lib/rancher/agent/
