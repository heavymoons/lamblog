#!/bin/bash

DIR_NAME="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
echo DIR_NAME=$DIR_NAME

. .env

rm -rf verndor
rm -f lambda.zip

docker run --rm -v $DIR_NAME:/opt lambci/lambda:build-ruby2.5 sh -c "\
cd /opt && \
bundle install --path vendor --without development test && \
find vendor -type f | grep \"\.o\" | xargs rm -rf && \
zip -r lambda.zip libs locales routes views .env config.ru lambda.rb static vendor \
"

FUNCTION_NAME=$APP_NAME
echo "FUNCTION_NAME=$FUNCTION_NAME"
aws lambda update-function-code --function-name=$FUNCTION_NAME --zip-file fileb://`pwd`/lambda.zip
aws lambda publish-version  --function-name=$FUNCTION_NAME
