# HaKoC #

A **H**igh **A**vailable **K**ubernetes **O**n **C**oreOs
***

The Goal: A production ready Kubernetes cluster running (atm only) on GCE that is provisioned by terraform
but is also capable to run on Vagrant.

## Status ##
The Project isnt ready yet. Some modules are working right now but its not ready
to deploy containers on it.

### Infrastructure ###

| Module     | Instance Templates   | Groupmanager | Pool   | Forwarding   | Healtcheck    | Firewall   | Network   |
| -----------|:--------------------:| ------------:| ------:| ------------:| -------------:| ----------:| ---------:|
| network    | -                    |-             |-       |-             |-              |x           |o          |
| etcd2      | o                    |o             |o       |o             |o              |o           |o          |
| master     | o                    |o             |x       |x             |x              |x           |o          |
| node       | x                    |x             |x       |x             |x              |x           |x          |


### Kubernetes ###

Nothing finished here

## Setup ##

### Build the image ###

HaKoC needs the Kubernetes binaries preinstalled on the image under /opt/kubernetes
There is already a http://packer.io template for that: https://github.com/stylelab-io/coreos-kubernetes-packer

### Configuration ###


### Deployment ###

```
cd terraform/gce
terraform get             // load submodules
terraform plan            // show changes
terraform apply
```
