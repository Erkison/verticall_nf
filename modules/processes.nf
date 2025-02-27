
// General processes
process VERTICALL_REPAIR {
    tag { sample_id }

    input:
    tuple(val(sample_id), path(assembly))

    output:
    path("${sample_id}_fixed.fasta")

    script:
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

    script:
    """
    mkdir verticall_repair
    for f in ${repaired_assemblies}; do
      n=\$(basename \$f _fixed.fasta);
      cp \$f verticall_repair/\${n}.fasta;
    done
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
    path(existing_tsv_file)

    output:
    path("verticall.tsv")

    script:
    if (existing_tsv_file) {
        """
        verticall pairwise -i ${assemblies_dir} -o verticall.tsv -t $task.cpus --existing_tsv ${existing_tsv_file}
        sed '1d' ${existing_tsv_file} >> verticall.tsv
        """
    } else {
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

    script:
    """
    verticall matrix -i ${verticall_tsv} -o verticall.phylip --multi ${params.multi}
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

    script:
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
    path("masked_alignment_variants_only.fasta")

    script:
    """
    verticall mask -i ${verticall_tsv} -a ${alignment} -o masked_alignment_variants_only.fasta --exclude_invariant
    """
}

process VERTICALL_RAXMLNG {
    tag { 'verticall raxmlng' }
        
    publishDir "${params.output_dir}/raxmlng",
        mode: 'copy',
        pattern: "*.raxml.*"

    input:
    path(masked_alignment_variants_only)

    output:
    path("*.raxml.*")

    script:
    if (params.raxml_bootstraps) {
        tree_search_arg = "--all --bs-metric fbp,tbe --bs-trees ${params.raxml_bs_trees}"
    } else {
        tree_search_arg = ""
    }

    """
    raxml-ng ${tree_search_arg} --msa ${masked_alignment_variants_only} --model ${params.raxml_model} \
        --prefix ${params.raxml_prefix} --tree ${params.raxml_starting_trees} \
        --seed 2 --threads auto{$task.cpus}
    """
}