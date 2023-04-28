# Template linux sles15

Transformer le template en VM.
Ajouter un Disque 3 de 200Go en mode Thin

Démarrer la VM

# Copie de la clé SSH
Copier le fichier keys/rkeid_rsa.pub en /root/.ssh/authorized_keys

# Ajout des AC Pole Emploi
Depuis un poste de travail linux :

```bash
# openssl x509 -in /usr/local/share/ca-certificates/P-16-R.crt -text > ac_pe_apps.crt
# openssl x509 -in /usr/local/share/ca-certificates/P-16-A.crt -text >> ac_pe_apps.crt
# scp -i keys/rkeid_rsa ac_pe_apps.crt root@10.xx.xx.xx:/etc/pki/trust/anchors/
# ssh -i keys/rkeid_rsa root@10.xx.xx.xx
# update-ca-certificates
```

# Resize du vg rootvg
```bash
pvcreate /dev/sdc
vgextend rootvg /dev/sdc
lvextend -l +100%FREE /dev/rootvg/root
xfs_growfs /
```

# Invalider le SWAP
Mettre en commentaire la ligne concernant le SWAP dans le fichier /etc/fstab

# Copie du binaire rke2
Utile uniquement pour la création d'un cluster de management RKE2
Copier le fichier rke2.linux-amd64 (récupréré sur https://github.com/rancher/rke2/releases)
Prendre la plus récente (lastest) mais pas de pre-release.
Copie des fichier rke2-agent.service et rke2-server.service dans /tmp.
# Bug wicked :
Il faut supprimer les informations wicked pour garantir le dhcp avec un identifiant unique pour le DHCP
```bash
# rm /var/lib/wicked/*
```



# Installation de cloud-init en suspens
~~
## installation cloud-init
```bash
# zypper in systemctl cloud-init cloud-init-config-suse
```
# Bug cloud-init :
L'activation de cloud-init ne fonctionne pas. Workaround 
```bash
# systemctl disable cloud-init.service cloud-final.service cloud-init-local.service cloud-config.service
# sed -i s/WantedBy=cloud-init.target/WantedBy=multi-user.target/ /usr/lib/systemd/system/cloud*.service
# systemctl enable cloud-init.service cloud-final.service cloud-init-local.service cloud-config.service
```
~~
