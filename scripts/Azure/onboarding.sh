#!/bin/bash

###########################################
# How to use this script in Azure Cloud Shell:
# 1. Open Azure Cloud Shell from the Azure Portal.
# 2. Ensure you're using Bash (not PowerShell).
# 3. Copy and paste this script into a file, e.g., "onboarding.sh":
#    nano onboarding.sh
# 4. Save the file (Ctrl+O, then Ctrl+X).
# 5. Make the file executable:
#    chmod +x onboarding.sh
# 6. Run the script:
#    ./onboarding.sh
###########################################

#######################################
# User-defined variables — fill these in before running
#######################################
SUBSCRIPTION_ID=""
DISPLAY_NAME=""                    # e.g. "MyCompany Service Account"
GIVEN_NAME=""                      # e.g. "MyCompany"
SURNAME=""                         # e.g. "Service"
USER_PRINCIPAL_NAME=""             # e.g. "mycompany-service@mycompany.onmicrosoft.com"
MAIL_NICKNAME=""                   # e.g. "mycompany-service"
PASSWORD=""                        # Strong password for the new user

#######################################
# Validate inputs
#######################################
for VAR in SUBSCRIPTION_ID DISPLAY_NAME GIVEN_NAME \
           SURNAME USER_PRINCIPAL_NAME MAIL_NICKNAME PASSWORD; do
    if [ -z "${!VAR}" ]; then
        echo "[ERROR] Variable '$VAR' is not set. Please fill in all required variables."
        exit 1
    fi
done

#######################################
# Global config
#######################################
CLI=az
APP_NAME="emma-connection"
ROLE_NAME="Owner"
SCOPE="/subscriptions/$SUBSCRIPTION_ID"
GRAPH_API_ID="00000003-0000-0000-c000-000000000000"
GRAPH_PERMISSION="User.ReadWrite.All"
RECREATE_USER=false

#######################################
# Inline permission definitions (no external files needed)
#######################################
read -r -d '' PERM_CustomAzureBotsContributor << 'JSONEOF'
[
  {
    "actions": [
      "Microsoft.Web/*",
      "Microsoft.Storage/*",
      "Microsoft.Resources/deployments/*",
      "Microsoft.Search/searchServices/*",
      "Microsoft.Insights/*",
      "Microsoft.Insights/components/*"
    ],
    "notActions": [
      "Microsoft.CognitiveServices/*",
      "Microsoft.BotService/*"
    ]
  }
]
JSONEOF

