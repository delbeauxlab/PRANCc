# Define the regions - only relates to our file structure
regions = ["africaasiaspain","aus","nz","denmark","nordic","southerneurope","uknorth","uksouth","1983","2013","2019","2020",
"sa","hawaii"]

# collates all metadata.csv and ngstar.csv files. run once. mostly applicable for projects
# where data comes from pathogen.watch
rule collate_metadata:
    input:
        expand("ngbin/{region}/metadata.csv", region=regions)
    output:
        "metadata.csv"
    conda:
        "snakemake" #snakemake and pandas
    script:
        "scripts/collate_metadata.py"

rule collate_ngstar:
    input:
        expand("ngbin/{region}/ngstar.csv", region=regions)
    output:
        "ngstar.csv"
    conda:
        "snakemake" #snakemake and pandas
    script:
        "scripts/collate_metadata.py"

# finds all cctyper outputs and metadata/ngstar files for region eg
# ngfastas/africaasiaspain
rule collect_cas:
    input:
        "{region}/results/{isolate}.fasta/cas_operons.tab",
        "{region}/metadata.csv",
        "{region}/ngstar.csv"
    output:
        "crisprcasgenes.csv",
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
        "{region}/{subregion}/results/{isolate}.fasta/cas_operons.tab",
        "{region}/metadata.csv",
        "{region}/ngstar.csv"
    output:
        "crisprcasgenes.csv",
        "crisprcassystems.csv"
    conda:
#       "envs/cctyper.yaml" because of how i've done this, this will be specified for
# final workflow. for now, using static environment. important for reproducability later
        "snakemake"
    script:
        "scripts/collect_cctyper_output.py"
