#------------------------------
# LOCALS
#------------------------------

locals {
  subscription_types = {
    connectivity      = "conn"
    identity          = "id"
    management        = "mgmt"
    alz-tbd-dev-01   = "tbd"
  }
  environment = {
    alz-tbd-dev-01   = "dev"
  }
}