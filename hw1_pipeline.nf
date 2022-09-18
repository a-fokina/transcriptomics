params.results_dir = "results/"
SRA_file = new File(params.file).readLines()

log.info "List of files: ${SRA_file}"
log.info ""
log.info "  Q U A L I T Y   C O N T R O L  "
log.info "================================="
log.info "SRA number         : ${SRA_file}"
log.info "Results location   : ${params.results_dir}"

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

workflow {
  data = Channel.fromList( SRA_file )
  DownloadFastQ(data)
  QC( DownloadFastQ.out )
  MultiQC( QC.out.collect() )
}
