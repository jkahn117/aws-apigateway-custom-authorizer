# API Gateway Lambda Authorizers

Blog post: https://blog.iamjkahn.com/

This project contains source code and supporting files for a serverless application that you can deploy with the SAM CLI.

## Deployment

This project requires the following prerequisites:

* [AWS Account](https://aws.amazon.com/account/)
* [AWS SAM CLI (1.0+)](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
* [Docker](https://docs.docker.com/install/)

``` bash
# build with Docker container
sam build --use-container

# deploy
sam deploy --guided
```

Follow the prompts to deploy.