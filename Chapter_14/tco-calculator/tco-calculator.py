#!/usr/bin/env python3
"""
Total Cost of Ownership Calculator: ECS vs EKS vs Fargate
Book: Mastering Container Architectures on AWS - Chapter 14

Compares the full cost of running containers on AWS including:
  - Infrastructure costs (compute, networking, storage)
  - Management overhead (control plane, tooling)
  - Operational costs (team expertise, time)
"""

def calculate_tco(num_services: int, avg_cpu_per_service: float,
                  avg_memory_gb: float, team_size: int = 5):
    """Calculate monthly TCO for each platform option."""

    hours_per_month = 730
    total_cpu = num_services * avg_cpu_per_service
    total_memory = num_services * avg_memory_gb

    results = {}

    # ---- Amazon ECS on EC2 ----
    ec2_instances = max(3, int(total_cpu / 4) + 1)  # m6i.xlarge (4 vCPU)
    ec2_cost = ec2_instances * 0.192 * hours_per_month  # On-demand
    ec2_savings = ec2_cost * 0.6  # With Savings Plan
    ecs_mgmt = 0  # No control plane cost for ECS
    ecs_ops = team_size * 0.1 * 150000 / 12  # 10% of time on infra

    results["ECS on EC2"] = {
        "infrastructure": round(ec2_savings, 2),
        "management": round(ecs_mgmt, 2),
        "operations": round(ecs_ops, 2),
        "total": round(ec2_savings + ecs_mgmt + ecs_ops, 2),
    }

    # ---- Amazon EKS on EC2 ----
    eks_control = 73.0  # $0.10/hr for EKS control plane
    eks_ec2 = ec2_instances * 0.192 * hours_per_month * 0.6  # With SP
    eks_ops = team_size * 0.15 * 150000 / 12  # 15% - K8s needs more expertise

    results["EKS on EC2"] = {
        "infrastructure": round(eks_ec2, 2),
        "management": round(eks_control, 2),
        "operations": round(eks_ops, 2),
        "total": round(eks_ec2 + eks_control + eks_ops, 2),
    }

    # ---- AWS Fargate ----
    fargate_cpu_rate = 0.04048
    fargate_mem_rate = 0.004445
    fargate_cost = num_services * (
        (avg_cpu_per_service * fargate_cpu_rate) +
        (avg_memory_gb * fargate_mem_rate)
    ) * hours_per_month
    fargate_ops = team_size * 0.05 * 150000 / 12  # 5% - minimal ops

    results["Fargate"] = {
        "infrastructure": round(fargate_cost, 2),
        "management": 0,
        "operations": round(fargate_ops, 2),
        "total": round(fargate_cost + fargate_ops, 2),
    }

    return results

if __name__ == "__main__":
    print("=" * 65)
    print("  Total Cost of Ownership: ECS vs EKS vs Fargate")
    print("=" * 65)

    scenarios = [
        {"name": "Small (5 services)", "services": 5, "cpu": 0.5, "mem": 1, "team": 3},
        {"name": "Medium (20 services)", "services": 20, "cpu": 1, "mem": 2, "team": 5},
        {"name": "Large (50 services)", "services": 50, "cpu": 2, "mem": 4, "team": 8},
    ]

    for scenario in scenarios:
        print(f"\n--- {scenario['name']} ---")
        print(f"  {scenario['services']} services, {scenario['cpu']} vCPU, "
              f"{scenario['mem']} GB each, {scenario['team']}-person team")
        print(f"  {'Platform':<18} {'Infra':>10} {'Mgmt':>8} {'Ops':>10} {'TOTAL':>10}")
        print(f"  {'-'*56}")

        results = calculate_tco(
            scenario["services"], scenario["cpu"],
            scenario["mem"], scenario["team"]
        )

        for platform, costs in sorted(results.items(), key=lambda x: x[1]["total"]):
            print(f"  {platform:<18} ${costs['infrastructure']:>8,.0f} "
                  f"${costs['management']:>6,.0f} "
                  f"${costs['operations']:>8,.0f} "
                  f"${costs['total']:>8,.0f}")

    print("\n" + "=" * 65)
    print("  Note: Operations cost assumes $150K avg salary.")
    print("  Infrastructure uses Savings Plan pricing where applicable.")
    print("=" * 65)
