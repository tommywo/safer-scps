provider "aws" {
  region = "us-east-1"
}

# Management account resources
module "bus" {
  source = "./modules/bus"
  
  # Use your organization ID
  org_id = "o-123456789101"
}

# Member account resources
module "rules" {
  source = "./modules/rules"
  
  # Reference the event bus ARN from the bus module output
  event_bus_arn = module.bus.event_bus_arn
}
