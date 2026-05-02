# Agnostic Platform Strategy

This repository is intentionally agnostic across:

- Linux / Windows
- x86 32-bit / x86_64
- armhf / arm64
- low-resource and moderate-resource systems

## What “agnostic” means here

It does **not** mean pretending every platform is the same.

It means:
- detect the platform first
- classify the architecture
- recommend a suitable role
- generate evidence before optimization
- keep the scripts safe to rerun

## Architecture-aware recommendations

### x86 32-bit
- preserve light workloads
- avoid modern heavy stacks
- prefer recovery, thin-client, or limited support roles

### x86_64
- widest compatibility range
- can support modern Windows/Linux paths depending on RAM/storage

### armhf / armv7
- prioritize lightweight userspace, constrained stacks, and well-supported packages

### arm64 / aarch64
- stronger modern path when packages and drivers are available
- good fit for lightweight edge, kiosk, or remote-support roles

## End-of-run recommendation policy
At the end of the general lanes, the operator should receive:
- a role recommendation
- an OS/path recommendation
- optimization priorities
- report locations
- next-step warnings before invasive changes
