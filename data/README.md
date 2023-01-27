This repository contains all data for the analyses. Find the raw sequence data at: NCBI; Bioproject no. PRJNA872341

Capture probe information:
- `MUMMICHOG-probes-120-filtration.txt`: filtering results from designed probes.
- `MUMMICHOG-probes-120-stringent.bed`: location of probes in F. het genome.
- `MUMMICHOG-probes-120.fas`: fasta file of probes used.

Variant data:
- `all.final.vcf.gz`: filtered, all individuals.

`environmental_params.csv`
- environmental data used for supplemental figures 1 and 2
- downloaded from https://eyesonthebay.dnr.maryland.gov on Nov 25, 2022. 
- Stations: 
    - BW population, Point lookout: LE2.3 Lower Potomac River Point Lookout 38.0215 -76.3477 1984 - 2022 
    - FW population:, Piscataway Park: TF2.1 Middle Potomac River Off Piscataway 38.7065 -77.0486 1986 - 2022

Reproduction data:
- `fert.data.binom.csv`: no choice test
- `hatch.data.binom.csv`: no choice test
- `BreedingExpPlottingData`: choice test hatching and fertilization

`parent_data.csv`
- information about each parental fish in the analysis 

Parentage assignment:
- `parentage.assignment.txt`: raw parentage assignments from colony
- `parentage.plotting.txt`: processed parentage assignments for actual analysis. 
