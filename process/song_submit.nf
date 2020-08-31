#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// processes resources
params.cpus = 1
params.mem = 1

// required params w/ default
params.container_version = '4.2.1'

// required params, no default
// --song_url         song url for download process (defaults to main song_url param)
// --api_token        song/score API token for download process (defaults to main api_token param)

process songSubmit {
    pod secret: workflow.runName + '-secret', mountPath: '/tmp/' + workflow.runName
    
    cpus params.cpus
    memory "${params.mem} GB"
 
    container "overture/song-client:${params.container_version}"
    
    tag "${study_id}"
    label "songSubmit"
    
    input:
        val study_id
        path payload
    
    output:
        stdout()

    """
    export CLIENT_SERVER_URL=${params.song_url}
    export CLIENT_STUDY_ID=${study_id}
    export CLIENT_ACCESS_TOKEN=`cat /tmp/${workflow.runName}/secret`

    set -euxo pipefail
    sing submit -f ${payload} | jq -er .analysisId | tr -d '\\n'
    """
}
