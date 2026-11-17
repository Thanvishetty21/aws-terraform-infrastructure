#!/bin/bash
# Bootstraps an Amazon Linux 2023 instance with Nginx and a simple status page.
set -euxo pipefail

dnf update -y
dnf install -y nginx

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>Provisioned with Terraform</title></head>
<body style="font-family: sans-serif; text-align: center; margin-top: 10%;">
  <h1>Deployed with Terraform on AWS</h1>
  <p>Instance: <b>${INSTANCE_ID}</b></p>
  <p>Availability Zone: <b>${AZ}</b></p>
</body>
</html>
EOF

systemctl enable --now nginx
