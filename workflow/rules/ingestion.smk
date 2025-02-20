rule ingest_metadata:
    input:
        config.get("metadata_file"),
        rules.aggregate_checksum.output,
    output:
        touch(ws_path("metadata_ingestion.done")),
    container:
        "docker://ghcr.io/ht-diva/gwasstudio:b6353b"
    resources:
        runtime=lambda wc, attempt: attempt * 60,
    shell:
        "gwasstudio"


rule ingest_dataset:
    input:
        harmonized=rules.harmonize_sumstats.output,
        checksum=rules.checksum.output,
    output:
        touch(ws_path("outputs/{dataid}/{dataid}.done")),
    container:
        "docker://ghcr.io/ht-diva/gwasstudio:b6353b"
    params:
        uri_path=config.get("uri")
    shell:
        """gwasstudio \
        ingest \
        --uri {params.uri_path}\
        --multiple-input {input.harmonized}
        """
