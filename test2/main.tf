locals{
    SVMresult=module.OntapSVM.CreatedSVM
    Volresult=module.OntapSVM.CreatedVol
}

module "OntapSVM" {
  source = "../Modules/Ontap/SVMwithVolumes/0.1"
  #version = "0.1"
  Appname = "PatFirstGit"
  Environment = "TEST"

}

module "OntapSVMtwee" {
  source = "../Modules/Ontap/SVMwithVolumes/0.1"
  #version = "0.1"
  Appname = "PatSecondGit"
  Environment = "test"


}

output "svm_id"{
value=local.SVMresult.id
}

output "svm_name"{
value=local.SVMresult.name
}

output "volumes"{
value=local.Volresult
}
