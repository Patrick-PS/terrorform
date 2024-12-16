locals{
    Aggr4Volume= tolist(module.NieuweSVM.result.aggregates)[0].name
}

module "NieuweSVM" {
  source = "../modules/ontap/SVM/0.1"
  
  SVMname="PatTestWeer"
}


module "NieuwVolume" {
  source = "../modules/ontap/Volume/0.1"
  
  SVMname=module.NieuweSVM.result.name
  Aggrname=local.Aggr4Volume
  Volumename="NogEenVolume"
  VolSize=100
  VolSizeUnit="GB"
}

