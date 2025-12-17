def help_message() {
  log.info """
        Usage:
        The typical command for running the pipeline is as follows:
        nextflow run main.nf --assemblies "path/to/assemblies/*.fasta" --output_dir <output_dir>  

        The pipeline mostly uses default Verticall parameters, but some options are customisable here.
        Mandatory arguments:
          Main:
            --workflow              Workflow to run. One of "distance" or "alignment"
            --assemblies            Path with glob of all fasta sequences (e.g., "data/assemblies/*.fasta")
            --output_dir            Output directory to place output files (e.g., "data/verticall")
          Alignment workflow:
            --reference             Path to reference sequence. Required if workflow == "alignment"
            
        Optional arguments:
          General:
            --existing_tsv          Path to existing verticall.tsv file from interrupted run. 
                                    Pairs in this file are skipped in `verticall pairwise` and are concatenated back into the final verticall.tsv output
            --multi                 How to handle close calls. One of 'first', 'exclude', 'high', or 'low'. (default: 'first').
          Alignment workflow:
            --alignment             Path to pseudogenome alignment of all assemblies to the reference. 
                                    Must include reference sequence (named as in reference filename without extension, 
                                    e.g., ">reference" if file name is "reference.fasta") and all reference positions. 
                                    If not provided, an alignment will be made using snippy with default parameters.
            --filter_alignment      Whether to filter the masked alignment to core sites only. (default: true)
            --core_threshold        Proportion of genomes a site must be present in to be considered core. (default: 0.95)
            --exclude_invariant     Whether to exclude invariant sites from the filtered alignment. (default: true)
          Alignment tree building:
            --tree_builder          Tree builder to use. One of 'raxmlng' or 'iqtree'. (default: 'raxmlng')
            --tree_prefix           Prefix for RAxML-NG trees (default: 'verticall')
            --include_ref           Whether to include the reference sequence in the final tree. (default: false)
          RAxML-NG options:
            --raxml_starting_trees  Starting trees (default: 'pars{10},rand{10}'). Defaults uses 10 random and 10 parsimony starting trees
            --raxml_model           Evolutionary model (default: 'GTR+G')
            --raxml_bootstraps      Whether or not to run bootstrapping ('fbp,tbe'). Default: false
            --raxml_bs_trees        Number of bootstrap replicates (default: 100)
          IQ-tree options:
            --iqtree_bootsraps      Whether or not to run ultrafast bootstrapping. Default: false
            --iqtree_bs_trees       Number of ultrafast bootstrap replicates (default: 1000)
            --iqtree_bs_bnni        Whether to perform the BNNI step to reduce overestimation of branch supports. Default: true
        Other:    
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