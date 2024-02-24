module "gcp_module_table" {
  source = "../../modules/gcp-module-table"

  landscape_file = "../../../config/landscape.yaml"
  applications_file = "../../../config/applications.yaml"

  depends_on = [module.gcp_module_project]
}
