


module "schema" {
  source = "./modules/naming-schema"

  naming = yamldecode(file("${path.root}/default.naming.yaml"))
  parameters = {
    location    = "westeurope"
    environment = "DEVELOPMENT"
    name        = "TEST"
  }
}

module "naming_01" {
  source = "./modules/naming-generator"

  schema = module.schema
  index = {
    count = 10
  }

  resource = "Azure::Microsoft.Compute/disks::os"
}


output "test" {
  value = {
    debug = module.naming_01.debug

    # schema = module.schema,

    single = module.naming_01.name

    multi = module.naming_01.by_index
  }

}
