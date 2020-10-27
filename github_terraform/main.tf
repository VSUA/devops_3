provider "github" {
  token = "${var.github_token}"
}

resource "github_repository" "test-terraform" {
  name = "test_terraform"
  auto_init = true
  visibility = "public"
}

resource "github_branch_protection" "protect" {
  repository_id = github_repository.test-terraform.node_id
  pattern = "main" 
}

resource "github_user_ssh_key" "VM" {
  title = "VM"
  key   = file("~/.ssh/id_rsa.pub")
}

resource "github_branch" "dev" {
  repository = "test_terraform"
  branch     = "dev"
  source_branch = "main"
  depends_on = [github_repository.test-terraform]
}
