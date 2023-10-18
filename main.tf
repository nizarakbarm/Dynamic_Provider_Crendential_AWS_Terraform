// Create OIDC
variable "terraform_cloud_address" {
    type = string
    default = "app.terraform.io"
}
resource "aws_iam_openid_connect_provider" "terraform_cloud_oidc" {
    url = "https://${var.terraform_cloud_address}"
    client_id_list = [ "aws.workload.identity" ]
    thumbprint_list = [ "9e99a48a9960b14926bb7f3b02e22da2b0ab7280" ]
}

resource "aws_iam_role" "oidc_role" {
    name = "oidc-role"
    assume_role_policy = jsonencode(
        {
            Version = "2012-10-17"
            Statement = [
                {
                    Effect = "Allow"
                    Principal = {
                        Federated = resource.aws_iam_openid_connect_provider.terraform_cloud_oidc.arn
                    }
                    Action = "sts:AssumeRoleWithWebIdentity"
                    Condition = {
                        StringEquals = {
                            "${var.terraform_cloud_address}:aud" = resource.aws_iam_openid_connect_provider.terraform_cloud_oidc.client_id_list
                            "${var.terraform_cloud_address}:sub" = "organization:findnull:project:*:workspace:LearnEKSTerraform:run_phase:*"
                        }
                    } 
                },
            ]
        }
    )
    depends_on = [ aws_iam_openid_connect_provider.terraform_cloud_oidc ]
}

resource "aws_iam_role_policy" "oidc_policy_one" {
    name = "learneks-policy"
    role = aws_iam_role.oidc_role.id
    
    policy = jsonencode(
        {
            Version = "2012-10-17"
            Statement = [
                {
                    Action = [ "eks:*", "ec2:*", "iam:*", "sts:*"]
                    Effect = "Allow"
                    Resource = "*"
                },
            ]
        }
    )
    depends_on = [ aws_iam_role.oidc_role ]
}
output "oidc_role_arn" {
  value = aws_iam_role.oidc_role.arn
}