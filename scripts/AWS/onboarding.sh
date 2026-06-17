#!/bin/bash

###########################################
# How to use this script in AWS Cloud Shell:
# 1. Open AWS Cloud Shell from the AWS Portal.
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
# User-defined variables — fill before running
#######################################
ENV=""          # e.g. account

#######################################
# Validate inputs
#######################################
if [ -z "$ENV" ]; then
    echo "[ERROR] Variable 'ENV' is not set."
    exit 1
fi

#######################################
# Global config
#######################################
CLI=aws
AWSNAME="sa-$ENV-apikey"
ACCOUNTID=$($CLI sts get-caller-identity --query Account --output text --no-cli-pager)

#######################################
# Inline policy definitions
#######################################

read -r -d '' POL_sts_GetFederationToken << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:GetFederationToken",
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_federated_fullaccess_services << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "kms:*",
        "ce:*",
        "cur:*"
      ],
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_federated_kafka_access << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "kafka:ListClustersV2",
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_federated_eks_access << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:AccessKubernetesApi",
        "eks:List*",
        "eks:Describe*",
        "eks:CreateCluster",
        "eks:CreateAccessEntry",
        "eks:CreateAddon",
        "eks:CreateNodegroup",
        "eks:DeleteCluster",
        "eks:DeleteNodegroup",
        "eks:TagResource",
        "redshift-serverless:ListWorkgroups",
        "aps:ListScrapers",
        "iam:ListPolicies",
        "iam:ListAttachedRolePolicies",
        "iam:ListEntitiesForPolicy",
        "iam:GetRole",
        "aws-marketplace:*",
        "guardduty:ListDetectors",
        "cloudshell:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_federated_cloudfront_access << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:Create*",
        "cloudfront:List*",
        "cloudfront:GetDistribution",
        "cloudfront:UpdateDistribution",
        "cloudfront:DeleteDistribution",
        "acm:ListCertificates",
        "acm-pca:ListCertificateAuthorities",
        "iam:ListServerCertificates",
        "s3:GetBucket*",
        "s3:PutBucketPolicy",
        "s3:CreateBucket",
        "s3:ListBucket",
        "s3:PutEncryptionConfiguration",
        "access-analyzer:ValidatePolicy",
        "wafv2:CreateWebACL"
      ],
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_federated_sns_access << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "SNS:CreateTopic",
        "SNS:Subscribe",
        "SNS:Get*",
        "SNS:List*",
        "SNS:Unsubscribe",
        "SNS:DeleteTopic",
        "SNS:ConfirmSubscription"
      ],
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_federated_msk_access << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kafka:*",
        "kms:DescribeKey",
        "kms:CreateGrant",
        "logs:CreateLogDelivery",
        "logs:GetLogDelivery",
        "logs:UpdateLogDelivery",
        "logs:DeleteLogDelivery",
        "logs:ListLogDeliveries",
        "logs:PutResourcePolicy",
        "logs:DescribeResourcePolicies",
        "logs:DescribeLogGroups",
        "S3:GetBucketPolicy",
        "firehose:TagDeliveryStream",
        "cloudwatch:GetMetricData",
        "iam:CreateServiceLinkedRole"
      ],
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_identity_based_lambda_access << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "lambda:CreateFunction",
        "lambda:ListFunctions",
        "lambda:ListEventSourceMappings",
        "lambda:ListLayers",
        "lambda:GetAccountSettings",
        "lambda:ListCodeSigningConfigs",
        "lambda:GetFunction",
        "lambda:InvokeFunction",
        "lambda:DeleteFunction",
        "lambda:ListAliases",
        "lambda:ListVersionsByFunction",
        "lambda:UpdateFunctionCode",
        "lambda:PublishVersion",
        "lambda:GetFunctionConcurrency",
        "lambda:GetPolicy",
        "lambda:GetFunctionEventInvokeConfig",
        "lambda:ListProvisionedConcurrencyConfigs",
        "states:ListStateMachines",
        "tag:GetResources",
        "iam:CreateRole",
        "iam:GetRole",
        "iam:CreatePolicy",
        "iam:AttachRolePolicy",
        "iam:PassRole",
        "iam:ListRoles",
        "iam:Get*",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "cloudformation:ListStacks",
        "cloudwatch:GetMetricData",
        "logs:DescribeLogGroups",
        "logs:CreateLogStream",
        "logs:StartQuery",
        "logs:PutLogEvents",
        "logs:GetQueryResults",
        "codeguru-profiler:GetFindingsReportAccountSummary"
      ],
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_identity_based_sqs_access << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:createqueue",
        "sqs:listqueues",
        "sqs:tagqueue",
        "sqs:getqueueattributes",
        "sqs:deletequeue",
        "sqs:deletemessage",
        "sqs:sendmessage",
        "sqs:receivemessage",
        "pipes:ListPipes"
      ],
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_identity_based_s3_access << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:ListAllMyBuckets",
        "s3:ListBucketVersions",
        "s3:ListBucketMultipartUploads",
        "s3:PutEncryptionConfiguration",
        "s3:PutBucketVersioning",
        "s3:PutBucketTagging",
        "s3:DeleteBucket",
        "s3:ListBucket",
        "s3:GetBucketVersioning",
        "s3:GetBucketTagging",
        "s3:GetEncryptionConfiguration",
        "s3:GetIntelligentTieringConfiguration",
        "s3:GetBucketLogging",
        "s3:GetBucketNotification",
        "s3:GetAccelerateConfiguration",
        "s3:GetBucketObjectLockConfiguration",
        "s3:GetBucketRequestPayment",
        "s3:GetBucketWebsite",
        "s3:GetAccountPublicAccessBlock",
        "s3:GetBucketPolicy",
        "s3:GetBucketCORS",
        "s3:GetAnalyticsConfiguration",
        "s3:GetReplicationConfiguration",
        "s3:GetLifecycleConfiguration",
        "s3:GetInventoryConfiguration",
        "s3:ListAccessPoints",
        "s3:ListAccessPointsForObjectLambda",
        "s3:ListMultiRegionAccessPoints",
        "s3:ListJobs",
        "cloudwatch:ListMetrics",
        "s3:PutObject",
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:DeleteObject",
        "s3:DeleteObjectVersion",
        "s3:PutBucketPublicAccessBlock",
        "route53domains:ListDomains",
        "route53:DeleteHostedZone",
        "route53:GetHostedZone",
        "route53:GetHostedZoneCount",
        "route53domains:ListOperations",
        "route53:GetTrafficPolicyInstanceCount",
        "route53:GetHealthCheckCount",
        "route53:ListTrafficPolicies",
        "route53domains:GetDomainSuggestions",
        "route53:CreateHostedZone",
        "route53domains:CheckDomainAvailability",
        "route53domains:ListPrices",
        "route53:ListHostedZonesByName",
        "route53resolver:ListResolverRules",
        "route53resolver:ListResolverEndpoints",
        "route53resolver:ListOutpostResolvers",
        "route53profiles:ListProfiles",
        "route53:ListCidrCollections",
        "route53domains:GetDomainDetail",
        "route53domains:GetContactReachabilityStatus",
        "route53domains:RegisterDomain",
        "route53domains:DeleteDomain",
        "route53:ListResourceRecordSets",
        "route53:ChangeResourceRecordSets",
        "route53domains:UpdateDomainNameservers",
        "s3:PutBucketWebsite",
        "access-analyzer:ValidatePolicy"
      ],
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_identity_based_dynamodb_access << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:CreateTable",
        "dynamodb:ListTables",
        "dynamodb:DescribeTable",
        "dynamodb:DescribeReservedCapacity",
        "dynamodb:DeleteTable",
        "dax:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DynamoDBIndexAndStreamAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetShardIterator",
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:DescribeStream",
        "dynamodb:GetRecords",
        "dynamodb:ListStreams"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DynamoDBTableAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:ConditionCheckItem",
        "dynamodb:PutItem",
        "dynamodb:DescribeTable",
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:UpdateItem"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DynamoDBDescribeLimitsAccess",
      "Effect": "Allow",
      "Action": "dynamodb:DescribeLimits",
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_identity_based_elasticache_access << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "elasticache:Describe*",
        "elasticache:List*",
        "elasticache:AddTagsToResource",
        "elasticache:AuthorizeCacheSecurityGroupIngress",
        "elasticache:BatchApplyUpdateAction",
        "elasticache:BatchStopUpdateAction",
        "elasticache:CompleteMigration",
        "elasticache:CopySnapshot",
        "elasticache:CreateCacheCluster",
        "elasticache:CreateCacheParameterGroup",
        "elasticache:CreateCacheSubnetGroup",
        "elasticache:CreateGlobalReplicationGroup",
        "elasticache:CreateReplicationGroup",
        "elasticache:DecreaseNodeGroupsInGlobalReplicationGroup",
        "elasticache:DecreaseReplicaCount",
        "elasticache:DeleteCacheCluster",
        "elasticache:DeleteCacheParameterGroup",
        "elasticache:DeleteCacheSubnetGroup",
        "elasticache:DeleteGlobalReplicationGroup",
        "elasticache:DeleteReplicationGroup",
        "elasticache:DeleteSnapshot",
        "elasticache:DisassociateGlobalReplicationGroup",
        "elasticache:FailoverGlobalReplicationGroup",
        "elasticache:IncreaseNodeGroupsInGlobalReplicationGroup",
        "elasticache:IncreaseReplicaCount",
        "elasticache:ModifyCacheCluster",
        "elasticache:ModifyCacheParameterGroup",
        "elasticache:ModifyCacheSubnetGroup",
        "elasticache:ModifyGlobalReplicationGroup",
        "elasticache:ModifyReplicationGroup",
        "elasticache:ModifyReplicationGroupShardConfiguration",
        "elasticache:RebalanceSlotsInGlobalReplicationGroup",
        "elasticache:RebootCacheCluster",
        "elasticache:RemoveTagsFromResource",
        "elasticache:ResetCacheParameterGroup",
        "elasticache:RevokeCacheSecurityGroupIngress",
        "elasticache:StartMigration",
        "elasticache:TestFailover",
        "elasticache:DeleteServerlessCache",
        "iam:CreateServiceLinkedRole"
      ],
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_rds_fullaccess << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds:*",
        "application-autoscaling:DeleteScalingPolicy",
        "application-autoscaling:DeregisterScalableTarget",
        "application-autoscaling:DescribeScalableTargets",
        "application-autoscaling:DescribeScalingActivities",
        "application-autoscaling:DescribeScalingPolicies",
        "application-autoscaling:PutScalingPolicy",
        "application-autoscaling:RegisterScalableTarget",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:DeleteAlarms",
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricData",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeVolumes",
        "ec2:DescribeKeyPairs",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeInstanceTypeOfferings",
        "ec2:DescribeImages",
        "ec2:DescribeImageAttribute",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeCoipPools",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeLocalGatewayRouteTablePermissions",
        "ec2:DescribeLocalGatewayRouteTables",
        "ec2:DescribeLocalGatewayRouteTableVpcAssociations",
        "ec2:DescribeLocalGateways",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcAttribute",
        "ec2:DescribeVpcs",
        "ec2:GetCoipPoolUsage",
        "ec2:DescribeNatGateways",
        "ec2:DescribeVpcEndpoints",
        "ec2:DescribeRouteTables",
        "ec2:DescribeNetworkAcls",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeEgressOnlyInternetGateways",
        "ec2:AssociateVpcCidrBlock",
        "ec2:DescribeIpv6Pools",
        "ec2:CreateSubnet",
        "ec2:CreateTags",
        "ec2:DeleteSubnetCidrReservation",
        "ec2:DescribeSecurityGroupRules",
        "sns:ListSubscriptions",
        "sns:ListTopics",
        "sns:Publish",
        "logs:DescribeLogStreams",
        "logs:GetLogEvents",
        "outposts:GetOutpostInstanceTypes",
        "devops-guru:GetResourceCollection",
        "iam:CreateRole",
        "kms:ListAliases",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey*",
        "kms:ReEncryptFrom",
        "kms:ReEncryptTo"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "pi:*",
      "Resource": [
        "arn:aws:pi:*:*:metrics/rds/*",
        "arn:aws:pi:*:*:perf-reports/rds/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "iam:AWSServiceName": [
            "rds.amazonaws.com",
            "rds.application-autoscaling.amazonaws.com"
          ]
        }
      }
    },
    {
      "Action": [
        "devops-guru:SearchInsights",
        "devops-guru:ListAnomaliesForInsight"
      ],
      "Effect": "Allow",
      "Resource": "*",
      "Condition": {
        "ForAllValues:StringEquals": {
          "devops-guru:ServiceNames": ["RDS"]
        },
        "Null": {
          "devops-guru:ServiceNames": "false"
        }
      }
    }
  ]
}
JSONEOF

