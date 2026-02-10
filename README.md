# podman-container-supervisor
podman-container-supervisor

# Motivation
This Container & Approach has been Develop in order to monitor the state of the Pod from within, while not being able to perform the Checks directly through one of the running Containers.

This attempts to address [this Issue](https://github.com/containers/podman/issues/18318), until an official Solution will be provided.

This can be useful in order for instance to restart the Pod in the following Cases:
- TLS Certificate is expired (but was in the meantime changed on Disk)
- Date & Time are not set correctly (e.g. on Raspberry Pi) until after a `ntpdate` / `chrony` Time Synchronization (thus TLS Certificate looks too new & is deemed invalid)
- Something was not ready when the container started (e.g. NFS Share not yet mounted)
- ...

# Setup
You need to first clone the Common https://github.com/luckylinux/container-build-tools somewhere in your System first, as I didn't want to over-complicate the Setup with `git subtree` or `git submodule`).

Then Symlink the Directory within this Repository to the "includes" Target:
```
git clone https://github.com/luckylinux/podman-container-supervisor.git
cd podman-container-supervisor
ln -s /path/to/container-build-tools includes
```

# Build
The Container can simply be built using:
```
./build_container.sh
```

Edit the Options to your liking.

# Deployment
Both Deployment as a self-sufficient Container ("internal Kill") and as a Podman Health Check ("external kill") are possible.

## As a self-sufficient Container
```
[Unit]
Description=<Application> Supervisor Container

[Service]
Restart=always

[Container]
ContainerName=<application>-supervisor

Pod=<application>.pod
StartWithPod=true

# Environment File
EnvironmentFile=.env.supervisor

# Environment Settings
Environment=HEALTH_CMD=./healthcheck.sh
Environment=HEALTH_START_PERIOD=60
Environment=HEALTH_RETRIES=3
Environment=HEALTH_INTERVAL=30
Environment=HEALTH_ON_FAILURE=kill
Environment=HEALTH_OUTPUT_STREAM=stderr

# Stop Container Immediately
StopSignal=SIGKILL

Image=podman-container-supervisor:alpine-latest
Pull=missing

Volume=./healthcheck.sh:/healthcheck.sh:ro,z
```


## As a Podman Health Check

```
[Unit]
Description=<Application> Supervisor Container

[Service]
Restart=always

[Container]
ContainerName=<application>-supervisor

Pod=<application>.pod
StartWithPod=true

# Environment File
EnvironmentFile=.env.supervisor

# Health Check
HealthCmd=["/healthcheck.sh"]
HealthStartPeriod=15s
HealthRetries=2
HealthInterval=5s
HealthOnFailure=kill
#HealthLogDestination=/home/podman/containers/quadlets/<application>/healthcheck
Environment=HEALTH_DEBUG=0
Environment=HEALTH_START_PERIOD=0
Environment=HEALTH_INTERVAL=0
Environment=HEALTH_INTERNAL_LOOP=0
Environment=HEALTH_OUTPUT_STREAM=stdout,stderr

# Stop Container Immediately
StopSignal=SIGKILL

Image=podman-container-supervisor:alpine-latest
Pull=missing

Volume=./healthcheck.sh:/healthcheck.sh:ro,z
```

# HealthCheck Script
`healthcheck.sh`:
```
#!/bin/bash

# Abort on Error
set -e

# Ping GHCR.io (IPv4)
is_pingable_ipv4 "ghcr.io"

# Ping GHCR.io (IPv6)
is_pingable_ipv6 "ghcr.io"

# Ping hub.docker.com (IPv4)
is_pingable_ipv4 "hub.docker.com"

# Ping hub.docker.com (IPv6)
is_pingable_ipv6 "hub.docker.com"

# Check if Caddy is listening on TCP Port 443 (HTTPS)
is_tcp_listening 443

# Check if Caddy is listening on TCP Port 80 (HTTP)
is_tcp_listening 80

# Check that HTTP Status Code is 200 when querying Caddy Webserver
http_status_code=$(curl_http_status_code "https://MYHOST.MYDOMAIN.TLD")
curl_return_code=$?

if [[ ${http_status_code} -ne 200 ]]
then
    # Exit abnormally
    exit 1
fi

# Exit Normally
exit 0
```

# Example
See Examples in the `examples/` Subfolder of this Repository.
