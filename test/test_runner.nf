#!/usr/bin/env nextflow
nextflow.preview.dsl=2

// processes resources
params.cpus = 1
params.mem = 1024

// test data
test_data_dir = "data"

// include songScoreUpload from '../modules/song_score_download' params(params)
include song_score_download from '../modules/song_score_download' params(params)

// payload = file("${test_data_dir}/payload.json")
// fq_files = Channel.fromPath("${test_data_dir}/*.fq")

workflow {
  // Upload files with payload
  // stepOneUpload(payload, fq_files.collect())

  // Download same files
  song_score_download(params.study_id, params.analysis_id)

  song_score_download.out.view()
}
