#!/usr/bin/env bash
set -euo pipefail
 
SECRET_NAME="${1:?Usage: $0 <secret-name> [max-age-days]}"
MAX_AGE_DAYS="${2:-90}"
AWS_REGION="${AWS_REGION:-us-east-1}"
 
echo "Checking rotation age for: $SECRET_NAME"
echo "Maximum allowed age: $MAX_AGE_DAYS days"
echo "---"
 
METADATA=$(aws secretsmanager describe-secret \
  --secret-id "$SECRET_NAME" \
  --region "$AWS_REGION" \
  --output json)
 
LAST_CHANGED=$(echo "$METADATA" | jq -r '.LastChangedDate // .CreatedDate')
SECRET_ARN=$(echo "$METADATA" | jq -r '.ARN')
 
LAST_CHANGED_EPOCH=$(date -d "$LAST_CHANGED" +%s 2>/dev/null \
  || date -j -f "%Y-%m-%dT%H:%M:%S" "$(echo "$LAST_CHANGED" | cut -d. -f1)" +%s 2>/dev/null)
NOW_EPOCH=$(date +%s)
 
AGE_DAYS=$(( (NOW_EPOCH - LAST_CHANGED_EPOCH) / 86400 ))
 
echo "Secret ARN:    $SECRET_ARN"
echo "Last changed:  $LAST_CHANGED"
echo "Age:           $AGE_DAYS days"
 
if [ "$AGE_DAYS" -gt "$MAX_AGE_DAYS" ]; then
  echo ""
  echo "WARNING: Secret is $AGE_DAYS days old (limit: $MAX_AGE_DAYS days)"
  echo "ACTION REQUIRED: Rotate this secret immediately."
  exit 1
else
  echo ""
  echo "OK: Secret is within the $MAX_AGE_DAYS-day rotation window."
  exit 0
fi