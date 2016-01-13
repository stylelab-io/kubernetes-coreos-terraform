# HaKoC #

A **H**igh **A**vailable **K**ubernetes **O**n **C**oreOs
***

The Goal: A production ready Kubernetes cluster running (atm only) on GCE that is provisioned by terraform
but is also capable to run on Vagrant.

## Status ##
**Work in Progress**

Servers can be spinned up with gce but the kubernetes tools have some configuration problems.

## Why not using cluster-up ##

  1. More readable than bash
  2. Every part of a Kubernetes Cluster should be easy to scale (Nodes should autoscale!)
  3. Fault tolerant with network loadbalancer + healtchecks
  4. Pre build image for speed enhancement
  5. Provision only configuration

o = working
x = not working
- = not needed

### Infrastructure GCE ###

| Resource   | Instance Templates   | Groupmanager | Pool   | Forwarding   | Healtcheck    | Firewall   | Network   |
| ----------:|---------------------:| ------------:| ------:| ------------:| -------------:| ----------:| ---------:|
| network    | -                    |-             |-       |-             |-              |o           |o          |
| etcd2      | o                    |o             |o       |o             |o              |o           |o          |
| master     | o                    |o             |o       |o             |o              |o           |o          |
| node       | o                    |o             |o       |o             |o              |o           |o          |

### Provisioning ###

| Module     | Certs | Communication   | Flannel   | Etcd Config | KubeConfig | Locofo | Docker | Wupiao | Heapster |
| ----------:|------:|----------------:|----------:|------------:|-----------:|-------:|-------:|-------:|---------:|
| etcd2      | o     |o                |-          |-            |-           |o       |-       |x       |x         |
| kube-master| o     |o                |o          |o            |o           |o       |o       |x       |x         |
| kube-node  | o     |o                |o          |-            |o           |-       |o       |x       |x         |

### Kubernetes ###

| Service             | GCE | AWS | Vagrant |
|--------------------:|----:|----:|--------:|
| Kube-Api            |o    |x    |x        |
| Scheduler           |o    |x    |x        |
| Controller-Manager  |o    |x    |x        |
| Kubelet             |o    |x    |x        |
| Proxy               |o    |x    |x        |


### Addons ###
None atm


## Setup ##

### Requirements ###
  - terraform  -
  - packer -
  - gcloud in $PATH -
  - terraform local exec provider -
  - a domain added to cloud-dns from (gce only)

### Build the image ###

HaKoC needs the Kubernetes binaries preinstalled on the image under /opt/kubernetes
There is already a http://packer.io template for that: https://github.com/stylelab-io/coreos-kubernetes-packer

### GCE Preperation ###
Create a dns zone under network if you dont have one already.

### Configuration ###
Terraform uses `variables.tf` files to define the variables a module or the root module needs.

To get an overview of all variables and their defaults see:
`variables.tf`

To overwrite them create a new file `provider/gce/terraform.tfvars`

You need at least the following:

```
gce_project = "xxxxxx-1234"
gce_zone = "europe-west1-b"
gce_account_file = "/path/to/your-account-file.json"
domain = "domain.with.dots.tld"
domain_zone_name = "zone-name-tld"
image = "coreos-alpha-815-0-0-kube-1-0-6-xxxxxxxxx" # has to be builded first
etcd_cert_passphrase = "1234"
```

### Deployment ###

```
cd terraform/gce
terraform get             // load submodules
terraform plan            // show changes
terraform apply
```

## Under the hood ##

What happens when i type `terraform apply`?

We are starting from the `kubernetes.tf` file.
Here we load the different modules. Normaly terraform executes everything in parrallel
to speed up. Because there is no `depends_on` for modules we have to use a little hack.
The modules are using variables that come from a module instead of the variables file.

### 1. Network ###
We setup one network for the nodes and one for the pods including all needed firewall rules.

### 2. Certs ###
Because we need a CA cert to generate our certs and key files, we generate one
via the `terraform-local-execute` provider  (a plugin for terraform) and etcd-ca.

We upload them to GCEs metadata store. So we can later download them from any new instance and create
client certs.

### 3. etcd2 ###

Terraform generates a discovery token for etcd before it spinns up the cluster.
This is not the best solution but works for the moment. Should be replaced by something like this:
http://engineering.monsanto.com/2015/06/12/etcd-clustering/

### 4. Kubernetes Master ###

### 5. Kubernetes Nodes ###

### etcd TLS / Certificates ###

For etcd2 we are using the ecd-ca generator. The etcd-ca generator is preinstalled on the images.
It is stored under `./tools/etcd-ca` the binaries for linux-amd46 and darwin46 are stored
under `./tools/etcd_ca` the script checks the os and switches to the right binary.

The ca certificate + key is then stored as metadata to the project. So it can be downloaded in the cloud-init process from coreos.
After the the system went up, it generates the server / client certs.

### locofo ###

Because health checks wont work with tls i wrote a little proxy. Locofo is installed automatically if you create an image with
https://github.com/stylelab-io/coreos-kubernetes-packer

You can find the code here:
https://github.com/stvnwrgs/locofo

## Limitations ##
