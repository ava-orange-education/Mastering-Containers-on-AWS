#!/bin/bash
# Velero Backup and Restore for Cluster Migration
# Book: Mastering Container Architectures on AWS - Chapter 12
set -euo pipefail

ACTION="${1:?Usage: $0 <backup|restore> [namespace]}"
NAMESPACE="${2:-}"
BACKUP_NAME="migration-$(date +%Y%m%d-%H%M%S)"
BUCKET="my-velero-backups"
REGION="${AWS_REGION:-us-east-1}"

case "$ACTION" in
  backup)
    echo "=== Creating Velero Backup ==="
    if [ -n "$NAMESPACE" ]; then
        echo "Backing up namespace: $NAMESPACE"
        velero backup create "$BACKUP_NAME" \
            --include-namespaces "$NAMESPACE" \
            --snapshot-volumes=true \
            --wait
    else
        echo "Backing up entire cluster..."
        velero backup create "$BACKUP_NAME" \
            --snapshot-volumes=true \
            --wait
    fi
    echo "Backup complete: $BACKUP_NAME"
    velero backup describe "$BACKUP_NAME"
    ;;

  restore)
    BACKUP_TO_RESTORE="${NAMESPACE:-$BACKUP_NAME}"
    echo "=== Restoring from Velero Backup ==="
    echo "Backup: $BACKUP_TO_RESTORE"
    velero restore create --from-backup "$BACKUP_TO_RESTORE" --wait
    echo "Restore complete."
    velero restore describe "$(velero restore get -o json | python3 -c 'import sys,json; print(json.load(sys.stdin)["items"][-1]["metadata"]["name"])')"
    ;;

  *)
    echo "Unknown action: $ACTION"
    echo "Usage: $0 <backup|restore> [namespace|backup-name]"
    exit 1
    ;;
esac
