params.step = 0


workflow{

    // Task 1 - Read in the samplesheet.

    if (params.step == 1) {
        out_ch = Channel.fromPath('samplesheet.csv').splitCsv(header:true)
    }


    // Task 2 - Read in the samplesheet and create a meta-map with all metadata and another list with the filenames ([[metadata_1 : metadata_1, ...], [fastq_1, fastq_2]]).
    //          Set the output to a new channel "in_ch" and view the channel. YOU WILL NEED TO COPY AND PASTE THIS CODE INTO SOME OF THE FOLLOWING TASKS (sorry for that).

    if (params.step == 2) {
        out_ch = Channel.fromPath('samplesheet.csv').splitCsv(header:true)
        out_ch = out_ch.map { row -> def meta = [sample: row.sample, strandedness: row.strandedness]
                                     def files = [ row.fastq_1, row.fastq_2 ]
                                     tuple(meta, files)
                            }
    }

    // Task 3 - Now we assume that we want to handle different "strandedness" values differently. 
    //          Split the channel into the right amount of channels and write them all to stdout so that we can understand which is which.

    if (params.step == 3) {

        in_ch = Channel.fromPath('samplesheet.csv').splitCsv(header:true)
        in_ch = in_ch.map { row -> def meta = [sample: row.sample, strandedness: row.strandedness]
                                   def files = [ row.fastq_1, row.fastq_2 ]
                                   tuple(meta, files)
                          }

        def forward_ch   = in_ch.filter { it[0].strandedness == 'forward' }
        def reverse_ch   = in_ch.filter { it[0].strandedness == 'reverse' }
        def unstranded_ch = in_ch.filter { it[0].strandedness == 'auto' }

        forward_ch.view()
        reverse_ch.view()
        unstranded_ch.view()
                
    }

    // Task 4 - Group together all files with the same sample-id and strandedness value.

    if (params.step == 4) {
        in_ch = Channel.fromPath('samplesheet.csv').splitCsv(header:true)
        in_ch = in_ch.map { row -> def meta = [sample: row.sample, strandedness: row.strandedness]
                                   def files = [ row.fastq_1, row.fastq_2 ]
                                   tuple(meta, files)
                          }

        out_ch = in_ch.groupTuple(by: 0)

    }


    if (params.step != 3) {
        out_ch.view()
    }


}