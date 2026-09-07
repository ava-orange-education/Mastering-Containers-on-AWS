#!/bin/bash
# ============================================================================
# AWS Container Service Decision Tree
# Book: Mastering Container Architectures on AWS - Chapter 1
#
# Interactive script to help choose the right AWS container service based on
# workload requirements. Covers ECS, EKS, Fargate, and App Runner.
# ============================================================================

set -euo pipefail

echo "========================================================"
echo "  AWS Container Service Decision Guide"
echo "  Mastering Container Architectures on AWS"
echo "========================================================"
echo ""

# Helper function for prompts
ask() {
    local prompt="$1"
    local response
    while true; do
        read -rp "$prompt [y/n]: " response
        case "$response" in
            [yY]|[yY][eE][sS]) return 0 ;;
            [nN]|[nN][oO]) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

echo "Answer a few questions about your workload to get a recommendation."
echo ""

# ---- Question 1: Web app simplicity ----
if ask "Is this a simple web application or API with minimal infrastructure needs?"; then
    echo ""
    if ask "Do you want zero infrastructure management (no clusters, no task definitions)?"; then
        echo ""
        echo "┌─────────────────────────────────────────────────────┐"
        echo "│  RECOMMENDATION: AWS App Runner                     │"
        echo "├─────────────────────────────────────────────────────┤"
        echo "│  - Deploy directly from source code or container    │"
        echo "│  - Automatic HTTPS, scaling, and load balancing     │"
        echo "│  - Pay only when processing requests                │"
        echo "│  - Best for: Web apps, APIs, microservices          │"
        echo "│  - Trade-off: Less control over infrastructure      │"
        echo "└─────────────────────────────────────────────────────┘"
        exit 0
    fi
fi

# ---- Question 2: Kubernetes requirement ----
echo ""
if ask "Does your team require Kubernetes APIs, ecosystem tools, or multi-cloud portability?"; then
    echo ""
    if ask "Do you want AWS to manage the compute infrastructure (no EC2 instances)?"; then
        echo ""
        echo "┌─────────────────────────────────────────────────────┐"
        echo "│  RECOMMENDATION: Amazon EKS with Fargate            │"
        echo "├─────────────────────────────────────────────────────┤"
        echo "│  - Managed Kubernetes control plane                 │"
        echo "│  - Serverless compute (no nodes to manage)          │"
        echo "│  - Full Kubernetes API compatibility                │"
        echo "│  - Best for: K8s teams wanting less ops overhead    │"
        echo "│  - Trade-off: No DaemonSets, limited instance types │"
        echo "└─────────────────────────────────────────────────────┘"
    else
        echo ""
        echo "┌─────────────────────────────────────────────────────┐"
        echo "│  RECOMMENDATION: Amazon EKS with Managed Node Groups│"
        echo "├─────────────────────────────────────────────────────┤"
        echo "│  - Managed Kubernetes control plane                 │"
        echo "│  - Full control over EC2 worker nodes               │"
        echo "│  - GPU support, DaemonSets, custom AMIs             │"
        echo "│  - Best for: Complex workloads, AI/ML, custom infra │"
        echo "│  - Consider: Karpenter for dynamic node scaling     │"
        echo "└─────────────────────────────────────────────────────┘"
    fi
    exit 0
fi

# ---- Question 3: AWS-native preference ----
echo ""
echo "You prefer an AWS-native container orchestration (not Kubernetes)."
echo ""

if ask "Do you want AWS to manage the compute infrastructure (no EC2 instances)?"; then
    echo ""
    echo "┌─────────────────────────────────────────────────────┐"
    echo "│  RECOMMENDATION: Amazon ECS with Fargate            │"
    echo "├─────────────────────────────────────────────────────┤"
    echo "│  - AWS-native orchestration (simpler than K8s)      │"
    echo "│  - Serverless compute (no instances to manage)      │"
    echo "│  - Deep AWS integration (IAM, CloudWatch, ALB)      │"
    echo "│  - Best for: Teams new to containers on AWS         │"
    echo "│  - Trade-off: No DaemonSets, limited customization  │"
    echo "└─────────────────────────────────────────────────────┘"
else
    echo ""
    echo "┌─────────────────────────────────────────────────────┐"
    echo "│  RECOMMENDATION: Amazon ECS on EC2                  │"
    echo "├─────────────────────────────────────────────────────┤"
    echo "│  - AWS-native orchestration                         │"
    echo "│  - Full control over EC2 instances                  │"
    echo "│  - GPU support, custom instance types               │"
    echo "│  - Best for: Cost optimization with Reserved/Spot   │"
    echo "│  - Trade-off: Must manage instance patching/scaling │"
    echo "└─────────────────────────────────────────────────────┘"
fi

echo ""
echo "Additional resources:"
echo "  - Amazon ECR: Container image registry (use with any service above)"
echo "  - AWS Copilot: CLI tool for deploying to ECS and App Runner"
echo "  - eksctl: CLI tool for creating and managing EKS clusters"
