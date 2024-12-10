include { check_mandatory_parameter; check_optional_parameters; check_parameter_value } from './params_utils.nf'

def default_params(){
    /***************** Setup inputs and channels ************************/
    def params = [:] as nextflow.script.ScriptBinding$ParamsMap
    // Defaults for configurable variables
    params.help = false
    params.version = false
    // Input & output
    params.assemblies = false
    params.output_dir = false
    params.existing_tsv = false
    // Workflow alignment files and options
    params.alignment = false
    params.reference = false
    params.raxml_prefix = 'verticall'
    params.raxml_starting_trees = 'pars{10},rand{10}'
    params.raxml_model = 'GTR+G'
    params.raxml_bootstraps = false
    params.raxml_bs_trees = 100
    // Workflow distance files and options

    // General options
    params.multi = 'first'
    
    return params
}

def check_params(Map params) { 
    final_params = params
    
    // check workflow
    final_params.workflow = check_mandatory_parameter(params, 'workflow')

    // check workflow value
    allowed_wf_values = ['alignment', 'distance']
    final_params.workflow = check_parameter_value('workflow', params.workflow, allowed_wf_values)

    // set up assembly files
    final_params.assemblies = check_mandatory_parameter(params, 'assemblies')
     
    // set up output directory
    final_params.output_dir = check_mandatory_parameter(params, 'output_dir') - ~/\/$/

    // check required parameters for alignment workflow
    if (params.workflow == "alignment") {
        // reference file
        final_params.reference = check_mandatory_parameter(params, 'reference')

        final_params.alignment = check_mandatory_parameter(params, 'alignment')
    }

    // check multi value
    allowed_multi_values = ['first', 'exclude', 'high', 'low']
    final_params.multi = check_parameter_value('multi', params.multi, allowed_multi_values)
      
    return final_params
}