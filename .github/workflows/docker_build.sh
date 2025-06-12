#!/bin/bash
set -ev
trap 'exit' ERR

echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USER}" --password-stdin
docker build -q -t robertjscooper/ideal-octo-fortnight  .
docker push robertjscooper/ideal-octo-fortnight
