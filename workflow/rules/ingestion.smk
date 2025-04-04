rule ingest_metadata:
    input:
        metadata=get_metadata_ingestion_file(),
        harmonized=expand(rules.harmonize_sumstats.output, dataid=records.dataid),
    output:
        touch(ws_path("metadata_ingestion.done")),
    container:
        "docker://ghcr.io/ht-diva/gwasstudio:3a21d0"
    resources:
        runtime=lambda wc, attempt: attempt * 60,
    params:
        mongo_uri=config.get("mongo_uri"),
        vault_auth=config.get("vault_auth"),
        vault_mount_point=config.get("vault_mount_point"),
        vault_path=config.get("vault_path"),
        vault_token=config.get("vault_token"),
        vault_url=config.get("vault_url")

    shell:
    """gwasstudio \
        --vault-auth {params.vault_auth} \
        --vault-mount-point {params.vault_mount_point} \
        --vault-path {params.vault_path} \
        --vault-token {params.vault_token} \
        --vault-url {params.vault_url} 
        --mongo-uri {params.mongo_uri}  \
        meta-ingest \
        --file-path {input.metadata}
    """

rule ingest_dataset:
    input:
        harmonized=rules.harmonize_sumstats.output,
    output:
        touch(ws_path("outputs/{dataid}/{dataid}.done")),
    container:
        "docker://ghcr.io/ht-diva/gwasstudio:3a21d0"
    resources:
        runtime=lambda wc, attempt: attempt * 60,
    params:
        uri_path=config.get("uri"),
        vault_auth=config.get("vault_auth"),
        vault_mount_point=config.get("vault_mount_point"),
        vault_path=config.get("vault_path"),
        vault_token=config.get("vault_token"),
        vault_url=config.get("vault_url")
    shell:
        """gwasstudio \
        --vault-auth {params.vault_auth} \
        --vault-mount-point {params.vault_mount_point} \
        --vault-path {params.vault_path} \
        --vault-token {params.vault_token} \
        --vault-url {params.vault_url} \
        ingest \
        --uri {params.uri_path}\
        --single-input {input.harmonized}
        """
