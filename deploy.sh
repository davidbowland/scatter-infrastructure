#!/usr/bin/env bash

# Stop immediately on error
set -e

if [[ -z "$1" ]]; then
  $(./scripts/assumeDeveloperRole.sh)
fi

# Deploy infrastructure

sam deploy --stack-name scatter-infrastructure-east-1-test \
  --template-file template-east-1.yaml --region us-east-1 \
  --capabilities CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset \
  --parameter-overrides Environment=test

PINPOINT_ID=$(AWS_REGION=us-east-1 aws cloudformation describe-stacks --stack-name scatter-infrastructure-east-1-test --output text --query 'Stacks[0].Outputs[?OutputKey==`PinpointId`].OutputValue')
sam deploy --stack-name scatter-infrastructure-test \
  --template-file template.yaml --region us-east-2 \
  --capabilities CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset \
  --parameter-overrides Environment=test PinpointId=$PINPOINT_ID
