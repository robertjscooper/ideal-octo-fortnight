#!/bin/bash
set -ev
trap 'exit' ERR

echo "${docker_pass}" | docker login -u "${docker_user}" --password-stdin
docker build -q -t ${TRAVIS_REPO_SLUG}  .
