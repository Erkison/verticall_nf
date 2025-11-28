include { VERTICALL_REPAIR; PREPARE_REPAIRED_FILES; VERTICALL_PAIRWISE; VERTICALL_MATRIX; 
            VERTICALL_FASTME; GENERATE_ALIGNMENT; VERTICALL_MASK; VERTICALL_ALN_TREE } from '../modules/processes.nf' 

workflow DIST_TREE {
    take:
        assemblies_ch
        existing_tsv_ch

    main:
        VERTICALL_REPAIR(assemblies_ch)

        PREPARE_REPAIRED_FILES(VERTICALL_REPAIR.out.collect())

        VERTICALL_PAIRWISE(PREPARE_REPAIRED_FILES.out, existing_tsv_ch, reference_ch=[])

        VERTICALL_MATRIX(VERTICALL_PAIRWISE.out)

        VERTICALL_FASTME(VERTICALL_MATRIX.out)

    emit:
        VERTICALL_FASTME.out
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

        VERTICALL_PAIRWISE(PREPARE_REPAIRED_FILES.out, existing_tsv_ch, reference_ch)

        if (!alignment_ch) {
            GENERATE_ALIGNMENT(PREPARE_REPAIRED_FILES.out, reference_ch)
            alignment_final = GENERATE_ALIGNMENT.out
        } else {
            alignment_final = alignment_ch
        }

        VERTICALL_MASK(VERTICALL_PAIRWISE.out, alignment_final)

        VERTICALL_ALN_TREE(VERTICALL_MASK.out)

    emit:
        VERTICALL_MASK.out
}