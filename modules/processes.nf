
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

process VERTICALL_PAIRWISE {
    tag { 'verticall pairwise' }
        
    publishDir "${params.output_dir}/",
        mode: 'copy',
        pattern: "verticall.tsv"

    input:
    path(assemblies_dir)
    path(existing_tsv_file)
    path(reference)

    output:
    path("verticall.tsv")

    script:
    """
    # Prepare arguments
    if [[ "${reference}" != "" ]]; then
      ref_arg="-r ${reference}"
    else
      ref_arg=""
    fi
    if [[ "${existing_tsv_file}" != "" ]]; then
      existing_tsv_arg="--existing_tsv ${existing_tsv_file}"
    else
      existing_tsv_arg=""
    fi

    # Run
    verticall pairwise -i ${assemblies_dir} -o verticall.tsv \${ref_arg} \${existing_tsv_arg} -t $task.cpus

    # Append existing tsv contents except header
    if [[ "${existing_tsv_file}" != "" ]]; then
      sed '1d' ${existing_tsv_file} >> verticall.tsv
    fi
    """
}

// distance workflow-specific processes

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

process SNIPPY_ALIGN {
    tag { sample_id }

    input:
    tuple(val(sample_id), path(assembly))
    tuple(val(ref_name), path(reference))

    output:
    path("${sample_id}/"), emit: snippy_outdir

    script:
    """
    snippy --cpus $task.cpus --outdir ${sample_id} --ref ${reference} --ctgs ${assembly}
    """
}

// need a process for the snippy-core command
process SNIPPY_CORE {
    tag { 'snippy core' }

    publishDir "${params.output_dir}/snippy/",
        mode: 'copy',
        pattern: "*.*"

    input:
    path(snippy_dirs)
    val(ref_name)

    output:
    path("clean.full.aln"), emit: clean_alignment
    path("core.full.aln"), emit: core_alignment
    path("*.*")

    script:
    """
    # Get the reference from the first directory
    ref_fa=\$(ls ${snippy_dirs[0]}/ref.fa 2>/dev/null || ls ${snippy_dirs[0]}/reference.fa 2>/dev/null)
    
    # Get all directory names
    dirs=\$(for dir in ${snippy_dirs}; do basename \$dir; done | tr '\n' ' ')
    
    # Run snippy-core with all directories
    snippy-core --ref "\${ref_fa}" \${dirs}
    sed -i '' "s/>Reference/>${ref_name}/" core.full.aln
    snippy-clean_full_aln core.full.aln > clean.full.aln
    """
}

process VERTICALL_MASK {
    tag { 'verticall mask' }
        
    publishDir "${params.output_dir}/",
        mode: 'copy',
        pattern: "*.fasta"

    input:
    path(verticall_tsv)
    path(alignment)
    tuple(val(ref_name), path(reference))

    output:
    path("masked_alignment.fasta"), emit: alignment_no_ref
    path("masked_alignment_with_ref.fasta"), emit: alignment_with_ref

    script:
    """
    verticall mask -i ${verticall_tsv} -a ${alignment} \
        --reference ${ref_name} --multi ${params.multi} \
        -o masked_alignment_with_ref.fasta

    cat masked_alignment_with_ref.fasta | paste - - | grep -v ">${ref_name}" | tr '\t' '\n' > masked_alignment.fasta
    """
}


process FILTER_MASKED_ALIGNMENT {
    tag { 'filter masked alignment' }
        
    publishDir "${params.output_dir}/",
        mode: 'copy',
        pattern: "masked_alignment_filtered.fasta"
    
    publishDir "${params.output_dir}/",
        mode: 'copy',
        pattern: "coresnpfilter.log",
        overwrite: true

    input:
    path(alignment)

    output:
    path("masked_alignment_filtered.fasta"), emit: filtered_alignment
    path("coresnpfilter.log")

    script:
    if (params.exclude_invariant) {
        exclude_invariant="-e"
    } else {
        exclude_invariant=""
    }
    if (params.core_threshold) {
        core_filter_arg="-c ${params.core_threshold}"
    } else {
        core_filter_arg=""
    }
    """
    coresnpfilter ${exclude_invariant} ${core_filter_arg} \
        ${alignment} > masked_alignment_filtered.fasta \
        2> coresnpfilter.log
    """
}


process VERTICALL_ALN_TREE {
    tag { params.tree_builder }
        
    publishDir "${params.output_dir}/${params.tree_builder}",
        mode: 'copy',
        pattern: "*"

    input:
    path(alignment)

    output:
    path("*")

    script:
    if (params.raxml_bootstraps) {
        raxmlng_search = "--all --bs-metric fbp,tbe --bs-trees ${params.raxml_bs_trees}"
    } else {raxmlng_search = ""}
    if (params.iqtree_bootsraps) {
        if (params.iqtree_bs_bnni) {
            iqtree_bs_args = "-B ${params.iqtree_bs_trees} -bnni"
        } else {
            iqtree_bs_args = "-B ${params.iqtree_bs_trees}"
        }
    } else {iqtree_bs_args = ""}

    """
    if [[ "${params.tree_builder}" == "iqtree" ]]; then
        iqtree2 -s ${alignment} ${iqtree_bs_args} -pre ${params.tree_prefix} -nt $task.cpus
    elif [[ "${params.tree_builder}" == "raxmlng" ]]; then
        raxml-ng ${raxmlng_search} --msa ${alignment} --model ${params.raxml_model} \
            --prefix ${params.tree_prefix} --tree ${params.raxml_starting_trees} \
            --seed 2 --threads auto{$task.cpus}
    fi
    """
}