#!/bin/bash
# verify-cli.sh
# Verifies the AWS CLI is installed, configured, and working.
# Run this after completing the aws configure setup.
#
# Usage: bash verify-cli.sh

set -e

echo "========================================"
echo " AWS CLI Verification"
echo "========================================"
echo ""

# Check CLI is installed
echo "1. AWS CLI Version:"
if command -v aws &>/dev/null; then
  aws --version
else
  echo "   ERROR: AWS CLI is not installed."
  echo "   Install it: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
  exit 1
fi

echo ""

# Check credentials are configured
echo "2. Credentials configured:"
if [ -f "$HOME/.aws/credentials" ] || [ -n "$AWS_ACCESS_KEY_ID" ]; then
  echo "   Credentials file found or env vars set."
else
  echo "   WARNING: No credentials found."
  echo "   Run: aws configure"
  exit 1
fi

echo ""

# Verify identity
echo "3. Current identity (aws sts get-caller-identity):"
IDENTITY=$(aws sts get-caller-identity 2>&1)
if echo "$IDENTITY" | grep -q "Account"; then
  echo "$IDENTITY" | python3 -m json.tool 2>/dev/null || echo "$IDENTITY"
else
  echo "   ERROR: Could not authenticate."
  echo "   $IDENTITY"
  exit 1
fi

echo ""

# Show configured region
echo "4. Configured region:"
REGION=$(aws configure get region 2>/dev/null || echo "not set")
echo "   $REGION"

echo ""

# List instances
echo "5. EC2 Instances in $REGION:"
aws ec2 describe-instances \
  --query "Reservations[].Instances[].{ID:InstanceId,State:State.Name,Type:InstanceType,IP:PublicIpAddress}" \
  --output table 2>/dev/null || echo "   Error listing instances — check permissions."

echo ""
echo "========================================"
echo " All checks passed. AWS CLI is working."
echo "========================================"
