#!/usr/bin/env nextflow
nextflow.preview.dsl=2

// processes resources
params.cpus = 1
params.mem = 1024

// test data
test_data_dir = "data"

include songScoreUpload from '../workflow/song_score_upload' params(params)
include songScoreDownload from '../workflow/song_score_download' params(params)
include a2PayloadGen from '../process/a2_payload_gen'

payload = file("${test_data_dir}/payload.json")
upload = Channel.fromPath("${test_data_dir}/*.bam").collect()

a2_upload_template = file("${test_data_dir}/a2_upload_template.json")
a2_files = Channel.fromPath("${test_data_dir}/a2_files/*").collect()
workflow {
  // Upload files with payload
  // songScoreUpload(params.study_id, payload, upload)

  // Download same files
  // songScoreDownload(params.study_id, songScoreUpload.out.analysis_id)
  
  a2PayloadGen(a2_upload_template, a2_files)
  // a2PayloadGen.out.view()
}
