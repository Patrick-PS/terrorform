


variable "Appname" {
    type = string
    description = "SVM naam"
}

variable "Environment"{
  type = string
  description = "test of prod"
  validation{
    condition = upper(var.Environment) =="TEST" || upper(var.Environment) =="PROD"
    error_message = "alleen test of prod toegestaan"
  }
}



locals{
validate_certs=false
}


locals{
 filer=   upper(var.Environment)=="PROD" ? "SomeProdFiler"    : "vartofil001"
 username=upper(var.Environment)=="PROD" ? "SomeProdUSer"     : "admin"
 password=upper(var.Environment)=="PROD" ? "SomeProdPassword" : "Welkom01"
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
      filter = {
        #name = "NA1_SSD"
       #"e06cd74e-8b98-48e2-9028-8bf3ccc2b619"
      }
   
}


resource "netapp-ontap_svm_resource" "terraformSVM" {
  cx_profile_name = "OntapProfile"
  name = "TF_${var.Appname}"
  snapshot_policy = "default"
  subtype         = "default"
  language        = "c.utf_8"
  ipspace         = "Default"
  max_volumes     = "unlimited"
  #  #aggregates = [{name = "vartofil001_01_NVME_SSD_1"},{name = "vartofil001_02_NVME_SSD_1"}]
  aggregates = data.netapp-ontap_storage_aggregates_data_source.all_aggregates.storage_aggregates
  lifecycle{
    prevent_destroy = true
  }
}

resource "netapp-ontap_storage_volume_resource" "volume_1" {
  cx_profile_name = "OntapProfile"
  svm_name = resource.netapp-ontap_svm_resource.terraformSVM.name
  aggregates = [{name=data.netapp-ontap_storage_aggregates_data_source.all_aggregates.storage_aggregates[0].name}]
    name = "${var.Appname}_Volume1"
  space = {
    size = 30
    size_unit = "mb"
  }
  depends_on = [netapp-ontap_svm_resource.terraformSVM]
  #count =0
}

resource "netapp-ontap_storage_volume_resource" "volume_2" {
  cx_profile_name = "OntapProfile"
  svm_name = resource.netapp-ontap_svm_resource.terraformSVM.name
  aggregates = [{name=data.netapp-ontap_storage_aggregates_data_source.all_aggregates.storage_aggregates[1].name}]
    name = "${var.Appname}_Volume2"
  space = {
    size = 20
    size_unit = "mb"
  }
  depends_on = [netapp-ontap_svm_resource.terraformSVM]
  #count =0
}

output  "CreatedSVM"{
  value = netapp-ontap_svm_resource.terraformSVM
}

output "CreatedVol"{
 value = [resource.netapp-ontap_storage_volume_resource.volume_1.name,resource.netapp-ontap_storage_volume_resource.volume_2.name]
}
