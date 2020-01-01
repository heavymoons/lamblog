#!/bin/bash

DIR_NAME="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
echo DIR_NAME=$DIR_NAME

. .env

if [ "$AWS_PROFILE" != "" ]; then
  export AWS_PROFILE=$AWS_PROFILE
fi

echo "creating s3 bucket: $S3_BUCKET}"
aws s3api create-bucket \
  --bucket $S3_BUCKET \
  --create-bucket-configuration \
    "{\"LocationConstraint\":\"$AWS_REGION\"}" \
  --acl private

ROLE_NAME=${APP_NAME}-lambda-role
echo "createing lambda role: $ROLE_NAME"
aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document \
  '{"Version":"2012-10-17","Statement":[{"Effect": "Allow","Principal":{"Service": "lambda.amazonaws.com"},"Action": "sts:AssumeRole"}]}'
echo "attach S3FullAccess Policy (restrict if you need)"
aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
echo "attach LambdaBasicExecution Policy (restrict if you need)"
aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

echo "creating lambda function: $APP_NAME"
aws lambda create-function \
  --function-name $APP_NAME \
  --runtime ruby2.5 \
  --role arn:aws:iam::$AWS_USER_ID:role/$ROLE_NAME \
  --handler lambda.handler \
  --environment "Variables={APP_ENV=production,GEM_PATH=/var/task/verndor/ruby/2.5.0}" \
  --zip-file fileb://`pwd`/bin/empty.zip
