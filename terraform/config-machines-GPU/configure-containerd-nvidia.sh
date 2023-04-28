#!/bin/sh

CONFIGPATH="/var/lib/rancher/rke2/agent/etc/containerd"
INPUTFILE="/tmp/config-machines-GPU/config.toml-nvidia"
KUBEBIN="/var/lib/rancher/rke2/bin/kubectl"
LOGFILE="/tmp/configure-containerd-nvidia.log"

export KUBECONFIG=/var/lib/rancher/rke2/agent/kubelet.kubeconfig

if modinfo nvidia>/dev/null 2>&1
then
  echo driver nvidia non detecte. Exiting >> $LOGFILE
  exit
fi

if 
# Fonction qui verifie si les blocks sont deja presents dans le config.toml
check_blocks_toappend ()
{
  blocks=$(grep "^\[" $INPUTFILE| sed -e 's/\[//')
  for i in $blocks;
  do
   if grep "$i" $CONFIGPATH/config.toml.tmpl
   then
    echo erreur block existe >> $LOGFILE
    exit 1
   fi
  done
  unset blocks
}

# Fix pour nvidia container runtime (/usr/local/nvidia/toolkit/.config/nvidia-container-runtime/config.toml)
ln -s /sbin/ldconfig /sbin/ldconfig.real

echo "`date`: On commence a attendre que kubernetes soit fonctionnel" >> $LOGFILE
# Boucle qui attend que le node soit Read dans le cluster
while true
do
  if $KUBEBIN get no $HOSTNAME |grep -w "Ready"
  then
    $KUBEBIN get no $HOSTNAME >> $LOGFILE 2>&1
    echo "`date`: Kubernetes fonctionnel" >> $LOGFILE
    break
  fi
  sleep 15
done

check_blocks_toappend 

cp -v $CONFIGPATH/config.toml $CONFIGPATH/config.toml.tmpl >> $LOGFILE 2>&1

# Ajoute le block Nvidia dans config.toml.tml
sed -i "/snapshotter/r$INPUTFILE" $CONFIGPATH/config.toml.tmpl >> $LOGFILE 2>&1

cat $CONFIGPATH/config.toml.tmpl >> $LOGFILE
# Redémarre le service rke2-agent pour prise en compte modification
systemctl restart rke2-agent >> $LOGFILE 2>&1

echo "`date`: Fin execution script"
