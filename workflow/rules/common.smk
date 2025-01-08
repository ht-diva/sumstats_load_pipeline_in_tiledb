from pathlib import Path
import pandas as pd


# Define input for the rules
data = []
with open(config["sumstats_path"], "r") as fp:
    lines = fp.readlines()

for line in lines:
    p = Path(line.strip())
    dataid = ".".join(p.stem.split(".")[:1])
    data.append((dataid, str(p)))

records = (
    pd.DataFrame.from_records(data, columns=["dataid", "sumstat_path"])
    .set_index("dataid", drop=False)
    .sort_index()
)


def get_sumstats(wildcards):
    return records.loc[wildcards.dataid, "sumstat_path"]


def ws_path(file_path):
    return str(Path(config.get("workspace_path"), file_path))


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
