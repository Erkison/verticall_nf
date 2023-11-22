# Verticall_nf
This is a nextflow implementation of [Verticall](https://github.com/rrwick/Verticall) by Ryan Wick

## Installation
```
# Clone this repo
git clone https://github.com/Erkison/verticall_nf.git

# Install verticall and other dependencies
conda env create -f verticall_nf/conda_environments/verticall.yml
# OR
mamba env create -f verticall_nf/conda_environments/verticall.yml

# Activate the environment
conda activate verticall

```

## Example usage with distance workflow

### Local run
```
nextflow run verticall_nf/main.nf \
    --workflow "distance" --assemblies "path/to/assemblies/*.fasta" --output_dir path/to/output/dir \
    [--existing_tsv path/to/old_verticall.tsv] \
    -profile local \
    -resume
```

### MASSIVE run
```
nextflow run verticall_nf/main.nf \
    --workflow "distance" --assemblies "path/to/assemblies/*.fasta" --output_dir path/to/output/dir \
    [--existing_tsv path/to/old_verticall.tsv] \
    -profile standard -resume
    
```