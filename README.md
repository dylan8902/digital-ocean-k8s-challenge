# Digital Ocean Kubernetes Challenge

https://www.digitalocean.com/community/pages/kubernetes-challenge

I have chosen the following challenge:

> ### Deploy a log monitoring system
> So your applications produce logs. Lots of logs. How are you supposed to analyze them? A common solution is to aggregate and analyze them using the ELK stack, alongside fluentd or fluentbit.


## Step 1: Set up a Kubernetes cluster on Digital Ocean

Using the terraform digital ocean provider, I setup a small cluster
https://registry.terraform.io/providers/digitalocean/digitalocean/latest


To authenticate to Digital Ocean, I created a personal access token:
https://cloud.digitalocean.com/account/api/tokens

```
cd 01-terraform
terraform apply
```


Followed the instructions from the DO website to get `~/.kube/config` setup using the CLI, which was new to me

```
doctl auth init --context dylan8902
doctl auth switch --context dylan8902
doctl kubernetes cluster kubeconfig save a8270b2d-096c-4d3c-bce3-ef3e95fd3ffc
kubectl cluster-info
```

## Step 2: Deploying the Elastic stack

Elastic provide a Kubernetes operator to help manage the ELK stack.
I installed it following their guide
https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-deploy-eck.html

```
kubectl create -f https://download.elastic.co/downloads/eck/1.8.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/1.8.0/operator.yaml
```

Created a simple Elasticsearch cluster:

```
cd 02-kubernetes
kubectl apply -f elasticsearch.yml
```

Checked the status of the cluster and got the elastic credentials from k8s secrets:

```
kubectl get elasticsearch
PASSWORD=$(kubectl get secret logging-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
```

Created a Kibana instance with load balancer:

```
kubectl apply -f kibana.yml
```

Could get external IP to load balancer from kubernetes services API:
```
kubectl get services
```

## Step 3: Deploying the Elastic agent

Elastic provide example configuration for running the Elastic agent, using the Elastic k8s operator.

I used a slightly modified version of their example agent configuration to get metrics from kubernetes API:

https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-elastic-agent-configuration-examples.html#k8s_kubernetes_integration

```
kubectl apply -f agent.yml
```
