#!/usr/bin/env bash

set -e -u

cd $(dirname $0)

docker run --rm -v $PWD/keys/web:/keys concourse/concourse \
generate-key -t rsa -f /keys/session_signing_key

docker run --rm -v $PWD/keys/web:/keys concourse/concourse \
generate-key -t ssh -f /keys/tsa_host_key

docker run --rm -v $PWD/keys/worker:/keys concourse/concourse \
generate-key -t ssh -f /keys/worker_key

cp $PWD/keys/worker/worker_key.pub $PWD/keys/web/authorized_worker_keys
cp $PWD/keys/web/tsa_host_key.pub $PWD/keys/worker
