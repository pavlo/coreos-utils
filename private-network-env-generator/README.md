## PRIVATE NETWORK ENVIRONMENT GENERATOR

Some providers, such as Rackspace, inject the `COREOS_PRIVATE_IPV4` variable pointed to Service Network even when a real private network is available. This would make difficulties for you if your services need to bind to the real private network.

This service is a simple script that receives a network interface to get the IP address for and saves the address in `/etc/private-network-environment` file like this:   

```bash
COREOS_REAL_PRIVATE_IP=192.168.3.1
```

### Installation

Add the following unit to your cloud-init:

    units:
     - name: private-network-env-generator.service
       command: start
       content: |
         [Unit]
         Requires=network.target
         After=network.target
         [Service]
         ExecStartPre=-/usr/bin/mkdir -p /opt/bin
         ExecStartPre=/usr/bin/wget -N -P /opt/bin https://raw.githubusercontent.com/pavlo/coreos-utils/master/private-network-env-generator/private-network-env-generator.sh
         ExecStartPre=/usr/bin/chmod +x /opt/bin/private-network-env-generator.sh
         ExecStart=/opt/bin/etcd-env-generator.sh eth2
         RemainAfterExit=yes
         Type=oneshot

Note, we just passed it a `eth2` network interface as the argument. This is going to be the interface it will read the IP address for.

After this, a unit, that needs to know the real private IP address can be declared like this:

    [Unit]
    Requires=private-network-env-generator.service
    After=private-network-env-generator.service
    [Service]
    EnvironmentFile=/etc/private-network-environment
    ExecStart=myapp $(COREOS_REAL_PRIVATE_IP)

## License

The tool is licensed under the [MIT License](http://www.opensource.org/licenses/MIT).
