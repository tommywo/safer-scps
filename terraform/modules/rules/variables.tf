variable "event_bus_arn" {
  description = "ARN of the event bus in the management account"
  type        = string
  default     = "arn:aws:events:us-east-1:123456789101:event-bus/scp-errors-event-bus"
}
