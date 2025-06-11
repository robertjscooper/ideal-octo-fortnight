#!/bin/bash
set -ev
trap 'exit' ERR

echo "${DOCKER_PASSWORD}" | docker login --username="${DOCKER_USER}" --password-stdin
docker build -q -t robertjscooper/ideal-octo-fortnight  .
