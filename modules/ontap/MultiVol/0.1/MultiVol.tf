variable "VolCount" {
    type = number
    description = "Number of volumes"
    default = 2
}

variable "VolSize" {
    type = number
    description = "Size of each volume"
    default =20
}

variable "VolSizeUnit" {
    type = string
    description = "mb /gb /tb"
    default="mb"
    validation{
    condition = lower(var.VolSizeUnit) =="mb" || lower(var.VolSizeUnit) =="gb" || lower(var.VolSizeUnit) =="tb"
    error_message = "alleen mb gb tb toegestaan"
  }
}

variable "SVMname" {
    type = string
    description = "SVM name"
    default="GreedyMoFo"
}


locals{
 validate_certs=false
 filer="vartofil001"
 username="admin"
 password="Welkom01"
}




 
terraform {
  required_providers {
    netapp-ontap = {
      source = "NetApp/netapp-ontap"
      version = "1.1.4"
    }
  }
}

provider "netapp-ontap" {
  # Configuration options
  connection_profiles = [
    {
      name = "OntapProfile"
      hostname = local.filer
      username = local.username
      password = local.password
      validate_certs = local.validate_certs
    }
	]
}

data "netapp-ontap_storage_aggregates_data_source" "all_aggregates" {
    # required to know which system to interface with
    cx_profile_name = "OntapProfile"
}


resource "netapp-ontap_svm_resource" "baseSVM" {
  cx_profile_name = "OntapProfile"
  name = var.SVMname
  snapshot_policy = "default"
  subtype         = "default"
  language        = "c.utf_8"
  ipspace         = "Default"
  max_volumes     = "unlimited"
  aggregates = data.netapp-ontap_storage_aggregates_data_source.all_aggregates.storage_aggregates
}


resource "netapp-ontap_storage_volume_resource" "volumes" {
  cx_profile_name = "OntapProfile"
  svm_name = resource.netapp-ontap_svm_resource.baseSVM.name
  aggregates = [{name=data.netapp-ontap_storage_aggregates_data_source.all_aggregates.storage_aggregates[0].name}]
  name = "${resource.netapp-ontap_svm_resource.baseSVM.name}_Volume${count.index+1}"
  space = {
    size = var.VolSize
    size_unit = var.VolSizeUnit
  }
  space_guarantee="none"
  nas={
    junction_path="/${resource.netapp-ontap_svm_resource.baseSVM.name}_Volume${count.index+1}"
  }
  
  depends_on = [netapp-ontap_svm_resource.baseSVM]
  count = var.VolCount
}
