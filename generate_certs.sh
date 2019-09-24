#!/bin/bash

# Generate keys for concourse web and worker nodes

certstrap init --cn vault-ca --passphrase ""
certstrap request-cert --domain vault --ip 127.0.0.1 --passphrase ""
certstrap sign vault --CA vault-ca --passphrase ""
certstrap request-cert --cn concourse --passphrase ""
certstrap sign concourse --CA vault-ca --passphrase ""
mv out vault-certs