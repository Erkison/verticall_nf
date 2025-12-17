include { VERTICALL_REPAIR; PREPARE_REPAIRED_FILES; VERTICALL_PAIRWISE; VERTICALL_MATRIX; 
            VERTICALL_FASTME; VERTICALL_MASK; FILTER_MASKED_ALIGNMENT; 
            SNIPPY_ALIGN; SNIPPY_CORE; VERTICALL_ALN_TREE } from '../modules/processes.nf' 

workflow DIST_TREE {
    take:
        assemblies_ch
        existing_tsv_ch

    main:
        VERTICALL_REPAIR(assemblies_ch)

        PREPARE_REPAIRED_FILES(VERTICALL_REPAIR.out.collect())

        VERTICALL_PAIRWISE(PREPARE_REPAIRED_FILES.out, existing_tsv_ch, [])

        VERTICALL_MATRIX(VERTICALL_PAIRWISE.out)

        VERTICALL_FASTME(VERTICALL_MATRIX.out)

    emit:
        VERTICALL_PAIRWISE.out
}


workflow ALIGNMENT {
    take:
        assemblies_ch
        existing_tsv_ch
        reference_ch
        alignment_ch        

    main:
        VERTICALL_REPAIR(assemblies_ch)

        PREPARE_REPAIRED_FILES(VERTICALL_REPAIR.out.collect())

        VERTICALL_PAIRWISE(PREPARE_REPAIRED_FILES.out, existing_tsv_ch, reference_ch.map{ it[1] })

        if (!alignment_ch) {
            SNIPPY_ALIGN(assemblies_ch, reference_ch.first())
            SNIPPY_CORE(SNIPPY_ALIGN.out.snippy_outdir.collect(), reference_ch.map{ it[0] })
            alignment = SNIPPY_CORE.out.clean_alignment
        } else {
            alignment = alignment_ch
        }

        VERTICALL_MASK(VERTICALL_PAIRWISE.out, alignment, reference_ch)

        if (params.include_ref) {
            masked_alignment = VERTICALL_MASK.out.alignment_with_ref
        } else {
            masked_alignment = VERTICALL_MASK.out.alignment_no_ref
        }

        if (params.filter_alignment) {
            FILTER_MASKED_ALIGNMENT(masked_alignment)
            masked_alignment = FILTER_MASKED_ALIGNMENT.out.filtered_alignment
        }

        VERTICALL_ALN_TREE(masked_alignment)

    emit:
        VERTICALL_PAIRWISE.out
}