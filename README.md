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

Each application is packaged within isolated containers with all its dependencies. The container is redeployed every time a change needs to be made.

A vanilla, supporting infrastructure is built in a cloud provider in order to provide a standard environment in which the containers can run. The infrastructure stack includes a basic OS, a distributed key-value store, the container management and orchestration tools and a reverse proxy to route the application layer traffic.

This model guarantees separation between the application and infrastructure realms. This perfectly fits environments where the product development is organised within multiple teams developing a smaller subset of features (microservices). The microservices are packaged with all their dependencies in containers. This enforces a clear separation of responsibilities between the development teams building the containers and the operation teams, tasked with running them.

Testing is also incredibily simplified: the containers can include conflicting dependencies and can still run within the same operating system. By redeploying a self-sufficient container as artefact, the delopment teams can be assured the resulting environments are predictable and reproducible.

Since the underlying infrastructure does not hold any data or specific application configuration, it can be easily created or destroyed. For this reason, the packaged applications become perfectly scalable and resilient to the environment or business needs.

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

## How to run

You need the latest version of terraform (`0.8.6` at the time of writing).
`direnv` is also strongly suggested to automatically load environment variable.

You need a Google Cloud Compute account and an available project.

If you have `direnv` installed, you can just create a `.secrets` file in the `terraform/` directory including the following 4 variables.


```
TF_VAR_region="europe-west1"
TF_VAR_credentials_file_path="thoughtworks-111111.json"
TF_VAR_project_name="thoughtworks-111111"
TF_VAR_public_key_path="~/.ssh/id_rsa.pub"

```

The `region` and `project_name` must match with the Google Cloud Compute set-up. You can also obtain from Google Cloud Compute a `credentials_file` in json format which allows API access into the platform. Lastly, you will need to specify the path to your local `public_key`, which will be distributed to the running hosts.

Once done this, `direnv allow` will cause those variable to be automatically exported into the environment. If direnv is not installed, then the variables will have to be manually exported.

In order to spin-up the infrastructure (and VMs), you will have to run the following commands:

```
terraform get
terraform plan
terraform apply
```

### Note on DNS

In order to complete this task, I have used a subdomain of an owned domain. If you wish to use your own, you will have to comment out the code included in `dns.tf` and plug the `dns_name` and `name` variable into the load_balancer and instance modules. This will allow the names to be created for your specific domain.

I have used `gce.norix.co.uk` as base domain name. The terraform run will produce the following entries:

- `www.gce.norix.co.uk` -> resolves to the public load balancer's IP address.
- `vm-app-1.gce.norix.co.uk` -> resolves to vm-app-1's public IP address.
- `vm-app-2.gce.norix.co.uk` -> resolves to vm-app-2's public IP address.
  
  and so on...