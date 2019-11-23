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

    script:
    list_of_files = upload.collect { "\'${it.getName()}\'" }.join(', ')
    """
    #!/usr/bin/python

    import os
    import json
    import hashlib

    def generate_file_meta(file_path):
        return {
            'fileName': os.path.basename(file_path),
            'fileSize': os.path.getsize(file_path),
            'fileMd5sum': generateMD5Hash(file_path),
            'fileType': 'BAM' if os.path.splitext(file_path)[1] == '.cram' else 'BAI',
            'fileAccess': 'public'
        }

    def generateMD5Hash(file_path):
        md5_hash = hashlib.md5()
        with open(file_path, 'rb') as f:
            # Read and update hash in chunks of 4K
            for byte_block in iter(lambda: f.read(4096), b""):
                md5_hash.update(byte_block)
            return md5_hash.hexdigest()

    payload_json = json.load(open('${template}'))
    payload_json['file'] = []

    for upload_file_path in [${list_of_files}]:
        payload_json['file'].append(generate_file_meta(upload_file_path))

    with open('payload.json', 'w') as payload_file:
        json.dump(payload_json, payload_file)
    
    """
}