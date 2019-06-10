# Single Author Deployment

This module defines an approach for running Peregrine as a single author instance on
Kubernetes. It uses a StatefulSet, a PersistentVolume and a PersistentVolumeContainer to
ensure that JCR data is peresisted across pod deletions.

# Prerequisites

The configuration that follows was designed to run on an on-permise Kubernetes cluster that
was deployed on bare metal servers using kubeadm. Since the deployment pattern uses
local volumes, there are portions of the configuration that refer to k8s nodes by name. 
Our environment is a 3-node cluster with the following nodes.

* k8smaster
* k8sworker1
* k8sworker2

Since local volumes are used, the following directories where created on each worker node:

```
$ k8sworkerN ~$ sudo -p /mnt/disk/vol1
```

The `/mnt/disk/vol1` directory should be created on k8sworker1 and k8sworker2 before 
continuing.


## Deploying Peregrine to Kubernetes

1. Manually allocate two (2) PersistentVolumes (local volumes). 

        $ kubectl create -f peregrine-pv.yml

2. Create a headless Service to support service discovery between nodes.

        $ kubectl create -f peregrine-service-headless.yml

3. Create a StatefulSet with 1 Peregrine replica.

        $ kubectl create -f peregrine-statefulset.yml

4. Forward a local port so that use can access Peregrine.

        $ kubectl port-forward peregrine-0 8080:8080

5. Open a browser and visit http://localhost:8080

