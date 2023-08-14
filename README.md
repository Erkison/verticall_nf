# verticall_nf

## Local run
```
nextflow run ~/Ewomazino/Erkison/code/bioinformatics_scripts/massive/verticall_nf/main.nf \
    --workflow "distance" --assemblies "path/to/assemblies/*.fasta" --output_dir path/to/output/dir \
    -profile local \
    -resume \
    [--threads 8 --existing_tsv path/to/old_verticall.tsv]
```

## MASSIVE run
```
nextflow run ~/js66_scratch/erkison/seroepi/scripts/nextflow/verticall_nf/main.nf \
    --workflow "distance" --assemblies "path/to/assemblies/*.fasta" --output_dir path/to/output/dir \
    -profile standard -resume \
    [--threads 32 --existing_tsv path/to/old_verticall.tsv]
```