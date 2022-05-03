### New Relic Provider

variable "account_id" {
  description = "The ID of your New Relic account in which the resources shall be created."
  sensitive = true
  type = number
}

variable "api_key" {
  description = "Your personal API key from New Relic. Normally prefixed with NRAK-"
  sensitive = true
  type = string
}

variable "region" {
  default = "US"
  description = "The region in which your New Relic account is hosted. Options are EU and US. Default is US."
  type = string
}

### Dashboard functionality

variable "cpu_limit_margin" {
  default = 100
  description = "The percentage to keep as a margin for CPU above the TP95 consumption for the resource limit. Default is 100."
  type = number
}

variable "cpu_request_margin" {
  default = 50
  description = "The percentage to keep as a margin for CPU above the TP95 consumption for the resource request. Default is 100."
  type = number
}

variable "memory_limit_margin" {
  default = 100
  description = "The percentage to keep as a margin for Memory above the TP95 consumption for the resource limit. Default is 100."
  type = number
}

variable "memory_request_margin" {
  default = 50
  description = "The percentage to keep as a margin for Memory above the TP95 consumption for the resource request. Default is 100."
  type = number
}