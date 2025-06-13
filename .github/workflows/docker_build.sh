#!/bin/bash
set -ev
trap 'exit' ERR

echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USER}" --password-stdin
docker build --network=host -t "${GIT_REPO}:latest"  .
GIT_TAG=$(git tag | sort --version-sort | tail -n1)
GIT_TAG=$(( GIT_TAG + 1))

if [ "${PR_STATE}" == "Closed" ]; then
    COMMIT_MESSAGE=$(git log -1 --pretty=format:"%s")
    read -ra commit_array <<< "$COMMIT_MESSAGE"
    OLD_BRANCH=$(basename "${commit_array[-1]}")
    git config --local user.email "action@github.com"
    git config --local user.name "GitHub Action"
    docker tag "${GIT_REPO}:latest" "${GIT_REPO}:$GIT_TAG"
    git tag -a "$GIT_TAG" -m "Release $GIT_TAG"

    echo "PR State is: ${PR_STATE}"
    echo "Branch Name is: ${BRANCH_NAME}"
    echo "Old Branch name: $OLD_BRANCH"
    echo "Git Tag will be: $GIT_TAG"

    docker push -q "${GIT_REPO}:$GIT_TAG"
    git remote add origin-gha https://"${GITHUB_TOKEN}"@github.com/"${GIT_REPO}".git
    git push -q --tags --set-upstream origin-gha

    TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -H "Content-Type: application/json" -d "{\"username\": \"${DOCKER_USER}\", \"password\":\"${DOCKER_PASSWORD}\"}" "https://hub.docker.com/v2/users/login/" | jq -r .token)
    curl "https://hub.docker.com/v2/repositories/${TRAVIS_REPO_SLUG}/tags/$OLD_BRANCH/" -X DELETE -H "Authorization: JWT ${TOKEN}"
elif [ "${PR_STATE}" == "Open" ]; then
    echo "PR State is: ${PR_STATE}"
    echo "Branch Name is: ${BRANCH_NAME}"
    echo "Git Tag will be: $GIT_TAG"
    docker tag "${GIT_REPO}:latest" "${GIT_REPO}:${BRANCH_NAME}"
    docker push "${GIT_REPO}:${BRANCH_NAME}"
fi
