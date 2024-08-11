### 1. **Check if SAM is Installed:**

   Open your terminal and run:
   ```bash
   sam --version
   ```

   If SAM is installed, it will display the version number, something like:
   ```
  SAM CLI, version 1.121.0
   ```

   If you get an error or command not found, it means that SAM is not installed.

### 2. **Install AWS SAM (if not installed):**

   - **For macOS:**
     ```bash
     brew install aws/tap/aws-sam-cli
     ```
   - **For Linux:**
     You can follow the installation instructions on the [AWS SAM CLI installation guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install-linux.html).

   - **For Windows:**
     Download the installer from the [AWS SAM CLI installation guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install-windows.html).

### 3. **Verify Installation Again:**

   After installation, run the command again to verify:
   ```bash
   sam --version
   ```

### 4. **Validate Your Template File (Optional):**

   You can also validate your `template.yaml` file to ensure it's correct:
   ```bash
   sam validate
   ```

This will check your SAM template for any issues before deploying.