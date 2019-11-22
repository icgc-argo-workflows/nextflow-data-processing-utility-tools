#!/usr/bin/env nextflow
nextflow.preview.dsl=2

// processes resources
params.cpus = 1
params.mem = 1024

// required params w/ default
params.container_version = 'latest'

process a2PayloadGen {

    cpus params.cpus
    memory "${params.mem} MB"
 
    input:
        path template
        path upload

    output:
        path 'payload.json'

    echo true

    script:
    list_of_files = upload.collect { "\'${it.getName()}\'" }.join(', ')
    """
    #!/usr/bin/python

    import json

    def generate_file_meta(file):
        return {
            'fileName': 'test+val',
            'fileSize': 'test+val',
            'fileMd5sum': 'test+val',
            'fileType': 'test+val',
            'fileAccess': 'test+val'
        }

    payload_json = json.load(open('${template}'))
    payload_json['file'] = []

    for upload in [${list_of_files}]:
        with open(upload, 'r'):
            payload_json['file'].append(generate_file_meta(upload))

    print(payload_json)

    with open('payload.json', 'w') as payload_file:
        json.dump(payload_json, payload_file)
    """
}