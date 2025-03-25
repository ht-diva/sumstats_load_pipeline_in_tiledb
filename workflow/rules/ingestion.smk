rule ingest_metadata:
    input:
        metadata=ws_path("metadata_ingestion.tsv"),
        harmonized=expand(rules.harmonize_sumstats.output, dataid=records.dataid),
    output:
        touch(ws_path("metadata_ingestion.done")),
    container:
        "docker://ghcr.io/ht-diva/gwasstudio:c63dd3"
    resources:
        runtime=lambda wc, attempt: attempt * 60,
    params:
        mongo_uri=config.get("mongo_uri"),
    shell:
        "gwasstudio "
        "--mongo-uri {params.mongo_uri} "
        "meta_ingest "
        "--file_path {input.metadata}"


rule ingest_dataset:
    input:
        harmonized=rules.harmonize_sumstats.output,
    output:
        touch(ws_path("outputs/{dataid}/{dataid}.done")),
    container:
        "docker://ghcr.io/ht-diva/gwasstudio:c63dd3"
    resources:
        runtime=lambda wc, attempt: attempt * 60,
    params:
        uri_path=config.get("uri"),
    shell:
        """gwasstudio \
        ingest \
        --uri {params.uri_path}\
        --single-input {input.harmonized}
        """
