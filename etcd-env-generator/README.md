## ETCD ENVIRONMENT GENERATOR

The tool generates an `EnvironmentFile` file for `etcd2.service` which then can be injected (via the drop-in feature of `systemd`) into `etcd2.service`.

This allows to bypass the normal 'etcd2' configuration in `cloud-init` in order to be able to stand up `etcd2` on a real private network (versus PublicNet or ServiceNet Rackspace exposes).

See this thread for more detailed description of original issue and comments - http://serverfault.com/questions/745609/coreos-inject-a-real-private-ip-in-etcd2-cloud-config

### Setup

1. In your cloud-init file you comment out default `etcd2` declaration because it uses `$private_ipv4` which Rackspace resolves to ServiceNet (which is not quite private).

        #cloud-config
          coreos:
          # NOTE, THE WHOLE ETCD2 SECTION BELOW IS COMMENTED OUT!
          # It is because it actually creates exactly the same drop-in for etcd2.service
          # that we're going create with our 'etcd-env-generator.service' below
          # For more information see this -
          # https://coreos.com/os/docs/latest/using-environment-variables-in-systemd-units.html
          # skip to section called "etcd2.service Unit Advanced Example"
          #
          # etcd2:
          #    discovery: https://discovery.etcd.io/<token>
          #    advertise-client-urls: http://$private_ipv4:2379,http://$private_ipv4:4001
          #    initial-advertise-peer-urls: http://$private_ipv4:2380
          #    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
          #    listen-peer-urls: http://$private_ipv4:2380

2. Add a new `unit` like shown below:

        units:
          - name: etcd-env-generator.service
            command: start
            content: |
              [Unit]
              Description=Creates an EnvironmentFile with etcd2 setup on private network to be injected into etcd2 service
              Documentation=https://github.com/pavlo/coreos-utils/etcd-env-generator
              Requires=network.target
              After=network.target
              [Service]
              ExecStartPre=-/usr/bin/mkdir -p /opt/bin
              ExecStartPre=/usr/bin/wget -N -P /opt/bin https://raw.githubusercontent.com/pavlo/coreos-utils/master/etcd-env-generator/etcd-env-generator.sh
              ExecStartPre=/usr/bin/chmod +x /opt/bin/etcd-env-generator.sh
              ExecStart=/opt/bin/etcd-env-generator.sh <iface> <token>
              RemainAfterExit=yes
              Type=oneshot

Note that you're supposed to pass network interface for etcd2 to listen at as well as CoreOS cluster token (obtained at `https://discovery.etcd.io/new?size=x`) in the ExecStart command:

        ExecStart=/opt/bin/etcd-env-generator.sh eth2 1c62104e7b81dcd903e848309f2eaa25

3. Create a drop-in for original `etcd2.service`:

        - name: etcd2.service
        drop-ins:
          - name: "urls.conf"
            content: |
              [Unit]
              Requires=etcd-env-generator.service
              After=etcd-env-generator.service
              [Service]
              EnvironmentFile=/etc/etcd2-environment

This will prescribe `etcd2.service` to get configuration data from `/etc/etcd2-environment` file the `etcd-env-generator.service` generated at step #2

### More details

1. See `how-to-inject-into-etcd2-service` text file for a sample `cloud-init` that uses `etcd-env-generator` tool.
2. The tread on Serverfault - [CoreOS: Inject a real private IP in etcd2 cloud-config](http://serverfault.com/questions/745609/coreos-inject-a-real-private-ip-in-etcd2-cloud-config)
3. The [approach]( https://coreos.com/os/docs/latest/using-environment-variables-in-systemd-units.html) described in CoreOS documentation, (skip to section called "etcd2.service Unit Advanced Example")

## License

The tool is licensed under the [MIT License](http://www.opensource.org/licenses/MIT).
