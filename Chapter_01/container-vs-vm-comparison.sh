#!/bin/bash
# ============================================================================
# Container vs VM Comparison - Educational Demonstration
# Book: Mastering Container Architectures on AWS
# Chapter 1: Foundations of Containers and Cloud-Native on AWS
#
# This script demonstrates the key Linux kernel features that enable
# container isolation: namespaces and cgroups. It contrasts containers
# with virtual machines to illustrate the fundamental architectural
# differences discussed in this chapter.
# ============================================================================

set -euo pipefail

echo "========================================================"
echo "  Container vs Virtual Machine - Architectural Comparison"
echo "========================================================"
echo ""

# ---------------------------------------------------------------------------
# Part 1: Demonstrate Linux Namespaces (Container Isolation Mechanism)
# ---------------------------------------------------------------------------
echo "--- Part 1: Linux Namespaces (How Containers Achieve Isolation) ---"
echo ""
echo "Containers use Linux namespaces to isolate processes. Each namespace"
echo "provides a separate view of a system resource."
echo ""

echo "Current namespaces for this process (PID $$):"
ls -la /proc/$$/ns/ 2>/dev/null || echo "(Namespace listing not available on this system)"
echo ""

echo "Namespace types used by containers:"
echo "  - pid:    Process ID isolation (container sees only its own processes)"
echo "  - net:    Network isolation (own network stack, interfaces, IP addresses)"
echo "  - mnt:    Mount isolation (own filesystem view)"
echo "  - uts:    Hostname isolation (own hostname)"
echo "  - ipc:    Inter-process communication isolation"
echo "  - user:   User ID mapping isolation"
echo "  - cgroup: Cgroup visibility isolation"
echo ""

# ---------------------------------------------------------------------------
# Part 2: Demonstrate cgroups (Resource Limiting)
# ---------------------------------------------------------------------------
echo "--- Part 2: Control Groups (cgroups) - Resource Limits ---"
echo ""
echo "Cgroups limit and account for resource usage (CPU, memory, I/O)."
echo "This is how containers enforce resource boundaries."
echo ""

if [ -d /sys/fs/cgroup ]; then
    echo "Cgroup v2 hierarchy on this system:"
    ls /sys/fs/cgroup/ 2>/dev/null | head -20
    echo ""

    echo "Available cgroup controllers:"
    cat /sys/fs/cgroup/cgroup.controllers 2>/dev/null || echo "(Not available)"
    echo ""

    echo "Current memory usage of this cgroup:"
    cat /sys/fs/cgroup/memory.current 2>/dev/null || echo "(Not available)"
else
    echo "(Cgroup filesystem not mounted - running in restricted environment)"
fi
echo ""

# ---------------------------------------------------------------------------
# Part 3: Container vs VM Architecture Comparison
# ---------------------------------------------------------------------------
echo "--- Part 3: Architecture Comparison ---"
echo ""
echo "┌─────────────────────────────────────────────────────────────────┐"
echo "│              VIRTUAL MACHINES              │    CONTAINERS      │"
echo "├─────────────────────────────────────────────────────────────────┤"
echo "│                                            │                    │"
echo "│  ┌────────┐ ┌────────┐ ┌────────┐        │ ┌──────┐ ┌──────┐ │"
echo "│  │  App A │ │  App B │ │  App C │        │ │App A │ │App B │ │"
echo "│  ├────────┤ ├────────┤ ├────────┤        │ ├──────┤ ├──────┤ │"
echo "│  │ Libs/  │ │ Libs/  │ │ Libs/  │        │ │Libs/ │ │Libs/ │ │"
echo "│  │ Bins   │ │ Bins   │ │ Bins   │        │ │Bins  │ │Bins  │ │"
echo "│  ├────────┤ ├────────┤ ├────────┤        │ └──────┘ └──────┘ │"
echo "│  │Guest OS│ │Guest OS│ │Guest OS│        │ ┌────────────────┐ │"
echo "│  └────────┘ └────────┘ └────────┘        │ │Container Engine│ │"
echo "│  ┌───────────────────────────────┐        │ └────────────────┘ │"
echo "│  │         Hypervisor            │        │ ┌────────────────┐ │"
echo "│  └───────────────────────────────┘        │ │  Host OS Kernel│ │"
echo "│  ┌───────────────────────────────┐        │ └────────────────┘ │"
echo "│  │       Host OS / Hardware      │        │ ┌────────────────┐ │"
echo "│  └───────────────────────────────┘        │ │    Hardware    │ │"
echo "│                                            │ └────────────────┘ │"
echo "├─────────────────────────────────────────────────────────────────┤"
echo "│ Startup: Minutes                 │ Startup: Milliseconds       │"
echo "│ Size: Gigabytes                  │ Size: Megabytes             │"
echo "│ Isolation: Hardware-level        │ Isolation: OS-level         │"
echo "│ Overhead: High (full OS)         │ Overhead: Low (shared OS)   │"
echo "│ Density: 10-20 per host          │ Density: 100s per host      │"
echo "└─────────────────────────────────────────────────────────────────┘"
echo ""

# ---------------------------------------------------------------------------
# Part 4: Practical Demonstration with Docker (if available)
# ---------------------------------------------------------------------------
echo "--- Part 4: Docker Container Demonstration ---"
echo ""

if command -v docker &>/dev/null; then
    echo "Docker is available. Demonstrating container isolation:"
    echo ""

    echo "1. Container sees isolated process namespace:"
    docker run --rm alpine ps aux 2>/dev/null || echo "   (Docker daemon not running)"
    echo ""

    echo "2. Container has its own hostname:"
    docker run --rm alpine hostname 2>/dev/null || echo "   (Docker daemon not running)"
    echo ""

    echo "3. Container has its own network namespace:"
    docker run --rm alpine ip addr show 2>/dev/null || echo "   (Docker daemon not running)"
    echo ""

    echo "4. Container resource limits (cgroups in action):"
    echo "   docker run --memory=256m --cpus=0.5 alpine cat /sys/fs/cgroup/memory.max"
    docker run --rm --memory=256m alpine cat /sys/fs/cgroup/memory.max 2>/dev/null || echo "   (Docker daemon not running)"
else
    echo "Docker is not installed. Install Docker to run the practical demonstrations."
    echo ""
    echo "On Amazon Linux 2/AL2023:"
    echo "  sudo yum install -y docker"
    echo "  sudo systemctl start docker"
    echo ""
    echo "On Ubuntu:"
    echo "  sudo apt-get install -y docker.io"
    echo "  sudo systemctl start docker"
fi

echo ""
echo "========================================================"
echo "  Key Takeaway: Containers share the host OS kernel and"
echo "  use namespaces + cgroups for isolation. VMs virtualize"
echo "  entire hardware stacks. This makes containers faster,"
echo "  lighter, and more efficient for application packaging."
echo "========================================================"
