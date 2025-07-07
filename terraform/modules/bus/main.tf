resource "aws_cloudwatch_log_group" "scp_errors" {
  name              = "/aws/events/scp-errors-events"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_metric_filter" "scp_errors" {
  name           = "ScpErrorsFilter"
  pattern        = "{ $.account = * }"
  log_group_name = aws_cloudwatch_log_group.scp_errors.name

  metric_transformation {
    name          = "ScpErrors"
    namespace     = "ScpErrors"
    value         = "1"
    unit          = "Count"
    dimensions = {
      Account = "$.account"
      Action  = "$.detail.eventName"
    }
  }
}

resource "aws_cloudwatch_event_bus" "scp_errors" {
  name = "scp-errors-event-bus"
}

resource "aws_cloudwatch_event_permission" "organization" {
  principal      = "*"
  statement_id   = "AllowAllAccountsFromOrganizationToPutEvents"
  event_bus_name = aws_cloudwatch_event_bus.scp_errors.name

  condition {
    key   = "aws:PrincipalOrgID"
    type  = "StringEquals"
    value = var.org_id
  }
}

resource "aws_cloudwatch_event_rule" "scp_errors_log" {
  name           = "scp-errors-log-rule"
  description    = "Rule to log SCP errors"
  event_bus_name = aws_cloudwatch_event_bus.scp_errors.name
  
  event_pattern = jsonencode({
    source = [{ prefix = "" }]
  })

  depends_on = [aws_cloudwatch_event_bus.scp_errors]
}

resource "aws_cloudwatch_event_target" "scp_errors_log" {
  rule           = aws_cloudwatch_event_rule.scp_errors_log.name
  event_bus_name = aws_cloudwatch_event_bus.scp_errors.name
  target_id      = "IdScpErrorsEventBusLogRuleTarget"
  arn            = aws_cloudwatch_log_group.scp_errors.arn
}

resource "aws_cloudwatch_log_resource_policy" "eventbridge" {
  policy_name = "EventBridgeToSCPErrorsLogGroupPolicy"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEventBridgeToWriteSCPErrorLogs"
        Effect    = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action    = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource  = aws_cloudwatch_log_group.scp_errors.arn
      }
    ]
  })
}
