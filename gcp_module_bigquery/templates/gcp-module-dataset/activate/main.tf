locals {
  module_name = replace(substr(basename(path.module), 9, length(basename(path.module)) - 9), "-", "_")
  landscape = yamldecode(file(var.landscape_file))
  applications = yamldecode(file(var.applications_file))
  project_prefix = local.landscape["settings"]["project_prefix"]
  environment_dict = local.landscape["environments"]
  application_list = local.landscape["modules"][local.module_name]["applications"]
}

locals {
  all_role_attribution = toset(flatten([
    for env_name, env in local.environment_dict : [
      for app_name in local.application_list : {
        app_name          = app_name
        env_name          = env_name
        project_id        = "${local.project_prefix}${env_name}"
      }
    ]
  ]))
}

resource "google_project_iam_custom_role" "gcp_module_dataset_deployer_role" {
  for_each = local.environment_dict

  project     = "${local.project_prefix}${each.key}"
  role_id     = "gcpModuleDatasetDeployer"
  title       = "GCP Bigquery Dataset Deployer Role"
  description = "GCP Bigquery Dataset Deployer Role"
  permissions = [
    "bigquery.datasets.create",
    "bigquery.datasets.get",
    "bigquery.datasets.update",
    "bigquery.datasets.delete"
  ]
}

resource "google_project_iam_member" "gcp_module_table_dataset_role_member" {
  for_each = { for s in local.all_role_attribution : "${s.app_name}-${s.env_name}" => s }

  project = each.value["project_id"]
  role    = google_project_iam_custom_role.gcp_module_dataset_deployer_role[each.value["env_name"]].id
  member  = "serviceAccount:wip-${each.value["app_name"]}-sa@${each.value["project_id"]}.iam.gserviceaccount.com"

  depends_on = [google_project_iam_custom_role.gcp_module_dataset_deployer_role]
}