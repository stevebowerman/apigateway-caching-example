.PHONY: load
load:
	@cd serverless && \
		TABLE=cache-test-table AWS_REGION=eu-west-1 node load-data.js

.PHONY: merge
merge:
	@npx merge-yaml-cli -i api-definitions/definition.yaml api-definitions/implementation.yaml -o api-definitions/openapi.yaml

.PHONY: validate
validate: merge
	@cd api-definitions && \
		npx @stoplight/spectral lint openapi.yaml && \
		cd ..

.PHONY: plan
plan: validate
	@cd terraform && \
		rm -Rf .terraform && \
		terraform init && \
		terraform plan && \
		cd ..

.PHONY: apply
apply: plan
	@cd serverless && \
		sls deploy && \
		cd .. && \
		cd terraform && \
		terraform apply -auto-approve && \
		cd ..

.PHONY: destroy
destroy:
	@cd terraform && \
		terraform init && \
		terraform destroy -auto-approve && \
		rm -f terraform.tfstate* && \
		cd .. && \
		cd serverless && \
		sls remove
