#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { songScoreDownload } from './workflow/song_score_download' params(params)
include { songScoreUpload } from './workflow/song_score_upload' params(params)

process analysisToPayload() {
    container "ubuntu:18.04"

    input:
        path analysis_json
    output:
        path 'payload.json', emit: payload
    script:
        """
            sed '/\"analysisId\"/ d  ;  /\"analysisState\"/ d' $analysis_json > payload.json
        """
}

workflow {
    // download analysis meta json and files
    songScoreDownload(params.study_id, params.analysis_id)

    // print paths of analysis_id and files to verify they exist
    songScoreDownload.out.analysis_json.view()
    songScoreDownload.out.files.view()

    // convert analysis to new payload for reupload
    analysisToPayload(songScoreDownload.out.analysis_json)
    analysisToPayload.out.payload.view()

    // reupload the same files with payload
    songScoreUpload(params.study_id, analysisToPayload.out.payload, songScoreDownload.out.files)

    // print new analysis_id
    songScoreUpload.out.analysis_id.view()
}
