params.step = 0
params.zip = 'zip'


process SAYHELLO {
    debug true
    script: 
    
    """
    echo "Hello World!"
    """
}

process SAYHELLO_PYTHON {
    debug true

    script: 
    """
    python3 -c 'print("Hello World!")'
    """
}

process SAYHELLO_PARAM {

    debug true

    input:
    val msg

    output:
    stdout

    script:
    """
    echo "$msg"
    """
}

process SAYHELLO_FILE {

    debug true

    input:
    val msg

    output:
    path 'greeting.txt'

    script:
    """
    echo "$msg" > greeting.txt
    """
}


process UPPERCASE {

    debug true

    input:
    val msg

    output:
    path 'uppercase.txt'

    script:
    """
    echo "$msg" | tr '[:lower:]' '[:upper:]' > uppercase.txt
    """
}

process PRINTUPPER {

    debug true

    input:
    path file_in

    output:
    stdout

    script:
    """
    cat $file_in
    """
}

process ZIPFILE {

    debug true

    input:
    path file_in
    val zip_type

    output:
    path "*", emit: zipped_file  

    script:
    if (zip_type == 'zip') {
        """
        zip ${file_in}.zip $file_in
        """
    } else if (zip_type == 'gzip') {
        """
        gzip -c $file_in > ${file_in}.gz
        """
    } else if (zip_type == 'bzip2') {
        """
        bzip2 -c $file_in > ${file_in}.bz2
        """
    }
}

process ZIPALL {

    debug true

    input:
    path file_in

    output:
    path "*.zip", emit: zip_file
    path "*.gz", emit: gzip_file
    path "*.bz2", emit: bzip2_file

    script:
    """
    zip ${file_in}.zip $file_in
    gzip -c $file_in > ${file_in}.gz
    bzip2 -c $file_in > ${file_in}.bz2
    """
}


process WRITETOFILE {

    debug true

    publishDir "results/"

    input:
    val person_list

    output:
    path "names.tsv"

    script:
    """
    printf "name\\ttitle\\n" > names.tsv
    ${person_list.collect { p -> "printf \"${p.name}\\t${p.title}\\n\" >> names.tsv" }.join('\n')}
    """
}











workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
    if (params.step == 1) {
        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == 2) {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    if (params.step == 3) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == 4) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == 5) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == 6) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
        out_ch.view()
    }

    
    // Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console
    if (params.step == 7) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        zipped_ch = ZIPFILE(out_ch, params.zip)
        zipped_ch.view()
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == 8) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)

        zip_files = ZIPALL(out_ch)

        zip_files.zip_file.view()
        zip_files.gzip_file.view()
        zip_files.bzip2_file.view()
    }


    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

    if (params.step == 9) {
        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )
        in_ch.collect().set { all_people_ch }
        WRITETOFILE(all_people_ch)
    }

}