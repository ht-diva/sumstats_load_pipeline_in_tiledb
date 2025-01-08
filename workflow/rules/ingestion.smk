rule ingest_metadata:
    input:
        config.get("metadata_file"),
    output:
        touch(ws_path("metadata_ingestion.done")),
    conda:
        "../envs/gwasstudio.yml"
    shell:
        "python py"


rule ingest_dataset:
    input:
        rules.harmonize_sumstats.output,
    output:
        touch(ws_path("outputs/{dataid}/{dataid}.done")),
    conda:
        "../envs/gwasstudio.yml"
    shell:
        "python py"
