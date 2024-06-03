#------------------------------
# LOCALS
#------------------------------

# TODO: - these locals are only used for name convention overrides
locals {
  application_names = {
    # subscription_activity_log_settings                    = "conn"
    # resource_group_sdwan                                = "sdwan"
    resource_group_vwan                                 = "vwan"
    resource_group_alert_rules                          = "alert_rules"
    #log_analytics_workspace                             = "shared"
    #log_analytics_workspace_diagnostic_settings         = "log"
    firewall_diagnostic_settings                        = "afw"
    # TODO: add local application_names for remaining resource calls once they are module calls
  }
  diagnostic_settings = {
    logs_to_exclude     = []
    metrics_to_exclude  = []
    retention_days      = "7"
  }
}