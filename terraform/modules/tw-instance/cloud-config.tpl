#cloud-config

write_files:
  - path: /etc/traefik.toml
    content: |
      [etcd]
      endpoint = "docker-host:2379"
      watch = true
      prefix = "/traefik"
      [web]
      address = ":8080"
  - path: /var/lib/fleet/tw-quotes@.service
    content: |
      [Unit]
      Description=tw-quotes
      After=docker.service
      After=etcd2.service
      After=fleet.service
      [Service]
      Restart=always
      ExecStartPre=-/usr/bin/docker kill tw-quotes
      ExecStartPre=-/usr/bin/docker rm tw-quotes
      ExecStartPre=/usr/bin/docker pull quay.io/queeno/tw-quotes
      ExecStart=/bin/sh -c "/usr/bin/docker run --health-cmd 'curl http://localhost:8081/ping || exit 1' --health-interval 3s --health-retries 3 --health-timeout 3s -p %i:8081 --name tw-quotes-%i quay.io/queeno/tw-quotes"
      ExecStop=/usr/bin/docker kill tw-quotes
  - path: /var/lib/fleet/tw-quotes-discovery@.service
    content: |
      [Unit]
      Description=Service Discovery for tw-quotes
      BindsTo=tw-quotes@%i.service
      After=tw-quotes@%i.service
      [Service]
      Restart=always
      ExecStart=/bin/sh -c "while true; do \
      etcdctl set /traefik/backends/tw-quotes/servers/server%i/url 'http://%H:%i' \
      --ttl 60; \
      etcdctl set /traefik/frontends/tw-quotes/backend 'tw-quotes' \
      --ttl 60; \
      etcdctl set /traefik/frontends/tw-quotes/routes/test_1/rule 'Host:tw-quotes' \
      --ttl 60; \
      sleep 45; \
      done"
      ExecStop=/usr/bin/etcdctl rmdir /traefik/backends/tw-quotes/servers/server%i
      [X-Fleet]
      MachineOf=tw-quotes@%i.service
  - path: /var/lib/fleet/tw-newsfeed@.service
    content: |
      [Unit]
      Description=tw-newsfeed
      After=docker.service
      After=etcd2.service
      After=fleet.service
      [Service]
      Restart=always
      ExecStartPre=-/usr/bin/docker kill tw-newsfeed
      ExecStartPre=-/usr/bin/docker rm tw-newsfeed
      ExecStartPre=/usr/bin/docker pull quay.io/queeno/tw-newsfeed
      ExecStart=/bin/sh -c "/usr/bin/docker run --health-cmd 'curl http://localhost:8082/ping || exit 1' --health-interval 3s --health-retries 3 --health-timeout 3s -p %i:8082 --name tw-newsfeed-%i quay.io/queeno/tw-newsfeed"
      ExecStop=/usr/bin/docker kill tw-newsfeed
  - path: /var/lib/fleet/tw-newsfeed-discovery@.service
    content: |
      [Unit]
      Description=Service Discovery for tw-newsfeed
      BindsTo=tw-newsfeed@%i.service
      After=tw-newsfeed@%i.service
      [Service]
      Restart=always
      ExecStart=/bin/sh -c "while true; do \
      etcdctl set /traefik/backends/tw-newsfeed/servers/server%i/url 'http://%H:%i' \
      --ttl 60; \
      etcdctl set /traefik/frontends/tw-newsfeed/backend 'tw-newsfeed' \
      --ttl 60; \
      etcdctl set /traefik/frontends/tw-newsfeed/routes/test_2/rule 'Host:tw-newsfeed' \
      --ttl 60; \
      sleep 45; \
      done"
      ExecStop=/usr/bin/etcdctl rmdir /traefik/backends/tw-newsfeed/servers/server%i
      [X-Fleet]
      MachineOf=tw-newsfeed@%i.service
  - path: /var/lib/fleet/tw-static-assets@.service
    content: |
      [Unit]
      Description=tw-static-assets
      After=docker.service
      After=etcd2.service
      After=fleet.service
      [Service]
      Restart=always
      ExecStartPre=-/usr/bin/docker kill tw-static-assets
      ExecStartPre=-/usr/bin/docker rm tw-static-assets
      ExecStartPre=/usr/bin/docker pull quay.io/queeno/tw-static-assets
      ExecStart=/bin/sh -c "/usr/bin/docker run --health-cmd 'curl http://localhost:8000/ping || exit 1' --health-interval 3s --health-retries 3 --health-timeout 3s -p %i:8000 --name tw-static-assets-%i quay.io/queeno/tw-static-assets"
      ExecStop=/usr/bin/docker kill tw-static-assets
  - path: /var/lib/fleet/tw-static-assets-discovery@.service
    content: |
      [Unit]
      Description=Service Discovery for tw-static-assets
      BindsTo=tw-static-assets@%i.service
      After=tw-static-assets@%i.service
      [Service]
      Restart=always
      ExecStart=/bin/sh -c "while true; do \
      etcdctl set /traefik/backends/tw-static-assets/servers/server%i/url 'http://%H:%i' \
      --ttl 60; \
      etcdctl set /traefik/frontends/tw-static-assets/backend 'tw-static-assets' \
      --ttl 60; \
      etcdctl set /traefik/frontends/tw-static-assets/routes/test_3/rule 'Host:www.gce.norix.co.uk;PathPrefix:/css' \
      --ttl 60; \
      sleep 45; \
      done"
      ExecStop=/usr/bin/etcdctl rmdir /traefik/backends/tw-static-assets/servers/server%i
      [X-Fleet]
      MachineOf=tw-static-assets@%i.service
  - path: /var/lib/fleet/tw-front-end@.service
    content: |
      [Unit]
      Description=tw-front-end
      After=docker.service
      After=etcd2.service
      After=fleet.service
      [Service]
      Restart=always
      ExecStartPre=-/usr/bin/docker kill tw-front-end
      ExecStartPre=-/usr/bin/docker rm tw-front-end
      ExecStartPre=/usr/bin/docker pull quay.io/queeno/tw-front-end
      ExecStart=/bin/sh -c "/usr/bin/docker run --health-cmd 'curl http://localhost:8083/ping || exit 1' --health-interval 3s --health-retries 3 --health-timeout 3s --add-host=tw-static-assets:$(dig +short %H) --add-host=tw-quotes:$private_ipv4 --add-host=tw-newsfeed:$private_ipv4 -p %i:8083 --name tw-front-end-%i quay.io/queeno/tw-front-end"
      ExecStop=/usr/bin/docker kill tw-front-end
  - path: /var/lib/fleet/tw-front-end-discovery@.service
    content: |
      [Unit]
      Description=Service Discovery for tw-front-end
      BindsTo=tw-front-end@%i.service
      After=tw-front-end@%i.service
      [Service]
      Restart=always
      ExecStart=/bin/sh -c "while true; do \
      etcdctl set /traefik/backends/tw-front-end/servers/server%i/url 'http://%H:%i' \
      --ttl 60; \
      etcdctl set /traefik/frontends/tw-front-end/backend 'tw-front-end' \
      --ttl 60; \
      etcdctl set /traefik/frontends/tw-front-end/routes/test_4/rule 'Host:www.gce.norix.co.uk;Path:/' \
      --ttl 60; \
      sleep 45; \
      done"
      ExecStop=/usr/bin/etcdctl rmdir /traefik/backends/tw-front-end/servers/server%i
      [X-Fleet]
      MachineOf=tw-front-end@%i.service
