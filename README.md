# verticall_nf

## Local run
```
nextflow run ~/Ewomazino/Erkison/code/bioinformatics_scripts/massive/verticall_nf/main.nf \
    --assemblies "path/to/assemblies/*.fasta" --output_dir path/to/output/dir \
    -profile local \
    -resume
```

## MASSIVE run
```
nextflow run ~/js66_scratch/erkison/seroepi/scripts/nextflow/verticall_nf/main.nf \
    --assemblies "path/to/assemblies/*.fasta" --output_dir path/to/output/dir \
    -profile standard -resume
```