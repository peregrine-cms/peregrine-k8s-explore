# Peregrine - Single Instance with Stage and Live Support

[Peregrine CMS](http://www.peregrine-cms.com/) is an Apache Sling based content management system embracing a head optional and API driven approach.  

## Introduction

This chart bootstraps a single Peregrine instance with an Apache instance for your live site and an Apache instance for your stage environment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.14+
- PV provisioner support in the underlying infrastructure
- Helm 2.14+


## Supported Platforms

The following Kubernetes runtimes are known to work with this Helm chart:

- Google Kubernetes Engine (GKE)
- Bare metal (kubeadmin)  

Note: For bare metal k8s clusters refer to the Bare Metal section below first.

## Installing the Chart

To install the chart with the release name `r1` invoke:

```bash
$ helm install --name r1 peregrine
```

The command deploys Peregrine on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

### Uninstall

To uninstall/delete the `r1` release:

```bash
$ helm del --purge r1
```

### Upgrade

To upgrade the `r1` release:

```bash
$ helm upgrade r1 peregrine
```


## Configuration

The following table lists the configurable parameters of the Pergrine chart and their default values.

| Parameter                                    | Description                                       | Default                                |
| -----------------------------------------    | ------------------------------------------------- | -------------------------------------- |
| `peregrine.site`                             | Peregrine site name                               | `themeclean`                           |
| `peregrine.storage`                          | Storage size for Peregrine's /app mount point     | `5Gi`                                  |
| `apache.liveDomain`                          | Apache live domain name                           | `live.peregrine.cxm`                   |
| `apache.stageDomain`                         | Apache stage domain name                          | `stage.peregrine.cxm`                  |
| `k8s.apacheLiveServiceType`                  | Service type for live Apache service              | `LoadBalancer`                         |
| `k8s.apacheStageServiceType`                 | Service type for stage Apache service             | `LoadBalancer`                         |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

For example, to create your Peregrine with a large disk (i.e. 10GB), you can override the storage size as follows:

```
$ helm install --name r1 peregrine --set peregrine.storage=10Gi
$ k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                         STORAGECLASS   REASON   AGE
pvc-2d40e730-afc9-11e9-a43e-42010aa80005   10Gi       RWO            Delete           Bound    default/data-r4-peregrine-0   standard                24s
```

## GKE

TODO

## Bare Metal (kubeadm)

Additional configuration is needed when the target cluster is running on bare metal (i.e. kubeadm).

Note: These steps are not needed if you are running on a cloud provider such as GKE.

### PersistentVolumes

1. You need to manually provision a PersistentVolume. Begin by logging into one of your
worker nodes and create a directory for use by the PersistentVolumeClaim. 

```bash
$ ssh someworker
$ sudo mkdir -p /mnt/disk/vol1
```

2. Copy the sample PersistentVolume file to `peregrine/templates`.

```bash
$ cp extra/peregrine-pv-kubeadm.yaml peregrine/templates
```

3. Edit `peregrine/templates/peregrine-pv-kubeadm.yaml` and replace _yourworkerhostname_ with the hostname of the
worker where you created the directory for the PersistentVolume.


### Helm

1. Deploy role based access controlls for Tiller.

```bash
$ kubectl create -f extra/rbac-kubeadm.yaml 
```

2. Initialize Helm.

```bash
$ helm init --service-account tiller --history-max 200
```

3. Deploy Peregrine via the Helm chart. Notice that we are changing the Apache services to use a NodePort instead of the LoadBalancer since kubeadm does not support LoadBalancer.

```bash
$ helm install --name r1 peregrine --set k8s.apacheLiveServiceType=NodePort,k8s.apacheStageServiceType=NodePort
```
