# Verticall_nf
This is a nextflow implementation of [Verticall](https://github.com/rrwick/Verticall) by Ryan Wick

## Installation
First install [nextflow](https://www.nextflow.io/docs/stable/install.html) if you dont already have it installed.

Clone this repo
```
git clone https://github.com/Erkison/verticall_nf.git
```
Install verticall and other dependencies
```
cd verticall_nf
conda env create -f conda_environments/verticall.yml
# OR
mamba env create -f conda_environments/verticall.yml
```
Activate the environment
```
conda activate verticall
```

## Example usage with distance workflow

### Local run
```
nextflow run main.nf --workflow "distance" --assemblies "assemblies/*.fasta" --output_dir verticall_out/ \
    -profile local -resume
```

### Slurm run
```
nextflow run main.nf --workflow "distance" --assemblies "assemblies/*.fasta" --output_dir verticall_out/ \
    -profile slurm -resume
```

The pipeline mostly uses default Verticall parameters, but some options are customisable. For a full list of available options, run:
```
nextflow run main.nf --help
```