# Overview

Concourse CI is a simple CI/CD tool that leverages containers to manage tasks for clean execution of pipelines. Vault is an API driven secrets management platform that allows a secure centralized source of housing credentials.

This lab is for local testing purposes only, not recommended for any production usage.

## What's covered in this lab

1. Using docker-compose to stand up a local test environment of Concourse CI

2. Integrate Vault as a credentials/variable manager for Concourse CI

3. Push credentials to Vault via cli 

4. Run sample task to test access to secrets in Concourse CI

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

The following script uses the Concourse docker image to generate the keys and place them in keys/web and keys/worker directories

```console
$ ./generate_keys.sh
```
  
```bash
#!/usr/bin/env bash

set -e -u

cd $(dirname $0)

docker run --rm -v $PWD/keys/web:/keys concourse/concourse \
generate-key -t rsa -f /keys/session_signing_key

docker run --rm -v $PWD/keys/web:/keys concourse/concourse \
generate-key -t ssh -f /keys/tsa_host_key

docker run --rm -v $PWD/keys/worker:/keys concourse/concourse \
generate-key -t ssh -f /keys/worker_key

```

Copy pub keys from web to workers and vice-versa

```console
sudo cp -f ./keys/worker/worker_key.pub ./keys/web/authorized_worker_keys
sudo cp -f ./keys/web/tsa_host_key.pub ./keys/worker
```


Next, we will generate a tls-cert to be used for authentication between the Concourse web node and Vault

The following script will init a local CA authority and generate the certs needed

```console
$ ./generate_certs.sh
```

```bash
#!/bin/bash

# Generate keys for concourse web and worker nodes

certstrap init --cn vault-ca --passphrase ""
certstrap request-cert --domain vault --ip 127.0.0.1 --passphrase ""
certstrap sign vault --CA vault-ca --passphrase ""
certstrap request-cert --cn concourse --passphrase ""
certstrap sign concourse --CA vault-ca --passphrase ""
mv out vault-certs
```
  
  
### Exercise #2: Setting up docker-compose file for Concourse CI and Vault

We will use docker-compose to set-up the environment. Included in this repo is a `docker-compose.yml` file that uses the certs and keys generated to init Concourse web/workers and Vault.

To run the docker-compose file, run the following

```console
$ docker-compose up -d
```

If successful you will see the following output when running `docker container ls`
```console
$ docker container ls
CONTAINER ID        IMAGE                 COMMAND                  CREATED              STATUS              PORTS                    NAMES
288054bf2478        concourse/concourse   "dumb-init /usr/loca…"   About a minute ago   Up About a minute                            concourse_ci_vault_worker_1
9083e13ed496        concourse/concourse   "dumb-init /usr/loca…"   About a minute ago   Up About a minute   0.0.0.0:8080->8080/tcp   concourse_ci_vault_web_1
1efd97078b52        vault                 "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:8200->8200/tcp   concourse_ci_vault_vault_1
9b963b7e9917        postgres              "docker-entrypoint.s…"   About a minute ago   Up About a minute   5432/tcp                 concourse_ci_vault_db_1
```

Open your browser and check `http://localhost:8080` for concourse and `https://localhost:8200` for vault.


### Exercise #3: Using Vault cli to add credentials to Vault

Now that we have Concourse and Vault up, let's initialize Vault for Concourse to use.

Set the local environment variable and run the init command for Vault

```console
$ export VAULT_CACERT=$PWD/vault-certs/vault-ca.crt
$ vault operator init
Unseal Key 1: key1
Unseal Key 2: key2
Unseal Key 3: key3
Unseal Key 4: key4
Unseal Key 5: key5

Initial Root Token: roottoken

Vault initialized with 5 key shares and a key threshold of 3. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 3 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 3 key to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
```

Use at least 3 keys to unseal Vault and login with the root token

```console
$ vault operator unseal # paste unseal key 1
$ vault operator unseal # paste unseal key 2
$ vault operator unseal # paste unseal key 3
$ vault login           # paste root token
```

Now we enable the cert backend to allow concourse to authenticate to Vault.  

You can use the following script to enable the cert backend and secrets engine.

```console
$ ./generate_concourse_policy.sh
```

```bash
#!/bin/bash

vault policy write concourse vault-config/concourse-policy.hcl

vault auth enable cert

vault write auth/cert/certs/concourse \
policies=concourse \
certificate=@vault-certs/vault-ca.crt \
ttl=1h

vault secrets enable -path=concourse/ kv
```

Add a sample secret to Vault to test the path is writable.

```console
$ vault kv put concourse/main/demo_value TEST=HELLOWORLD
```

### Exercise #4: Test secret using a Concourse pipeline

Now to test concourse is able to access the secret stored in Vault.

Login to concourse using the following commands

```console
$ sudo fly --target tutorial login --concourse-url http://127.0.0.1:8080 -u test -p test
logging in to team 'main'


target saved
$ sudo fly --target tutorial sync
version 5.1.0 already matches; skipping
```

Now use the sample Concourse task to test if we can access the secret and use it in a task.

```console
$ sudo fly -t tutorial execute -c .ci/sample.yml 
uploading concourse_ci_vault done
executing build 1 at http://127.0.0.1:8080/builds/1 
initializing
running sh -exc echo $SAMPLE
+ echo HELLOWORLD
HELLOWORLD
succeeded
```

You can also browse to [http://127.0.0.1:8080/builds/1](http://127.0.0.1:8080/builds/1) to see your build in the Concourse web console.

And that's a wrap with this tutorial! Hopefully this demo provides a better understanding of both Concourse CI and Vault and their uses for managing sensitive values.