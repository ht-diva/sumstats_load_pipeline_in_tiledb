rule ingest_metadata:
    input:
        config.get("input_file"),
    output:
        touch(ws_path("metadata_ingestion.done")),
    container:
        "docker://ghcr.io/ht-diva/gwasstudio:d2c7c7"
    resources:
        runtime=lambda wc, attempt: attempt * 60,
    shell:
        "gwasstudio "
        "meta_ingest "
        "--file_path {input}"


rule ingest_dataset:
    input:
        harmonized=rules.harmonize_sumstats.output,
    output:
        touch(ws_path("outputs/{dataid}/{dataid}.done")),
    container:
        "docker://ghcr.io/ht-diva/gwasstudio:d2c7c7"
    params:
        uri_path=config.get("uri"),
    shell:
        """gwasstudio \
        ingest \
        --uri {params.uri_path}\
        --multiple-input {input.harmonized}
        """
