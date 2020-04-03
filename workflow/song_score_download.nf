#!/usr/bin/env nextflow
nextflow.preview.dsl=2

// processes resources
params.song_cpus = 1
params.song_mem = 1
params.score_cpus = 8
params.score_mem = 20
params.score_transport_mem = 2

// required params w/ default
params.song_container_version = '4.1.1'
params.score_container_version = '3.1.1'

// required params, no default
// --song_url         song url for download process (defaults to main song_url param)
// --score_url        score url for download process (defaults to main score_url param)
// --api_token        song/score API token for download process (defaults to main api_token param)

song_params = [
    *:params,
    'cpus': params.song_cpus,
    'mem': params.song_mem,
    'container_version': params.song_container_version,
    'api_token': params.song_api_token ?: params.api_token
]

score_params = [
    *:params,
    'cpus': params.score_cpus,
    'mem': params.score_mem,
    'transport_mem': params.score_transport_mem,
    'container_version': params.score_container_version,
    'api_token': params.score_api_token ?: params.api_token
]

// import modules
include songGetAnalysis from '../process/song_get_analysis' params(song_params)
include scoreDownload from '../process/score_download' params(score_params)

workflow songScoreDownload {
    take: study_id
    take: analysis_id

    main:
        songGetAnalysis(study_id, analysis_id, song_params.api_token)
        scoreDownload(songGetAnalysis.out.json, study_id, analysis_id, score_params.api_token)

    emit:
        analysis_json = songGetAnalysis.out.json
        analysis_json_and_files = scoreDownload.out.analysis_json_and_files
}
