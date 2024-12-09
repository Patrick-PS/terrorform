module "SVMmetVeelVolumes" {
  source = "../modules/ontap/MultiVol/0.1"
  SVMname="PatTestVeel"
  VolCount = 20
  VolSize =30
  VolSizeUnit="mb"
}
