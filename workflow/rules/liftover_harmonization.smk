rule liftover:
    input:
        sumstats=get_sumstats,
    output:
        vcf=temp(ws_path("temp/{dataid}/{dataid}_liftover.vcf.gz")),
    container:
        "docker://ghcr.io/ht-diva/containers/bcftools:e06c15"
    params:
        hg37=config.get("hg37_fasta_file"),
        hg38=config.get("hg38_fasta_file"),
        chain_file=config.get("chain_file"),
    resources:
        runtime=lambda wc, attempt: attempt * 30,
    shell:
        "workflow/scripts/liftover.sh {input.sumstats} {params.hg37} {params.hg38} {params.chain_file} {output.vcf} {threads}"


rule harmonize_sumstats:
    input:
        sumstats=rules.liftover.output.vcf,
    output:
        ws_path("outputs/{dataid}/{dataid}.gwaslab.tsv.gz"),
    conda:
        "../scripts/gwaspipe/environment.yml"
    params:
        format=config.get("params").get("harmonize_sumstats").get("input_format"),
        config_file=config.get("params").get("harmonize_sumstats").get("config_file"),
        output_path=config.get("workspace_path"),
    resources:
        runtime=lambda wc, attempt: attempt * 60,
    shell:
        "python workflow/scripts/gwaspipe/src/gwaspipe.py "
        "-f {params.format} "
        "-c {params.config_file} "
        "-i {input.sumstats} "
        "-o {params.output_path}"
