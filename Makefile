# Define variables
REGION := us-east-1
S3_BUCKET := go-serverless-lambda-$(REGION)
TEMPLATE_FILE := template.yaml
PACKAGED_TEMPLATE := packaged.yaml
STACK_NAME := my-lambda-stack
ROLE_NAME := lambda-role  # Default name of the IAM role used in your template

# ANSI color codes
RED = \033[0;31m
NC = \033[0m # No Color

# Automatically find all folder names under the functions/ directory
APP_NAMES := $(shell find functions -maxdepth 1 -type d | sed '1d' | sed 's/functions\///' | sed 's/[^a-zA-Z0-9]/_/g')

# Default target
all: check-account-id build package deploy

# Check if the AWS Account ID placeholder is still in use
check-account-id:
	@if grep -q 'arn:aws:iam::123456789012:role/$(ROLE_NAME)' $(TEMPLATE_FILE); then \
		echo "${RED}ERROR: You need to replace '123456789012' with your AWS Account ID in ./$(TEMPLATE_FILE).${NC}"; \
		exit 1; \
	fi

# Build the Go binary and create the bootstrap file for each function
build: check-account-id
	@for app in $(APP_NAMES); do \
		echo "Building $$app..."; \
		GOOS=linux GOARCH=amd64 go build -o functions/$$app/main functions/$$app/main.go; \
		echo '#!/bin/sh' > functions/$$app/bootstrap; \
		echo 'set -euo pipefail' >> functions/$$app/bootstrap; \
		echo 'exec /var/task/main "$$@"' >> functions/$$app/bootstrap; \
		chmod +x functions/$$app/bootstrap; \
	done


# Run tests for all functions
test:
	@for app in $(APP_NAMES); do \
		echo "Testing $$app..."; \
		cd functions/$$app && go test -v || exit 1; \
		cd -; \
	done


# Check if the S3 bucket exists, and create it if it doesn't
create-bucket:
	aws s3api head-bucket --bucket $(S3_BUCKET) 2>/dev/null || aws s3 mb s3://$(S3_BUCKET) --region $(REGION)

# Package the application
package: build create-bucket
	sam package \
		--template-file $(TEMPLATE_FILE) \
		--s3-bucket $(S3_BUCKET) \
		--output-template-file $(PACKAGED_TEMPLATE) \
		--region $(REGION)

# Deploy the application
deploy: package
	sam deploy \
		--template-file $(PACKAGED_TEMPLATE) \
		--stack-name $(STACK_NAME) \
		--capabilities CAPABILITY_IAM \
		--region $(REGION)

# Clean up the build artifacts
clean:
	@for app in $(APP_NAMES); do \
		echo "Cleaning up $$app..."; \
		rm -f functions/$$app/main; \
		rm -f functions/$$app/bootstrap; \
	done
	rm -f $(PACKAGED_TEMPLATE)

# Validate the SAM template
validate:
	sam validate --region $(REGION)

# Delete the CloudFormation stack (Lambda function and related resources)
delete-stack:
	aws cloudformation delete-stack \
		--stack-name $(STACK_NAME) \
		--region $(REGION)

# Wait until the CloudFormation stack is deleted
wait-for-delete-stack:
	aws cloudformation wait stack-delete-complete \
		--stack-name $(STACK_NAME) \
		--region $(REGION)

# Delete the S3 bucket and its contents
delete-bucket:
	aws s3 rm s3://$(S3_BUCKET) --recursive
	aws s3api delete-bucket --bucket $(S3_BUCKET) --region $(REGION)

# Clean up everything: CloudFormation stack, S3 bucket, and IAM role
delete-all: delete-stack wait-for-delete-stack delete-bucket
