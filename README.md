# Infra-Problem: an immutable solution

## The problem

A number of Clojure apps shall be deployed in a dev environment for testing purposes.

A test environment in a cloud provider shall be built from code in a cloud provider. The deployment of the infrastructure shall be fully automated and must also include the application deployment on top.

Scalability and resilience are optional, but nice to have.

### Included in this repo

  - A fork of the apps source code.
  - A Dockerfile to build containers for each app.
  - Terraform code to deploy infrastructure in a Google Cloud Compute account.

## Design

The *immutable infrastructure* pattern has been employed in order to resolve this problem.

Each application is packaged within isolated containers with all its dependencies. Each container is redeployed every time a change needs to be made.

A vanilla, supporting infrastructure is built in a cloud provider in order to provide a standard environment in which the containers can run. The infrastructure stack includes a basic OS, a distributed key-value store, the container management and orchestration tools and a reverse proxy to route the application layer traffic.

This model guarantees separation between the application and infrastructure realms. This perfectly fits environments where the product development is organised within multiple teams developing a smaller subset of features (microservices). The microservices are packaged with all their dependencies in containers. This enforces a clear separation of responsibilities between the development teams building the containers and the operation teams, tasked with running them.

Testing is also incredibily simplified: the containers can include conflicting dependencies and can still run within the same operating system. By redeploying a self-sufficient container as artefact, the delopment teams can be assured the resulting environments are predictable and reproducible.

Since the underlying infrastructure does not hold any data or specific application configuration, it can be easily created or destroyed. For this reason, the packaged applications become perfectly scalable and resilient to technical faults or business needs.

## Implementation

Having chosen the immutable design pattern, I have made the following implementation choices:

- I have chosen Hashicorp **Terraform** in order to deploy the infrastructure inside a cloud provider.
- **Google Cloud Engine** has been used to host the virtual infrastructure.
- **CoreOS** has been chosen as container Linux operating system.
- CoreOS includes natively **etcd** as key-value store, **docker** as container management tool and **fleet** as rudimental orchestration tool.
- Them apps have been packaged in docker containers. The build of these containers has been automated using **quay.io** container building and repository site.
- **Traefik** has been used as simple reverse proxy, which reads configuration within etcd and produces a reverse proxy routing the traffic to the right container.
- An external **GCE load balancer** has been employed to forward the traffic to one cluster host.
- Terraform also registers the load balancer and the single VMs external IP address with the **GCE DNS service** and **firewall rules** are produced to selectively allow the internet traffic.

A summary of the technologies highlighted in this section is represented in the follwing diagram:

[alt text](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Logo Title Text 1")

## How to run

You need the latest version of terraform (`0.8.6` at the time of writing).
`direnv` is also strongly recommended to automatically load environment variables.

A Google Cloud Compute account and an available project are needed.

If `direnv` is installed, it is possible to create a `.secrets` file in the `terraform/` directory with the following variable declarations:


```
TF_VAR_region="europe-west1"
TF_VAR_credentials_file_path="thoughtworks-111111.json"
TF_VAR_project_name="thoughtworks-111111"
TF_VAR_public_key_path="~/.ssh/id_rsa.pub"

```

The `region` and `project_name` must reflect the Google Cloud Compute setup. You can also obtain from Google Cloud Compute a `credentials_file` in json format which allows API access into the platform. Lastly, you will need to specify the path to your local `public_key`, which will be distributed to the running hosts.

Once done this, `direnv allow` will cause the secrets to be automatically exported into the environment. If direnv is not installed, then the variables will have to be manually exported.

In order to create the whole infrastructure, the following commands should be run:

```
terraform get
terraform plan
terraform apply
```

### Note on terraform

The following module instance declaration spins up a cluster of 7 app servers and applies firewalls rules allowing ports 22, 80 (http) and 8080 (Traefik stats) from the world. You can modify the `instances` param to increase or decrease the cluster size.

```

module "tw_instance" {
    instances = 7
    source = "modules/tw-instance"
    role = "app"
    environment = "dev"
    public_key_path = "${var.public_key_path}"
    dns_zone_name   = "gce.norix.co.uk."
    dns_resource_name   = "norix"
    fw_rules = [
        {
            name = "world-to-ssh"
            protocol = "tcp"
            source_ips = "0.0.0.0/0"
            ports = "22"
        },
        {
            name = "world-to-http-80"
            protocol = "tcp"
            source_ips = "0.0.0.0/0"
            ports = "80"
        },
        {
            name = "world-to-http-8080"
            protocol = "tcp"
            source_ips = "0.0.0.0/0"
            ports = "8080"
        }
    ]
}
```

The folowing load balancer declaration spins up an external load balancer listening on port 80:

```
module "tw_loadbalancer_80" {
    source              = "modules/tw-loadbalancer"
    name                = "www"
    port                = "80"
    instances           = "${module.tw_instance.names}"
    zones               = "${module.tw_instance.zones}"
    dns_zone_name       = "gce.norix.co.uk."
    dns_resource_name   = "norix"
}
```

### Note on DNS

In order to complete this task, I have used my own domain. `dns.tf` includes code to provision a new zone within Google cloud engine (GCE). Since I had created this resource manually in GCE, the code is currently commented out. Should you wish to manage your domain name using GCE, please plug the relevant `dns_name` and `name` variables into the load_balancer and instance modules. This will allow the names to be created in the managed zone for your specific domain.

I have used `gce.norix.co.uk` as base domain name. The terraform run will produce the following entries:

- `www.gce.norix.co.uk` -> resolves to the public load balancer's IP address.
- `vm-app-1.gce.norix.co.uk` -> resolves to vm-app-1's public IP address.
- `vm-app-2.gce.norix.co.uk` -> resolves to vm-app-2's public IP address.
  
  and so on...
  
## Terraform apply *step by step*
  
`Terraform apply` produces the following actions:
  
- Curls `discovery.etcd.io` to retrieve a fresh token to initialise the etcd cluster.
- Spins up a number of VMs, creates the load balancer and firewall rules, creates the DNS names to resolve the public ip addresses.
- The VMs clone a public image called `coreos-stable`.
- `Cloud-config` places a number of fleet unit files on disk in `/var/lib/fleet`, the Traefik configuration file in `/etc`, then a number of systemd unit files.
- On boot, systemd enables `etcd` which registers itself with the cluster, runs the `docker` and `fleet` services. It also starts a `Traefik` container on each machine.
- The fleet unit files include information how to start the docker containers and the service discovery units.
- A systemd service acquires a lock (so only one is run in the cluster), submits the unit files to fleet and starts the containers with the discovery units.
- The discovery units register the containers with etcd. The keys are automatically picked up by traefik, which creates the appropriate reverse proxies.

## Future work

This work can be extended so that the container's application deployment can happen on a different system, typically a continuous integration tool.

If multiple environments are required, the continuous integration tool can deploy the containers throughout the environment and run integration tests.

The continuous integration system can be just another container running in the app cluster.

Dev teams should closely work with operation teams to define their needs and discuss whether this solution accommodates their requirements.