read -r -d '' PERM_CustomAzureDatabasePostgres << 'JSONEOF'
[
  {
    "actions": [
      "Microsoft.DBforPostgreSQL/flexibleServers/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/administrators/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/firewallRules/write",
      "Microsoft.DBforPostgreSQL/assessForMigration/action",
      "Microsoft.DBforPostgreSQL/privateEndpointConnectionsApproval/action",
      "Microsoft.DBforPostgreSQL/register/action",
      "Microsoft.DBforPostgreSQL/checkNameAvailability/action",
      "Microsoft.DBforPostgreSQL/locations/getAutoMigrationFreeSlots/action",
      "Microsoft.DBforPostgreSQL/locations/getLatestAutoMigrationSchedule/action",
      "Microsoft.DBforPostgreSQL/locations/updateAutoMigrationSchedule/action",
      "Microsoft.DBforPostgreSQL/locations/resourceType/usages/read",
      "Microsoft.DBforPostgreSQL/locations/administratorAzureAsyncOperation/read",
      "Microsoft.DBforPostgreSQL/locations/privateEndpointConnectionProxyAzureAsyncOperation/read",
      "Microsoft.DBforPostgreSQL/locations/privateEndpointConnectionProxyOperationResults/read",
      "Microsoft.DBforPostgreSQL/locations/privateEndpointConnectionAzureAsyncOperation/read",
      "Microsoft.DBforPostgreSQL/locations/privateEndpointConnectionOperationResults/read",
      "Microsoft.DBforPostgreSQL/locations/serverKeyAzureAsyncOperation/read",
      "Microsoft.DBforPostgreSQL/locations/serverKeyOperationResults/read",
      "Microsoft.DBforPostgreSQL/locations/capabilities/read",
      "Microsoft.DBforPostgreSQL/locations/performanceTiers/read",
      "Microsoft.DBforPostgreSQL/locations/operationResults/read",
      "Microsoft.DBforPostgreSQL/locations/azureAsyncOperation/read",
      "Microsoft.DBforPostgreSQL/locations/administratorOperationResults/read",
      "Microsoft.DBforPostgreSQL/locations/securityAlertPoliciesAzureAsyncOperation/read",
      "Microsoft.DBforPostgreSQL/locations/securityAlertPoliciesOperationResults/read",
      "Microsoft.DBforPostgreSQL/serverGroupsv2/privateEndpointConnectionsApproval/action",
      "Microsoft.DBforPostgreSQL/serverGroupsv2/privateEndpointConnections/read",
      "Microsoft.DBforPostgreSQL/serverGroupsv2/privateEndpointConnections/write",
      "Microsoft.DBforPostgreSQL/serverGroupsv2/privateEndpointConnections/delete",
      "Microsoft.DBforPostgreSQL/serverGroupsv2/privateEndpointConnectionProxies/read",
      "Microsoft.DBforPostgreSQL/serverGroupsv2/privateEndpointConnectionProxies/write",
      "Microsoft.DBforPostgreSQL/serverGroupsv2/privateEndpointConnectionProxies/delete",
      "Microsoft.DBforPostgreSQL/serverGroupsv2/privateEndpointConnectionProxies/validate/action",
      "Microsoft.DBforPostgreSQL/serverGroupsv2/privateLinkResources/read",
      "Microsoft.DBforPostgreSQL/performanceTiers/read",
      "Microsoft.DBforPostgreSQL/operations/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/delete",
      "Microsoft.DBforPostgreSQL/flexibleServers/waitStatistics/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/resetQueryPerformanceInsightData/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/checkMigrationNameAvailability/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/administrators/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/restart/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/start/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/stop/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/getSourceDatabaseList/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/testConnectivity/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/startLtrBackup/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/ltrPreBackup/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/privateEndpointConnectionsApproval/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/advisors/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/advisors/recommendedActions/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/queryStatistics/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/queryTexts/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/topQueryStatistics/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/privateEndpointConnections/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/privateEndpointConnections/delete",
      "Microsoft.DBforPostgreSQL/flexibleServers/privateEndpointConnections/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/privateEndpointConnectionProxies/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/privateEndpointConnectionProxies/delete",
      "Microsoft.DBforPostgreSQL/flexibleServers/privateEndpointConnectionProxies/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/privateEndpointConnectionProxies/validate/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/virtualendpoints/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/virtualendpoints/delete",
      "Microsoft.DBforPostgreSQL/flexibleServers/virtualendpoints/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/advancedThreatProtectionSettings/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/advancedThreatProtectionSettings/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/privateLinkResources/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/providers/Microsoft.Insights/diagnosticSettings/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/providers/Microsoft.Insights/diagnosticSettings/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/providers/Microsoft.Insights/metricDefinitions/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/migrations/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/migrations/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/migrations/delete",
      "Microsoft.DBforPostgreSQL/flexibleServers/firewallRules/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/firewallRules/delete",
      "Microsoft.DBforPostgreSQL/flexibleServers/backups/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/backups/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/backups/delete",
      "Microsoft.DBforPostgreSQL/flexibleServers/capabilities/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/logFiles/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/replicas/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/administrators/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/administrators/delete",
      "Microsoft.DBforPostgreSQL/flexibleServers/configurations/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/configurations/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/databases/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/databases/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/databases/delete",
      "Microsoft.DBforPostgreSQL/flexibleServers/ltrBackupOperations/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/tuningOptions/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/tuningOptions/recommendations/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/providers/Microsoft.Insights/logDefinitions/read",
      "Microsoft.DBforPostgreSQL/servers/queryTexts/action",
      "Microsoft.DBforPostgreSQL/servers/resetQueryPerformanceInsightData/action",
      "Microsoft.DBforPostgreSQL/servers/privateEndpointConnectionsApproval/action",
      "Microsoft.DBforPostgreSQL/servers/read",
      "Microsoft.DBforPostgreSQL/servers/write",
      "Microsoft.DBforPostgreSQL/servers/delete",
      "Microsoft.DBforPostgreSQL/servers/restart/action",
      "Microsoft.DBforPostgreSQL/servers/updateConfigurations/action",
      "Microsoft.DBforPostgreSQL/servers/administrators/read",
      "Microsoft.DBforPostgreSQL/servers/administrators/write",
      "Microsoft.DBforPostgreSQL/servers/administrators/delete",
      "Microsoft.DBforPostgreSQL/servers/advisors/read",
      "Microsoft.DBforPostgreSQL/servers/advisors/recommendedActionSessions/action",
      "Microsoft.DBforPostgreSQL/servers/advisors/recommendedActions/read",
      "Microsoft.DBforPostgreSQL/servers/privateEndpointConnectionProxies/validate/action",
      "Microsoft.DBforPostgreSQL/servers/privateEndpointConnectionProxies/read",
      "Microsoft.DBforPostgreSQL/servers/privateEndpointConnectionProxies/write",
      "Microsoft.DBforPostgreSQL/servers/privateEndpointConnectionProxies/delete",
      "Microsoft.DBforPostgreSQL/servers/keys/read",
      "Microsoft.DBforPostgreSQL/servers/keys/write",
      "Microsoft.DBforPostgreSQL/servers/keys/delete",
      "Microsoft.DBforPostgreSQL/servers/privateEndpointConnections/read",
      "Microsoft.DBforPostgreSQL/servers/privateEndpointConnections/delete",
      "Microsoft.DBforPostgreSQL/servers/privateEndpointConnections/write",
      "Microsoft.DBforPostgreSQL/servers/privateLinkResources/read",
      "Microsoft.DBforPostgreSQL/servers/configurations/read",
      "Microsoft.DBforPostgreSQL/servers/configurations/write",
      "Microsoft.DBforPostgreSQL/servers/providers/Microsoft.Insights/diagnosticSettings/read",
      "Microsoft.DBforPostgreSQL/servers/providers/Microsoft.Insights/diagnosticSettings/write",
      "Microsoft.DBforPostgreSQL/servers/providers/Microsoft.Insights/metricDefinitions/read",
      "Microsoft.DBforPostgreSQL/servers/firewallRules/read",
      "Microsoft.DBforPostgreSQL/servers/firewallRules/write",
      "Microsoft.DBforPostgreSQL/servers/firewallRules/delete",
      "Microsoft.DBforPostgreSQL/servers/performanceTiers/read",
      "Microsoft.DBforPostgreSQL/servers/databases/read",
      "Microsoft.DBforPostgreSQL/servers/databases/write",
      "Microsoft.DBforPostgreSQL/servers/databases/delete",
      "Microsoft.DBforPostgreSQL/servers/logFiles/read",
      "Microsoft.DBforPostgreSQL/servers/replicas/read",
      "Microsoft.DBforPostgreSQL/servers/queryTexts/read",
      "Microsoft.DBforPostgreSQL/servers/recoverableServers/read",
      "Microsoft.DBforPostgreSQL/servers/securityAlertPolicies/read",
      "Microsoft.DBforPostgreSQL/servers/securityAlertPolicies/write",
      "Microsoft.DBforPostgreSQL/servers/providers/Microsoft.Insights/logDefinitions/read",
      "Microsoft.DBforPostgreSQL/servers/topQueryStatistics/read",
      "Microsoft.DBforPostgreSQL/servers/virtualNetworkRules/read",
      "Microsoft.DBforPostgreSQL/servers/virtualNetworkRules/write",
      "Microsoft.DBforPostgreSQL/servers/virtualNetworkRules/delete",
      "Microsoft.DBforPostgreSQL/servers/waitStatistics/read",
      "Microsoft.DBforPostgreSQL/serversv2/read",
      "Microsoft.DBforPostgreSQL/serversv2/write",
      "Microsoft.DBforPostgreSQL/serversv2/delete",
      "Microsoft.DBforPostgreSQL/serversv2/updateConfigurations/action",
      "Microsoft.DBforPostgreSQL/serversv2/configurations/read",
      "Microsoft.DBforPostgreSQL/serversv2/configurations/write",
      "Microsoft.DBforPostgreSQL/serversv2/providers/Microsoft.Insights/diagnosticSettings/read",
      "Microsoft.DBforPostgreSQL/serversv2/providers/Microsoft.Insights/diagnosticSettings/write",
      "Microsoft.DBforPostgreSQL/serversv2/providers/Microsoft.Insights/metricDefinitions/read",
      "Microsoft.DBforPostgreSQL/serversv2/firewallRules/read",
      "Microsoft.DBforPostgreSQL/serversv2/firewallRules/write",
      "Microsoft.DBforPostgreSQL/serversv2/firewallRules/delete",
      "Microsoft.DBforPostgreSQL/serversv2/providers/Microsoft.Insights/logDefinitions/read"
    ],
    "notActions": []
  }
]
JSONEOF

