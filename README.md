Brain-Tasks-App README

Overview

This repository contains the source code and configuration for the Brain-Tasks-App, a web application deployed on Amazon Elastic Kubernetes Service (EKS) using a CI/CD pipeline powered by AWS CodeBuild and Amazon ECR for container management. The full code repository is available at https://github.com/dineshpowercloud/Brain-Tasks-App.

Setup Instructions

Prerequisites





AWS Account: Ensure you have an AWS account with appropriate permissions (e.g., IAM user with powerusergd credentials).



AWS CLI: Installed and configured with credentials (aws configure).



kubectl: Installed for interacting with the EKS cluster (curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/).



Docker: Installed for building container images.



Git: Installed and cloned this repository (git clone https://github.com/dineshpowercloud/Brain-Tasks-App).

Step-by-Step Setup





Configure AWS Credentials





Run aws configure and input your Access Key ID, Secret Access Key, region (us-east-1), and output format (json) for the powerusergd IAM user.



Set Up IAM Role





Create an IAM role named codebuild-brain-tasks-build-service-role:





Trust Policy:

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}



Inline Policy (CodeBuildEKSDeployPolicy):

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ],
      "Resource": "arn:aws:eks:us-east-1:342137541267:cluster/brain-tasks-cluster"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:us-east-1:342137541267:log-group:/aws/codebuild/brain-tasks-pipeline:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::codepipeline-us-east-1-*"
    }
  ]
}



Attach the policy to the role via the AWS Console.



Configure CodeBuild Project





In the AWS Console, go to CodeBuild > Create build project.



Name: brain-tasks-pipeline.



Source: GitHub (link to this repo).



Environment: Managed image (e.g., aws/codebuild/standard:5.0).



Service role: arn:aws:iam::342137541267:role/codebuild-brain-tasks-build-service-role.



Buildspec: Use the existing buildspec.yml in the repo.



Save and trigger a build.



Set Up EKS Cluster





Ensure the brain-tasks-cluster exists in us-east-1.



Update kubeconfig:

aws eks update-kubeconfig --name brain-tasks-cluster --region us-east-1 --role-arn arn:aws:iam::342137541267:role/codebuild-brain-tasks-build-service-role



Map the role in the aws-auth ConfigMap (via admin access if needed):

- rolearn: arn:aws:iam::342137541267:role/codebuild-brain-tasks-build-service-role
  username: build
  groups:
  - system:masters



Deploy the Application





Push changes to the repo to trigger the CodeBuild pipeline.



Verify deployment with:

kubectl get pods
kubectl get svc



Access the app via the LoadBalancer ARN: http://a272051ea458e4451bf3525cd4b84e7c-523441450.us-east-1.elb.amazonaws.com.

Pipeline Explanation

CI/CD Pipeline Overview

The CI/CD pipeline is implemented using AWS CodeBuild, automating the build, test, and deployment of the Brain-Tasks-App to an EKS cluster.





Source Stage:





Triggers on git push to the main branch from the GitHub repository.



Pulls the latest code and buildspec.yml.



Build Stage:





Installs kubectl for EKS interaction.



Logs into Amazon ECR and builds a Docker image tagged with the latest version.



Pushes the image to 342137541267.dkr.ecr.us-east-1.amazonaws.com/brain-tasks-app:latest.



Post-Build Stage:





Generates an imagedefinitions.json file with the image URI.



Updates the EKS kubeconfig with the codebuild-brain-tasks-build-service-role.



Applies the deployment.yaml and service.yaml to deploy the app to the brain-tasks-cluster.

Pipeline Flow





Code Commit: Changes are pushed to GitHub.



Build Trigger: CodeBuild starts the build process.



Image Build and Push: Docker image is built and pushed to ECR.



Deployment: Kubernetes resources are applied to EKS, and the app becomes accessible via the LoadBalancer.

Monitoring





Check build status and logs in the AWS CodeBuild console.



Monitor pod and service status with kubectl get pods and kubectl get svc.

Screenshots and Documentation





Screenshots: Add screenshots of the following to a separate document (e.g., screenshots.pdf) or embed them here:





AWS CodeBuild pipeline execution (successful build).



EKS cluster dashboard showing deployed pods.



LoadBalancer URL access in a browser.



kubectl get pods and kubectl get svc command outputs.

