# SCP Errors Monitoring Terraform Modules

This directory contains Terraform modules converted from the CloudFormation templates for SCP error monitoring.

## Module Structure

- `bus` - Contains resources for the event bus in the management account
- `rules` - Contains resources for the event rules in member accounts

## Architecture

This solution monitors Service Control Policy (SCP) errors across an AWS organization:

1. The `bus` module (deployed in management account) creates:
   - An EventBridge event bus that collects SCP error events
   - A CloudWatch log group to store these events
   - Metric filters to track SCP errors by account and action
   - Event bus permissions allowing member accounts to send events

2. The `rules` module (deployed in member accounts) creates:
   - IAM role that allows EventBridge to send events cross-account
   - EventBridge rule that matches SCP-related error events
   - EventBridge target that forwards matching events to the management event bus

## Usage

### Management Account

```hcl
module "scp_errors_bus" {
  source = "./modules/bus"
  
  org_id = "o-yourawsorgid"
}
```

### Member Accounts

```hcl
module "scp_errors_rules" {
  source = "./modules/rules"
  
  event_bus_arn = "arn:aws:events:us-east-1:MANAGEMENT_ACCOUNT_ID:event-bus/scp-errors-event-bus"
}
```

## CloudFormation to Terraform Mapping

### bus.yml → modules/bus
- `CloudWatchLogGroup` → `aws_cloudwatch_log_group`
- `CloudWatchLogGroupMetricFilter` → `aws_cloudwatch_log_metric_filter`
- `EventBus` → `aws_cloudwatch_event_bus`
- `EventBusPolicy0` → `aws_cloudwatch_event_permission`
- `EventRule0` → `aws_cloudwatch_event_rule` + `aws_cloudwatch_event_target`
- `SCPErrorsLogGroupEventBridgePolicy` → `aws_cloudwatch_log_resource_policy`

### rules.yml → modules/rules
- `EventBusIAMRole` → `aws_iam_role` (with inline policy)
- `EventRule0` → `aws_cloudwatch_event_rule` + `aws_cloudwatch_event_target`