read -r -d '' PERM_CustomCosmosDbContributor << 'JSONEOF'
[
  {
    "actions": [
      "Microsoft.DocumentDB/*",
      "Microsoft.DocumentDb/databaseAccounts/*"
    ],
    "notActions": []
  }
]
JSONEOF

read -r -d '' PERM_CustomDatabricksContributor << 'JSONEOF'
[
  {
    "actions": [
      "Microsoft.Databricks/workspaces/*"
    ],
    "notActions": []
  }
]
JSONEOF

read -r -d '' PERM_CustomDatafactoryRegister << 'JSONEOF'
[
  {
    "actions": [
      "Microsoft.Databricks/workspaces/*"
    ],
    "notActions": []
  }
]
JSONEOF

read -r -d '' PERM_CustomQuotaActions << 'JSONEOF'
[
  {
    "actions": [
      "Microsoft.Quota/quotas/read",
      "Microsoft.Quota/quotas/write",
      "Microsoft.Quota/quotaRequests/read",
      "Microsoft.Quota/usages/read",
      "Microsoft.Quota/operations/read"
    ],
    "notActions": []
  }
]
JSONEOF

read -r -d '' PERM_KubernetesRegister << 'JSONEOF'
[
  {
    "actions": [
      "Microsoft.ContainerService/register/*"
    ],
    "notActions": []
  }
]
JSONEOF

