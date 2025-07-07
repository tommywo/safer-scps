resource "aws_iam_role" "event_bus" {
  name = "events-send-to-management-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  path = "/"
  
  inline_policy {
    name = "send-events-cross-account"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["events:PutEvents"]
          Resource = var.event_bus_arn
        }
      ]
    })
  }
}

resource "aws_cloudwatch_event_rule" "scp_errors" {
  name        = "scp-errors-rule"
  description = "Rule to send SCP errors to event bus"
  
  event_pattern = jsonencode({
    "detail-type" = ["AWS API Call via CloudTrail"]
    "detail" = {
      "errorCode" = ["AccessDenied", "Client.UnauthorizedOperation"]
      "errorMessage" = [{"wildcard": "*service control policy*"}]
    }
  })
  
  depends_on = [aws_iam_role.event_bus]
}

resource "aws_cloudwatch_event_target" "scp_errors" {
  rule      = aws_cloudwatch_event_rule.scp_errors.name
  target_id = "IdScpErrorsEventBusRuleTarget"
  arn       = var.event_bus_arn
  role_arn  = aws_iam_role.event_bus.arn
}
