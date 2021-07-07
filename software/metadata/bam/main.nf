workflow BAM_METADATA {
    take: file_path
    main:
        Channel
            .fromPath( file_path )
            .splitCsv(header:true)
            .map { row -> processRow(row, true) }
            .set { metadata }
    emit:
        metadata
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