coreos:
  etcd2:
    discovery: "${etcd_discovery_url}"
    advertise-client-urls: "http://$private_ipv4:2379"
    initial-advertise-peer-urls: "http://$private_ipv4:2380"
    listen-client-urls: "http://0.0.0.0:2379"
    listen-peer-urls: "http://$private_ipv4:2380"
  fleet:
    public-ip: "$public_ipv4"
    metadata: "region=${region}"
  units:
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start
    - name: format-ephemeral.service
      command: start
      content: |
        [Unit]
        Description=Formats the ephemeral drive
        After=dev-sdb.device
        Requires=dev-sdb.device
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStart=/usr/sbin/wipefs -f /dev/sdb
        ExecStart=/usr/sbin/mkfs.ext4 -F /dev/sdb
    - name: var-lib-docker.mount
      command: start
      content: |
        [Unit]
        Description=Mount ephemeral to /var/lib/docker
        Requires=format-ephemeral.service
        After=format-ephemeral.service
        [Mount]
        What=/dev/sdb
        Where=/var/lib/docker
        Type=ext4
    - name: docker.service
      command: start
      enable: true
      drop-ins:
        - name: 10-wait-docker.conf
          content: |
            [Unit]
            After=var-lib-docker.mount
            Requires=var-lib-docker.mount
    - name: traefik.service
      command: start
      enable: true
      content: |
        [Unit]
        Description=Traefik
        After=docker.service
        After=etcd2.service
        After=fleet.service
        [Service]
        Restart=always
        ExecStartPre=-/usr/bin/docker kill traefik
        ExecStartPre=-/usr/bin/docker rm traefik
        ExecStartPre=/usr/bin/docker pull traefik
        ExecStart=/bin/sh -c "/usr/bin/docker run --health-cmd 'curl http://localhost:8080 || exit 1' --health-interval 3s --health-retries 3 --health-timeout 3s --add-host=docker-host:$private_ipv4 --name traefik -p 8080:8080 -p 80:80 -v /etc/traefik.toml:/etc/traefik/traefik.toml traefik"
        ExecStop=/usr/bin/docker stop traefik
    - name: run-containers.service
      command: start
      enable: true
      content: |
        [Unit]
        Description=Run all containers in the cluster
        After=traefik.service
        After=docker.service
        After=fleet.service
        After=etcd2.service
        [Service]
        Type=oneshot
        RemainAfterExit=no
        ExecStartPre=/bin/sh -c "until /usr/bin/fleetctl list-machines; do sleep 2; done"
                                 if [ $? != 0 ]; then etcdctl mkdir /containers; \
                                                      etcdctl set /containers/started 1; \
                                 else exit 1; fi"
        ExecStartPre=/bin/sh -c "/usr/bin/fleetctl submit /var/lib/fleet/*.service"
        ExecStart=/bin/sh -c "/usr/bin/fleetctl start tw-quotes@8888; \
        /usr/bin/fleetctl start tw-quotes-discovery@8888; \
        /usr/bin/fleetctl start tw-newsfeed@7777; \
        /usr/bin/fleetctl start tw-newsfeed-discovery@7777; \
        /usr/bin/fleetctl start tw-static-assets@6666; \
        /usr/bin/fleetctl start tw-static-assets-discovery@6666; \
        /usr/bin/fleetctl start tw-front-end@5555; \
        /usr/bin/fleetctl start tw-front-end-discovery@5555; \
        /usr/bin/fleetctl start tw-quotes@18888; \
        /usr/bin/fleetctl start tw-quotes-discovery@18888; \
        /usr/bin/fleetctl start tw-newsfeed@17777; \
        /usr/bin/fleetctl start tw-newsfeed-discovery@17777; \
        /usr/bin/fleetctl start tw-static-assets@16666; \
        /usr/bin/fleetctl start tw-static-assets-discovery@16666; \
        /usr/bin/fleetctl start tw-front-end@15555; \
        /usr/bin/fleetctl start tw-front-end-discovery@15555"
