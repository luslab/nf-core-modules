// Import groovy libs
import groovy.transform.Synchronized

workflow FASTQ_METADATA_10X {
    take: file_path
    main:
        Channel
            .fromPath( file_path )
            .splitCsv(header:true)
            .map { row -> processRow(row) }
            .set { metadata }
    emit:
        metadata
}

def processRow(LinkedHashMap row, boolean flattenData = false, String glob='.*fastq.gz') {
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

    def array = [ meta, files]

    return array
}