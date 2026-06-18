# provider-onboarding-scripts

Provider Onboarding Scripts
This repository contains scripts and instructions to connect your cloud accounts (AWS, Azure, GCP) to the Emma platform. Follow the guide for each provider you want to onboard.

Overview

Provider     Type                ToolRequired
AWS          Shell script        AWS Cloud Shell
Azure        Shell script        Azure Cloud Shell
GCP          Manual instructions GCP Console (browser)

AWS

Prerequisites

Access to AWS Cloud Shell (Bash)
Admin-level IAM permissions on the target account
AWS CLI (pre-installed in Cloud Shell)

Setup

Open AWS Cloud Shell.
Upload or paste the contents of scripts/AWS/onboarding.sh.
Open the file and set the ENV variable on line 19 to a short identifier for your company, e.g.:

ENV="mycompany"

Run the script:

./onboarding.sh
What the script does

Creates an IAM service user named sa-<ENV>-apikey
Attaches all required AWS-managed and custom IAM policies
Enables all opt-in AWS regions for your account

Output
At the end of the run, the script prints your Access Key ID and Secret Access Key. Copy these immediately — the secret key is shown only once and cannot be retrieved again.

Note: Region activation runs in the background after the script completes. Full activation may take several minutes. Check status with:
account list-regions --region-opt-status-contains ENABLED ENABLING

Azure

Prerequisites

Global Administrator role in your Azure tenant
Access to Azure Cloud Shell (Bash)
Azure CLI (pre-installed in Cloud Shell)

Setup

Open Azure Cloud Shell and select Bash.
Upload or paste the contents of scripts/Azure/onboarding.sh.

Open the file and fill in all seven required variables at the top:

Variable                  Example value
SUBSCRIPTION_ID           xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
DISPLAY_NAME              MyCompany Service Account
GIVEN_NAME                MyCompany
SURNAME                   Service
USER_PRINCIPAL_NAME       mycompany-service@mycompany.onmicrosoft.com
MAIL_NICKNAME             mycompany-service
PASSWORD                  (strong password)

Run the script:

./onboarding.sh
What the script does

Creates an Azure AD App Registration (emma-connection) with a 180-day client secret
Creates a Service Principal and assigns it the Owner role on the subscription
Creates or reuses a service user account with all required built-in and custom RBAC roles
Accepts required marketplace image terms
Registers required Azure resource providers

Output
At the end of the run, the script prints:

tenantId, subscriptionId, clientId, clientSecret
Service user email and password

Save these immediately. If admin consent for Graph API permissions fails, grant it manually in the Azure Portal under App registrations → emma-connection → API permissions → Grant admin consent.

Tip: To delete and recreate an existing service user instead of reusing it, set RECREATE_USER=true before running.

GCP

GCP onboarding is done manually through the browser console — no script is required.
Prerequisites

An existing GCP project with billing enabled
Project Owner or Editor + IAM Admin permissions

Setup
Follow the instructions in scripts/GCP/Instructions.md. In summary:

Enable APIs — In the GCP Console, enable these nine APIs on your project:

Identity and Access Management (IAM) API
Resource Manager API
Compute Engine API
Cloud Billing API
Cloud Build API
Storage API
Storage Component API
Stackdriver Monitoring API
Cloud Quotas API

Verify the default service account — After enabling the Compute Engine API, confirm that the Compute Engine default service account was automatically created under IAM & Admin → Service Accounts.
Assign roles — Go to IAM, find the Compute Engine default service account, and assign it these six roles:

Compute Admin
Service Account User
Service Account Admin
Role Administrator
Service Account Key Admin
Project IAM Admin

Create a JSON key — In Service Accounts, open the default service account, go to Keys → Add Key → Create new key, select JSON, and download the file.
Provide the key to Emma — Copy the contents of the downloaded JSON file into the Emma platform's input field.

Security note: The JSON key grants broad access to your project. Do not share it beyond the Emma platform.

License
See LICENSE for details.
