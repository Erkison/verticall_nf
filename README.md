# Verticall_nf
This is a nextflow implementation of [Verticall](https://github.com/rrwick/Verticall) by Ryan Wick

## Local run
```
nextflow run verticall_nf/main.nf \
    --workflow "distance" --assemblies "path/to/assemblies/*.fasta" --output_dir path/to/output/dir \
    [--existing_tsv path/to/old_verticall.tsv] \
    -profile local \
    -resume
```

## MASSIVE run
```
nextflow run verticall_nf/main.nf \
    --workflow "distance" --assemblies "path/to/assemblies/*.fasta" --output_dir path/to/output/dir \
    [--existing_tsv path/to/old_verticall.tsv] \
    -profile standard -resume
    
```