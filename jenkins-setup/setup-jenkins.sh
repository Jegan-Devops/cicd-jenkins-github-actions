#!/bin/bash
# =============================================================================
# Jenkins + Tools Automated Setup Script
# Run this on a fresh Ubuntu EC2 (t3.medium recommended) as the ubuntu user:
#   chmod +x setup-jenkins.sh && sudo ./setup-jenkins.sh
# =============================================================================

set -e  # exit immediately if any command fails

echo "==> [1/7] Installing system dependencies..."
apt-get update -y
apt-get install -y \
    openjdk-17-jdk \
    docker.io \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    unzip \
    git

echo "==> [2/7] Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
    | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/" \
    | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update -y
apt-get install -y jenkins

echo "==> [3/7] Installing AWS CLI v2..."
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/awscliv2.zip /tmp/aws

echo "==> [4/7] Installing Trivy..."
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
    | sh -s -- -b /usr/local/bin

echo "==> [5/7] Configuring Docker..."
# Add jenkins user to docker group so pipeline can run docker commands
# without sudo — without this, every docker command in the Jenkinsfile fails
usermod -aG docker jenkins
systemctl enable docker
systemctl start docker

echo "==> [6/7] Starting Jenkins..."
systemctl enable jenkins
systemctl start jenkins

# Wait for Jenkins to fully start before printing credentials
echo "    Waiting 30 seconds for Jenkins to initialize..."
sleep 30

echo "==> [7/7] Setup complete!"
echo ""
echo "============================================================"
echo "  Jenkins is running at: http://$(curl -s ifconfig.me):8080"
echo ""
echo "  Initial admin password:"
cat /var/lib/jenkins/secrets/initialAdminPassword
echo ""
echo "  NEXT STEPS:"
echo "  1. Open the URL above in your browser"
echo "  2. Enter the password shown above"
echo "  3. Install suggested plugins"
echo "  4. Add your AWS_ACCOUNT_ID credential:"
echo "     Manage Jenkins → Credentials → Global → Add Credential"
echo "     Kind: Secret text | ID: AWS_ACCOUNT_ID | Value: your 12-digit account ID"
echo "  5. Add a new Pipeline item pointing to your GitHub repo"
echo "     Script Path: jenkins/Jenkinsfile"
echo "============================================================"
