from pathlib import Path
import pandas as pd


def ws_path(file_path):
    Path(config.get("workspace_path")).mkdir(parents=True, exist_ok=True)
    return str(Path(config.get("workspace_path"), file_path))


def get_metadata_ingestion_file():
    output_file = ws_path("metadata_ingestion.tsv")
    with open(config["input_file"], "r") as fp:
        df = pd.read_csv(fp, sep="\t")
        df["file_path"] = df["file_path"].apply(Path)
        df["dataid"] = df["file_path"].apply(lambda x: x.stem.split(".")[:1]).str[0]
        df["file_path"] = df["dataid"].apply(
            lambda x: ws_path(f"outputs/{x}/{x}.gwaslab.tsv.gz")
        )
        df.to_csv(output_file, sep="\t", index=False)
    return output_file


# Define input for the rules
data = []
with open(config["input_file"], "r") as fp:
    df = pd.read_csv(fp, sep="\t")
    df["file_path"] = df["file_path"].apply(Path)
    df["dataid"] = df["file_path"].apply(lambda x: x.stem.split(".")[:1]).str[0]

records = df[["dataid", "file_path"]].set_index("dataid", drop=False).sort_index()

with open(config["input_file"], "r") as fp:
    df = pd.read_csv(fp, sep="\t")
    df["file_path"] = df["file_path"].apply(Path)
    df["dataid"] = df["file_path"].apply(lambda x: x.stem.split(".")[:1]).str[0]
    df["file_path"] = df["dataid"].apply(
        lambda x: ws_path(f"outputs/{x}/{x}.gwaslab.tsv.gz")
    )
    df.to_csv(ws_path("metadata_ingestion.tsv"), sep="\t", index=False)


def get_sumstats(wildcards):
    return records.loc[wildcards.dataid, "file_path"]


def get_final_output():
    final_output = []

    final_output.append(ws_path("metadata_ingestion.done")),
    final_output.extend(
        expand(
            ws_path("outputs/{dataid}/{dataid}.done"),
            dataid=records.dataid,
        )
    )

    return final_output
