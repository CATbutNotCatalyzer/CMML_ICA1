# Temperature-dependent stability of the ECs1815–Caspase-9 complex

This repository contains the code, parameter files, analysis scripts, and documentation for the CMML3 ICA1 mini-project on the temperature-dependent behaviour of the *Escherichia coli* effector protein ECs1815 in complex with human Caspase-9.

## Project summary

The aim of this project was to investigate how temperature affects the stability of the ECs1815–Caspase-9 complex using molecular dynamics simulation at 280 K, 300 K and 320 K. The final MD-derived structures were also compared with an AlphaFold-predicted complex model.

The main analyses included:

- trajectory-based structural analysis
- interface hydrogen-bond counting
- Ramachandran assessment
- secondary-structure comparison
- interface-area analysis with PISA
- comparison with an AlphaFold model

## Structural system

- Experimental structure source: **PDB 3V3K**
- Host protein: **Caspase-9**
- Pathogen protein: **ECs1815**
- Selected biological unit: one representative host–pathogen complex

Because residues 299–317 were missing from the Caspase-9 crystal structure, the host protein had to be represented as two chain fragments during MD setup. As a result:

- host = chains **A + C**
- pathogen = chain **B**

This fragmentation complicated interpretation of whole-complex global metrics, so greater emphasis was placed on interface-level analyses and on chain-specific analysis of the intact pathogen chain.

## MD setup

Simulations were performed in **GROMACS 2024.3** with:

- force field: **AMBER99SB-ILDN**
- water model: **SPC/E**
- approximate salt concentration: **0.15 M**
- simulation temperatures:
  - 280 K
  - 300 K
  - 320 K

The simulation workflow was:

1. topology generation
2. box definition
3. solvation
4. ion addition
5. energy minimisation
6. NVT equilibration
7. NPT equilibration
8. 20 ns production MD

## Repository structure

```text
.
├── README.md
├── mdp/
├── scripts/
├── r/
├── analysis/
└── docs/
```

## Software and resources used

GROMACS 2024.3
PyMOL
PISA
Protein iQ DSSP web application
AlphaFold Server 
R for plotting and figure assembly

## Course context

This repository was prepared for the CMML3 ICA1 mini-project and is intended to accompany the submitted report and supplementary methods.

## Author

Name: ZHU Yichen
Course: CMML3
Institution: ZJE