read -r -d '' POL_cloudformation_fullaccess << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:*",
        "kms:ListAliases",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey*",
        "kms:ReEncryptFrom",
        "kms:ReEncryptTo"
      ],
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_cloudfront_fullaccess << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListAllMyBuckets",
        "s3:GetBucketPolicy",
        "s3:PutBucketPolicy",
        "s3:GetBucketPublicAccessBlock",
        "s3:GetBucketOwnershipControls",
        "s3:GetBucketAcl",
        "s3:GetBucketCORS",
        "s3:CreateBucket",
        "s3:ListBucket",
        "s3:GetBucketVersioning",
        "s3:GetBucketObjectLockConfiguration",
        "s3:GetEncryptionConfiguration",
        "s3:DeleteBucket",
        "s3:PutObject",
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:DeleteObject",
        "s3:DeleteObjectVersion",
        "s3:PutBucketPublicAccessBlock",
        "s3:PutEncryptionConfiguration",
        "kms:ListAliases",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey*",
        "kms:ReEncryptFrom",
        "kms:ReEncryptTo"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::*"
    },
    {
      "Action": [
        "acm:ListCertificates",
        "cloudfront:*",
        "iam:ListServerCertificates",
        "waf:ListWebACLs",
        "waf:GetWebACL",
        "wafv2:ListWebACLs",
        "wafv2:GetWebACL",
        "wafv2:CreateWebACL",
        "kinesis:ListStreams",
        "access-analyzer:ValidatePolicy"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": "kinesis:DescribeStream",
      "Effect": "Allow",
      "Resource": "arn:aws:kinesis:*:*:*"
    },
    {
      "Action": "iam:ListRoles",
      "Effect": "Allow",
      "Resource": "arn:aws:iam::*:*"
    }
  ]
}
JSONEOF