# Images inline (no external file needed)
IMAGES_JSON='[
  {"publisher":"ProComputers",            "offer":"alma-linux-8",                     "sku":"alma-linux-8"},
  {"publisher":"ProComputers",            "offer":"almalinux-9",                      "sku":"almalinux-9"},
  {"publisher":"ProComputers",            "offer":"rhel-7-latest",                    "sku":"rhel-7-latest"},
  {"publisher":"ProComputers",            "offer":"rhel-8-latest",                    "sku":"rhel-8-latest"},
  {"publisher":"ProComputers",            "offer":"rhel-9-0",                         "sku":"rhel-9-0"},
  {"publisher":"ntegralinc1586961136942", "offer":"ntg_fedora_36",                    "sku":"ntg_fedora_36"},
  {"publisher":"resf",                    "offer":"rockylinux-x86_64",                "sku":"8-base"},
  {"publisher":"resf",                    "offer":"rockylinux-x86_64",                "sku":"9-base"},
  {"publisher":"arista-networks",         "offer":"cloudeos-router-byol",             "sku":"cloudeos-4_29_0-byol"},
  {"publisher":"checkpoint",              "offer":"check-point-cg-r82",               "sku":"sg-byol"},
  {"publisher":"cisco",                   "offer":"cisco-c8000v-byol",                "sku":"17_16_01a-byol"},
  {"publisher":"juniper-networks",        "offer":"vsrx-next-generation-firewall-payg","sku":"vsrx-azure-image-byol"},
  {"publisher":"sentriumsl",              "offer":"vyos-1-2-lts-on-azure",            "sku":"vyos-1-3"}
]'

#######################################
# Helper functions
#######################################

handle_error() {
    echo "[ERROR] $1" >&2
    exit 1
}

get_uuid() {
    cat /proc/sys/kernel/random/uuid 2>/dev/null \
        || python3 -c "import uuid; print(uuid.uuid4())"
}

