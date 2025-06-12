#!/bin/bash
set -ev
trap 'exit' ERR

echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USER}" --password-stdin
docker build --network=host -t "${GIT_REPO}:latest"  .

if [ "${PR_STATE}" == "Closed" ]; then
    COMMIT_MESSAGE=$(git log -1 --pretty=format:"%s")
    IFS=' '
    read -ra newarr <<< "$COMMIT_MESSAGE"
    OLD_BRANCH=$(${newarr[5]})
    git config --local user.email "action@github.com"
    git config --local user.name "GitHub Action"

    GIT_TAG=$(git tag | sort --version-sort | tail -n1)
    GIT_TAG=$(( GIT_TAG + 1))

    docker tag "${GIT_REPO}:latest" "${GIT_REPO}:$GIT_TAG"
    git tag "$GIT_TAG" -a -m "Release $GIT_TAG"

    echo "PR State is: ${PR_STATE}"
    echo "Branch Name is: ${BRANCH_NAME}"
    echo "Old Branch name: $OLD_BRANCH"
    echo "Git Tag will be: $GIT_TAG"

    docker push "${GIT_REPO}:$GIT_TAG"
    git push origin "$GIT_TAG"

    TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -H "Content-Type: application/json" -d "{\"username\": \"${DOCKER_USER}\", \"password\":\"${DOCKER_PASSWORD}\"}"
     "https://hub.docker.com/v2/users/login/" | jq -r .token)
    curl "https://hub.docker.com/v2/repositories/${TRAVIS_REPO_SLUG}/tags/$OLD_BRANCH/" -X DELETE -H "Authorization: JWT ${TOKEN}"
elif [ "${PR_STATE}" == "Open" ]; then
    echo "PR State is: ${PR_STATE}"
    echo "Branch Name is: ${BRANCH_NAME}"
    docker tag "${GIT_REPO}:latest" "${GIT_REPO}:${BRANCH_NAME}"
    docker push "${GIT_REPO}:${BRANCH_NAME}"
fi
