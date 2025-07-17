# Hello DevOps App: CI/CD Pipeline

This repository contains a simple Node.js application and a robust Continuous Integration/Continuous Delivery (CI/CD) pipeline built using GitHub Actions to deploy the application to an AWS EC2 instance via Amazon Elastic Container Registry (ECR).

## Project Description

The `hello-devops-app` is a basic Node.js web server that serves a "Hello from DevOps!" message. The core purpose of this project is to demonstrate an automated deployment workflow: any code changes pushed to the `main` branch will automatically trigger a build, containerization, image push to ECR, and deployment to a running EC2 instance.

## Features

* **Node.js Application:** A simple web server.
* **Dockerization:** The application is containerized using Docker.
* **GitHub Actions CI/CD:** Automated workflow for building, pushing, and deploying.
* **Amazon ECR Integration:** Securely stores Docker images.
* **AWS EC2 Deployment:** Deploys the containerized application to an EC2 instance.
* **Automated Deployment:** Pushing to `main` branch triggers a full deployment.

## Technologies Used

* **Node.js:** Backend JavaScript runtime.
* **Docker:** Containerization platform.
* **GitHub Actions:** CI/CD platform.
* **AWS EC2:** Virtual servers in the cloud.
* **AWS ECR:** Managed Docker container registry.
* **AWS IAM:** Identity and Access Management for secure access.
* **SSH:** Secure shell for remote command execution.

## Architecture Overview

The pipeline operates as follows:

1.  **Code Commit:** A developer pushes code changes to the `main` branch of this GitHub repository.
2.  **GitHub Actions Trigger:** The push event triggers the `main.yml` workflow in GitHub Actions.
3.  **Build & Push (CI):**
    * GitHub Actions checks out the code.
    * It builds a Docker image of the Node.js application.
    * It logs into AWS ECR using provided AWS credentials (via GitHub Secrets).
    * The built Docker image is tagged and pushed to the designated ECR repository.
4.  **Deploy (CD):**
    * GitHub Actions connects to the EC2 instance via SSH using a private key (stored securely in GitHub Secrets).
    * On the EC2 instance, the Docker daemon logs into ECR (using an IAM role attached to the EC2 instance).
    * Any existing `hello-node-app` Docker container is stopped and removed.
    * The latest Docker image is pulled from ECR.
    * A new Docker container is run from the pulled image, mapping port 80 on the EC2 instance to port 3000 inside the container.

