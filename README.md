# Peregrine - Single Instance with Stage and Live Support

[Peregrine CMS](http://www.peregrine-cms.com/) is an Apache Sling based content management system embracing a head optional and API driven approach.  

## Introduction

This chart bootstraps a single Peregrine instance with an Apache instance for your live site and an Apache instance for your stage environment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.14+
- PV provisioner support in the underlying infrastructure


## Installing the Chart

To install the chart with the release name `r1`:

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

Note: If you are running a kubeadm cluster, change k8s.apacheLiveServiceType tp `NodePort`.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

For example, to create your Peregrine with a large disk (i.e. 10GB), you can override the storage size as follows:

```
$ helm install --name r1 peregrine --set peregrine.storage=10Gi
$ k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                         STORAGECLASS   REASON   AGE
pvc-2d40e730-afc9-11e9-a43e-42010aa80005   10Gi       RWO            Delete           Bound    default/data-r4-peregrine-0   standard                24s
```

# Persistence

The [peregrine-cms](https://hub.docker.com/r/peregrinecms/peregrine-cms) image stores the data and configurations at the `/apps` path of the container.

By default persistence is enabled, and a PersistentVolumeClaim is created and mounted in that directory. As a result, a persistent volume will need to be defined:


### kubeadm

```bash
$ k create -f peregrine-pv.yml 
```
