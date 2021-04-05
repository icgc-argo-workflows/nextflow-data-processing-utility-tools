#!/usr/bin/env nextflow

/*
  Copyright (c) 2020-2021, Ontario Institute for Cancer Research

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

  Authors:
    Alex Lepsa
    Junjun Zhang
*/

nextflow.enable.dsl = 2
version = '2.6.0'  // package version

// universal params go here, change default value as needed
params.container = ""
params.container_registry = ""
params.publish_dir = ""  // set to empty string will disable publishDir

params.max_retries = 5  // set to 0 will disable retry
params.first_retry_wait_time = 1  // in seconds

// tool specific parmas go here, add / change as needed
params.study_id = "TEST-PR"
params.payload = "NO_FILE"
params.upload = []

params.api_token = ""

params.song_cpus = 1
params.song_mem = 1  // GB
params.song_url = "https://song.rdpc-qa.cancercollaboratory.org"
params.song_api_token = ""
params.song_container_version = "4.2.1"

params.score_cpus = 1
params.score_mem = 1  // GB
params.score_transport_mem = 1  // GB
params.score_url = "https://score.rdpc-qa.cancercollaboratory.org"
params.score_api_token = ""
params.score_container_version = "5.0.0"


song_params = [
    *:params,
    'cpus': params.song_cpus,
    'mem': params.song_mem,
    'song_url': params.song_url,
    'song_container_version': params.song_container_version,
    'api_token': params.song_api_token ?: params.api_token,
    'publish_dir': ''
]

score_params = [
    *:params,
    'cpus': params.score_cpus,
    'mem': params.score_mem,
    'transport_mem': params.score_transport_mem,
    'song_url': params.song_url,
    'score_url': params.score_url,
    'score_container_version': params.score_container_version,
    'api_token': params.score_api_token ?: params.api_token
]

include { songSubmit } from './local_modules/song-submit' params(song_params)
include { songManifest } from './local_modules/song-manifest' params(song_params)
include { scoreUpload } from './local_modules/score-upload' params(song_params)
include { songPublish } from './local_modules/song-publish' params(song_params)


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


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  SongScoreUpload(
    params.study_id,
    file(params.payload),
    Channel.fromPath(params.upload)
  )
}
