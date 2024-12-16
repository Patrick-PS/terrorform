locals{
  Creds={
      filer = "vartofil001"
      username = "admin"
      password = "Welkom01"
      validate_certs=false
    }
}


output "Auth"{
 value = local.Creds
}