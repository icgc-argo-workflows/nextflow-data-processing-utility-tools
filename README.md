# nextflow-data-processing-utility-tools

This repository intends to provide a data utilities for use in Nextflow workflows. Specifically at this time it provides processes wrapping Overture SONG/SCORE clients for upload and download of files and metadata.

Using Nextflow's experimental DSL2, the modules defined in the repo can be imported and used as part of a larger workflow (or independently).

# Testing the workflows
There are two tests scripts to verify songScoreDownload and songScoreUpload functionality

1. `./test/test_runner.nf` which can be used to test locally. This test gets the specified analysis from song, performs a dummy alignment with some dummy files, and uploads to files to score along with a new analysis in song.

2. `./main.nf` is setup to be used as a repo to test that the song_score download/upload workflows works in kubernetes. This test workflow takes an existing analysis, downloads all of its related files and reuploads them to score under a new analysis in song (the files also get new object ids)


# Troubleshooting notes
- In kubernetes, the directory specified for a `Channel.fromPath` is not the same as it is for a local script because it will not be available at the same location. In order to allow access to files, it has to be provided ahead of time or provided as an external link.

- Uploads may fail due to schema violations in the song analysis. Consult the schema for the analysis type in song's schemas endpoint to see what is required.

- Secrets need to be mounted ahead of time for the songScoreDownload and songScoreUpload workflows to work with a song or score which have api-key auth enabled
