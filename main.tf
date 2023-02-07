terraform {
  required_providers {
    akamai = {
      source  = "akamai/akamai"
      version = "3.3.0"
    }
  }
}

provider "akamai" {
  edgerc         = "~/.edgerc"
  config_section = "default"
}

variable "one_enabled" {
  type    = bool
  default = false
}

data "akamai_property_rules_template" "one" {
  count = var.one_enabled ? 1 : 0

  template {
    template_data = jsonencode({
      "rules" : {
        "name" : "default",
        "children" : [
          "#include:cpcode.json"
        ]
      }
    })
    template_dir = "property-snippets/"
  }
}

output "one" {
  value = var.one_enabled ? data.akamai_property_rules_template.one[0].template : null
}

variable "two_enabled" {
  type    = bool
  default = true
}

data "akamai_property_rules_template" "two" {
  count = var.two_enabled ? 1 : 0

  template {
    template_data = <<-EOT
    {
      "rules" : {
        "name" : "default",
        "behaviors": ["#include:origin.json","#include:cpcode.json"],
        "children" : []
      }
    }
    EOT
    template_dir  = "property-snippets/"
  }
}

output "two" {
  value = var.two_enabled ? data.akamai_property_rules_template.two[0].json : null
}
