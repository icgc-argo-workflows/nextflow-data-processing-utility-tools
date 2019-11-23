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

payload_json = json.load(open('./a2_upload_template.json'))
payload_json['file'] = []

for upload_file_path in ['./a2_files/HCC1143.3.20190726.wgs.grch38.cram', './a2_files/HCC1143.3.20190726.wgs.grch38.cram.crai']:
    payload_json['file'].append(generate_file_meta(upload_file_path))

with open('payload.json', 'w') as payload_file:
    json.dump(payload_json, payload_file)
