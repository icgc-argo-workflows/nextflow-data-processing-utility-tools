#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// processes resources
params.cpus = 8
params.mem = 20

// required params w/ default
params.container_version = '5.0.0'
params.transport_mem = 2 // Transport memory is in number of GBs

// required params, no default
// --song_url         song url for upload process
// --score_url        score url for upload process
// --api_token        song/score API token for upload process

process scoreUpload {
    pod secret: workflow.runName + '-secret', mountPath: '/tmp/' + workflow.runName
    
    cpus params.cpus
    memory "${params.mem} GB"
 
    container "overture/score:${params.container_version}"

    tag "${analysis_id}"

    input:
        val analysis_id
        path manifest
        path upload

    output:
        val analysis_id, emit: ready_to_publish

    """
    export METADATA_URL=${params.song_url}
    export STORAGE_URL=${params.score_url}
    export TRANSPORT_PARALLEL=${params.cpus}
    export TRANSPORT_MEMORY=${params.transport_mem}
    export ACCESSTOKEN=`cat /tmp/${workflow.runName}/secret`
    
    score-client upload --manifest ${manifest}
    """
}
