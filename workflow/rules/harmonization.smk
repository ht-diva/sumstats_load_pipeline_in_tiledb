rule harmonize_sumstats:
    input:
        sumstats=get_sumstats,
    output:
        ws_path("outputs/{dataid}/{dataid}.gwaslab.tsv.gz"),
    container:
        "docker://ghcr.io/ht-diva/gwaspipe:b82410"
    params:
        format=config.get("params").get("harmonize_sumstats").get("input_format"),
        config_file=config.get("params").get("harmonize_sumstats").get("config_file"),
        output_path=config.get("workspace_path"),
        study_label="{dataid}",
    resources:
        runtime=lambda wc, attempt: attempt * 180,
    shell:
        "gwaspipe "
        "-f {params.format} "
        "-c {params.config_file} "
        "-i {input.sumstats} "
        "-o {params.output_path} "
        "--study_label {params.study_label}"
