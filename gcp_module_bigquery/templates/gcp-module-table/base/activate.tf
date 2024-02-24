module "activate_gcp_module_table" {
  source = "../../modules/activate-gcp-module-table"

  landscape_file = var.landscape_file
  applications_file = var.applications_file
  modules_file = var.modules_file

  depends_on = [module.gcp_module_project]
}

