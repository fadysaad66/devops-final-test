# DevOps Intern Final Assessment

## Author

Name: Fady Soliman

## Date

August 20, 2026

## Project Description

This project implements a complete DevOps workflow using open-source tools and practices. It covers the core stages of a modern DevOps pipeline, from source control through containerization, CI/CD, orchestration, and observability.

The project covers:

- Git and GitHub
- Linux shell scripting
- Docker
- GitHub Actions CI/CD
- HashiCorp Nomad
- Grafana Loki monitoring and logging

The goal is to build a small but realistic DevOps pipeline where each stage produces an output that is used by the next stage.

## Repository Structure

```
.
├── hello.py                     # Sample Python application
├── Dockerfile                   # Container image definition for the app
├── scripts/
│   └── sysinfo.sh                # Linux shell script for basic system info
├── .github/
│   └── workflows/
│       └── ci.yml                 # GitHub Actions CI pipeline
├── nomad/
│   └── hello.nomad                # Nomad job spec to run the app as a service
└── monitoring/
    ├── config.alloy               # Grafana Alloy config (Docker log discovery -> Loki)
    └── loki_setup.txt             # Step-by-step Loki + Alloy monitoring setup notes
```

## 1. Application

A minimal Python script, `hello.py`, prints `Hello, DevOps!` and acts as the sample workload used throughout the pipeline (build, CI test, containerize, deploy).

```bash
python hello.py
```

## 2. Linux Shell Scripting

`scripts/sysinfo.sh` is a Bash script that reports basic system information: current user, current date, and disk usage.

```bash
chmod +x scripts/sysinfo.sh
./scripts/sysinfo.sh
```

## 3. Docker

The `Dockerfile` builds a lightweight container image for the app on top of `python:3.11-slim`.

```bash
docker build -t devops-intern-final:latest .
docker run --rm devops-intern-final:latest
```

## 4. CI/CD with GitHub Actions

`.github/workflows/ci.yml` defines a CI pipeline that runs on every `push` and `pull_request`:

1. Checks out the repository
2. Sets up Python 3.11
3. Runs `hello.py` to verify the application executes correctly

This ensures the app is validated automatically on every change before merging.

## 5. Orchestration with HashiCorp Nomad

`nomad/hello.nomad` defines a Nomad job (`hello-devops`) that runs the Docker image built above as a service:

- Datacenter: `dc1`
- Driver: `docker`
- Image: `devops-intern-final:latest`
- Restart policy: up to 2 attempts within a 30-minute window, 15s delay
- Resources: 100 MHz CPU, 128 MB memory

Deploy with:

```bash
nomad job run nomad/hello.nomad
```

## 6. Monitoring and Logging with Grafana Loki

Full setup steps are documented in `monitoring/loki_setup.txt`. Summary:

1. **Loki** was run locally in Docker on a dedicated `loki-network`, exposing its API on `http://localhost:3100`.
2. **Grafana Alloy** (`monitoring/config.alloy`) was configured to discover running Docker containers via the Docker socket and forward their logs to Loki.
3. A **test container** (`devops-log-test`, based on `alpine`) was run to continuously generate log lines, verified with `docker logs`.
4. Logs were also pushed directly to Loki's HTTP push API and verified with a `query_range` API call, confirming end-to-end log ingestion and querying.
5. Useful `docker ps` / `docker logs` / `curl` commands for checking Loki, Alloy, and the test container are included for reference.

Quick start:

```bash
docker network create loki-network

docker run -d --name loki --network loki-network -p 3100:3100 \
  grafana/loki:latest -config.file=/etc/loki/local-config.yaml

docker run -d --name alloy --network loki-network \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$(pwd)/monitoring/config.alloy:/etc/alloy/config.alloy" \
  grafana/alloy:latest run /etc/alloy/config.alloy
```

## Project Status

All stages of the pipeline are complete and verified:

- [x] Application code committed to Git/GitHub
- [x] Shell script for system diagnostics
- [x] Docker image builds and runs the app
- [x] GitHub Actions CI pipeline runs on push/PR
- [x] Nomad job spec defined to run the containerized app
- [x] Loki + Alloy monitoring stack set up and log ingestion verified
