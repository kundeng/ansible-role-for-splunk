# Splunk Virtual Lab

This directory contains a Docker + Molecule harness for exercising this role against systemd-based container topologies.

Goals:
- virtual lab: SSH into the ansible-controller and operate it like a real Splunk deployment
- repeatable integration testing for role changes
- realistic SSH connectivity (instead of docker connection for converge)
- optional web terminal into the controller for interactive debugging

## Architecture

```
Host (macOS / Linux)
  |
  task setup / task infra:test          <-- Taskfile is the single entry point
  |
  +-- molecule-runner (ephemeral)        Runs molecule via Docker socket
  |
  +-- splunk-test-network (Docker bridge)
        |
        +-- ansible-controller           <-- SSH / web terminal here
        |     ansible.cfg + SSH keys       run playbooks like production
        |     /workspace (bind mount)
        |
        +-- splunk-master                Cluster Manager
        +-- splunk-license               License Manager / DMC
        +-- splunkapp-prod01             Indexer (site1)
        +-- splunkapp-prod02             Indexer (site2, AlmaLinux)
        +-- splunkshc-prod01             Search Head
        +-- splunkshc-prod02             Search Head (AlmaLinux)
        +-- splunk-deploy                SH Deployer
        +-- splunk-fwdmanager            Deployment Server
        +-- splunk-uf01                  Universal Forwarder
        +-- git-server                   Gitea (app repos)

Topology shown: prod (MOLECULE_ENV=prod)
small (default) = splunk-master + splunkapp-prod01 + controller
dev             = single all-in-one node + controller
```

## Prereqs
- Docker
- [Task](https://taskfile.dev/) (go-task) on the host

## Quick start
```bash
cd testing

# one-time setup: secrets, images, downloads, network
task setup

# run the full test suite (infra, day0, day1, destroy)
task workflow:full

# quick workflow (infra + day0, keeps containers for debugging)
task workflow:quick

# list all available commands
task --list

# force rebuild all Docker images
task setup:rebuild
```

## Environments
Select a topology via `MOLECULE_ENV`:
- `small` (default): 2 Splunk nodes + controller
- `dev`: 1 Splunk node + controller
- `prod`: 9 Splunk nodes + controller (+ git-server)

Examples:
```bash
MOLECULE_ENV=dev task workflow:full
MOLECULE_ENV=prod task workflow:full
```

## Using the ansible-controller
After `task infra:setup`, the ansible-controller is a self-sufficient deployment box. SSH in or use the web terminal, then run playbooks directly:
```bash
# web terminal at http://localhost:3000/ttyd (ansible:<password from .secrets/ansible_password>)
# or: docker exec -it -u ansible ansible-controller bash

# from inside the controller — no --inventory flags needed:
ansible all -m ping
ansible-playbook /workspace/playbooks/splunk_install.yml
```

The controller has an `ansible.cfg` pre-configured with the correct inventory sources and roles path.

## Splunk version
The Splunk version is set in each environment's group_vars:
```yaml
# testing/molecule/environments/<env>/group_vars/all.yml
splunk_package_version: 9.4.2
build_id: e9664af3d956
```
Download URLs and architecture suffixes are derived automatically from the role defaults. After changing the version, re-run `task download:splunk` to fetch the new binaries.

## Secrets
`task setup:secrets` creates secrets if they don't exist in `testing/.secrets/`:
- `inventory/group_vars/all.yml` - YAML vars file with `splunk_admin_password` and `gitea_secret_key`
- `id_rsa` / `id_rsa.pub` - SSH keys for container communication
- `ansible_password` - password for the ansible user on the web terminal

Secrets are loaded as an Ansible inventory source, making them available as regular variables. None of these files are committed to the repository.

## Web terminal (password-protected)
After `task infra:setup`, a web terminal is exposed at `http://localhost:3000/ttyd`.
- Auth is enabled (`ansible:<password>`).
- The password is in `testing/.secrets/ansible_password`.

## Cleanup
```bash
# targeted cleanup: test containers, volumes, and network only
task reset
```
Docker volumes are prefixed with `ansible-splunk-test-` to avoid conflicts with other resources on your workstation.
