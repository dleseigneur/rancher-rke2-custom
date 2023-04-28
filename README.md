# rancher-rke2-custom-vmvsphere-gpuphysical

Projet pour déployer des clusters Rancher RKE2 en mode custom via API rancher management.

# Objectif
Pouvoir provisionner un cluster `rke2` et des `VM sur vsphere`,avec possibilité d'ajout de machine physique GPU externe.

# Préparation infrastructure vsphere
## storage policy sur le vcenter 
L'intérêt du storage policy est de pouvoir déclarer 1 seul storageclass, le scale du stockage se fera uniquement via vcenter sans impact sur la storageclass.

- sur le datastore shared storage ajout d'une balise `rke2`
strategie et profile, stockage , créer `rke-storage-policy` 

## Préparation template sles15
[modification template](./templatesles15spx.md)

## Préparation de Rancher
Terraform a besoin d'un token pour se connecter à Rancher. S'il n'en existe pas il est nécessaire d'en générer un (long durée).
Il sera ensuite à renseigner dans le fichier terraform.tfvars de l'environnement concerné.
# Organisation du projet terraform
## Répertoire terraform

| `Fichier/Répertoire` | `Description` | 
| :------: |  :------: |
|  `.terrfaform`   | Inititalisation projet terraform commande `terraform init`.<br/>Download modules fichier `versions.tf`<br/> Répertoire dans `.gitignore`  | 
|  `versions.tf`   | Versions minimum pour chaque provider ici<br/> `rancher2`, `vsphere`, `random`, `template`  | 
|  `variables.tf`   | Définition du type des variables:<br/>`string`, `integer`, `list`..| 
|  `provider.tf`   | Définition des méthodes d'accès via le provider vshpere et rancher2| 
|  `create_cluster_rke2.tf`   | création et configuration d'un cluster rke2 `provider rancher2` sans VM<br/>rke2_kubernetes_version = "v1.23.8+rke2r1" fichier `env/ti/terraform.tfstate`|
|  `create_vm.tf`   | création, configuration des VM, enregistrement dans le cluster rke2|
|  `integrer_worker.tf`   | ajout machine physique GPU dans cluster rke2 `provider rancher2` sans VM<br/>rke2_kubernetes_version = "v1.21.5+rke2r2" fichier `env/ti/terraform.tfstate`|

## Répertoire env
Exemple avec l'environnement Test Intégration `ti`   
**Important** le nom du répertoire sous `env/ti` doit être identique à la valeur de la variable `environnement = ti` dans le fichier `terraform.tfvars.

| `Répertoire` | `Fichiers` | `Description` | 
| :------: |  :------: | :------: |
|  `env`   | **N/A** | centralisation des environnements, backup terraform |
|  `env/ti`| | |
| | **terraform.tfvars** | variables terraform pour création VM + cluster rke2 |
| | **terrform.tfstate** | **important** permet de garantir la cohérence du cluster TI |
## keys
contient les clé ssh pour se connecter au VM.
Générer les clefs public privé dans ce repertoire
**TODO**: mettre les clé dans un vault
## templates
fichiers permettant la configuration via cloud-init.
`A refacto si test cloud-init ok, sinon à supprimer.`

# Deploiement
## création d'un cluster rke2 custom vm vsphere and serveurs physique GPU

Exemple avec le cluster `ti` 
```bash
# terraform apply -var-file ./env/ti/terraform.tfvars -state=./env/ti/terraform.tfstate -backup="-" -auto-approve
```
## Deploiement nfs subdir
Cela permet de partager des données entre les workers VM et Serveurs Physiques

```bash
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
helm upgrade --install nfs-subdir-external-provisioner --version 4.0.18 nfs-subdir-external-provisioner/nfs-subdir-external-provisioner -n kube-system -f ./values-nfs-provisioner.yaml
```

## Déploiement de l'opérateur GPU Nvidia
ref : https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/getting-started.html#install-helm

**Attention** pour `SUSE Sles` il faut installer le driver nvidia, normalement bientôt intégré dans le chart **A vérifier**. Pour d'autre distribution le chart helm le fait. Il faudra modidifer le fichier `env/ti/values-gpu-operator.yaml` :
```yaml
driver:
  enabled: false  # uniquement pour sles
```


Copier le fichier config.toml.tmpl dans le répertoire /var/lib/rancher/rke2/agent/etc/containerd

Dans le fichier /usr/local/nvidia/toolkit/.config/nvidia-container-runtime/config.toml remplacer `ldconfig.real` par `ldcondif`

Installer l'operateur GPU :

```bash
helm repo add nvidia https://nvidia.github.io/gpu-operator
helm repo update
helm upgrade --install gpu-operator --version v1.11.1 nvidia/gpu-operator --create-namespace -n gpu-operator -f values-gpu-operator.yaml
```
