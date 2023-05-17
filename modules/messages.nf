def help_message() {
  log.info """
        Usage:
        The typical command for running the pipeline is as follows:
        nextflow run main.nf --assemblies "path/to/assemblies/*.fasta" --output_dir <output_dir>  
        Mandatory arguments:
         --assemblies               Path with glob of all fasta sequences (e.g., "data/assemblies/*.fasta")
         --output_dir                   Output directory to place output files (e.g., "data/verticall")
        Optional arguments:
         --help                         This usage statement
         --version                      Version statement
        """
}


def version_message(String version) {
      println(
            """
            =========================================================================================
             verticall_nf pipeline : ${version}
            =========================================================================================
            """.stripIndent()
        )
}

def pipeline_start_message(String version, Map params){
    log.info "=========================================================================================="
    log.info " verticall_nf pipeline : ${version}"
    log.info "=========================================================================================="
    log.info "Running version   : ${version}"
    log.info "Fastas input      : ${params.assemblies}"
    log.info ""
    log.info "-------------------------- Other parameters ----------------------------------------------"
    params.sort{ it.key }.each{ k, v ->
        if (v){
            log.info "${k}: ${v}"
        }
    }
    log.info "=========================================================================================="
    log.info "Outputs written to path '${params.output_dir}'"
    log.info "=========================================================================================="

    log.info ""
}

def complete_message(Map params, nextflow.script.WorkflowMetadata workflow, String version){
    // Display complete message
    log.info ""
    log.info "Ran the workflow: ${workflow.scriptName} ${version}"
    log.info "Command line    : ${workflow.commandLine}"
    log.info "Completed at    : ${workflow.complete}"
    log.info "Duration        : ${workflow.duration}"
    log.info "Success         : ${workflow.success}"
    log.info "Work directory  : ${workflow.workDir}"
    log.info "Exit status     : ${workflow.exitStatus}"
    log.info "Thank you for using the verticall_nf pipeline!"
    log.info ""
}

def error_message(nextflow.script.WorkflowMetadata workflow){
    // Display error message
    log.info ""
    log.info "Workflow execution stopped with the following message:"
    log.info "  " + workflow.errorMessage
}