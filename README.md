# HaKoC #

A **H**igh **A**vailable **K**ubernetes **O**n **C**oreOs
***

The Goal: A production ready Kubernetes cluster running (atm only) on GCE that is provisioned by terraform
but is also capable to run on Vagrant.

## Status ##
**Work in Progress**

## Why not using cluster-up ##

  1. Make it more readable

    - The kubernetes cluster bash + salt files are great, because they work everywhere. But bash is not the best for readability.

  2. Make it scalable

    - Every part of a Kubernetes Cluster should be easy to scale.

  3. Make it fault tolerant

    - Google gives us health checks. Use them!

  4. Make it fast

    - Downloading binaries with cloud-config or a provisioning? No! We want a new Node up in seconds not in Minutes.
    - Provision only configuration

### Infrastructure ###

| Module     | Instance Templates   | Groupmanager | Pool   | Forwarding   | Healtcheck    | Firewall   | Network   |
| ----------:|---------------------:| ------------:| ------:| ------------:| -------------:| ----------:| ---------:|
| network    | -                    |-             |-       |-             |-              |x           |o          |
| etcd2      | o                    |o             |o       |x             |x              |o           |o          |
| master     | o                    |o             |x       |x             |x              |x           |o          |
| node       | x                    |x             |x       |x             |x              |x           |x          |

### Provisioning ###

| Module     | Authentication | Authorization | Communication A | Communication B |
| ----------:|---------------:|--------------:|----------------:|----------------:|
| etcd2      | o                    |o   |o |o |
| kube-master| x |x|x|x |
| kube-node| x |x|x|x |

### Kubernetes ###

Nothing finished here

## Setup ##

### Requirements ###
  - terraform  -
  - packer -
  - gcloud in $PATH -
  - terraform local exec provider -
  - image - see build the image

### Build the image ###

HaKoC needs the Kubernetes binaries preinstalled on the image under /opt/kubernetes
There is already a http://packer.io template for that: https://github.com/stylelab-io/coreos-kubernetes-packer

### Configuration ###
Terraform uses `variables.tf` files to define the variables a module or the root module needs.

To get an overview of all variables and their defaults see:
`variables.tf`

To overwrite them create a new file `terraform/gce/terraform.tfvars`

You need at least the following:

```
gce_project = "xxxxxx-1234"
gce_zone = "europe-west1-b"
gce_account_file = "/path/to/your-account-file.json"

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
We setup the network with the main firewall rules.

### 2. Cert ###
Because we need a CA cert to generate our certs and key files, we generate one.
This is done via the `terraform-local-execute` provider  (a plugin) and etcd-ca.
We upload them to GCEs metadata store. So we can later download them from any new instance.

### 3. etcd ###

### 4. Kubernetes Master ###

### 5. Kubernetes Nodes ###

### etcd TLS / Certificates ###

For etcd2 we are using the ecd-ca generator. The etcd-ca generator is preinstalled on the images.
It is stored under `./tools/etcd-ca` the binaries for linux-amd46 and darwin46 are stored
under `./tools/etcd_ca` the script checks the os and switches to the right binary.

The ca certificate + key is then stored as metadata to the project. So it can be downloaded in the cloud-init process from coreos.
After the the system went up, it generates the server / client certs.
