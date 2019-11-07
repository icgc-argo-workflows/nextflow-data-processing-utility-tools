#!/usr/bin/env nextflow
nextflow.preview.dsl=2

// processes resources
params.cpus = 1
params.mem = 1024

// test data
test_data_dir = "data"

// required params
params.songURI = "http://some-song-url.com"
params.scoreURI = "http://example-score-url.com"
params.apiToken = "this-is-only-a-test"

include songScoreUpload as stepOneUpload from '../modules/song_score_upload'
include songScoreUpload as stepTwoDownload from '../modules/song_score_download'

payload = file("${test_data_dir}/payload.json")
fq_files = Channel.fromPath("${test_data_dir}/*.fq")

workflow {
  // Upload files with payload
  stepOneUpload(params.apiToken, payload, fq_files.collect())

  // Download same files
  stepTwoDownload(params.apiToken, stepOneUpload.out)
}
