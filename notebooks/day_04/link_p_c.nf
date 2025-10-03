#!/usr/bin/env nextflow

process SPLITLETTERS {
    input:
    tuple val(prefix), val(in_str), val(block_size)

    output:
    path "chunk_${prefix}_*.txt", emit: chunks

    script:
    """
    mkdir -p temp_chunks
    str="${in_str}"
    size=${block_size}
    len=\${#str}

    for ((i=0; i<len; i+=size)); do
        chunk=\${str:i:size}
        echo \$chunk > temp_chunks/chunk_${prefix}_\$((i/size+1)).txt
    done
    mv temp_chunks/chunk_${prefix}_*.txt ./
    rm -rf temp_chunks
    """
}


process CONVERTTOUPPER {

    publishDir "."

    input:
    path chunk_file

    output:
    path "results/upper_*"

    script:
    """
    mkdir -p results
    cat ${chunk_file} | tr '[:lower:]' '[:upper:]' > results/upper_${chunk_file.baseName}
    """
}



workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout

    // read in samplesheet}
    samples = Channel.fromPath('samplesheet_2.csv').splitCsv(header:true)
    
    // split the input string into chunks
    chunk_ch = samples.map { row ->  tuple(row.out_name, row.input_str, row.block_size.toInteger()) }
    split_chunks = SPLITLETTERS(chunk_ch)

    // convert the chunks to uppercase and save the files to the results directory and view results
    upper_chunks = CONVERTTOUPPER(split_chunks.flatten())
    upper_chunks.map { f -> file("results/${f.name}") }.view()

}
