#!/bin/bash

#copilot output to start working on bash compilation scripts

# Directory containing text files
input_dir="results/ccfresults"

# Output CSV file
output_file="results/ccfresults.tsv"

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
echo "Sequence\tCRISPR_begin\tCRISPR_end\t" > "$output_file"

# Loop through all text files in the input directory
for file in "$input_dir"/*.txt; do
    # Check if the file exists
    if [[ -f "$file" ]]; then
        # Extract specific data from each file
        # Customize this extraction logic based on your needs
        extracted_data=$(grep -oE "pattern_to_extract" "$file" | paste -sd "," -)

        # If no data is extracted, use "N/A"
        extracted_data=${extracted_data:-"N/A"}

        # Append filename and extracted data to the output CSV
        echo "$(basename "$file"),$extracted_data" >> "$output_file"
    else
        echo "No text files found in the directory."
    fi
done

echo "Parsing and compilation complete! Results saved to $output_file."