assign_role_to_user() {
    local PRINCIPAL_ID=$1
    local SUB_ID=$2
    local ROLE_DEF_ID=$3
    local ASSIGNMENT_ID
    ASSIGNMENT_ID=$(get_uuid)

    echo "[INFO] Assigning role '$ROLE_DEF_ID' to principal '$PRINCIPAL_ID'..."

    local ROLE_DEF_PATH
    ROLE_DEF_PATH="/subscriptions/${SUB_ID}/providers"
    ROLE_DEF_PATH+="/Microsoft.Authorization/roleDefinitions/${ROLE_DEF_ID}"

    local URL
    URL="https://management.azure.com/subscriptions/${SUB_ID}"
    URL+="/providers/Microsoft.Authorization/roleAssignments/${ASSIGNMENT_ID}"
    URL+="?api-version=2022-04-01"

    $CLI rest --method put \
        --url "$URL" \
        --headers "Content-Type=application/json" \
        --body "{
          \"properties\": {
            \"roleDefinitionId\": \"${ROLE_DEF_PATH}\",
            \"principalId\": \"${PRINCIPAL_ID}\"
          }
        }" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "[SUCCESS] Role '$ROLE_DEF_ID' assigned."
    else
        echo "[WARNING] Failed to assign role '$ROLE_DEF_ID'" \
             "— may already be assigned or propagation delay."
    fi
}

find_and_delete_roles_by_prefix() {
    local SUB_ID=$1
    local PREFIX=$2

    local FILTER_URL
    FILTER_URL="https://management.azure.com/subscriptions/${SUB_ID}"
    FILTER_URL+="/providers/Microsoft.Authorization/roleDefinitions"
    FILTER_URL+="?%24filter=type%20eq%20%27CustomRole%27&api-version=2022-04-01"

    RESPONSE=$($CLI rest --method get \
        --url "$FILTER_URL" \
        --headers "Content-Type=application/json" 2>/dev/null)

    [ -z "$RESPONSE" ] && return 0

    TMP_FILE=$(mktemp)
    echo "$RESPONSE" | awk -v prefix="$PREFIX" '
        BEGIN { RS="},"; FS="\""; }
        {
            roleName=""; id="";
            for(i=1;i<=NF;i++){
                if($i=="roleName") roleName=$(i+2);
                if($i=="id")       id=$(i+2);
            }
            if(roleName ~ "^"prefix) print id;
        }
    ' > "$TMP_FILE"

    while read -r RID; do
        [ -z "$RID" ] && continue
        echo "[INFO] Deleting old role: $RID"
        $CLI rest --method delete \
            --url "https://management.azure.com${RID}?api-version=2022-04-01" \
            --headers "Content-Type=application/json" > /dev/null 2>&1
    done < "$TMP_FILE"
    rm -f "$TMP_FILE"
}

create_custom_role_and_assign() {
    local SUB_ID=$1
    local ROLE_BASE_NAME=$2
    local PERMISSIONS_JSON=$3
    local PRINCIPAL_ID=$4
    local MAX_RETRIES=5
    local RETRY=0

    find_and_delete_roles_by_prefix "$SUB_ID" "$ROLE_BASE_NAME"

    while [ $RETRY -lt $MAX_RETRIES ]; do
        local SUFFIX
        SUFFIX=$(get_uuid | cut -d'-' -f1)
        local ROLE_NAME="${ROLE_BASE_NAME}-${SUFFIX}"
        local ROLE_DEF_ID
        ROLE_DEF_ID=$(get_uuid)
        local ROLE_GUID
        ROLE_GUID=$(get_uuid)

        echo "[INFO] Creating custom role: $ROLE_NAME..."

        local URL
        URL="https://management.azure.com/subscriptions/${SUB_ID}"
        URL+="/providers/Microsoft.Authorization/roleDefinitions/${ROLE_DEF_ID}"
        URL+="?api-version=2022-04-01"

        $CLI rest --method put \
            --url "$URL" \
            --headers "Content-Type=application/json" \
            --body "{
              \"name\": \"${ROLE_GUID}\",
              \"properties\": {
                \"roleName\": \"${ROLE_NAME}\",
                \"description\": \"${ROLE_NAME}\",
                \"type\": \"CustomRole\",
                \"permissions\": ${PERMISSIONS_JSON},
                \"assignableScopes\": [\"/subscriptions/${SUB_ID}\"]
              }
            }" > /dev/null 2>&1

        if [ $? -eq 0 ]; then
            echo "[SUCCESS] Custom role '$ROLE_NAME' created."
            assign_role_to_user "$PRINCIPAL_ID" "$SUB_ID" "$ROLE_DEF_ID"
            return 0
        fi

        RETRY=$((RETRY+1))
        echo "[INFO] Retry $RETRY/$MAX_RETRIES for role '$ROLE_NAME'..."
        sleep 3
    done

    echo "[ERROR] Failed to create custom role '$ROLE_BASE_NAME'" \
         "after $MAX_RETRIES attempts." >&2
}

