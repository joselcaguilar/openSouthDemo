variable "acrResourceName" {
  description = "Specifies the name of the Azure resource"
  type        = string
  default     = "opensouthcode23jl"
}

variable "umiResourceName" {
  description = "Specifies the name of the Azure resource"
  type        = string
  default     = "opensouthcode23jl"
}

variable "resourceGroup" {
  description = "Resource group where the resource will be deployed"
  type        = string
  default     = "spoke-opensouthcode"
}

variable "location" {
  description = "Region where the resources will be deployed"
  type        = string
  default     = "West Europe"
}

variable "spnSparkObjectId" {
  description = "Object Id of the SPN who is deploying"
  type        = string
  default     = "d13b8f6d-2a66-4d60-a758-2376805adddd"
}
