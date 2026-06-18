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

1. Open **AWS Cloud Shell**.
2. Upload or paste the contents of `scripts/AWS/onboarding.sh`.
3. Set the `ENV` variable on line 19 to a short identifier for your organization:
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

1. Open **Azure Cloud Shell** and select **Bash**.
2. Upload or paste the contents of `scripts/Azure/onboarding.sh`.
3. Fill in the required variables at the top of the file:

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

GCP onboarding is performed manually through the browser console — no script is required.

### Prerequisites

- An existing GCP project with **billing enabled**
- **Project Owner** or **Editor + IAM Admin** permissions

### Setup

Follow the full instructions in `scripts/GCP/Instructions.md`. Summary:

**Step 1 — Enable APIs**

In the GCP Console, enable the following APIs on your project:

- Identity and Access Management (IAM) API
- Resource Manager API
- Compute Engine API
- Cloud Billing API
- Cloud Build API
- Cloud Storage API
- Cloud Storage Component API
- Cloud Monitoring (Stackdriver) API
- Cloud Quotas API

**Step 2 — Verify the default service account**

After enabling the Compute Engine API, confirm the **Compute Engine default service account** was created under **IAM & Admin → Service Accounts**.

**Step 3 — Assign roles**

In **IAM**, find the Compute Engine default service account and assign the following roles:

- Compute Admin
- Service Account User
- Service Account Admin
- Role Administrator
- Service Account Key Admin
- Project IAM Admin

**Step 4 — Create a JSON key**

In **Service Accounts**, open the default service account → **Keys** → **Add Key** → **Create new key** → select **JSON** → download the file.

**Step 5 — Provide the key to emma**

Paste the contents of the downloaded JSON file into the emma platform's credential input field.

> ⚠️ **Security notice:** The JSON key grants broad access to your GCP project. Do not share it outside the emma platform.

---

## Support

If you encounter issues during setup, open a support request through the emma platform.

