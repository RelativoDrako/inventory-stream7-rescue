# Hardware Baseline

## Stream 7 logic
HP Stream 7-class devices are useful precisely because they are constrained:
- limited storage
- limited RAM
- driver sensitivity
- firmware variability
- usability trade-offs

This makes them good technical references for:
- rescue triage
- install-path assessment
- lightweight optimization
- evidence-first change control

## Generalized baseline rule
The multiplatform lanes do not assume one architecture.

They explicitly consider:
- x86 32-bit
- x86_64
- armhf / armv7
- arm64 / aarch64

This matters because install-path and software recommendations differ substantially across these families.
