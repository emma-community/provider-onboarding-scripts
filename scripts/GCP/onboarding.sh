#!/bin/bash

###########################################
# How to use this script in GCP Cloud Shell:
# 1. Open GCP Cloud Shell from the GCP Portal.
# 2. Ensure you're using Bash (not PowerShell).
# 3. Copy and paste this script into a file, e.g., "onboarding.sh":
#    nano onboarding.sh
# 4. Save the file (Ctrl+O, then Ctrl+X).
# 5. Make the file executable:
#    chmod +x onboarding.sh
# 6. Run the script:
#    ./onboarding.sh
###########################################

PROJECT_ID=""      # e.g. "my-project-123"
KEY_FILE_NAME=""   # e.g. "sa-key.json" — if empty, defaults to "<project_id>-compute-sa-key.json"

# =============================================================================
# END OF VARIABLES — do not edit below this line unless you know what you're doing
# =============================================================================

set -e  # Exit on any error

info()    { echo "[INFO]  $1"; }
success() { echo "[OK]    $1"; }
warn()    { echo "[WARN]  $1"; }
error()   { echo "[ERROR] $1"; exit 1; }
section() { echo ""; echo "--- $1 ---"; }

# =============================================================================
# 1. Validate variables & resolve project
# =============================================================================
section "Validating Configuration"

if [[ -z "$PROJECT_ID" ]]; then
  error "PROJECT_ID is not set. Open the script and fill in the variable at the top."
fi

# Default key file name if not specified
if [[ -z "$KEY_FILE_NAME" ]]; then
  KEY_FILE_NAME="${PROJECT_ID}-compute-sa-key.json"
fi

info "Using project  : $PROJECT_ID"
info "Key output file: $KEY_FILE_NAME"

gcloud config set project "$PROJECT_ID"

# Derive project number (needed to locate the Compute Engine default SA)
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" \
  --format="value(projectNumber)" 2>/dev/null) \
  || error "Could not retrieve project number. Check project ID and permissions."

info "Project number: $PROJECT_NUMBER"

# =============================================================================
# 2. Enable required APIs
# =============================================================================
section "Enabling Required APIs"

APIS=(
  "iam.googleapis.com"
  "cloudresourcemanager.googleapis.com"
  "compute.googleapis.com"
  "cloudbilling.googleapis.com"
  "cloudbuild.googleapis.com"
  "storage.googleapis.com"
  "storage-component.googleapis.com"
  "monitoring.googleapis.com"
  "cloudquotas.googleapis.com"
)

for API in "${APIS[@]}"; do
  info "Enabling $API ..."
  gcloud services enable "$API" --project="$PROJECT_ID" \
    && success "$API enabled" \
    || warn "Could not enable $API (may already be enabled or need billing)"
done

# =============================================================================
# 3. Wait for Compute Engine default service account
# =============================================================================
section "Locating Compute Engine Default Service Account"

SA_EMAIL="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

info "Waiting for Compute Engine default SA to be provisioned..."
MAX_WAIT=60; WAITED=0; INTERVAL=5
until gcloud iam service-accounts describe "$SA_EMAIL" \
        --project="$PROJECT_ID" &>/dev/null; do
  if (( WAITED >= MAX_WAIT )); then
    error "Service account $SA_EMAIL not found after ${MAX_WAIT}s. \
Enable Compute Engine API manually and re-run."
  fi
  warn "Not ready yet, retrying in ${INTERVAL}s… (${WAITED}s elapsed)"
  sleep $INTERVAL
  WAITED=$(( WAITED + INTERVAL ))
done

success "Found service account: $SA_EMAIL"

# =============================================================================
# 4. Assign IAM roles
# =============================================================================
section "Assigning IAM Roles"

ROLES=(
  "roles/compute.admin"
  "roles/iam.serviceAccountUser"
  "roles/iam.serviceAccountAdmin"
  "roles/iam.roleAdmin"
  "roles/iam.serviceAccountKeyAdmin"
  "roles/resourcemanager.projectIamAdmin"
)

for ROLE in "${ROLES[@]}"; do
  info "Binding $ROLE ..."
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="$ROLE" \
    --condition=None \
    --quiet \
    && success "$ROLE assigned" \
    || warn "Could not assign $ROLE (check your own permissions)"
done

# =============================================================================
# 5. Create JSON key
# =============================================================================
section "Creating Service Account JSON Key"

KEY_FILE="$KEY_FILE_NAME"

info "Generating JSON key → ${KEY_FILE}"
gcloud iam service-accounts keys create "$KEY_FILE" \
  --iam-account="$SA_EMAIL" \
  --project="$PROJECT_ID" \
  && success "Key saved to ${KEY_FILE}" \
  || error "Key creation failed."

# =============================================================================
# 6. Summary
# =============================================================================
section "Setup Complete"

echo "
All steps completed successfully!

  Project ID   : ${PROJECT_ID}
  Service Acct : ${SA_EMAIL}
  Key file     : ${KEY_FILE}"