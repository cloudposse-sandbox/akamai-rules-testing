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
  default = true
}

## This example is straight out of the docs at https://registry.terraform.io/providers/akamai/akamai/latest/docs/data-sources/property_rules_template
## and does not work. 
##
## The error is:
## │ Error: template: main:1: unexpected "]" in template clause
## │
## │   with data.akamai_property_rules_template.one[0],
## │   on main.tf line 22, in data "akamai_property_rules_template" "one":
## │   22: data "akamai_property_rules_template" "one" {
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

## This example works as long as behaviors only includes one include. As soon as you include more than one include, 
## the error below is thrown:
##
## │ Error: template: main:4: unexpected "," in template clause
## │
## │   with data.akamai_property_rules_template.two[0],
## │   on main.tf line 47, in data "akamai_property_rules_template" "two":
## │   47: data "akamai_property_rules_template" "two" {
## │
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
