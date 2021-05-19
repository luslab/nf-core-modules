workflow FASTQ_10X_METADATA {
    take: file_path
    main:
        Channel
            .fromPath( file_path )
            .splitCsv(header:true)
            .map { row -> processRowTenx(row) }
            .set { metadata }
    emit:
        metadata
}

def processRowTenx(LinkedHashMap row, boolean flattenData = false) {
    def meta = [:]
    meta.id = row.id

    for (Map.Entry<String, ArrayList<String>> entry : row.entrySet()) {
        String key = entry.getKey();
        String value = entry.getValue();
    
        if(key != "id" && key != "data") {
            meta.put(key, value)
        }
    }

    def array = []

    data = file(row.data, checkIfExists: true)

    if (data instanceof List) {
        array = [ meta, data ] // read files from glob list
    } else if (data instanceof Path){
        array = [ meta, [ data ] ] //read path
    } else {
        throw new Exception("data class not recognised")
    }

    return array
}