```mermaid
graph TD
    A[Developer Push Code] --> B(GitHub Repository)
    B -- Trigger --> C(GitHub Actions Workflow)
    C -- Build Docker Image --> D(Docker Image)
    D -- Push to ECR --> E(AWS ECR)
    C -- SSH Connect (using SSH_PRIVATE_KEY) --> F(AWS EC2 Instance)
    E -- Pull Image (using EC2 IAM Role) --> F
    F -- Run Docker Container --> G(Node.js App Running)
    G -- Accessible via HTTP Port 80 --> H[User Browser]
Setup and Deployment
Follow these steps to set up and deploy your hello-devops-app.

Prerequisites
An AWS Account with administrative access.

A GitHub Account.

AWS CLI installed and configured locally (for initial ECR setup).

Docker installed locally (optional, for local testing).

Git installed locally.

1. AWS Setup
a. EC2 Instance
Launch a new EC2 instance (e.g., t2.micro running Amazon Linux 2 AMI).

Security Group: Create or configure a security group for your EC2 instance with the following inbound rules:

Type: SSH (Port 22) | Source: 0.0.0.0/0 (or your specific IP)

Type: HTTP (Port 80) | Source: 0.0.0.0/0

Type: Custom TCP (Port 3000) | Source: 0.0.0.0/0 (for internal testing/debugging, though 80 is mapped externally)

Key Pair: Create a new EC2 Key Pair (e.g., devops-key.pem) during instance launch. You will use this to connect via SSH.

b. ECR Repository
Navigate to ECR in the AWS Console.

Click "Create repository".

Give it a name (e.g., hello-node-app). Keep other settings as default.

Note down the Repository URI (e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com/hello-node-app). This is your ${{ env.ECR_REGISTRY }}/${{ env.ECR_REPOSITORY }}.

c. IAM Role for EC2
Navigate to IAM in the AWS Console.

Go to "Roles" and click "Create role".

Trusted entity: AWS service -> EC2.

Permissions: Attach the AmazonEC2ContainerRegistryReadOnly policy. (Optionally, CloudWatchLogsFullAccess for better logging).

Role name: Give it a name like EC2-ECR-Pull-Role.

Attach Role to EC2: Go back to your EC2 instance details, select it, go to Actions > Security > Modify IAM role, and select the EC2-ECR-Pull-Role.

2. GitHub Repository Setup
a. Fork/Clone this Repository
Fork this repository to your GitHub account or create a new one and copy the files.

b. Generate SSH Key for GitHub Actions
On your local machine, generate a new SSH key pair without a passphrase:

Bash

ssh-keygen -t rsa -b 4096 -f ~/.ssh/github_actions_id_rsa -N ""
Copy the Public Key:

Bash

cat ~/.ssh/github_actions_id_rsa.pub
Copy the entire output.

Add Public Key to EC2: Connect to your EC2 instance via SSH (using your devops-key.pem).

Create the .ssh directory if it doesn't exist: mkdir -p ~/.ssh

Set permissions: chmod 700 ~/.ssh

Add the public key to authorized_keys:

Bash

echo "PASTE_YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
(Replace PASTE_YOUR_PUBLIC_KEY_HERE with the content you copied from github_actions_id_rsa.pub).

Set permissions for authorized_keys: chmod 600 ~/.ssh/authorized_keys

c. Configure GitHub Secrets
In your GitHub repository, go to Settings > Secrets and variables > Actions.

Click "New repository secret" and add the following:

AWS_ACCESS_KEY_ID: Your AWS Access Key ID (from an IAM user with ECR push/pull permissions).

AWS_SECRET_ACCESS_KEY: Your AWS Secret Access Key.

SSH_PRIVATE_KEY: The entire content of your local ~/.ssh/github_actions_id_rsa file (including -----BEGIN... and -----END... lines). Ensure no extra spaces or newlines.

d. Update main.yml
Open .github/workflows/main.yml in your GitHub repository.

Update Environment Variables:

ECR_REGISTRY: Replace with your ECR Repository URI (e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com).

ECR_REPOSITORY: Replace with your ECR Repository Name (e.g., hello-node-app).

AWS_REGION: Set to your AWS region (e.g., us-east-1).

EC2_INSTANCE_IP: Crucially, update this with the CURRENT Public IPv4 address of your running EC2 instance. (This changes if you stop/start your instance).

SSH_USER: Set to ec2-user for Amazon Linux.

Ensure the script block under Deploy to EC2 is correct and has proper YAML indentation:

YAML

      script: |
        # Log in to ECR from the EC2 instance
        aws ecr get-login-password --region ${{ env.AWS_REGION }} | docker login --username AWS --password-stdin ${{ env.ECR_REGISTRY }}

        # Stop and remove the old container if it's running or exists
        docker stop hello-node-app || true
        docker rm hello-node-app || true

        # Pull the latest Docker image (now authenticated)
        docker pull ${{ env.ECR_REGISTRY }}/${{ env.ECR_REPOSITORY }}:${{ env.IMAGE_TAG }}

        # Run the new container, mapping port 80 to 3000
        docker run -d -p 80:3000 --name hello-node-app ${{ env.ECR_REGISTRY }}/${{ env.ECR_REPOSITORY }}:${{ env.IMAGE_TAG }}
3. Deployment Process
Once all the above setup is complete, any git push to the main branch of your GitHub repository will automatically:

Trigger the GitHub Actions workflow.

Build and push the Docker image to ECR.

Connect to your EC2 instance.

Log Docker into ECR on EC2.

Stop/remove old containers.

Pull the latest image.

Run the new container.

Monitor the "Actions" tab in your GitHub repository to see the workflow progress. A green checkmark indicates a successful deployment.

Usage
After a successful deployment, open your web browser and navigate to the Public IPv4 address of your EC2 instance.

Example: http://3.92.191.37 (replace with your actual EC2 IP).

You should see the "Hello from DevOps! Your Node.js app is running." message.

Troubleshooting Common Issues
dial tcp <IP>:22: i/o timeout:

Cause: GitHub Actions cannot reach your EC2 instance via SSH.

Fix:

Your EC2 instance's Public IP address has changed. Get the current IP from AWS Console and update EC2_INSTANCE_IP in main.yml.

EC2 Security Group inbound rules do not allow SSH (Port 22) from 0.0.0.0/0. Add/correct the rule.

ssh: handshake failed: ssh: unable to authenticate... no supported methods remain:

Cause: The SSH_PRIVATE_KEY in GitHub Secrets is incorrect or corrupted, or the public key on EC2 is incorrect/has wrong permissions.

Fix:

Carefully re-copy your ~/.ssh/github_actions_id_rsa private key (entire content, no extra spaces/newlines) and re-add it to GitHub Secrets.

On EC2, verify ~/.ssh/authorized_keys contains only the correct public key and has chmod 600. Ensure ~/.ssh has chmod 700.

Error response from daemon: no basic auth credentials / Unable to locate credentials on EC2:

Cause: The Docker daemon on your EC2 instance cannot authenticate with ECR to pull the image.

Fix: The IAM role attached to your EC2 instance does not have AmazonEC2ContainerRegistryReadOnly permissions. Create/attach this IAM role to your EC2 instance.

Error in your yaml syntax on line X:

Cause: Incorrect indentation or syntax in your main.yml file.

Fix: Carefully review the main.yml file, especially the script: block, and ensure all lines have the correct YAML indentation (2 spaces for each nested level).

Browser shows "Refused to connect" or "This site can't be reached" but workflow is green:

Cause: The Docker container is not running or the Node.js application inside it is crashing immediately after startup.

Fix:

Get the current EC2 Public IP address and ensure it's used in the browser.

Connect to EC2 via SSH. Run docker ps -a to see if hello-node-app exited.

Run docker logs hello-node-app (or the container ID/name if different) to see the application's internal logs and identify startup errors.

Ensure your Dockerfile uses CMD ["node", "index.js"] to keep the Node.js process in the foreground.
