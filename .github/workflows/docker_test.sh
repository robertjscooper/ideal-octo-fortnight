#!/bin/bash
set -ev
trap 'exit' ERR

echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USER}" --password-stdin
docker pull ${GIT_REPO}:test
docker run -ti ${GIT_REPO} py.test