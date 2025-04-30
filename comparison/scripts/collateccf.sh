#!/bin/bash

#copilot output to start working on bash compilation scripts

# Directory containing text files
input_dir="../../results/ccfresults"

# Output CSV file
output_file="../../results/ccfresults.tsv"

# Clear the output file if it already exists
> "$output_file"

# To avoid overcomplicated semantic structure, going to have 
# multiple lines in csv. 
# for example:
# Sequence,Crispr_begin,Crispr_end,Number_of_spacers,DR,Spacer_begin,Spacer_length,Spacer_sequence
# ATC775,43,3,GATT,56,4,ACA,98,3
# ,,,,,43,3,GATT,60,4,ACA,101,3
# ,,,,,43,3,GATT,60,4,ACA,101,3
# ,43,3,1,GATT,60,4,ACA,105,3
# will have to create a constructor to do this, and wont have
# one line per sequence but will have to cope

# Add a header to the CSV file (customize as needed)
echo -e "Sequence\tCRISPR_begin\tCRISPR_end\tNumber_of_spacers\tDR\tSpacer_begin\tSpacer_end\tSpacer_sequence" >> $output_file

total_sequences=0
total_spacers=0
crispr_begin_flag=0

# Loop through all text files in the input directory
for folder in "$input_dir"/*/
do
foldername=$(basename $folder)
echo -en "$foldername" >> $output_file
total_sequences=$((total_sequences + 1))
    # check if a folder matching the pattern exists
    for subfolder in $folder/*/
    do
        if ! { [ $subfolder = "CRISPRFinderProperties" ] && [ $subfolder = "GFF" ]; }
        then
            for file in $subfolder/*
            do
            if [[ $file =~ Crispr_[0-9] ]]
            then
                while IFS= read line
                do
                    if [[ $line =~ "Crispr_begin_position" ]]
                    then
                        read CRISPR_begin_position CRISPR_end_position <<<${line//[^0-9]/ }
                        echo -en "\t$CRISPR_begin_position\t$CRISPR_end_position" >> $output_file
                        crispr_begin_flag=1
                    elif [[ $line =~ DR: ]]
                    then
                        read DR_length Number_of_spacers <<<${line//[^0-9]/ }
                        read DR <<<${line//[^G,A,T,C]/ }
                        echo -en "\t$Number_of_spacers\t$DR" >> $output_file
                    elif [[ $line =~ [[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+[G,A,T,C]+ ]]
                    then
                        read Spacer_begin_position Spacer_length <<<${line//[^0-9]/ }
                        read Spacer_sequence <<<${line//[^G,A,T,C]/ }
                        total_spacers=$((total_spacers + 1))
                        if [[ $crispr_begin_flag = 1 ]]
                        then
                            echo -e "\t$CRISPR_begin_position\t$CRISPR_end_position\t$Spacer_sequence" >> $output_file
                            crispr_begin_flag=0
                        else
                            echo -e "\t\t\t\t\t$CRISPR_begin_position\t$CRISPR_end_position\t$Spacer_sequence" >> $output_file
                        fi
                    fi
                done < $file
            fi
            done
        fi
    done
done

real_output_path=$(realpath $output_path)
echo "Parsing and compilation complete! $total_spacers spacers found over $total_sequences sequences. Results saved to $real_output_path."