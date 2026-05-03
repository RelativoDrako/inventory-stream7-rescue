# inventory-stream7-rescue

Cross-platform **inventory, rescue triage, install-path assessment, and evidence-first reporting** for constrained hardware.

This repository has two complementary lanes:

1. **Multiplatform audit flows** for Linux and Windows.
2. **A specialized Stream 7 rescue lane** for very constrained devices.

It is designed to help answer these questions before invasive changes:

- What hardware and software do I actually have?
- Is this device better kept on its current OS or migrated?
- What is the best role for this machine under real constraints?
- What optimizations offer the highest return with the lowest risk?
- What evidence should be preserved before making changes?

## Repository value
This repository provides a structured, multiplatform inventory and rescue toolkit for device assessment, operational compatibility review, and constrained remediation support.

## Typical use cases
- Linux and Windows device inventory before intervention
- Platform capability review before update or recovery
- Stream 7 complementary rescue and diagnostic workflows
- Evidence-oriented baseline collection for technical support

## Supported lanes

### 1. Multiplatform general lanes
Reusable general-purpose audit and assessment flows for:
- Linux (x86 32-bit, x86_64, armhf, arm64)
- Windows PowerShell 5+
- Windows PowerShell 4 legacy compatibility lane

### 2. Stream 7 specialized lane
A focused lane for HP Stream 7-class devices where storage, memory, firmware, driver, and usability constraints require more careful sequencing.

## Repository structure

```text
docs/                                   Public documentation and operating notes
docs/professional-image/                Notes to align F1-F3 and this repository
shared/                                 Shared templates
shared/ip/                              Minimal IP-protection artifacts
stream7/stream7-linux-specialized/      Specialized Stream 7 Linux lane
multiplatform/linux-general/            General Linux lane
multiplatform/windows-ps5-general/      General Windows PowerShell 5+ lane
legacy/windows-ps4-general/             Legacy Windows PowerShell 4 lane
assets/                                 Publication assets
deploy.ps1                              Repository publication helper
.gitignore                              Repository hygiene rules
```

## Core methodology

1. **Inventory / Probe**
2. **Assessment**
3. **Recommendation framing**
4. **Controlled action**
5. **Reporting**
6. **Optional optimization review**

## Professional boundary

This repository is a **secondary public proof** of:
- constrained technical judgment
- rescue workflow discipline
- cross-platform inventory and reporting thinking
- install-path evaluation under limited conditions

It is **not**:
- an enterprise fleet-management system
- official vendor recovery media
- a licensing bypass workflow
- an all-device recovery guarantee
- a complete IP-protection procedure

## Minimal IP-protection layer

This package includes a minimum public-defense layer:
- copyright notice template
- publication boundary note
- authorship/evidence manifest generators (Linux + PowerShell)
- release-integrity hash guidance

This is intentionally minimal: it reduces plagiarism risk and strengthens authorship evidence without pretending to replace formal legal registration.

## Reading order

1. `docs/executive-summary.md`
2. `docs/hardware-baseline.md`
3. `docs/install-path-matrix.md`
4. `docs/methodology.md`
5. `docs/AGNOSTIC_PLATFORM_STRATEGY.md`
6. platform-specific guides


---

**Authorship note:** Original content © Daniel Franco Fajardo. Public technical reference only. Preserve attribution.
