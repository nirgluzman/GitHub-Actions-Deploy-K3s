# K3s Lightweight Kubernetes

- <https://docs.k3s.io/>
- <https://k3d.io> (dockerized version)

## GitHub repo

- <https://github.com/nirgluzman/GitHub-Actions-Deploy-K3s.git>

## Resources

- <https://mattermost.com/blog/intro-to-k3s-lightweight-kubernetes/>
- <https://github.com/xjantoth/k3s-udemy-course>
- <https://www.youtube.com/watch?v=1hwGdey7iUU>

## Architecture

- Servers and Agents.
- Single-server Setup with an Embedded DB (SQLite datastore).
- High-Availability K3s with Embedded DB (etcd datastore) or External DB (such as MySQL, PostgreSQL,
  or etcd).

## Default configurations

- `Flannel` for network communication.
- `Traefik` Ingress Controller; can be disabled with `--disable` option.

## Installation

- K3s is expected to work on most modern Linux systems. Some OSs have additional setup requirements.

## Networking

<https://docs.k3s.io/installation/requirements#networking>

- The K3s server needs port 6443 to be accessible by all nodes.

## K3s configuration file

- In addition to configuring K3s with environment variables and CLI arguments, K3s can also use a
  config file, `/etc/rancher/k3s/config.yaml`

## Server = Master

- <https://docs.k3s.io/installation/configuration>
- <https://docs.k3s.io/cli/server>

- Configuration File - by default located at `/etc/rancher/k3s/config.yaml`

```yaml
node-name: 'k3s-server'
write-kubeconfig-mode: '0644'
token: ${k3s_token}
```

```bash
curl -sfL https://get.k3s.io | sh -s -
```

- After the installation and initial setup process we can access the K3s cluster using the kube
  config file located at the `/etc/rancher/k3s/k3s.yaml`

## Agent = Worker

- <https://docs.k3s.io/installation/configuration>
- <https://docs.k3s.io/cli/agent>
- <https://docs.k3s.io/cli/token>

- K3s uses tokens to secure the node join process. Tokens authenticate the cluster to the joining
  node, and the node to the cluster.

- Token can be set before or after the cluster has been started.

- The agent token is written in server node to `/var/lib/rancher/k3s/server/agent-token`

- By default, K3s uses a single `static token` for both servers and agents. This token cannot be
  changed once the cluster has been created. It is possible to enable a second static token that can
  only be used to join agents, or to create temporary kubeadm style join tokens that expire
  automatically.

  <https://docs.k3s.io/advanced#token-management>

- Registering the agent

<https://docs.k3s.io/installation/configuration>

- Note that setting K3S_URL without explicitly setting an exec command will default the command to
  `agent`.

- Configuration File - by default located at `/etc/rancher/k3s/config.yaml`

```yaml
node-name: 'k3s-agent'
server: https://${server_private_ip}:6443
token: ${k3s_token}
```

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=agent sh -s -
```

## Uninstalling K3s

<https://docs.k3s.io/installation/uninstall>

- To uninstall K3s from a server node, run:

```bash
/usr/local/bin/k3s-uninstall.sh
```

- To uninstall K3s from an agent node, run:

```bash
/usr/local/bin/k3s-agent-uninstall.sh
```

## K3s systemd service

- `/etc/systemd/system/k3s.service` -> server
- `/etc/systemd/system/k3s-agent.service` -> agent

- It defines how the K3s agent service is managed by `systemd`, the system service manager.
- The file contains various directives that control the behavior of the K3s agent service.
- Use `systemctl` command with the service name (k3s-agent in this case) to interact with the
  service.
- Make sure to restart the service afterwards with: `systemctl restart k3s`

## NGINX Ingress Controller

- `Traefik` is the default settings; it must be disabled !

<https://kubernetes.github.io/ingress-nginx/>

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
```

```bash
# list the namespaces in the Kubernetes cluster
kubectl get ns

# retrieve info about services running within the namespace "ingress-nginx"
# the ip address exposed is the private ip of the agent node
kubectl -n ingress-nginx get svc
```

- The "ingress-nginx" will just pick up the private IP as external IP.
- We need to manually edit the service to make your public IP address available for nginx, so it can
  start listening on your public IP address.

```bash
kubectl -n ingress-nginx edit svc ingress-nginx-controller
```

- Add the public IP as list to `spec.externalIPs` like so:

```yaml
spec:
  externalIPs:
    - <YOUR_IP>
```
