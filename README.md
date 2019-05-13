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
    * [concourse-docker repo](https://github.com/concourse/concourse-docker)

### Exercise #1: Generate keys and certificates for Concourse and Vault

First steps will be to clone the [concourse-docker repo](https://github.com/concourse/concourse-docker).

```sh
$ git clone https://github.com/concourse/concourse-docker
```

Change directory to run the key generator script to create the keys for concourse web and worker nodes, then switch back to the project root
```sh
$ cd concourse-docker/keys/
$ sudo ./generate
$ cd ..
```


Next, we will generate a tls-cert to be used for authentication between the concourse web node and vault.

The following script will init a local CA authority and generate the certs needed.

```bash
#!/bin/bash

certstrap init --cn vault-ca
certstrap request-cert --domain vault --ip 127.0.0.1
certstrap sign vault --CA vault-ca
certstrap request-cert --cn concourse
certstrap sign concourse --CA vault-ca
mv out vault-certs
```

Ex

```sh
$ cd ..

```



### Exercise #2: Setting up docker-compose file for Concourse CI

### Exercise #3: Using Vault cli to add credentials to Vault

### Exercise #4: Test credentials using a Concourse pipeline