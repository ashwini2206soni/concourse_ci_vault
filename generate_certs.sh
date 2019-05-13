#!/bin/bash

# Generate keys for concourse web and worker nodes

certstrap init --cn vault-ca
certstrap request-cert --domain vault --ip 127.0.0.1
certstrap sign vault --CA vault-ca
certstrap request-cert --cn concourse
certstrap sign concourse --CA vault-ca
mv out vault-certs