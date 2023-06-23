# finds all cctyper outputs and metadata/ngstar files for region eg
# ngfastas/africaasiaspain
rule collect_cas:
    input:
        "{region}/results/{isolate}.fasta/cas_operons.tab"
        "{region}/metadata.csv"
        "{region}/ngstar.csv"
    output:
        "crisprcasgenes.csv"
        "crisprcassystems.csv"
    conda:
#       "envs/cctyper.yaml" because of how i've done this, this will be specified for
# final workflow. for now, using static environment. important for reproducability later
        "snakemake"
    script:
        "scripts/collect_cctyper_output.py"

# same but for nested files such as ngfastas/ausnz/nz - will be eliminated in final workflow
rule collect_nested_cas:
    input:
        "{region}/{subregion}/results/{isolate}.fasta/cas_operons.tab"
        "{region}/metadata.csv"
        "{region}/ngstar.csv"
    output:
        "crisprcasgenes.csv"
        "crisprcassystems.csv"
    conda:
#       "envs/cctyper.yaml" because of how i've done this, this will be specified for
# final workflow. for now, using static environment. important for reproducability later
        "snakemake"
    script:
        "scripts/collect_cctyper_output.py"
