output "event_bus_arn" {
  description = "ARN of the event bus"
  value       = aws_cloudwatch_event_bus.scp_errors.arn
}
