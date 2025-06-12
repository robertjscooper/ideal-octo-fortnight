ARG BASE_VERSION=latest
FROM btlnet/apibase:$BASE_VERSION
ARG BASE_DIR=/app
ARG REPO_NAME=btl_billing
RUN pip install --no-cache-dir pymongo==4.8.0