process_image() {
    local publisher=$1 offer=$2 sku=$3
    echo "[INFO] Checking marketplace terms: $publisher / $offer / $sku"
    TERMS=$($CLI vm image terms show \
        --publisher "$publisher" --offer "$offer" --plan "$sku" 2>/dev/null)
    if echo "$TERMS" | grep -q '"accepted": true'; then
        echo "[INFO] Terms already accepted."
    else
        $CLI vm image terms accept \
            --publisher "$publisher" --offer "$offer" --plan "$sku" \
            > /dev/null 2>&1 \
            && echo "[SUCCESS] Terms accepted." \
            || echo "[WARNING] Could not accept terms for $publisher:$offer:$sku"
    fi
}

#######################################
# STEP 1 — Create App Registration + Service Principal
#######################################
echo ""
echo "===== STEP 1: Creating App Registration ====="
APP_ID=$($CLI ad app create --display-name "$APP_NAME" --query appId -o tsv)
[ -z "$APP_ID" ] && handle_error "Failed to create App Registration."
echo "[SUCCESS] App ID: $APP_ID"

echo "===== STEP 2: Creating Service Principal ====="
SP_ID=$($CLI ad sp create --id "$APP_ID" --query id -o tsv)
[ -z "$SP_ID" ] && handle_error "Failed to create Service Principal."
echo "[SUCCESS] SP Object ID: $SP_ID"

echo "===== STEP 3: Assigning Owner role to Service Principal ====="
$CLI role assignment create \
    --assignee "$SP_ID" --role "$ROLE_NAME" --scope "$SCOPE" \
    > /dev/null 2>&1 \
    && echo "[SUCCESS] Owner role assigned." \
    || echo "[WARNING] Owner role assignment may have failed or already exists."

#######################################
# STEP 2 — Add Microsoft Graph permission + grant admin consent
#######################################
echo ""
echo "===== STEP 4: Adding Microsoft Graph permission ($GRAPH_PERMISSION) ====="
PERMISSION_ID=$($CLI ad sp show \
    --id "$GRAPH_API_ID" \
    --query "appRoles[?value=='$GRAPH_PERMISSION'].id" \
    -o tsv)
[ -z "$PERMISSION_ID" ] && \
    handle_error "Permission $GRAPH_PERMISSION not found in Microsoft Graph."

EXISTING=$($CLI ad app permission list \
    --id "$APP_ID" \
    --query "[?resourceAppId=='$GRAPH_API_ID']" \
    -o json 2>/dev/null)

if echo "$EXISTING" | grep -q "$PERMISSION_ID"; then
    echo "[INFO] Permission already assigned."
else
    $CLI ad app permission add \
        --id "$APP_ID" \
        --api "$GRAPH_API_ID" \
        --api-permissions "$PERMISSION_ID=Role" \
        && echo "[SUCCESS] Permission added."
fi

echo "===== STEP 5: Granting admin consent ====="
$CLI ad app permission admin-consent --id "$APP_ID" \
    && echo "[SUCCESS] Admin consent granted." \
    || echo "[WARNING] Admin consent failed — grant it manually in the Azure Portal."

#######################################
# STEP 3 — Create Client Secret
#######################################
echo ""
echo "===== STEP 6: Creating client secret (180 days) ====="
END_DATE=$(date -d "+180 days" +%Y-%m-%d)
CLIENT_SECRET=$($CLI ad app credential reset \
    --id "$APP_ID" --append --end-date "$END_DATE" \
    --query "password" -o tsv)
[ -z "$CLIENT_SECRET" ] && handle_error "Failed to create client secret."
echo "[SUCCESS] Client secret created, expires $END_DATE."

TENANT_ID=$($CLI account show --query "tenantId" -o tsv)

echo ""
echo "==== App Registration Credentials ===="
echo "tenantId=$TENANT_ID"
echo "subscriptionId=$SUBSCRIPTION_ID"
echo "clientId=$APP_ID"
echo "clientSecret=$CLIENT_SECRET"
echo "======================================"

#######################################
# STEP 4 — Create or reuse service user
#######################################
echo ""
echo "===== STEP 7: Checking service user ====="

ACCESS_TOKEN=$($CLI account get-access-token \
    --resource https://graph.microsoft.com \
    --query accessToken -o tsv)
