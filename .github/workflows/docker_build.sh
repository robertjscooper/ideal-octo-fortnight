#!/bin/bash
set -ev
trap 'exit' ERR
TAG_NAME = "${BRANCH_NAME}"
if [ "${BRANCH_NAME}" == "main"]; then
    TAG_NAME = "latest"
fi
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USER}" --password-stdin
docker build -q -t ${GIT_REPO}:$TAG_NAME  .
docker push ${GIT_REPO}:$TAG_NAME
