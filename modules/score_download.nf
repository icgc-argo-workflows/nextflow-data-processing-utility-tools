#!/usr/bin/env nextflow
nextflow.preview.dsl=2

// processes resources
params.cpus = 1
params.mem = 1024

// required params w/ default
params.container_version = 'latest'

// required params, no default
// --song_url         song url for download process (defaults to main song_url param)
// --score_url        score url for download process (defaults to main score_url param)
// --api_token        song/score API token for download process (defaults to main api_token param)

// TODO: Replace with score container once it can download files via analysisId
process scoreDownload {
    
    cpus params.cpus
    memory "${params.mem} MB"
 
    container "lepsalex/song-score-jq:${params.container_version}"

    input:
        path analysis

    output:
        tuple path(analysis), path('out/*'), emit: analysis_json_and_files


    """
    export METADATA_URL=${params.song_url}
    export STORAGE_URL=${params.score_url}
    export ACCESSTOKEN=${params.api_token}
    
    mkdir out
    cat ${analysis} | jq -r '.file[].objectId' | while IFS=\$'\\\t' read -r objectId; do score-client download --object-id "\$objectId" --output-dir ./out; done
    """
}