[ -z "$ACCESS_TOKEN" ] && handle_error "Failed to retrieve Graph access token."

USER_RESPONSE=$($CLI rest --method get \
    --url "https://graph.microsoft.com/v1.0/users/$USER_PRINCIPAL_NAME" \
    --headers "Authorization=Bearer $ACCESS_TOKEN" \
               "Content-Type=application/json" 2>/dev/null)

USER_ID=$(echo "$USER_RESPONSE" \
    | grep -o '"id": *"[^"]*"' | head -1 | awk -F'"' '{print $4}')

if [ -n "$USER_ID" ]; then
    echo "[INFO] User '$USER_PRINCIPAL_NAME' already exists (ID: $USER_ID)." \
         "Cleaning up existing role assignments..."

    RA_URL="https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}"
    RA_URL+="/providers/Microsoft.Authorization/roleAssignments"
    RA_URL+="?api-version=2022-04-01&\$filter=principalId eq '${USER_ID}'"

    ASSIGNMENTS=$($CLI rest --method get \
        --url "$RA_URL" \
        --headers "Content-Type=application/json" 2>/dev/null)

    ROLE_ASSIGNMENT_IDS=$(echo "$ASSIGNMENTS" \
        | grep -o '"id": *"[^"]*"' | awk -F'"' '{print $4}')

    for AID in $ROLE_ASSIGNMENT_IDS; do
        $CLI rest --method delete \
            --url "https://management.azure.com${AID}?api-version=2022-04-01" \
            --headers "Content-Type=application/json" > /dev/null 2>&1
    done
    echo "[INFO] Existing role assignments removed."

    if [ "$RECREATE_USER" = true ]; then
        echo "[INFO] Recreating user..."
        $CLI rest --method delete \
            --url "https://graph.microsoft.com/v1.0/users/$USER_PRINCIPAL_NAME" \
            --headers "Authorization=Bearer $ACCESS_TOKEN" \
                       "Content-Type=application/json" > /dev/null 2>&1 \
            || handle_error "Failed to delete existing user."
        USER_ID=""
    fi
fi

if [ -z "$USER_ID" ]; then
    echo "[INFO] Creating user '$USER_PRINCIPAL_NAME'..."
    CREATE_RESPONSE=$($CLI rest --method post \
        --url "https://graph.microsoft.com/v1.0/users" \
        --headers "Authorization=Bearer $ACCESS_TOKEN" \
                   "Content-Type=application/json" \
        --body "{
            \"accountEnabled\": true,
            \"displayName\": \"$DISPLAY_NAME\",
            \"givenName\": \"$GIVEN_NAME\",
            \"surname\": \"$SURNAME\",
            \"userPrincipalName\": \"$USER_PRINCIPAL_NAME\",
            \"mailNickname\": \"$MAIL_NICKNAME\",
            \"passwordProfile\": {
                \"password\": \"$PASSWORD\",
                \"forceChangePasswordNextSignIn\": false
            }
        }")

    USER_ID=$(echo "$CREATE_RESPONSE" \
        | grep -o '"id": *"[^"]*"' | head -1 | awk -F'"' '{print $4}')
    [ -z "$USER_ID" ] && \
        handle_error "Failed to create user. Response: $CREATE_RESPONSE"
    echo "[SUCCESS] User created. ID: $USER_ID"
fi

#######################################
# STEP 5 — Assign built-in roles
#######################################
echo ""
echo "===== STEP 8: Assigning built-in roles ====="

ROLE_IDS=(
    "ed7f3fbd-7b88-4dd4-9017-9adb7ce333f8"  # Azure Kubernetes Service Contributor
    "86e8f5dc-a6e9-4c67-9d15-de283e8eac25"  # Storage Account Contributor
    "230815da-be43-4aae-9cb4-875f7bd000aa"  # Cosmos DB Operator
    "87a39d53-fc1b-424a-814c-f7e04687dc9e"  # Logic App Contributor
    "673868aa-7521-48a0-acc6-0f60742d39f5"  # Data Factory Contributor
    "6670b86e-a3f7-4917-ac9b-5d6ab1be4567"  # Site Recovery Contributor
    "5e467623-bb1f-42f4-a55d-6e525e11384b"  # Backup Contributor
    "426e0c7f-0c7e-4658-b36f-ff54d6c29b45"  # CDN Endpoint Contributor
    "befefa01-2a29-4197-83a8-272ff33ce314"  # DNS Zone Contributor
    "749f88d5-cbae-40b8-bcfc-e573ddc772fa"  # Monitoring Contributor
    "92aaf0da-9dab-42b6-94a3-d43ce8d16293"  # Log Analytics Contributor
    "4d97b98b-1d4f-4787-a291-c67834d212e7"  # Network Contributor
    "9980e02c-c2be-4d73-94e8-173b1dc7cf3c"  # Virtual Machine Contributor
    "18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"  # User Access Administrator
    "b24988ac-6180-42a0-ab88-20f7382dd24c"  # Contributor
)

