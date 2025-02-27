def help_message() {
  log.info """
        Usage:
        The typical command for running the pipeline is as follows:
        nextflow run main.nf --assemblies "path/to/assemblies/*.fasta" --output_dir <output_dir>  

        The pipeline mostly uses default Verticall parameters, but some options are customisable here.
        Mandatory arguments:
          General:
            --workflow              Workflow to run. One of "distance" or "alignment"
            --assemblies            Path with glob of all fasta sequences (e.g., "data/assemblies/*.fasta")
            --output_dir            Output directory to place output files (e.g., "data/verticall")
          Alignment workflow:
            --reference             Path to reference sequence. Required if workflow == "alignment"
            --alignment             Path to pseudogenome alignment of all assemblies to the reference. 
                                    Must include reference sequence and all reference sites. Required if workflow == "alignment"
        Optional arguments:
          General:
            --existing_tsv          Path to existing verticall.tsv file from interrupted run. 
                                    Pairs in this file are skipped in `verticall pairwise` and are concatenated back into the final verticall.tsv output
            --multi                 How to handle close calls. One of 'first', 'exclude', 'high', or 'low'. (default: 'first').
          Alignment workflow:
            --raxml_prefix          Prefix for RAxML-NG trees (default: 'verticall')
            --raxml_starting_trees  Starting trees (default: 'pars{10},rand{10}'). Defaults uses 10 random and 10 parsimony starting trees
            --raxml_model           Evolutionary model (default: 'GTR+G')
            --raxml_bootstraps      Whether or not to run bootstrapping ('fbp,tbe'). Default: false
            --raxml_bs_trees        Number of bootstrap replicates (default: 100). Only applied when raxml_bootstraps == true
            --help                  This usage statement
            --version               Version statement
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