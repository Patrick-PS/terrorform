variable "SVMname" {
    type = string
    description = "SVM naam"
}


module "TestCreds" {
  source = "../../Filers/vartofil001"
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
      hostname =       module.TestCreds.Auth.filer
      username =       module.TestCreds.Auth.username
      password =       module.TestCreds.Auth.password
      validate_certs = module.TestCreds.Auth.validate_certs
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
  name = var.SVMname
  snapshot_policy = "default"
  subtype         = "default"
  language        = "c.utf_8"
  ipspace         = "Default"
  max_volumes     = "unlimited"
  #  #aggregates = [{name = "vartofil001_01_NVME_SSD_1"},{name = "vartofil001_02_NVME_SSD_1"}]
  aggregates = data.netapp-ontap_storage_aggregates_data_source.all_aggregates.storage_aggregates
  lifecycle{
    #prevent_destroy = true
  }
}



output  "CreatedSVM"{
  value = netapp-ontap_svm_resource.terraformSVM
}