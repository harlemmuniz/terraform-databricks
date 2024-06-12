variable "key_vault_url" {}
variable "token" {}
variable "host" {}
variable "databricks_url" {}
variable "ambiente" {}
variable "destinatarios_alertas" {
  type = list(string)
  default = [
    "mail.to.alert.1@mail.com",
    "mail.to.alert.2@mail.com"
  ]
}
variable "destinatarios_alertas_streaming" {
  type = list(string)
  default = [
    "mail.to.alert.1@mail.com"
  ]
}
variable "webhook_destinations" {
  type = list(string)
  default = []
  # default = [
  #   "8af5c854-10a7-42bc-b6dc-9f129778b855" # Notification Destination ID created
  # ]
}