#!/bin/bash
set -ev
trap 'exit' ERR
if [ "${BRANCH_NAME}" == "main"]; then
    TAG_NAME = "latest"
else
    TAG_NAME = "${BRANCH_NAME}"
fi
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USER}" --password-stdin
docker build -q -t ${GIT_REPO}:${TAG_NAME}  .
docker push ${GIT_REPO}:${TAG_NAME}
