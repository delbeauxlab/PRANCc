#!/bin/bash
args=( "$@" )

input_dir=${args[-3]}
output_file_array=${args[-2]}
output_file_cas=${args[-1]}
unset "args[-1]"
unset "args[-1]"
unset "args[-1]"

# Clear the output file if it already exists
> "$output_file_array"
> "$output_file_cas"

echo -en "Filename\t" >> $output_file_array
echo -en "Filename\t" >> $output_file_cas
sed -n '1p' "${args[0]}/Complete_summary.csv" |
    sed  's/,/\t/g' >> $output_file_array
sed -n '1p' "${args[0]}/Complete_Cas_summary.csv" |
    sed 's/,/\t/g' >> $output_file_cas

for folder in $input_dir/*/
do
    foldername=$(basename $folder)
    array_file="$folder/Complete_summary.csv"
    cas_file="$folder/Complete_Cas_summary.csv"
    # sed two commands, delete first line then replace all ',' with '\t' then pipe to loop
    sed -e '1d' -e 's/,/\t/g' $array_file | while IFS= read line
    do
        echo -en "$foldername\t" >> $output_file_array
        echo -e "$line" >> $output_file_array
    done
    sed -e '1d' -e 's/,/\t/g' $cas_file | while IFS= read line
    do
        echo -en "$foldername\t" >> $output_file_cas
        echo -e "$line" >> $output_file_cas
    done
done