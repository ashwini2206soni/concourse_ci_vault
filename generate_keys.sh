#!/usr/bin/env bash

docker run --rm -v "$PWD/keys/web:/keys" concourse/concourse \
generate-key -t rsa -f /keys/session_signing_key

docker run --rm -v "$PWD/keys/web:/keys" concourse/concourse \
generate-key -t ssh -f /keys/tsa_host_key

docker run --rm -v "$PWD/keys/worker:/keys" concourse/concourse \
generate-key -t ssh -f /keys/worker_key
