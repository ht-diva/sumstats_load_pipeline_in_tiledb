rule checksum:
    input:
        rules.harmonize_sumstats.output,
    output:
        temp(ws_path("temp/{dataid}/{dataid}.checksum.txt")),
    resources:
        runtime=lambda wc, attempt: attempt * 60,
    shell:
        "sha256sum {input} > {output}"


rule aggregate_checksum:
    input:
        expand(
            ws_path("temp/{dataid}/{dataid}.checksum.txt"),
            dataid=records.dataid,
        ),
    output:
        "aggregated.txt",
    shell:
        "..."
