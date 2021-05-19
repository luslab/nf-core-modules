// Import groovy libs
import groovy.transform.Synchronized

workflow FASTQ_SMARTSEQ2_METADATA {
    take: file_path
    main:
        Channel
            .fromPath( file_path )
            .splitCsv(header:true)
            .map { row -> processRow(row) }
            .map { row -> listFiles(row, '.*.gz') }
            .flatMap { row -> enumerateFastqDir(row) }
            .set { metadata }
    emit:
        metadata
}

@Synchronized
def listFiles(row, glob){
    file_array = []
    files = row[1].get(0).listFiles()
    for(def file:files){
        if(file.toString().matches(glob)){
            file_array.add(file)
        }
    }
    array = [row[0], [file_array]]
    return array
}

def processRow(LinkedHashMap row, boolean flattenData = false) {
    def meta = [:]
    meta.id = row.id

    for (Map.Entry<String, ArrayList<String>> entry : row.entrySet()) {
        String key = entry.getKey();
        String value = entry.getValue();
    
        if(key != "id" && key != "data1" && key != "data2") {
            meta.put(key, value)
        }
    }

    def array = []
    if(!flattenData) {
        if (row.data2 == null) {
            array = [ meta, [ file(row.data1, checkIfExists: true) ] ]
        } else {
            array = [ meta, [ file(row.data1, checkIfExists: true), file(row.data2, checkIfExists: true) ] ]
        }
    }
    else { 
        if (row.data2 == null) {
            array = [ meta, file(row.data1, checkIfExists: true) ]
        } else {
            array = [ meta, file(row.data1, checkIfExists: true), file(row.data2, checkIfExists: true) ]
        }
    }
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