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
    Junjun Zhang
*/

/*
 This is an auto-generated checker workflow to test the generated main template workflow, it's
 meant to illustrate how testing works. Please update to suit your own needs.
*/

nextflow.enable.dsl = 2
version = '2.6.0'  // package version

// universal params
params.publish_dir = ""

params.max_retries = 5  // set to 0 will disable retry
params.first_retry_wait_time = 1  // in seconds

// tool specific parmas go here, add / change as needed
params.study_id = ""
params.analysis_id = ""

params.api_token = ""

params.song_cpus = 1
params.song_mem = 1  // GB
params.song_url = "https://song.rdpc-qa.cancercollaboratory.org"
params.song_api_token = ""

params.score_cpus = 1
params.score_mem = 1  // GB
params.score_transport_mem = 1  // GB
params.score_url = "https://score.rdpc-qa.cancercollaboratory.org"
params.score_api_token = ""

song_params = [
    *:params,
    'cpus': params.song_cpus,
    'mem': params.song_mem,
    'song_url': params.song_url,
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
    'api_token': params.score_api_token ?: params.api_token
]

include { SongScoreDownload } from '../main'


workflow checker {
  take:
    study_id
    analysis_id

  main:
    SongScoreDownload(
      study_id,
      analysis_id
    )
}


workflow {
  checker(
    params.study_id,
    params.analysis_id
  )
}