read -r -d '' POL_cloudwatch_fullaccess << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:Describe*",
        "cloudwatch:*",
        "logs:*",
        "sns:*",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:GetRole",
        "oam:ListSinks",
        "kms:ListAliases",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey*",
        "kms:ReEncryptFrom",
        "kms:ReEncryptTo"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "arn:aws:iam::*:role/aws-service-role/events.amazonaws.com/AWSServiceRoleForCloudWatchEvents*",
      "Condition": {
        "StringLike": {
          "iam:AWSServiceName": "events.amazonaws.com"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "oam:ListAttachedLinks",
      "Resource": "arn:aws:oam:*:*:sink/*"
    }
  ]
}
JSONEOF

read -r -d '' POL_dynamodb_fullaccess << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*",
        "dax:*",
        "application-autoscaling:DeleteScalingPolicy",
        "application-autoscaling:DeregisterScalableTarget",
        "application-autoscaling:DescribeScalableTargets",
        "application-autoscaling:DescribeScalingActivities",
        "application-autoscaling:DescribeScalingPolicies",
        "application-autoscaling:PutScalingPolicy",
        "application-autoscaling:RegisterScalableTarget",
        "cloudwatch:DeleteAlarms",
        "cloudwatch:DescribeAlarmHistory",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:DescribeAlarmsForMetric",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:GetMetricData",
        "datapipeline:ActivatePipeline",
        "datapipeline:CreatePipeline",
        "datapipeline:DeletePipeline",
        "datapipeline:DescribeObjects",
        "datapipeline:DescribePipelines",
        "datapipeline:GetPipelineDefinition",
        "datapipeline:ListPipelines",
        "datapipeline:PutPipelineDefinition",
        "datapipeline:QueryObjects",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "iam:GetRole",
        "iam:ListRoles",
        "kms:DescribeKey",
        "kms:ListAliases",
        "sns:CreateTopic",
        "sns:DeleteTopic",
        "sns:ListSubscriptions",
        "sns:ListSubscriptionsByTopic",
        "sns:ListTopics",
        "sns:Subscribe",
        "sns:Unsubscribe",
        "sns:SetTopicAttributes",
        "lambda:CreateFunction",
        "lambda:ListFunctions",
        "lambda:ListEventSourceMappings",
        "lambda:CreateEventSourceMapping",
        "lambda:DeleteEventSourceMapping",
        "lambda:GetFunctionConfiguration",
        "lambda:DeleteFunction",
        "resource-groups:ListGroups",
        "resource-groups:ListGroupResources",
        "resource-groups:GetGroup",
        "resource-groups:GetGroupQuery",
        "resource-groups:DeleteGroup",
        "resource-groups:CreateGroup",
        "tag:GetResources",
        "kinesis:ListStreams",
        "kinesis:DescribeStream",
        "kinesis:DescribeStreamSummary",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey*",
        "kms:ReEncryptFrom",
        "kms:ReEncryptTo"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": "cloudwatch:GetInsightRuleReport",
      "Effect": "Allow",
      "Resource": "arn:aws:cloudwatch:*:*:insight-rule/DynamoDBContributorInsights*"
    },
    {
      "Action": "iam:PassRole",
      "Effect": "Allow",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "iam:PassedToService": [
            "application-autoscaling.amazonaws.com",
            "application-autoscaling.amazonaws.com.cn",
            "dax.amazonaws.com"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "iam:AWSServiceName": [
            "replication.dynamodb.amazonaws.com",
            "dax.amazonaws.com",
            "dynamodb.application-autoscaling.amazonaws.com",
            "contributorinsights.dynamodb.amazonaws.com",
            "kinesisreplication.dynamodb.amazonaws.com"
          ]
        }
      }
    }
  ]
}
JSONEOF

