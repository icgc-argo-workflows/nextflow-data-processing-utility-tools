#!/usr/bin/env nextflow
nextflow.preview.dsl=2

// processes resources
params.song_cpus = 1
params.song_mem = 1
params.score_cpus = 8
params.score_mem = 20
params.score_transport_mem = 2
params.extract_cpus = 1
params.extract_mem = 1

// required params w/ default
params.song_container_version = '4.2.1'
params.score_container_version = '5.0.0'
params.extract_container_version = 'latest'

// required params, no default
// --song_url         song url for download process (defaults to main song_url param)
// --score_url        score url for download process (defaults to main score_url param)
// --api_token        song/score API token for download process (defaults to main api_token param)

song_params = [
    *:params,
    'cpus': params.song_cpus,
    'mem': params.song_mem,
    'container_version': params.song_container_version,
]

score_params = [
    *:params,
    'cpus': params.score_cpus,
    'mem': params.score_mem,
    'transport_mem': params.score_transport_mem,
    'container_version': params.score_container_version,
]

extract_params = [
    'cpus': params.extract_cpus,
    'mem': params.extract_mem,
    'container_version': params.extract_container_version
]

// import modules
include songSubmit from '../process/song_submit' params(song_params)
include songManifest from '../process/song_manifest' params(song_params)
include scoreUpload from '../process/score_upload' params(score_params)
include songPublish from '../process/song_publish' params(song_params)

workflow songScoreUpload {
    take: study_id
    take: payload
    take: upload

    main:
        // Create new analysis
        songSubmit(study_id, payload)

        // Generate file manifest for upload
        songManifest(study_id, songSubmit.out, upload)

        // Upload to SCORE
        scoreUpload(songSubmit.out, songManifest.out, upload)

        // Publish the analysis
        songPublish(study_id, scoreUpload.out.ready_to_publish)

    emit:
        analysis_id = songPublish.out.analysis_id
}

