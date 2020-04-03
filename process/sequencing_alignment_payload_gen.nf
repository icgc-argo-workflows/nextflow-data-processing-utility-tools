#!/usr/bin/env nextflow
nextflow.preview.dsl=2

// processes resources
params.cpus = 1
params.mem = 1

// required params w/ default
params.container_version = '0.1.6.1'

process sequencingAlignmentPayloadGen {

    cpus params.cpus
    memory "${params.mem} GB"

    container "quay.io/icgc-argo/payload-gen-dna-alignment:payload-gen-dna-alignment.${params.container_version}"

    label "sequencingAlignmentPayloadGen"
 
    input:
        path seq_experiment_analysis
        path upload

    output:
        path '*.dna_alignment.payload.json', emit: analysis
        path "out/*", emit: upload_files
    
    // dna-seq-alignment is the only accepted value currently, should this be loosened?
    // this could be a thing: ${workflow.repository ? workflow.repository : workflow.scriptName}
    """
    payload-gen-dna-alignment.py \
      -a ${seq_experiment_analysis} \
      -f ${upload} \
      -w dna-seq-alignment \
      -r $workflow.runName \
      -v ${workflow.revision ? workflow.revision : 'latest'}
    """
}
