#!/usr/bin/env python3
"""
Container Cost Comparison Calculator
Book: Mastering Container Architectures on AWS - Chapter 6

Compares monthly costs across EC2, Fargate, Fargate Spot, and App Runner
for a given workload profile.
"""

def calculate_costs(vcpu: float, memory_gb: float, hours_per_month: float,
                    active_hours: float = None):
    """Calculate monthly costs across compute options."""

    active_hours = active_hours or hours_per_month  # For App Runner

    # Pricing (us-east-1, approximate as of 2025)
    costs = {}

    # EC2 On-Demand (m6i.xlarge ~$0.192/hr for 4 vCPU, 16 GB)
    ec2_hourly = 0.192 * (vcpu / 4)  # Scale proportionally
    costs["EC2 On-Demand"] = ec2_hourly * hours_per_month

    # EC2 with 1-year Savings Plan (~40% discount)
    costs["EC2 Savings Plan (1yr)"] = costs["EC2 On-Demand"] * 0.60

    # Fargate On-Demand
    fargate_cpu_rate = 0.04048  # per vCPU per hour
    fargate_mem_rate = 0.004445  # per GB per hour
    costs["Fargate On-Demand"] = (
        (vcpu * fargate_cpu_rate) + (memory_gb * fargate_mem_rate)
    ) * hours_per_month

    # Fargate Spot (~70% discount)
    costs["Fargate Spot"] = costs["Fargate On-Demand"] * 0.30

    # App Runner (active compute + paused memory)
    ar_cpu_rate = 0.064   # per vCPU per hour (active)
    ar_mem_rate = 0.007   # per GB per hour (active)
    ar_pause_rate = 0.0025  # per GB per hour (paused)
    paused_hours = hours_per_month - active_hours
    costs["App Runner"] = (
        (vcpu * ar_cpu_rate + memory_gb * ar_mem_rate) * active_hours +
        (memory_gb * ar_pause_rate) * max(0, paused_hours)
    )

    return costs

if __name__ == "__main__":
    print("=" * 60)
    print("  Container Compute Cost Comparison (Monthly)")
    print("=" * 60)

    # Example workload: 1 vCPU, 2 GB memory, running 24/7
    vcpu = 1
    memory = 2
    hours = 730  # ~24/7
    active = 365  # ~50% active for App Runner

    print(f"\nWorkload: {vcpu} vCPU, {memory} GB RAM, {hours} hours/month")
    print(f"App Runner active hours: {active}")
    print("-" * 45)

    costs = calculate_costs(vcpu, memory, hours, active)
    for option, cost in sorted(costs.items(), key=lambda x: x[1]):
        bar = "#" * int(cost / 5)
        print(f"  {option:<25} ${cost:>7.2f}  {bar}")

    print("\n" + "=" * 60)
    cheapest = min(costs, key=costs.get)
    print(f"  Most cost-effective: {cheapest} (${costs[cheapest]:.2f}/month)")
