include { VERTICALL_REPAIR; PREPARE_REPAIRED_FILES; VERTICALL_PAIRWISE; VERTICALL_MATRIX; VERTICALL_FASTME; VERTICALL_PAIRWISE_REF; VERTICALL_MASK, VERTICALL_RAXMLNG } from '../modules/processes.nf' 

workflow DIST_TREE {
    take:
        assemblies_ch
        existing_tsv_ch


    main:
        VERTICALL_REPAIR(assemblies_ch)

        PREPARE_REPAIRED_FILES(VERTICALL_REPAIR.out.collect())

        VERTICALL_PAIRWISE(PREPARE_REPAIRED_FILES.out, existing_tsv_ch)

        VERTICALL_MATRIX(VERTICALL_PAIRWISE.out)

        VERTICALL_FASTME(VERTICALL_MATRIX.out)

    emit:
        VERTICALL_FASTME.out
}

workflow ALIGNMENT {
    take:
        assemblies_ch
        reference_ch
        alignment_ch        


    main:
        VERTICALL_REPAIR(assemblies_ch)

        PREPARE_REPAIRED_FILES(VERTICALL_REPAIR.out.collect())

        VERTICALL_PAIRWISE_REF(PREPARE_REPAIRED_FILES.out, reference_ch)

        VERTICALL_MASK(VERTICALL_PAIRWISE_REF.out, alignment_ch)

        VERTICALL_RAXMLNG(VERTICALL_MASK.out)

    emit:
        VERTICALL_MASK.out
}