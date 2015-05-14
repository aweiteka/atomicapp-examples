# Pulp Server

## Requirements

* Kubernetes
* `atomic` CLI or similar tool to run Dockerfile LABELs
* a public IP address of a kubernetes node

## What It Is

Pulp is a platform for managing repositories of content, such as software packages, and pushing that content out to large numbers of consumers. This deploys a container-based Pulp server.

## Configuration

Configuration options TBD.

## Deployment

1. identify a public IP address for a kubernetes node.
2. run

        [sudo] atomic run markllama/pulpserver-app
