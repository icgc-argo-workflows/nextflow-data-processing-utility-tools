#!/usr/bin/env nextflow
nextflow.preview.dsl=2

// TODO: Make this work with default containers, not uber container

process songScoreUpload {
    
    cpus params.cpus
    memory "${params.mem} MB"

    container 'lepsalex/song-score-jq:latest'

    input:
        tuple path(payload), path(uploads)

    output:
        stdout()

    // rob will make sing submit extract study from payload
    """
    export ACCESSTOKEN=${params.api_token}
    export METADATA_URL=${params.song_url}
    export STORAGE_URL=${params.score_url}

    sing configure --server-url ${params.song_url} --access-token ${params.api_token}
    sing submit -f ${payload} > output.json
    sing manifest -a `cat output.json | jq .analysisId` -d . -f manifest.txt

    score-client upload --manifest manifest.txt

    sing publish -a `cat output.json | jq .analysisId`\
    
    cat output.json | jq .analysisId
    """
}
