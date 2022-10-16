params.results_dir = "results/"
SRA_file = new File(params.file).readLines()

log.info "List of files: ${SRA_file}"
log.info ""
log.info "  R E A D S  C O U N T  "
log.info "================================="
log.info "SRA number         : ${SRA_file}"
log.info "Results location   : ${params.results_dir}"
log.info "Index file         : ${params.i}"


process DownloadFastQ {
  publishDir "${params.results_dir}"

  input:
    val sra

  output:
    path "${sra}/*"

  script:
    """
    /content/sratoolkit.3.0.0-ubuntu64/bin/fastq-dump --gzip --split-3 ${sra} -O ${sra}/
    """
}

process QC {
  input:
    path x

  output:
    path "qc/*"

  script:
    """
    mkdir qc
    /content/FastQC/fastqc -o qc $x
    """
}

process MultiQC {
  publishDir "${params.results_dir}"

  input:
    path x

  output:
    path "multiqc_report.html"

  script:
    """
    multiqc $x
    """
}

process Kallisto {
  publishDir "${params.results_dir}"
  saveAs: { abundance.tsv -> "$x" }

  input:
    path i
    path x


  output:
    path "kallisto/abundance.tsv"

  script:
    """
    mkdir kallisto
    /content/kallisto/build/src/kallisto quant -i $i -o kallisto $x
    """   
}

workflow {
  data = Channel.fromList( SRA_file )
  DownloadFastQ(data)
  QC( DownloadFastQ.out )
  MultiQC( QC.out.collect() )
  Kallisto( params.i, DownloadFastQ.out )
}
