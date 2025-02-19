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
    shell:
        """gwasstudio \
        --minimum_workers 4 \
        --maximum_workers 8 \
        --memory_workers 10 \
        --cpu_workers 6 \
        ingest \
        --uri \
        --multiple-input {input.harmonized}
        """
