include {UNTAR} from "$baseDir/../../../untar/main.nf"

workflow FASTQ_METADATA_10X {
    take: file_path
    main:

        Channel
            .fromPath( file_path )
            .splitCsv(header:true)
            .map { row -> processRow(row) }
            .branch{ it ->  tar: it[1].toString().endsWith("tar.gz") == true
                            dir: it[1].toString().endsWith("tar.gz") == false}
            .set { metadata }

        UNTAR(metadata.tar)

        // set value if channel is empty
        UNTAR.out.untar.ifEmpty('empty').set{ch_tar}
        metadata.dir.ifEmpty('empty').set{ch_dir}

        // combine and filter empty channels
        ch_dir.concat(ch_tar).filter { it != 'empty' }.set{metadata}

        metadata
            .map{ row -> processtenx(row)}
            .set{metadata}

    emit:
        metadata
}

def processRow(LinkedHashMap row) {
    def meta = [:]
    meta.id = row.id

    for (Map.Entry<String, ArrayList<String>> entry : row.entrySet()) {
        String key = entry.getKey();
        String value = entry.getValue();

        if(key != "id" && key != "data") {
            meta.put(key, value)
        }
    }

    data = file(row.data, checkIfExists: true)

    def array = [ meta, data]
    return array
}

def processtenx(ArrayList row, String glob='.*fastq.gz'){
    def data = row[1]

    // List files
    if (!(data instanceof List) && data.isDirectory()){
        data = data.listFiles()
    }

    // Filter files not matching glob
    def files = []
    for(def file:data){
        if(file.toString().matches(glob)){
            files.add(file)
        }
    }

    def array = [row[0], files]
    return(array)
}
