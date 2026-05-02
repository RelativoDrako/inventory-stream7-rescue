# Methodology

The repository uses a bounded methodology:

1. **Probe / Inventory**
   - hardware
   - OS
   - storage
   - drivers / firmware
   - role constraints

2. **Assess**
   - architecture family
   - practical role
   - OS fit
   - install-path risk
   - optimization priority

3. **Report**
   - executive summary
   - technical detail
   - recommendation sheet
   - optimization proposals

4. **Controlled action**
   - only after evidence exists
   - only after review
   - only with bounded scope

5. **Integrity / authorship**
   - generate manifests and hashes
   - preserve release evidence
   - reduce plagiarism exposure

## Idempotence rule
Running the same mode again should:
- preserve prior evidence when possible
- overwrite only the intended report artifact
- avoid hidden destructive behavior
