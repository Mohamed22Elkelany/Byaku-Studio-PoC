###########################################################################
# OUT OF SCOPE (commented out): Amazon Bedrock is not part of the Byaku PoC yet.
# Uncomment together with var.bedrock_models (variables.tf) and the BEDROCK_*
# backend environment (ecs_tasks.tf) when the backend starts calling models.
#
# Two-model strategy over Global cross-Region inference:
#   - pipeline:  Claude Opus for the long-running pipeline layers.
#   - assistant: Claude Sonnet for the chatbot and the admin copilot.
# The backend task role is the only Bedrock identity; no secrets are stored.
###########################################################################

# locals {
#   bedrock_layer_models = {
#     BEDROCK_CRITERIA_MODEL      = var.bedrock_models.pipeline
#     BEDROCK_EXTRACT_MODEL       = var.bedrock_models.pipeline
#     BEDROCK_JUDGE_MODEL         = var.bedrock_models.pipeline
#     BEDROCK_NARRATE_MODEL       = var.bedrock_models.pipeline
#     BEDROCK_REMEDIATE_MODEL     = var.bedrock_models.pipeline
#     BEDROCK_ASSISTANT_MODEL     = var.bedrock_models.assistant
#     BEDROCK_ADMIN_COPILOT_MODEL = var.bedrock_models.assistant
#   }
#
#   # Global inference profile ID -> underlying model ID ("global.anthropic.x" -> "anthropic.x").
#   bedrock_profiles = {
#     for profile in distinct(values(var.bedrock_models)) :
#     profile => "arn:aws:bedrock:${var.aws_region}:${data.aws_caller_identity.current.account_id}:inference-profile/${profile}"
#   }
# }
#
# # Three-part policy required for Global cross-Region inference: the regional
# # inference profile, the regional foundation model and the global foundation model
# # (aws:RequestedRegion "unspecified"), each pinned to the approved profiles only.
# data "aws_iam_policy_document" "backend_bedrock" {
#   statement {
#     sid       = "InvokeApprovedGlobalInferenceProfiles"
#     actions   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
#     resources = values(local.bedrock_profiles)
#
#     condition {
#       test     = "StringEquals"
#       variable = "aws:RequestedRegion"
#       values   = [var.aws_region]
#     }
#
#     condition {
#       test     = "Bool"
#       variable = "aws:SecureTransport"
#       values   = ["true"]
#     }
#   }
#
#   statement {
#     sid     = "InvokeRegionalModelThroughApprovedProfiles"
#     actions = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
#     resources = [
#       for profile in keys(local.bedrock_profiles) :
#       "arn:aws:bedrock:${var.aws_region}::foundation-model/${trimprefix(profile, "global.")}"
#     ]
#
#     condition {
#       test     = "StringEquals"
#       variable = "aws:RequestedRegion"
#       values   = [var.aws_region]
#     }
#
#     condition {
#       test     = "StringEquals"
#       variable = "bedrock:InferenceProfileArn"
#       values   = values(local.bedrock_profiles)
#     }
#   }
#
#   statement {
#     sid     = "InvokeGlobalModelThroughApprovedProfiles"
#     actions = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
#     resources = [
#       for profile in keys(local.bedrock_profiles) :
#       "arn:aws:bedrock:::foundation-model/${trimprefix(profile, "global.")}"
#     ]
#
#     condition {
#       test     = "StringEquals"
#       variable = "aws:RequestedRegion"
#       values   = ["unspecified"]
#     }
#
#     condition {
#       test     = "StringEquals"
#       variable = "bedrock:InferenceProfileArn"
#       values   = values(local.bedrock_profiles)
#     }
#   }
# }
#
# resource "aws_iam_role_policy" "backend_bedrock" {
#   name   = "${local.name}-backend-bedrock"
#   role   = aws_iam_role.ecs_task["backend"].id
#   policy = data.aws_iam_policy_document.backend_bedrock.json
# }