read -r -d '' POL_eks_fullaccess << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "ec2:DeleteTags",
        "logs:DescribeLogStreams",
        "ec2:CreateTags"
      ],
      "Resource": [
        "arn:aws:logs:*:*:log-group:/aws/eks/*:*",
        "arn:aws:ec2:*:*:subnet/*",
        "arn:aws:ec2:*:*:vpc/*"
      ]
    },
    {
      "Sid": "VisualEditor1",
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "iam:AWSServiceName": "eks.amazonaws.com"
        }
      }
    },
    {
      "Sid": "VisualEditor2",
      "Effect": "Allow",
      "Action": [
        "iam:CreateInstanceProfile",
        "eks:UpdateClusterVersion",
        "ec2:DescribeInstances",
        "iam:CreateRole",
        "iam:GetRole",
        "iam:AttachRolePolicy",
        "iam:AddRoleToInstanceProfile",
        "iam:CreateAccessKey",
        "iam:ListInstanceProfilesForRole",
        "iam:PassRole",
        "iam:DetachRolePolicy",
        "iam:ListEntitiesForPolicy",
        "aps:ListScrapers",
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterfacePermission",
        "iam:ListAttachedRolePolicies",
        "iam:ListRolePolicies",
        "iam:ListAccessKeys",
        "iam:ListPolicies",
        "ec2:DetachNetworkInterface",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:DeleteNetworkInterface",
        "iam:ListRoles",
        "iam:DeleteRole",
        "logs:CreateLogGroup",
        "ec2:DescribeSecurityGroups",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeVpcs",
        "eks:DescribeCluster",
        "eks:ListClusters",
        "route53:AssociateVPCWithHostedZone",
        "ec2:DescribeSubnets",
        "eks:*",
        "kms:ListAliases",
        "ec2:GetSecurityGroupsForVpc",
        "aws-marketplace:ResolveCustomer",
        "aws-marketplace:BatchMeterUsage",
        "aws-marketplace:GetEntitlements",
        "aws-marketplace:GetBuyerDashboard",
        "guardduty:ListDetectors",
        "eks:DeleteNodegroup",
        "eks:CreateAccessEntry",
        "eks:CreateAddon",
        "cloudshell:*",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey*",
        "kms:ReEncryptFrom",
        "kms:ReEncryptTo"
      ],
      "Resource": "*"
    },
    {
      "Sid": "VisualEditor3",
      "Effect": "Allow",
      "Action": "logs:PutLogEvents",
      "Resource": "arn:aws:logs:*:*:log-group:/aws/eks/*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "iam:AWSServiceName": [
            "eks.amazonaws.com",
            "eks-nodegroup.amazonaws.com"
          ]
        }
      }
    }
  ]
}
JSONEOF

