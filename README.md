# tf-azure-nginx-challenge

## Challenge: Write Terraform code

### The task
Write Terraform code using Azure provider. The code must provision a web server *(VM with nginx installed)* that is hosted in a private subnet and be reachable from the Internet via a load balancer.

### The result

To fulfill the requirements of this challenge, the following main resources were provisioned:

- **Resource group**
- **Virtual Network (VNet)** - containing public and private subnet
- **Network security group for the web server** - containint inbound and outbound rules which control the traffic based on their priorities 
- **Linux Virtual Machine** - located in private subnet
- **Bastion host** - used as a jump server to connect to the web server
- **Load balancer** - located in public subnet
- **Backend pool** associations - for the connection between the load balancer and the web server

### Refactoring to modules

The code was refactored and all resources were separated into three modules - networking, load-balancer and compute module.

- **Networking** - provisions resources like subnets, public IPs, security groups, network interfaces
- **Compute** - provisions the VM resource
- **Load Balancer** - provisions the load balancer related resources including its public IP, backend pools, probe, rules, etc. 