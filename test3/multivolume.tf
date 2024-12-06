module "SVMmetVeelVolumes" {
  source = "../modules/ontap/MultiVol/0.1"
  SVMname="PatTestVeel"
  VolCount = 2
  VolSize =21
  VolSizeUnit="mb"
}
