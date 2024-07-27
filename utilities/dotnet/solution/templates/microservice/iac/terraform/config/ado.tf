resource "azuredevops_build_definition" "service_builds" {
  project_id = local.solution_project_id
  name       = "Solution.Context"

  ci_trigger {
    override {
      branch_filter {
        include = ["master"]
      }
      path_filter {
        include = ["microservices/Solution.Context"]
      }
    }
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = local.solution_repo_id
    branch_name = "refs/heads/master"
    yml_path    = "templates/Solution.Context.yml"
  }
}