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
app/                          # the application being deployed
jenkins/Jenkinsfile           # Jenkins version of the pipeline
.github/workflows/deploy.yml  # GitHub Actions version of the same pipeline
```

## Notes

The GitHub Actions workflow uses OIDC role assumption
(`aws-actions/configure-aws-credentials`) instead of long-lived AWS access
keys stored as secrets — this is the current AWS-recommended pattern and
worth mentioning if asked about credential security in CI/CD.

This is a sanitized demo app; in production these same stages ran against
real ERP and CMS codebases across 30+ applications.
