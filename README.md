# Example API Gateway Caching project

Demonstrates api gateway caching, using a serverless project to mock up back-end Lambda + DB's with synthetic delay's. API Gateway config managed by Terraform and based on OAS definition.

## Dependencies
- AWS account + cli + creds setup
- aws-sdk (for ```make load```)

## Install
From the root folder run ```make apply``` then ```make load``` to populate the DDB table with sample data.

## Update
From the root folder run ```make apply```

## Usage
When ```make apply``` is run, it will output the API endpoint/url. Use Postman or curl to hit the API. 
Caching is added to the methods/resources listed in the ```terraform/cache.yaml``` file. The cache can be invalidated/busted by adding the ```Cache-Control: max-age=0``` header

## Teardown
From the root folder run ```make destroy```
