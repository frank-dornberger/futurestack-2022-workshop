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