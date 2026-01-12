Kubernetes - Installation
==============================

This document provides guidance on Installing Kubernetes

- [Kubernetes - Installation](#kubernetes---installation)
- [IMPORTANT](#important)
- [Prerequisites](#prerequisites)
- [Variables](#variables)
  - [`deploymentNumber` options:](#deploymentnumber-options)
- [Deploy Kubernetes via Playbook](#deploy-kubernetes-via-playbook)
  - [Deploy Kubernetes](#deploy-kubernetes)

IMPORTANT
===============================

Before running the playbooks, ensure you've start a disconnected session by running the  `tmux` command before starting the deployment. This ensures the playbook doesn't break due to a disconnected session. For more details on leveraging screen, see https://linux.die.net/man/1/tmux.

Prerequisites
===============================

Ensure Kubernetes infrastructure has been deployed.

Variables
==============================

## `deploymentNumber` options:

- 0
- 1
- 2
- 3
- 4
- 5
- 6
- 7

*Subject to grow as more infrastructure is provisioned*

Deploy Kubernetes via Playbook
==============================

## Deploy Kubernetes

This playbook runs through all of the necessary roles to complete the install.

```bash
$ ansible-playbook -i "inventory_files/sample" \
  -e deployment_number=$deploymentNumber \
  playbooks/install-kubernetes.yml
```