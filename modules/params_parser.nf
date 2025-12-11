include { check_mandatory_parameter; check_optional_parameters; check_parameter_value } from './params_utils.nf'

def check_params(Map params) { 
    final_params = params
    
    // check workflow
    check_mandatory_parameter(params, 'workflow')
    // check workflow value
    allowed_wf_values = ['alignment', 'distance']
    final_params.workflow = check_parameter_value('workflow', params.workflow, allowed_wf_values)

    // check multi value
    allowed_multi_values = ['first', 'exclude', 'high', 'low']
    final_params.multi = check_parameter_value('multi', params.multi, allowed_multi_values)


    // check core_threshold value
    try {
        core_threshold_value = params.core_threshold.toBigDecimal()
        if (core_threshold_value < 0 || core_threshold_value > 1) {
            error "'--core_threshold' must be between 0 and 1 (inclusive). Provided value: ${params.core_threshold}"
        }
        final_params.core_threshold = core_threshold_value
    } catch (Exception e) {
        error "--core_threshold' must be between 0 and 1 (inclusive). Provided value: ${params.core_threshold}"
    }

    // check tree builder value
    allowed_tb_values = ['raxmlng', 'iqtree']
    final_params.workflow = check_parameter_value('tree_builder', params.tree_builder, allowed_tb_values)

    // set up assembly files
    final_params.assemblies = check_mandatory_parameter(params, 'assemblies')
     
    // set up output directory
    final_params.output_dir = check_mandatory_parameter(params, 'output_dir') - ~/\/$/

    // check required parameters for alignment workflow
    if (params.workflow == "alignment") {
        // reference file
        final_params.reference = check_mandatory_parameter(params, 'reference')
    }

    return final_params
}