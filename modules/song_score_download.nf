#!/usr/bin/env nextflow
nextflow.preview.dsl=2

// processes resources
params.cpus = 1
params.mem = 1024

// required params w/ default
params.song_container_version = 'latest'
params.score_container_version = 'latest'

// required params, no default
// --song_url         song url for download process (defaults to main song_url param)
// --score_url        score url for download process (defaults to main score_url param)
// --api_token        song/score API token for download process (defaults to main api_token param)

song_params = [
    *:params,
    'container_version': params.song_container_version
]

score_params = [
    *:params,
    'container_version': params.score_container_version
]

// import modules
include songGetAnalysis from './song_get_analysis' params(params = song_params)
include scoreDownload from './score_download' params(params = score_params)

workflow song_score_download {
    get: studyId
    get: analysisId

    main:
        songGetAnalysis(studyId, analysisId)
        scoreDownload(songGetAnalysis.out.json)

    emit:
        analysis_json = songGetAnalysis.out.json
        analysis_json_and_files = scoreDownload.out.analysis_json_and_files
}
