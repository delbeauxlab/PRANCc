#!/bin/bash

#copilot output to start working on bash compilation scripts

# Directory containing text files
input_dir="path/to/text_outputs"

# Output CSV file
output_file="compiled_output.csv"

# Clear the output file if it already exists
> "$output_file"

# Add a header to the CSV file (customize as needed)
echo "FileName,ExtractedData" > "$output_file"

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
