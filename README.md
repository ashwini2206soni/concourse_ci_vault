# Overview

Concourse CI is a simple CI/CD tool that leverages containers to manage tasks for clean execution of pipelines. Vault is an API driven secrets management platform that allows a secure centralized source of housing credentials.

This lab is for local testing purposes, configure security for any production usage.

## What's covered in this lab

1. Using docker-compose to stand up a local test environment of Concourse CI

2. Integrate Vault as a credentials/variable manager for Concourse CI

3. Push credentials to Vault via cli and test usage in Concourse CI

## Before you begin

1. This lab uses Ubuntu 18.04

2. Install the following pre-reqs
    * [docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
    * [vault](https://www.vaultproject.io/docs/install/)
    * [certify](https://github.com/square/certstrap)

3. Read reference documentation for troubleshooting issues
    * Steps follow deployment procedure from [concourse-docker repo](https://github.com/concourse/concourse-docker)
    * Vault integration steps followed on [Concourse Creds documentation](https://concourse-ci.org/vault-credential-manager.html)

### Exercise #1: Generate keys and certificates for Concourse and Vault

First steps will be to generate the keys needed for concourse web and worker nodes

The following script uses the concourse docker image to generate the keys and place them in keys/web and keys/worker directories

generate_keys.sh
```sh
#!/usr/bin/env bash

set -e -u

cd $(dirname $0)

docker run --rm -v $PWD/keys/web:/keys concourse/concourse \
generate-key -t rsa -f /keys/session_signing_key

docker run --rm -v $PWD/keys/web:/keys concourse/concourse \
generate-key -t ssh -f /keys/tsa_host_key

docker run --rm -v $PWD/keys/worker:/keys concourse/concourse \
generate-key -t ssh -f /keys/worker_key

cp ./keys/worker/worker_key.pub ./keys/web/authorized_worker_keys
cp ./keys/web/tsa_host_key.pub ./keys/worker
```


Next, we will generate a tls-cert to be used for authentication between the concourse web node and vault

The following script will init a local CA authority and generate the certs needed

generate_certs.sh
```bash
#!/bin/bash

certstrap init --cn vault-ca
certstrap request-cert --domain vault --ip 127.0.0.1
certstrap sign vault --CA vault-ca
certstrap request-cert --cn concourse
certstrap sign concourse --CA vault-ca
mv out vault-certs
```



### Exercise #2: Setting up docker-compose file for Concourse CI and Vault

### Exercise #3: Using Vault cli to add credentials to Vault

### Exercise #4: Test credentials using a Concourse pipeline