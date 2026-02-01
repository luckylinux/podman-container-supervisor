# podman-container-supervisor
podman-container-supervisor

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

HealthLogDestination=/home/podman/containers/quadlets/<application>/healthcheck

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
ping -c4 -4 ghcr.io

# Ping GHCR.io (IPv6)
ping -c4 -6 ghcr.io

# Ping hub.docker.com (IPv4)
ping -c4 -4 hub.docker.com

# Ping hub.docker.com (IPv6)
ping -c4 -6 hub.docker.com

# Exit Normally
exit 0
```

# Example
