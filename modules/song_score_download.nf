#!/usr/bin/env nextflow
nextflow.preview.dsl=2


process songScoreDownload {
    
    cpus params.cpus
    memory "${params.mem} MB"
 
    container 'lepsalex/song-score'

    env:
    ACCESSTOKEN = apiToken
    METADATA_URL = params.songURI
    STORAGE_URL = params.scoreURI

    input:
    val apiToken
    val analysisId
    val apiKey

    output:
    file 'analysis.json'
    file './out/*'

    // doesn't exist yet, Roberto will make it happen
    // rob will make sing submit extract study from payload
    """
    sing configure --server-url ${params.songURI} --access-token ${apiToken}
    sing get --analysisId ${analysisId} > analysis.json
    score-client download --analysisId ${analysisId} --output-dir ./out
    """
}