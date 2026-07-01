# CI/CD Pipeline: Jenkins + GitHub Actions

The same build → test → security scan → push → deploy pipeline implemented
twice — once in Jenkins, once in GitHub Actions — deploying a small Flask app
to Amazon ECS. Mirrors the CI/CD pipelines I built for 30+ applications,
cutting release cycle time from days to hours.

## Problem

Manual deployments are slow and error-prone, and a single CI/CD tool choice
can lock a team in. Understanding the same pipeline pattern across multiple
tools is what actually transfers between jobs — not memorized Jenkins or
Actions syntax in isolation.

## Solution

Both pipelines run identical stages:

1. **Install & test** — `pytest` runs against the Flask app
2. **Build** — Docker image built from the app's `Dockerfile`
3. **Security scan** — Trivy scans the image and **fails the build** on any
   CRITICAL CVE, before the image ever reaches a registry
4. **Push** — image pushed to Amazon ECR
5. **Deploy** — `aws ecs update-service --force-new-deployment` triggers ECS
   to perform a rolling replacement of running tasks — zero-downtime by
   default, since ECS won't kill old tasks until new ones pass their health
   check

## Tech Used

Jenkins (Jenkinsfile, declarative pipeline), GitHub Actions, Docker, Trivy,
Amazon ECR, Amazon ECS, Flask, pytest

## Folder Structure

```
app/                              # Flask app + tests + Dockerfile
ecs/task-definition.json          # reference task definition (managed by Terraform now)
terraform-ecs-infra/              # one-time infra: ECR, ECS cluster, task def, service, IAM, logs
jenkins/Jenkinsfile               # Jenkins version of the pipeline
.github/workflows/deploy.yml      # GitHub Actions version of the same pipeline
```

## Usage — fully automated, zero manual AWS setup

**Step 1: Provision all infrastructure with Terraform**
```bash
cd terraform-ecs-infra
terraform init
terraform apply
```
This single command creates: VPC + subnets, ECR repo (with lifecycle policy), ECS
cluster (with Container Insights), IAM execution + task roles, CloudWatch log
group, ECS task definition, and the Fargate service — nothing clicked in the
console.

**Step 2: Add GitHub Secrets** (only two, one-time)

Go to repo → Settings → Secrets → Actions:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

**Step 3: Push to main — pipeline runs automatically**
```bash
git push origin main
```
GitHub Actions: tests → builds Docker image → pushes to ECR → registers new
task definition revision with the new image → deploys to ECS → waits for
service to stabilize.

**Step 4: Verify the deployment**
```bash
# Get the running task's public IP
TASK_ARN=$(aws ecs list-tasks --cluster demo-cluster --region ap-south-1 \
  --query "taskArns[0]" --output text)

TASK_IP=$(aws ecs describe-tasks --cluster demo-cluster --tasks $TASK_ARN \
  --region ap-south-1 \
  --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" \
  --output text | xargs -I{} aws ec2 describe-network-interfaces \
  --network-interface-ids {} --region ap-south-1 \
  --query "NetworkInterfaces[0].Association.PublicIp" --output text)

curl http://$TASK_IP:5000/health
```

## Notes

The GitHub Actions workflow uses OIDC role assumption
(`aws-actions/configure-aws-credentials`) instead of long-lived AWS access
keys stored as secrets — this is the current AWS-recommended pattern and
worth mentioning if asked about credential security in CI/CD.

This is a sanitized demo app; in production these same stages ran against
real ERP and CMS codebases across 30+ applications.