for RID in "${ROLE_IDS[@]}"; do
    assign_role_to_user "$USER_ID" "$SUBSCRIPTION_ID" "$RID"
done

#######################################
# STEP 6 — Create and assign custom roles
#######################################
echo ""
echo "===== STEP 9: Creating and assigning custom roles ====="

create_custom_role_and_assign \
    "$SUBSCRIPTION_ID" "CustomAzureBotsContributor" \
    "$PERM_CustomAzureBotsContributor" "$USER_ID"

create_custom_role_and_assign \
    "$SUBSCRIPTION_ID" "CustomDatafactoryRegister" \
    "$PERM_CustomDatafactoryRegister" "$USER_ID"

create_custom_role_and_assign \
    "$SUBSCRIPTION_ID" "CustomDatabricksContributor" \
    "$PERM_CustomDatabricksContributor" "$USER_ID"

create_custom_role_and_assign \
    "$SUBSCRIPTION_ID" "KubernetesRegister" \
    "$PERM_KubernetesRegister" "$USER_ID"

create_custom_role_and_assign \
    "$SUBSCRIPTION_ID" "CustomCosmosDbContributor" \
    "$PERM_CustomCosmosDbContributor" "$USER_ID"

create_custom_role_and_assign \
    "$SUBSCRIPTION_ID" "CustomAzureDatabasePostgres" \
    "$PERM_CustomAzureDatabasePostgres" "$USER_ID"

create_custom_role_and_assign \
    "$SUBSCRIPTION_ID" "CustomQuotaActions" \
    "$PERM_CustomQuotaActions" "$USER_ID"

#######################################
# STEP 7 — Accept marketplace image terms
#######################################
echo ""
echo "===== STEP 10: Accepting marketplace image terms ====="

publisher="" offer="" sku=""
while IFS= read -r line; do
    if echo "$line" | grep -q '"publisher"'; then
        publisher=$(echo "$line" | sed -n 's/.*"publisher": *"\([^"]*\)".*/\1/p')
    elif echo "$line" | grep -q '"offer"'; then
        offer=$(echo "$line" | sed -n 's/.*"offer": *"\([^"]*\)".*/\1/p')
    elif echo "$line" | grep -q '"sku"'; then
        sku=$(echo "$line" | sed -n 's/.*"sku": *"\([^"]*\)".*/\1/p')
    fi
    if [ -n "$publisher" ] && [ -n "$offer" ] && [ -n "$sku" ]; then
        process_image "$publisher" "$offer" "$sku"
        publisher="" offer="" sku=""
    fi
done <<< "$IMAGES_JSON"

#######################################
# STEP 8 — Register resource providers
#######################################
echo ""
echo "===== STEP 11: Registering resource providers ====="

for NS in Microsoft.RecoveryServices Microsoft.Cdn Microsoft.Compute \
          Microsoft.Databricks Microsoft.Storage Microsoft.Network \
          Microsoft.Quota; do
    echo "[INFO] Registering $NS..."
    $CLI provider register --namespace "$NS" > /dev/null 2>&1 \
        && echo "[SUCCESS] $NS registered." \
        || echo "[WARNING] Could not register $NS."
done

#######################################
# Final summary
#######################################
echo ""
echo "========================================="
echo " Onboarding complete"
echo "========================================="
echo " tenantId:       $TENANT_ID"
echo " subscriptionId: $SUBSCRIPTION_ID"
echo " clientId:       $APP_ID"
echo " clientSecret:   $CLIENT_SECRET"
echo " userEmail:      $USER_PRINCIPAL_NAME"
echo " password:       $PASSWORD"
echo "========================================="
echo "[INFO] Script executed successfully."