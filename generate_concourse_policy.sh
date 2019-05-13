#!/bin/bash

vault policy write concourse vault-config/concourse-policy.hcl

vault auth enable cert

vault write auth/cert/certs/concourse \
policies=concourse \
certificate=@vault-certs/vault-ca.crt \
ttl=1h