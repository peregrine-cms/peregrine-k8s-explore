# Deploying Peregrine to Kubernetes

## Before you begin

This document makes several assumptions about the Kubernetes cluster:

1. It is a bare metal k8s cluster created with `kubeadm`.
2. Local disks are used on the worker nodes for PersistentVolumes.
3. Namespaces are used to segment Peregrine deployments. We assume 1 namespace per site.

# Deploying a site with Helm

TODO

# Deploying a site (Manually)

1. Create a namespace for your site. We will use `gastongonzalez` as an example.

        $ kubectl create namespace gastongonzalez

2. Log into each worker node in your cluster and create a directory called `/mnt/disk/vol1`. Then, 
   Edit `peregrine-pv.yml` and change the `nodeAffinity` values to match the hostnames of your worker
    nodes. Lastly, create the PersistentVolumes.

        $ kubectl create --namespace=gastongonzalez -f peregrine-pv.yml

3. Create a StatefulSet for Peregrine. This will create a StatefulSet that manages one instance of 
   Peregrine.

        $ kubectl create --namespace=gastongonzalez  -f peregrine-statefulset.yml

4. Create a headless Service for Peregrine. This will allow other services such as Apache to discover 
   the Peregrine pod(s).

        $ kubectl create --namespace=gastongonzalez -f peregrine-service-headless.yml


5. Create ReplicaSets to manage the Apache live and stage pods.

        $ kubectl create --namespace=gastongonzalez -f apache-live-rs.yml
        $ kubectl create --namespace=gastongonzalez -f apache-stage-rs.yml

6. Create NodePort Services so that you can access the live and stage pods.

        $ kubectl create --namespace=gastongonzalez -f apache-live-service.yml
        $ kubectl create --namespace=gastongonzalez -f apache-stage-service.yml

7. Access the apache-live and apache-stage services using the NodePort. 
