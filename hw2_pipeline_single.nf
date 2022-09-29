params.results_dir = "results/"
params.s = 1
params.l = 100

log.info ""
log.info "  R E A D S  C O U N T  "
log.info "================================="
log.info "Index file         : ${params.i}"
log.info "Infile             : ${params.infile}"




process Kallisto {
  publishDir "${params.results_dir}"

  input:
    path i
    path f
    val s
    val l

  output:
    path "abundance.tsv"

  script:
    """
    /content/kallisto/build/src/kallisto quant -l ${params.l} -i $i --single -s ${params.s} -o $params.results_dir $f
    """   
}

workflow {
  Kallisto( params.i, params.infile, params.s, params.l )
}
