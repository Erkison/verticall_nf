nextflow.enable.dsl=2

// include non-process modules
include { help_message; version_message; complete_message; error_message; pipeline_start_message } from './modules/messages.nf'
include { check_params } from './modules/params_parser.nf'
include { help_or_version } from './modules/params_utils.nf'

version = '1.0dev'

// help and version messages
help_or_version(params, version)
final_params = check_params(params)
// starting pipeline
pipeline_start_message(version, final_params)

// include processes and workflows
include { DIST_TREE; ALIGNMENT } from './modules/workflows.nf'

workflow {
    // Setup input Channels
    assemblies_ch = Channel
        .fromPath( final_params.assemblies, checkIfExists: true )
        .map{ file -> tuple (file.baseName, file) }
        .ifEmpty { error "Cannot find any files matching: ${final_params.assemblies}" }

    if (params.existing_tsv) {
        // Rename existing tsv file if filename is 'verticall.tsv' (same as output)
        def existing_tsv_path = file(params.existing_tsv)
        def existing_tsv_parent = existing_tsv_path.getParent()
        def existing_tsv_fn = existing_tsv_path.getName()
        if (!existing_tsv_path.exists()) {
            error "The specified file '${params.existing_tsv}' does not exist!"
        }
        if (existing_tsv_fn == 'verticall.tsv') {
            def renamed_tsv = file("${existing_tsv_parent}/previous_verticall.tsv")
            existing_tsv_path.renameTo(renamed_tsv)
            println "Renamed existing tsv file ${existing_tsv_fn} to ${renamed_tsv.getName()}"
            existing_tsv_ch = Channel
                .fromPath(renamed_tsv, checkIfExists: true)
                .ifEmpty { error "Cannot find any files matching: ${final_params.existing_tsv}" }
        } else {
            existing_tsv_ch = Channel
                .fromPath( final_params.existing_tsv, checkIfExists: true )
                .ifEmpty { error "Cannot find any files matching: ${final_params.existing_tsv}" }
        } 
    } else {
        existing_tsv_ch = []
    }
    
    if (params.reference) {
        reference_ch = Channel
            .fromPath( final_params.reference, checkIfExists: true )
            .ifEmpty { error "Cannot find any files matching: ${final_params.reference}" }
    } else {
        reference_ch = []
    }

    if (params.alignment) {
        alignment_ch = Channel
            .fromPath( final_params.alignment, checkIfExists: true )
            .ifEmpty { error "Cannot find any files matching: ${final_params.alignment}" }
    } else {
        alignment_ch = []
    }

    // choose workflow
    if (params.workflow == "alignment"){
        ALIGNMENT(assemblies_ch, reference_ch, alignment_ch)
    } else {
        DIST_TREE(assemblies_ch, existing_tsv_ch)
    }


}

// Messages on completion 
workflow.onComplete {
    complete_message(final_params, workflow, version)
}

workflow.onError {
    error_message(workflow)
}