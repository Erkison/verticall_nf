include { VERTICALL_REPAIR; PREPARE_REPAIRED_FILES; VERTICALL_PAIRWISE; VERTICALL_MATRIX; VERTICALL_FASTME } from '../modules/processes.nf' 

workflow DIST_TREE {
    take:
        assemblies_ch
    take:
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