read -r -d '' POL_lambda_fullaccess << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:GetAccountSettings",
        "lambda:ListFunctions",
        "lambda:CreateFunction",
        "lambda:GetFunction",
        "lambda:UpdateFunctionCode",
        "lambda:DeleteFunction",
        "lambda:InvokeFunction",
        "lambda:ListEventSourceMappings",
        "lambda:ListLayers",
        "lambda:ListAliases",
        "lambda:ListCodeSigningConfigs",
        "lambda:ListVersionsByFunction",
        "lambda:PublishVersion",
        "lambda:GetFunctionEventInvokeConfig",
        "lambda:ListProvisionedConcurrencyConfigs",
        "lambda:GetPolicy",
        "lambda:GetFunctionConcurrency",
        "tag:GetResources",
        "iam:CreateRole",
        "iam:GetRole",
        "iam:CreatePolicy",
        "iam:AttachRolePolicy",
        "iam:PassRole",
        "iam:ListRoles",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:Get*",
        "states:ListStateMachines",
        "cloudwatch:GetMetricData",
        "cloudformation:ListStacks",
        "logs:DescribeLogGroups",
        "logs:CreateLogStream",
        "logs:StartQuery",
        "logs:PutLogEvents",
        "logs:GetQueryResults",
        "codeguru-profiler:GetFindingsReportAccountSummary",
        "kms:ListAliases",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey*",
        "kms:ReEncryptFrom",
        "kms:ReEncryptTo"
      ],
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_route53_fullaccess << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:*",
        "route53domains:*",
        "route53:ListHostedZonesByName",
        "cloudfront:ListDistributions",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticbeanstalk:DescribeEnvironments",
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:GetBucketWebsite",
        "s3:PutBucketWebsite",
        "s3:ListAllMyBuckets",
        "s3:CreateBucket",
        "ec2:DescribeVpcs",
        "ec2:DescribeVpcEndpoints",
        "ec2:DescribeRegions",
        "sns:ListTopics",
        "sns:ListSubscriptionsByTopic",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:GetMetricStatistics",
        "route53profiles:ListProfiles",
        "access-analyzer:ValidatePolicy",
        "kms:ListAliases",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey*",
        "kms:ReEncryptFrom",
        "kms:ReEncryptTo"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "s3-object-lambda:*",
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricStatistics"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "apigateway:GET",
      "Resource": "arn:aws:apigateway:*::/domainnames"
    }
  ]
}
JSONEOF

