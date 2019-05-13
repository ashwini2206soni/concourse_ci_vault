# Overview

Concourse CI is a simple CI/CD tool that leverages containers to manage tasks for clean execution of pipelines. 

## What's covered in this lab

1. Using docker to stand up a local test environment of Concourse CI

2. Integrate Vault as a credentials/variable manager for Concourse CI

3. Push credentials to Vault via cli and test usage in Concourse CI

## Before you begin

1. This lab uses Ubuntu 18.04

2. Install the following pre-reqs
    * [docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
    * [vault](https://www.vaultproject.io/docs/install/)
    * [certify](https://github.com/square/certstrap)

### Exercise #1: Generate keys and certificates for Concourse and Vault

### Exercise #2: Setting up docker-compose file for Concourse CI

### Exercise #3: Using Vault cli to add credentials to Vault

### Exercise #4: Test credentials using a Concourse pipeline