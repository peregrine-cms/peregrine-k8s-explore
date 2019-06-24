# Deploying Peregrine to Kubernetes

## Before you begin

This document makes several assumptions about your Kubernetes cluster:

1. It is a bare metal k8s cluster created with `kubeadm`.
2. Local disks are used on the worker nodes for PersistentVolumes.
3. Namespaces are used to segment Peregrine deployments. We assume 1 namespace per site.

If you are running Kubernetes on a Cloud provider, you may have to adjust the procedure below.

# Deploying a site with Helm

TODO

# Deploying a site (Manually)

1. Create a namespace for your site. We will use `gastongonzalez` as an example. Then, set this namespace
   as your default.

        $ kubectl create namespace gastongonzalez
        $ kubectl config set-context $(kubectl config current-context) --namespace=gastongonzalez

2. Edit the values of the environment variables defined in the ConfigMaps. `live-configmap.yml` defines
   the variables for your live instance, and `stage-configmap.yml` defines the variables for your stage
   instance. You should only change the `APACHE_DOMAIN` and `PEREGRINE_SITE` variables. The 
   `APACHE_DOMAIN` refers to the name of your site (i.e virtual host) and `PEREGRINE_SITE` referes to
   the site that you will be creating in Peregrine after the deployment is complete.

        $ kubectl create -f live-configmap.yml
        $ kubectl create -f stage-configmap.yml

3. Log into each worker node in your cluster and create a directory called `/mnt/disk/vol1`. Then, 
   Edit `peregrine-pv.yml` and change the `nodeAffinity` values to match the hostnames of your worker
   nodes. In our Kubernetes cluster our worker nodes are named `k8sworker1` and `k8sworker2`. Lastly, 
   create the PersistentVolumes.

        $ kubectl create -f peregrine-pv.yml

4. Create a StatefulSet for Peregrine. This will create a StatefulSet that manages one instance of 
   Peregrine.

        $ kubectl create -f peregrine-statefulset.yml

5. Create a headless Service for Peregrine. This will allow other services such as Apache to discover 
   the Peregrine pod(s). It should be noted, that all pods in the cluster will be able to resolve
   the Peregrine pod via internal DNS using the hostname `peregrine` once this headless service is 
   deployed.

        $ kubectl create -f peregrine-service-headless.yml


6. Create ReplicaSets to manage the Apache live and stage pods.

        $ kubectl create -f apache-live-rs.yml
        $ kubectl create -f apache-stage-rs.yml

7. Create NodePort Services so that you can access the live and stage pods.

        $ kubectl create -f apache-live-service.yml
        $ kubectl create -f apache-stage-service.yml

8. Access the apache-live and apache-stage services using the NodePort. First, determine which nodes your Apache pods are deployed to. In our case, both the Apache live and stage pods are deployed to our `k8sworker2` node.


```
$ kubectl get pods -o wide
NAME                 READY   STATUS    RESTARTS   AGE     IP           NODE         NOMINATED NODE   READINESS GATES
apache-live-6kq2c    1/1     Running   0          80s     10.244.2.3   k8sworker2   <none>           <none>
apache-stage-dglk8   1/1     Running   0          84s     10.244.2.2   k8sworker2   <none>           <none>
peregrine-0          1/1     Running   0          3m22s   10.244.1.2   k8sworker1   <none>           <none>
```

Then, determine the port for the Apache stage and live services.

```
$ k get svc
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
apache-live    NodePort    10.101.235.183   <none>        80:31063/TCP   4m59s
apache-stage   NodePort    10.105.243.162   <none>        80:31705/TCP   4m55s
peregrine      ClusterIP   None             <none>        80/TCP         6m57s
```

You can see that the `apache-live` listens on port `31063` on each worker node, and `apache-stage` listens on port `31705`. So, we can now access Apache live at http://k8sworker2:31063 and Apache stage at http://k8sworker2:31705.