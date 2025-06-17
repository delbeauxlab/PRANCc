#!/bin/bash

# directory containing results
input_dir=${1:-"results/ccfresults"}

# output .tsv files
output_file_cas=${2:-"results/ccfcas.tsv"}

output_file_crispr=${3:-"results/ccfcrispr.tsv"}

# Clear the output files if they already exist
> "$output_file_cas"
> "$output_file_crispr"

# Add headers to the TSV files
cas_header="Filename\tSequence(s)\tCRISPR array(s)\tNb CRISPRs\tEvidence-levels\tCas cluster(s)\t"
cas_header+="Nb Cas\tCas Types/Subtypes"
crispr_header="Filename\tStrain	Sequence\tSequence_basename\tDuplicated_Spacers\tCRISPR_Id\t"
crispr_header+="CRISPR_Start\tCRISPR_End\tCRISPR_Length\tPotential_Orientation (AT%)\t"
crispr_header+="CRISPRDirection\tConsensus_Repeat\tRepeat_ID (CRISPRdb)\t"
crispr_header+="Nb_CRISPRs_with_same_Repeat (CRISPRdb)\tRepeat_Length\tSpacers_Nb\tMean_size_Spacers\t"
crispr_header+="Standard_Deviation_Spacers\tNb_Repeats_matching_Consensus\tRatio_Repeats_match/TotalRepeatt"
crispr_header+="Conservation_Repeats (% identity)\tEBcons_Repeats\tConservation_Spacers (% identity)\t"
crispr_header+="EBcons_Spacers\tRepeat_Length_plus_mean_size_Spacers\tRatio_Repeat/mean_Spacers_Length\t"
crispr_header+="CRISPR_found_in_DB (if sequence IDs are similar)\tEvidence_Level\t"

echo -e $cas_header >> $output_file_cas
echo -e $crispr_header >> $output_file_crispr

# Create variables to keep track of total sequences processed, the number of spacers 
# and the number of cas systems (for an average)
total_sequences=0
total_spacers=0
total_cas=0

# loop over results summaries in TSV folder per output sequence
# add on the fna fikes name and collate
for folder in $input_dir/*/
do
    total_sequences=$((total_sequences + 1))
    foldername=$(basename $folder)
    sed 1d $folder/TSV/CRISPR-Cas_summary.tsv | while read line
    do
        echo -en "$foldername\t" >> $output_file_cas
        echo -e $line >> $output_file_cas
        total_cas=$((total_cas + 1))
    done
    sed 1d $folder/TSV/Crisprs_REPORT.tsv | while read line
    do
        echo -en "$foldername\t" >> $output_file_crispr
        echo -e $line >> $output_file_crispr
        total_spacers=$((total_spacers + 1))
    done
done

# grab absolute path from relative paths specified above
real_output_path=$(realpath $output_file_crispr)
echo "Parsing and compilation complete! $total_spacers spacers and $total_cas cas systems found over $total_sequences sequences. Results saved to $real_output_path."
