# Windows PowerShell 5+ General Guide

## Purpose
The PowerShell 5+ lane performs:
- deep inventory
- architecture-aware assessment
- executive/technical reporting
- optimization/recommendation guidance

## Suggested flow
1. open PowerShell as administrator
2. `Set-ExecutionPolicy -Scope Process Bypass -Force`
3. run `probe`
4. run `assess`
5. run `report`
6. run `flow`

## Architecture-aware scope
The lane is designed for general Windows environments, but also classifies hardware in a way that remains useful for low-resource devices and cross-platform decision-making.
