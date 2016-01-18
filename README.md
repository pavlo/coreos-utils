## COREOS UTILS

A small set of utilities that allows me to walk around some configuration issues I had during deploying CoreOS clusters on Rackspace.

The most prominent issue I faced was the fact that at Rackspace, the `COREOS_PRIVATE_IPV4` variable (lives in `/etc/environment` file) actually points to a Service Network which is not actually private as it is shared between tenants in the same Rackspace datacenter.

That means that your `etcd` cluster and possible other services that you think are bound to private network are not so!

### PRIVATE-NETWORK-ENV-GENERATOR

This service is a simple script that receives a network interface to get the IP address for and saves the address in `/etc/private-network-environment` file like this:   

```bash
COREOS_REAL_PRIVATE_IP=192.168.3.1
```

your services then can source this file and get the IP address of the real private network.

See more details [here](https://github.com/pavlo/coreos-utils/tree/master/private-network-env-generator)


### ETCD-ENV-GENERATOR

Helps you to configure ETCD cluster to listen on the real private network. See [here](https://github.com/pavlo/coreos-utils/tree/master/etcd-env-generator) for more details.
