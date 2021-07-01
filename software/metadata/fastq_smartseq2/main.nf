// Import groovy libs
import groovy.transform.Synchronized

include {UNTAR} from "$baseDir/../../../untar/main.nf"

workflow FASTQ_METADATA_SMARTSEQ2 {
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
            .map { row -> listFiles(row, '.*.gz') }
            .flatMap { row -> enumerateFastqDir(row) }
            .set { metadata }

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

@Synchronized
def listFiles(row, glob){
    file_array = []
    println(row[1])
    files = row[1].listFiles()
    for(def file:files){
        if(file.toString().matches(glob)){
            file_array.add(file)
        }
    }
    array = [row[0], file_array]
    return array
}

@Synchronized
def enumerateFastqDir(metadata){
    def fastqList = []
    def array = []
    if(metadata[0].strip2.isEmpty()){
        for (def fastq : metadata[1].flatten()){
            String s1 = fastq.getName().replaceAll(metadata[0].strip1, "")
            temp_meta = metadata[0].getClass().newInstance(metadata[0])
            temp_meta.remove("id")
            temp_meta.put("id", metadata[0].id+"-"+s1)
            array.add([ temp_meta, [file(fastq, checkIfExists: true)]])
        }
    } else {
        fastqs = metadata[1].flatten().sort()

        for (int i = 0; i < fastqs.size(); i++){
            String s1 = fastqs.get(i).getName().replaceAll(metadata[0].strip1, "")
            temp_meta = metadata[0].getClass().newInstance(metadata[0])
            temp_meta.remove("id")
            temp_meta.put("id", metadata[0].id+"-"+s1)
            array.add([ temp_meta, [file(fastqs.get(i), checkIfExists: true), file(fastqs.get(++i), checkIfExists: true)]])
        }
    }
    return array
}