# Delete command explained

1. **`delete-stack`:**
   - This target deletes the CloudFormation stack, which in turn deletes the Lambda function and any other resources associated with it.

2. **`delete-bucket`:**
   - This target deletes the S3 bucket you used for storing the Lambda package. It first removes all the objects within the bucket and then deletes the bucket itself.

3. **`delete-all`:**
   - This is a convenience target that runs both `delete-stack` and `delete-bucket` to completely clean up all resources associated with your deployment.

### Usage:

- **To delete the CloudFormation stack:**
  ```bash
  make delete-stack
  ```

- **To delete the S3 bucket and its contents:**
  ```bash
  make delete-bucket
  ```

- **To delete everything (both the stack and the S3 bucket):**
  ```bash
  make delete-all
  ```