# Install Path Matrix

## Path logic

### Linux general
Best when:
- hardware is diverse
- remote/technical use is acceptable
- lighter desktop or headless roles are viable
- package ecosystem and hardware support can be matched safely

### Windows PowerShell 5+
Best when:
- the device already has a stable Windows lane
- vendor drivers matter
- office/web/support use is expected
- hardware supports modern enough builds without excessive friction

### Windows PowerShell 4 legacy
Keep only when:
- the device remains on older Windows baselines
- upgrade cost is not justified yet
- audit/reporting is needed before modernization

### Stream 7 specialized Linux lane
Use when:
- storage is very tight
- driver sensitivity is high
- rescue/optimization sequence matters more than general-purpose convenience

## Decision rule
Never force a migration only because it is technically possible.
Choose the path with the best ratio of:
- supportability
- role fit
- driver viability
- maintenance cost
- user friction
