rule liftover:
    input:
        sumstats=get_sumstats,
    output:
        vcf=temp(ws_path("temp/{dataid}/{dataid}.liftover.vcf.gz")),
    container:
        "docker://ghcr.io/ht-diva/containers/crossmap:0.7.3"
    params:
        hg38=config.get("hg38_fasta_file"),
        chain_file=config.get("chain_file"),
        vcf=subpath(output.vcf, strip_suffix=".gz"),
    resources:
        runtime=lambda wc, attempt: attempt * 30,
    shell:
        "workflow/scripts/liftover.sh {input.sumstats} {params.hg38} {params.chain_file} {params.vcf}"


rule harmonize_sumstats:
    input:
        sumstats=rules.liftover.output.vcf,
    output:
        ws_path("outputs/{dataid}/{dataid}.gwaslab.tsv.gz"),
    container:
        "docker://ghcr.io/ht-diva/gwaspipe:b82410"
    params:
        format=config.get("params").get("harmonize_sumstats").get("input_format"),
        config_file=config.get("params").get("harmonize_sumstats").get("config_file"),
        output_path=config.get("workspace_path"),
        study_label=lambda wc: wc.dataid.split(".")[0].replace("ukb", "UKB"),
    resources:
        runtime=lambda wc, attempt: attempt * 60,
    shell:
        "gwaspipe "
        "-f {params.format} "
        "-c {params.config_file} "
        "-i {input.sumstats} "
        "-o {params.output_path} "
        "--study_label {params.study_label}"
