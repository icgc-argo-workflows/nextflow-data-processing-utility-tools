#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// processes resources
params.cpus = 1
params.mem = 1

// required params w/ default
params.container_version = "4.2.1"

// optional if secret mounted from pod else required
params.api_token = "" // song/score API token for download process

// required params, no default
// --song_url         song url for download process
// --score_url        score url for download process

process songManifest {
    pod = [secret: params.rdpc_secret_name, mountPath: "/tmp/rpdc_secret"]
    
    cpus params.cpus
    memory "${params.mem} GB"
 
    container "overture/song-client:${params.container_version}"

    tag "${analysis_id}"

    input:
        val study_id
        val analysis_id
        path upload
    
    output:
        path "out/manifest.txt"

    script:
        accessToken = params.api_token ? params.api_token : "`cat /tmp/rpdc_secret/secret`"
        """
        export CLIENT_SERVER_URL=${params.song_url}
        export CLIENT_STUDY_ID=${study_id}
        export CLIENT_ACCESS_TOKEN=${accessToken}

        sing manifest -a ${analysis_id} -d . -f ./out/manifest.txt
        """
}
