# emma Provider Onboarding Scripts

Scripts and step-by-step instructions for connecting your cloud accounts to the [emma platform](https://emma.ms) via **BYOA (Bring Your Own Account)**.

Supported providers: **AWS · Azure · GCP**

---

## Overview

| Provider | Method         | Tool required        |
|----------|----------------|----------------------|
| AWS      | Shell script   | AWS Cloud Shell      |
| Azure    | Shell script   | Azure Cloud Shell    |
| GCP      | Manual steps   | GCP Console (browser)|

---

## AWS

### Prerequisites

- Access to [AWS Cloud Shell](https://console.aws.amazon.com/cloudshell/)
- Admin-level IAM permissions on the target account

### Setup

1. Open AWS Cloud Shell from the AWS Portal.
2. Ensure you're using Bash (not PowerShell).
3. Copy and paste the contents of `scripts/AWS/onboarding.sh` into a file, e.g., "onboarding.sh":
   nano onboarding.sh
4. Save the file (Ctrl+O, then Ctrl+X).
5. Make the file executable:
   chmod +x onboarding.sh
6. Run the script:
   ./onboarding.sh
7. . Set the `ENV` variable on line 19 to a short identifier for your organization:
   ```bash
   ENV="mycompany"
   ```
4. Run the script:
   ```bash
   ./onboarding.sh
   ```

### What the script does

- Creates an IAM service user `sa-<ENV>-apikey`
- Attaches all required AWS-managed and custom IAM policies
- Enables all opt-in AWS regions for the account

### Output

The script prints an **Access Key ID** and **Secret Access Key** on completion.

> ⚠️ **Copy these immediately.** The secret key is shown only once and cannot be retrieved later.

Region activation runs in the background after the script completes. Full activation may take several minutes. To check status:
```bash
aws account list-regions --region-opt-status-contains ENABLED ENABLING
```

---

## Azure

### Prerequisites

- **Global Administrator** role in your Azure tenant
- Access to [Azure Cloud Shell](https://shell.azure.com/) (Bash mode)

### Setup

1. Open Azure Cloud Shell from the Azure Portal.
2. Ensure you're using Bash (not PowerShell).
3. Copy and paste the contents of `scripts/Azure/onboarding.sh` into a file, e.g., "onboarding.sh":
   nano onboarding.sh
4. Save the file (Ctrl+O, then Ctrl+X).
5. Make the file executable:
   chmod +x onboarding.sh
6. Run the script:
   ./onboarding.sh
7. Fill in the required variables at the top of the file:

   | Variable               | Example                                      |
   |------------------------|----------------------------------------------|
   | `SUBSCRIPTION_ID`      | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`       |
   | `DISPLAY_NAME`         | `MyCompany Service Account`                  |
   | `GIVEN_NAME`           | `MyCompany`                                  |
   | `SURNAME`              | `Service`                                    |
   | `USER_PRINCIPAL_NAME`  | `mycompany-service@mycompany.onmicrosoft.com`|
   | `MAIL_NICKNAME`        | `mycompany-service`                          |
   | `PASSWORD`             | *(strong password)*                          |

4. Run the script:
   ```bash
   ./onboarding.sh
   ```

### What the script does

- Creates an Azure AD App Registration (`emma-connection`) with a 180-day client secret
- Creates a Service Principal and assigns it the **Owner** role on the subscription
- Creates or reuses a service user account with all required RBAC roles
- Accepts required marketplace image terms
- Registers required Azure resource providers

### Output

The script prints the following credentials on completion:

- `tenantId`, `subscriptionId`, `clientId`, `clientSecret`
- Service user email and password

> ⚠️ **Save these immediately.**

**If admin consent for Graph API permissions fails**, grant it manually:  
Azure Portal → **App registrations** → `emma-connection` → **API permissions** → **Grant admin consent**.

> 💡 To delete and recreate an existing service user instead of reusing it, set `RECREATE_USER=true` before running the script.

---

## GCP

### Prerequisites

- An existing GCP project with **billing enabled**
- **Project Owner** or **Editor + IAM Admin** permissions
- Access to [GCP Cloud Shell](https://shell.cloud.google.com/) (Bash mode)

### Setup

1. Open GCP Cloud Shell from the GCP Portal.
2. Ensure you're using Bash (not PowerShell).
3. Copy and paste the contents of `scripts/GCP/onboarding.sh` into a file, e.g., `onboarding.sh`:
   ```bash
   nano onboarding.sh
   ```
4. Save the file (Ctrl+O, then Ctrl+X).
5. Make the file executable:
   ```bash
   chmod +x onboarding.sh
   ```
6. Fill in the required variables at the top of the file:

   | Variable        | Example                     |
   |-----------------|-----------------------------|
   | `PROJECT_ID`    | `my-project-123`            |
   | `KEY_FILE_NAME` | `sa-key.json` *(optional)*  |

   If `KEY_FILE_NAME` is left empty, the key file will be named `<project_id>-compute-sa-key.json` automatically.

7. Run the script:
   ```bash
   ./onboarding.sh
   ```

### What the script does

- Enables all required GCP APIs (IAM, Compute Engine, Cloud Billing, Cloud Build, Cloud Storage, Cloud Monitoring, Cloud Quotas, and others)
- Locates the **Compute Engine default service account** for the project
- Assigns all required IAM roles to the service account
- Generates a **JSON key file** for the service account

### Output

The script saves a JSON key file to the current directory and prints a summary:

```
  Project ID   : <your-project-id>
  Service Acct : <project-number>-compute@developer.gserviceaccount.com
  Key file     : <key-file-name>.json
```

> ⚠️ **Security notice:** The JSON key grants broad access to your GCP project. Paste its contents into the emma platform's credential input field and do not share it elsewhere.

---

## Support

If you encounter issues during setup, open a support request through the emma platform.
