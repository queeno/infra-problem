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
        Restart=on-failure
        ExecStartPre=-/usr/bin/docker kill traefik
        ExecStartPre=-/usr/bin/docker rm traefik
        ExecStartPre=/usr/bin/docker pull traefik
        ExecStart=/bin/sh -c "/usr/bin/docker run --add-host=docker-host:$private_ipv4 --name traefik -p 8080:8080 -p 80:80 -v /etc/traefik.toml:/etc/traefik/traefik.toml traefik"
        ExecStop=/usr/bin/docker stop traefik
    - name: tw-quotes@.service
      content: |
        [Unit]
        Description=tw-quotes
        After=docker.service
        After=etcd2.service
        After=fleet.service
        [Service]
        Restart=on-failure
        ExecStartPre=-/usr/bin/docker kill tw-quotes
        ExecStartPre=-/usr/bin/docker rm tw-quotes
        ExecStartPre=/usr/bin/docker pull quay.io/queeno/tw-quotes
        ExecStart=/bin/sh -c "/usr/bin/docker run -p %i:8081 --name tw-quotes-%i quay.io/queeno/tw-quotes"
        ExecStop=/usr/bin/docker stop tw-quotes
        [X-Fleet]
        MachineOf=tw-quotes@%i.service
    - name: tw-quotes-discovery@.service
      content: |
        [Unit]
        Description=Service Discovery for tw-quotes
        BindsTo=tw-quotes@%i.service
        After=tw-quotes@%i.service
        [Service]
        ExecStart=/bin/sh -c "while true; do \
        etcdctl set /traefik/backends/tw-quotes/servers/server%i/url 'http://$private_ipv4:%i' \
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
    - name: tw-newsfeed@.service
      content: |
        [Unit]
        Description=tw-newsfeed
        After=docker.service
        After=etcd2.service
        After=fleet.service
        [Service]
        Restart=on-failure
        ExecStartPre=-/usr/bin/docker kill tw-newsfeed
        ExecStartPre=-/usr/bin/docker rm tw-newsfeed
        ExecStartPre=/usr/bin/docker pull quay.io/queeno/tw-newsfeed
        ExecStart=/bin/sh -c "/usr/bin/docker run -p %i:8082 --name tw-newsfeed-%i quay.io/queeno/tw-newsfeed"
        ExecStop=/usr/bin/docker stop tw-newsfeed
        [X-Fleet]
        MachineOf=tw-newsfeed@%i.service
    - name: tw-newsfeed-discovery@.service
      content: |
        [Unit]
        Description=Service Discovery for tw-newsfeed
        BindsTo=tw-newsfeed@%i.service
        After=tw-newsfeed@%i.service
        [Service]
        ExecStart=/bin/sh -c "while true; do \
        etcdctl set /traefik/backends/tw-newsfeed/servers/server%i/url 'http://$private_ipv4:%i' \
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
    - name: tw-static-assets@.service
      content: |
        [Unit]
        Description=tw-static-assets
        After=docker.service
        After=etcd2.service
        After=fleet.service
        [Service]
        Restart=on-failure
        ExecStartPre=-/usr/bin/docker kill tw-static-assets
        ExecStartPre=-/usr/bin/docker rm tw-static-assets
        ExecStartPre=/usr/bin/docker pull quay.io/queeno/tw-static-assets
        ExecStart=/bin/sh -c "/usr/bin/docker run -p %i:8000 --name tw-static-assets-%i quay.io/queeno/tw-static-assets"
        ExecStop=/usr/bin/docker stop tw-static-assets
        [X-Fleet]
        MachineOf=tw-static-assets@%i.service
    - name: tw-static-assets-discovery@.service
      content: |
        [Unit]
        Description=Service Discovery for tw-static-assets
        BindsTo=tw-static-assets@%i.service
        After=tw-static-assets@%i.service
        [Service]
        ExecStart=/bin/sh -c "while true; do \
        etcdctl set /traefik/backends/tw-static-assets/servers/server%i/url 'http://$private_ipv4:%i' \
        --ttl 60; \
        etcdctl set /traefik/frontends/tw-static-assets/backend 'tw-static-assets' \
        --ttl 60; \
        etcdctl set /traefik/frontends/tw-static-assets/routes/test_3/rule 'Host:tw-static-assets' \
        --ttl 60; \
        sleep 45; \
        done"
        ExecStop=/usr/bin/etcdctl rmdir /traefik/backends/tw-static-assets/servers/server%i
        [X-Fleet]
        MachineOf=tw-static-assets@%i.service
    - name: tw-front-end@.service
      content: |
        [Unit]
        Description=tw-front-end
        After=docker.service
        After=etcd2.service
        After=fleet.service
        [Service]
        Restart=on-failure
        ExecStartPre=-/usr/bin/docker kill tw-front-end
        ExecStartPre=-/usr/bin/docker rm tw-front-end
        ExecStartPre=/usr/bin/docker pull quay.io/queeno/tw-front-end
        ExecStart=/bin/sh -c "/usr/bin/docker run --add-host=tw-static-assets:$private_ipv4 --add-host=tw-quotes:$private_ipv4 --add-host=tw-newsfeed:$private_ipv4 -p %i:8083 --name tw-front-end-%i quay.io/queeno/tw-front-end"
        ExecStop=/usr/bin/docker stop tw-front-end
        [X-Fleet]
        MachineOf=tw-front-end@%i.service
    - name: tw-front-end-discovery@.service
      content: |
        [Unit]
        Description=Service Discovery for tw-front-end
        BindsTo=tw-front-end@%i.service
        After=tw-front-end@%i.service
        [Service]
        ExecStart=/bin/sh -c "while true; do \
        etcdctl set /traefik/backends/tw-front-end/servers/server%i/url 'http://$private_ipv4:%i' \
        --ttl 60; \
        etcdctl set /traefik/frontends/tw-front-end/backend 'tw-front-end' \
        --ttl 60; \
        etcdctl set /traefik/frontends/tw-front-end/routes/test_4/rule 'Path:/' \
        --ttl 60; \
        sleep 45; \
        done"
        ExecStop=/usr/bin/etcdctl rmdir /traefik/backends/tw-front-end/servers/server%i
        [X-Fleet]
        MachineOf=tw-front-end@%i.service
    - name: run-containers.service
      command: start
      content: |
        [Unit]
        Description=Run all containers in the cluster
        After=traefik.service
        Requires=docker.service
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStart=/usr/bin/systemctl start tw-quotes@8888
        ExecStart=/usr/bin/systemctl start tw-quotes-discovery@8888
        ExecStart=/usr/bin/systemctl start tw-newsfeed@7777
        ExecStart=/usr/bin/systemctl start tw-newsfeed-discovery@7777
        ExecStart=/usr/bin/systemctl start tw-static-assets@6666
        ExecStart=/usr/bin/systemctl start tw-static-assets-discovery@6666
        ExecStart=/usr/bin/systemctl start tw-front-end@5555
        ExecStart=/usr/bin/systemctl start tw-front-end-discovery@5555
