#!/usr/bin/env nextflow
nextflow.preview.dsl=2


process songScoreDownload {
    
    cpus params.cpus
    memory "${params.mem} MB"
 
    container 'lepsalex/song-score-jq'

    input:
        val studyId
        val analysisId

    output:
        tuple file('analysis.json'), file('./out/*')


    """
    export ACCESSTOKEN=${params.api_token}
    export METADATA_URL=${params.song_url}
    export STORAGE_URL=${params.score_url}

    curl -X GET "${params.song_url}/studies/$studyId/analysis/$analysisId" -H  "accept: */*" > analysis.json
    
    cat analysis.json | jq -r '.file[].objectId' | while IFS=\$'\\\t' read -r objectId; do score-client download --object-id "\$objectId" --output-dir ./out; done
    """
}
