
// General processes
process VERTICALL_REPAIR {
    tag { sample_id }

    input:
    tuple(val(sample_id), path(assembly))

    output:
    path("${sample_id}_fixed.fasta")

    """
    verticall repair -i ${assembly} -o ${sample_id}_fixed.fasta
    """
}

process PREPARE_REPAIRED_FILES {
    tag { 'Prepare repaired files' }

    input:
    path(repaired_assemblies)

    output:
    path("verticall_repair")

    """
    mkdir verticall_repair
    cp ${repaired_assemblies} verticall_repair
    """
    
}

//Distance tree-specific processes
process VERTICALL_PAIRWISE {
    tag { 'verticall pairwise' }
        
    publishDir "${params.output_dir}/",
        mode: 'copy',
        pattern: "verticall.tsv"

    input:
    path(assemblies_dir)
    path(optional_existing_tsv_file)

    output:
    path("verticall.tsv")

    script:
    if (optional_existing_tsv_file) {
        existing_tsv_arg = "--existing_tsv ${optional_existing_tsv_file}"
        """
        verticall pairwise -i ${assemblies_dir} -o verticall.tsv -t $task.cpus ${existing_tsv_arg}
        sed '1d' ${optional_existing_tsv_file} >> verticall.tsv
        """
    } else {
        existing_tsv_arg = ""
        """
        verticall pairwise -i ${assemblies_dir} -o verticall.tsv -t $task.cpus
        """
    }
    
}

process VERTICALL_MATRIX {
    tag { 'verticall matrix' }
        
    publishDir "${params.output_dir}/",
        mode: 'copy',
        pattern: "verticall.phylip"

    input:
    path(verticall_tsv)

    output:
    path("verticall.phylip")


    """
    verticall matrix -i ${verticall_tsv} -o verticall.phylip
    """
}

process VERTICALL_FASTME {
    tag { 'verticall fastme' }
        
    publishDir "${params.output_dir}/",
        mode: 'copy',
        pattern: "verticall.newick"

    input:
    path(verticall_phylip)

    output:
    path("verticall.newick")


    """
    fastme --method B --nni B --spr -i ${verticall_phylip} -o verticall.newick

    """
}

// alignment workflow-specific processes
process VERTICALL_PAIRWISE_REF {
    tag { 'verticall pairwise' }
        
    publishDir "${params.output_dir}/",
        mode: 'copy',
        pattern: "verticall.tsv"

    input:
    path(assemblies_dir)
    path(reference)

    output:
    path("verticall.tsv")

    script:
    """
    verticall pairwise -i ${assemblies_dir} -o verticall.tsv -r ${reference}
    """    
}

process VERTICALL_MASK {
    tag { 'verticall mask' }
        
    publishDir "${params.output_dir}/",
        mode: 'copy',
        pattern: "masked_alignment_variants_only.fasta"

    input:
    path(verticall_tsv)
    path(alignment)

    output:
    path("verticall.phylip")


    """
    verticall mask -i ${verticall_tsv} -a ${alignment} -o masked_alignment_variants_only.fasta --exclude_invariant
    """
}