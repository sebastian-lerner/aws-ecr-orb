#!/bin/bash
REGION=$(eval echo "${PARAM_REGION}")
PROFILE_NAME=$(eval echo "${PARAM_PROFILE_NAME}")
REGISTRY_ID=$(eval echo "\$${PARAM_REGISTRY_ID}")
PUBLIC_REGISTRY=$(eval echo "${PARAM_PUBLIC_REGISTRY}")
ACCOUNT_URL="${REGISTRY_ID}.dkr.ecr.${REGION}.amazonaws.com"
ECR_COMMAND="ecr"

if [ "$PUBLIC_REGISTRY" == "1" ]; then
    REGION="us-east-1"
    ACCOUNT_URL="public.ecr.aws"
    ECR_COMMAND="ecr-public"
    echo "it gets to ecr-login" >> test.txt
fi

if [ -n "${PROFILE_NAME}" ]; then
    set -- "$@" --profile "${PROFILE_NAME}"
fi

if [ -f ~/.docker/config.json ]; then
    echo "Credential helper is already installed"
else
    echo "aws ${ECR_COMMAND} get-login-password --region ${REGION} $@ | docker login --username AWS --password-stdin ${ACCOUNT_URL}" >> test.txt
    aws "${ECR_COMMAND}" get-login-password --region "${REGION}" "$@" | docker login --username AWS --password-stdin "${ACCOUNT_URL}"
fi