read -r -d '' POL_s3_fullaccess << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "s3-object-lambda:*",
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricStatistics",
        "kms:ListAliases",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey*",
        "kms:ReEncryptFrom",
        "kms:ReEncryptTo"
      ],
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_sns_fullaccess << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "sns:*",
        "kms:ListAliases",
        "kms:DescribeKey",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:ReEncryptFrom",
        "kms:ReEncryptTo"
      ],
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_sqs_fullaccess << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:*",
        "lambda:ListEventSourceMappings",
        "pipes:ListPipes",
        "kms:ListAliases",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey*",
        "kms:ReEncryptFrom",
        "kms:ReEncryptTo"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_elasticache_fullaccess << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSecurityGroupRules",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupEgress",
        "kms:ListAliases",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey*",
        "kms:ReEncryptFrom",
        "kms:ReEncryptTo"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ElastiCacheManagementActions",
      "Effect": "Allow",
      "Action": "elasticache:*",
      "Resource": "*"
    },
    {
      "Sid": "CreateServiceLinkedRole",
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "arn:aws:iam::*:role/aws-service-role/elasticache.amazonaws.com/AWSServiceRoleForElastiCache",
      "Condition": {
        "StringLike": {
          "iam:AWSServiceName": "elasticache.amazonaws.com"
        }
      }
    },
    {
      "Sid": "CreateVPCEndpoints",
      "Effect": "Allow",
      "Action": "ec2:CreateVpcEndpoint",
      "Resource": "arn:aws:ec2:*:*:vpc-endpoint/*",
      "Condition": {
        "StringLike": {
          "ec2:VpceServiceName": "com.amazonaws.elasticache.serverless.*"
        }
      }
    },
    {
      "Sid": "AllowAccessToElastiCacheTaggedVpcEndpoints",
      "Effect": "Allow",
      "Action": "ec2:CreateVpcEndpoint",
      "NotResource": "arn:aws:ec2:*:*:vpc-endpoint/*"
    },
    {
      "Sid": "TagVPCEndpointsOnCreation",
      "Effect": "Allow",
      "Action": "ec2:CreateTags",
      "Resource": "arn:aws:ec2:*:*:vpc-endpoint/*",
      "Condition": {
        "StringEquals": {
          "ec2:CreateAction": "CreateVpcEndpoint",
          "aws:RequestTag/AmazonElastiCacheManaged": "true"
        }
      }
    },
    {
      "Sid": "AllowAccessToEc2",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowAccessToKMS",
      "Effect": "Allow",
      "Action": [
        "kms:DescribeKey",
        "kms:ListAliases",
        "kms:ListKeys"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowAccessToCloudWatch",
      "Effect": "Allow",
      "Action": [
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:GetMetricData"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowAccessToAutoScaling",
      "Effect": "Allow",
      "Action": [
        "application-autoscaling:DescribeScalableTargets",
        "application-autoscaling:DescribeScheduledActions",
        "application-autoscaling:DescribeScalingPolicies",
        "application-autoscaling:DescribeScalingActivities"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DescribeLogGroups",
      "Effect": "Allow",
      "Action": "logs:DescribeLogGroups",
      "Resource": "*"
    },
    {
      "Sid": "ListLogDeliveryStreams",
      "Effect": "Allow",
      "Action": "firehose:ListDeliveryStreams",
      "Resource": "*"
    },
    {
      "Sid": "DescribeS3Buckets",
      "Effect": "Allow",
      "Action": "s3:ListAllMyBuckets",
      "Resource": "*"
    },
    {
      "Sid": "AllowAccessToOutposts",
      "Effect": "Allow",
      "Action": "outposts:ListOutposts",
      "Resource": "*"
    },
    {
      "Sid": "AllowAccessToSNS",
      "Effect": "Allow",
      "Action": "sns:ListTopics",
      "Resource": "*"
    }
  ]
}
JSONEOF

read -r -d '' POL_msk_fullaccess << 'JSONEOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:DeleteSubnet",
        "ec2:DeleteTags",
        "ec2:GetSubnetCidrReservations",
        "ec2:CreateSubnetCidrReservation",
        "ec2:AssociateVpcCidrBlock",
        "ec2:DisassociateVpcCidrBlock",
        "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
        "ec2:ModifySubnetAttribute",
        "ec2:CreateDefaultSubnet",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:GetSecurityGroupsForVpc",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
        "ec2:CreateTags",
        "ec2:ModifySecurityGroupRules",
        "ec2:DisassociateSubnetCidrBlock",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DeleteSecurityGroup",
        "ec2:AssociateSubnetCidrBlock",
        "ec2:ApplySecurityGroupsToClientVpnTargetNetwork",
        "ec2:CreateSubnet",
        "ec2:DeleteSubnetCidrReservation",
        "kms:ListAliases",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey*",
        "kms:ReEncryptFrom",
        "kms:ReEncryptTo"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kafka:*",
        "ec2:Describe*",
        "kms:DescribeKey",
        "kms:CreateGrant",
        "logs:CreateLogDelivery",
        "logs:GetLogDelivery",
        "logs:UpdateLogDelivery",
        "logs:DeleteLogDelivery",
        "logs:ListLogDeliveries",
        "logs:PutResourcePolicy",
        "logs:DescribeResourcePolicies",
        "logs:DescribeLogGroups",
        "S3:GetBucketPolicy",
        "firehose:TagDeliveryStream",
        "cloudwatch:GetMetricData"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:CreateVpcEndpoint",
      "Resource": [
        "arn:*:ec2:*:*:vpc/*",
        "arn:*:ec2:*:*:subnet/*",
        "arn:*:ec2:*:*:security-group/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "ec2:CreateVpcEndpoint",
      "Resource": "arn:*:ec2:*:*:vpc-endpoint/*",
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/AWSMSKManaged": "true"
        },
        "StringLike": {
          "aws:RequestTag/ClusterArn": "*"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "ec2:CreateTags",
      "Resource": "arn:*:ec2:*:*:vpc-endpoint/*",
      "Condition": {
        "StringEquals": {
          "ec2:CreateAction": "CreateVpcEndpoint"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "ec2:DeleteVpcEndpoints",
      "Resource": "arn:*:ec2:*:*:vpc-endpoint/*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/AWSMSKManaged": "true"
        },
        "StringLike": {
          "ec2:ResourceTag/ClusterArn": "*"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": "kafka.amazonaws.com"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "arn:aws:iam::*:role/aws-service-role/kafka.amazonaws.com/AWSServiceRoleForKafka*",
      "Condition": {
        "StringEquals": {
          "iam:AWSServiceName": "kafka.amazonaws.com"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "arn:aws:iam::*:role/aws-service-role/delivery.logs.amazonaws.com/AWSServiceRoleForLogDelivery*",
      "Condition": {
        "StringEquals": {
          "iam:AWSServiceName": "delivery.logs.amazonaws.com"
        }
      }
    }
  ]
}
JSONEOF

#######################################
# Helper functions
#######################################

create_or_update_policy() {
    local POLICY_NAME=$1
    local POLICY_DOC=$2

    POLICY_ARN=$($CLI iam create-policy \
        --policy-name "$POLICY_NAME" \
        --policy-document "$POLICY_DOC" \
        --query 'Policy.Arn' \
        --output text \
        --no-paginate --no-cli-pager 2>&1)

    if echo "$POLICY_ARN" | grep -q 'EntityAlreadyExists\|Duplicate names'; then
        POLICY_ARN="arn:aws:iam::${ACCOUNTID}:policy/${POLICY_NAME}"
        echo "[INFO] Policy '$POLICY_NAME' already exists, updating..." >&2

        VERSIONS=$($CLI iam list-policy-versions \
            --policy-arn "$POLICY_ARN" \
            --query 'Versions[].VersionId' \
            --output text \
            --no-paginate --no-cli-pager | wc -w)

        if [ "$VERSIONS" -gt 4 ]; then
            OLDEST=$($CLI iam list-policy-versions \
                --policy-arn "$POLICY_ARN" \
                --query 'sort_by(Versions, &CreateDate)[0].VersionId' \
                --output text \
                --no-paginate --no-cli-pager)
            echo "[INFO] Deleting oldest version: $OLDEST" >&2
            $CLI iam delete-policy-version \
                --policy-arn "$POLICY_ARN" \
                --version-id "$OLDEST" \
                --no-paginate --no-cli-pager > /dev/null
        fi

        $CLI iam create-policy-version \
            --policy-arn "$POLICY_ARN" \
            --policy-document "$POLICY_DOC" \
            --set-as-default \
            --no-paginate --no-cli-pager > /dev/null
    fi

    echo "$POLICY_ARN"
}

attach_policy() {
    local POLICY_ARN=$1
    echo "[INFO] Attaching policy: $POLICY_ARN"
    $CLI iam attach-user-policy \
        --policy-arn "$POLICY_ARN" \
        --user-name "$AWSNAME" \
        --no-paginate --no-cli-pager
}

put_inline_policy() {
    local POLICY_NAME=$1
    local POLICY_DOC=$2
    echo "[INFO] Putting inline policy: $POLICY_NAME"
    $CLI iam put-user-policy \
        --user-name "$AWSNAME" \
        --policy-name "$POLICY_NAME" \
        --policy-document "$POLICY_DOC" \
        --no-paginate --no-cli-pager
}

#######################################
# STEP 1 — Create user if not exists
#######################################
echo ""
echo "===== STEP 1: Checking IAM user ====="

USEREXIST=$($CLI iam get-user \
    --user-name "$AWSNAME" \
    --no-paginate --no-cli-pager 2>/dev/null)

if [ -z "$USEREXIST" ]; then
    echo "[INFO] Creating user '$AWSNAME'..."
    $CLI iam create-user \
        --user-name "$AWSNAME" \
        --tags '{"Key":"Creator","Value":"onboarding-script-aws"}' \
        --no-paginate --no-cli-pager

    echo "[INFO] Creating access key..."
    ACCESS_KEY_JSON=$($CLI iam create-access-key \
        --user-name "$AWSNAME" \
        --output json \
        --no-paginate --no-cli-pager)

    echo "[INFO] Attaching AWS managed policies..."
    attach_policy "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    attach_policy "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
    attach_policy "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
    attach_policy "arn:aws:iam::aws:policy/AWSDirectConnectFullAccess"
    attach_policy "arn:aws:iam::aws:policy/ServiceQuotasFullAccess"
else
    echo "[INFO] User '$AWSNAME' already exists, skipping creation."
fi

#######################################
# STEP 2 — Create/update and attach managed custom policies
#######################################
echo ""
echo "===== STEP 2: Creating/updating custom managed policies ====="

IBLAMBDA=$(create_or_update_policy \
    "emma-identity-based-lambda-access" "$POL_identity_based_lambda_access")
echo "[INFO] emma-identity-based-lambda-access = $IBLAMBDA"
attach_policy "$IBLAMBDA"

IBSQS=$(create_or_update_policy \
    "emma-identity-based-sqs-access" "$POL_identity_based_sqs_access")
echo "[INFO] emma-identity-based-sqs-access = $IBSQS"
attach_policy "$IBSQS"

IBS3=$(create_or_update_policy \
    "emma-identity-based-s3-access" "$POL_identity_based_s3_access")
echo "[INFO] emma-identity-based-s3-access = $IBS3"
attach_policy "$IBS3"

IBDYNAMODB=$(create_or_update_policy \
    "emma-identity-based-dynamodb-access" "$POL_identity_based_dynamodb_access")
echo "[INFO] emma-identity-based-dynamodb-access = $IBDYNAMODB"
attach_policy "$IBDYNAMODB"

IBELASTICACHE=$(create_or_update_policy \
    "emma-identity-based-elasticache-access" "$POL_identity_based_elasticache_access")
echo "[INFO] emma-identity-based-elasticache-access = $IBELASTICACHE"
attach_policy "$IBELASTICACHE"

#######################################
# STEP 3 — Put inline policies
#######################################
echo ""
echo "===== STEP 3: Putting inline policies ====="

put_inline_policy "sts-GetFederationToken-all-resources" \
    "$POL_sts_GetFederationToken"

put_inline_policy "federated-fullaccess-services" \
    "$POL_federated_fullaccess_services"

put_inline_policy "federated-kafka-access" \
    "$POL_federated_kafka_access"

put_inline_policy "federated-eks-access" \
    "$POL_federated_eks_access"

put_inline_policy "federated-cloudfront-access" \
    "$POL_federated_cloudfront_access"

put_inline_policy "federated-sns-access" \
    "$POL_federated_sns_access"

put_inline_policy "federated-msk-access" \
    "$POL_federated_msk_access"

#######################################
# STEP 4 — Create STS signUrl policies (no attachment)
#######################################
echo ""
echo "===== STEP 4: Creating STS signUrl policies ====="

create_or_update_policy "rds-fullaccess-emma"            "$POL_rds_fullaccess"            > /dev/null
create_or_update_policy "cloudformation-fullaccess-emma" "$POL_cloudformation_fullaccess" > /dev/null
create_or_update_policy "cloudfront-fullaccess-emma"     "$POL_cloudfront_fullaccess"     > /dev/null
create_or_update_policy "cloudwatch-fullaccess-emma"     "$POL_cloudwatch_fullaccess"     > /dev/null
create_or_update_policy "dynamodb-fullaccess-emma"       "$POL_dynamodb_fullaccess"       > /dev/null
create_or_update_policy "eks-fullaccess-emma"            "$POL_eks_fullaccess"            > /dev/null
create_or_update_policy "lambda-fullaccess-emma"         "$POL_lambda_fullaccess"         > /dev/null
create_or_update_policy "route53-fullaccess-emma"        "$POL_route53_fullaccess"        > /dev/null
create_or_update_policy "s3-fullaccess-emma"             "$POL_s3_fullaccess"             > /dev/null
create_or_update_policy "sns-fullaccess-emma"            "$POL_sns_fullaccess"            > /dev/null
create_or_update_policy "sqs-fullaccess-emma"            "$POL_sqs_fullaccess"            > /dev/null
create_or_update_policy "elasticache-fullaccess-emma"    "$POL_elasticache_fullaccess"    > /dev/null
create_or_update_policy "msk-fullaccess-emma"            "$POL_msk_fullaccess"            > /dev/null
echo "[SUCCESS] All STS signUrl policies created/updated."

#######################################
# STEP 5 — Enable all opt-in regions
#######################################
echo ""
echo "===== STEP 5: Enabling opt-in regions ====="

DISABLED_REGIONS=($($CLI account list-regions \
    --region-opt-status-contains DISABLED \
    --query "Regions[].RegionName" \
    --output text \
    --no-cli-pager 2>/dev/null | tr '\t' '\n'))

TOTAL=${#DISABLED_REGIONS[@]}

if [ "$TOTAL" -eq 0 ]; then
    echo "[INFO] No disabled regions found — all opt-in regions already enabled."
else
    echo "[INFO] Found $TOTAL disabled region(s) to enable."

    # Enable first three simultaneously
    BATCH=("${DISABLED_REGIONS[@]:0:3}")
    REST=("${DISABLED_REGIONS[@]:3}")

    echo "[INFO] Enabling first batch simultaneously: ${BATCH[*]}"
    for REGION in "${BATCH[@]}"; do
        echo "[INFO] Requesting enable: $REGION"
        $CLI account enable-region --region-name "$REGION" --no-cli-pager \
            && echo "[SUCCESS] Enable requested: $REGION" \
            || echo "[WARNING] Failed to request enable: $REGION"
    done

    # Enable remaining one by one with 1 minute wait
    for REGION in "${REST[@]}"; do
        echo "[INFO] Waiting 60 seconds before enabling next region..."
        sleep 60
        echo "[INFO] Requesting enable: $REGION"
        $CLI account enable-region --region-name "$REGION" --no-cli-pager \
            && echo "[SUCCESS] Enable requested: $REGION" \
            || echo "[WARNING] Failed to request enable: $REGION"
    done

    echo ""
    echo "[INFO] All region enable requests submitted."
    echo "[INFO] Regions may take several minutes to reach ENABLED status."
    echo "[INFO] Check status with:"
    echo "       aws account list-regions --region-opt-status-contains ENABLED ENABLING"
fi

#######################################
# Final summary
#######################################
echo ""
echo "========================================="
echo " Onboarding complete"
echo "========================================="
echo " accountId: $ACCOUNTID"
echo " userName:  $AWSNAME"
echo "========================================="

if [ -n "$ACCESS_KEY_JSON" ]; then
    ACCESS_KEY_ID=$(echo "$ACCESS_KEY_JSON" \
        | grep -o '"AccessKeyId": *"[^"]*"' | awk -F'"' '{print $4}')
    SECRET_ACCESS_KEY=$(echo "$ACCESS_KEY_JSON" \
        | grep -o '"SecretAccessKey": *"[^"]*"' | awk -F'"' '{print $4}')
    echo " AccessKeyId:     $ACCESS_KEY_ID"
    echo " SecretAccessKey: $SECRET_ACCESS_KEY"
    echo "========================================="
    echo " IMPORTANT: Save the SecretAccessKey now — it will not be shown again."
fi

echo "[INFO] Script executed successfully."